import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spacex_launch/model/launchX.dart';
import 'package:spacex_launch/pages/detail_page.dart';
import 'package:spacex_launch/provider/launch_service.dart';
import 'package:spacex_launch/widgets/group_listview.dart';
import 'package:spacex_launch/widgets/popup_submenu_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ValueNotifier<bool> _isFilter = ValueNotifier<bool>(false);
  SortType _sortType = SortType.None;
  OrderType _orderType = OrderType.Ascending;
  @override
  void initState() {
    super.initState();
    context.read<LaunchXProvider>().qureyAllLaunch();
  }

  int Function(Launch, Launch)? compare(SortType sortType,
      {OrderType order = OrderType.Ascending}) {
    switch (sortType) {
      case SortType.LaunchDate:
        return (a, b) {
          if (a.launch_date_utc == null && b.launch_date_utc == null) return 0;
          if (a.launch_date_utc == null && b.launch_date_utc != null)
            return order == OrderType.Ascending ? 1 : -1;
          if (a.launch_date_utc != null && b.launch_date_utc == null)
            return order == OrderType.Ascending ? -1 : 1;

          var timeA = DateTime.parse(a.launch_date_utc!);
          var timeB = DateTime.parse(b.launch_date_utc!);
          var ret = timeA.compareTo(timeB);
          return order == OrderType.Ascending ? ret : -ret;
        };
      case SortType.MissionName:
        return (a, b) {
          if (a.mission_name == null && b.mission_name == null) return 0;
          if (a.mission_name == null && b.mission_name != null)
            return order == OrderType.Ascending ? 1 : -1;
          if (a.mission_name != null && b.mission_name == null)
            return order == OrderType.Ascending ? -1 : 1;

          var nameA = a.mission_name!;
          var nameB = b.mission_name!;
          var ret = nameA.compareTo(nameB);
          return order == OrderType.Ascending ? ret : -ret;
        };
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            PopupMenuButton<dynamic>(
              onSelected: (sel) {
                _isFilter.value = !sel;
                context
                    .read<LaunchXProvider>()
                    .filterLaunchSuccess(_isFilter.value);
              },
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry<dynamic>>[
                  PopupMenuItem(
                    child: !_isFilter.value
                        ? Text("Only Show Success")
                        : Text("Show All"),
                    value: _isFilter.value,
                  ),
                  PopupSubMenuItem<String>(
                    title: 'Sort By Launch Date',
                    subTitle: [
                      buildSubItemWidget("Ascending", SortType.LaunchDate,
                          OrderType.Ascending),
                      buildSubItemWidget("Descending", SortType.LaunchDate,
                          OrderType.Descending),
                    ],
                    values: [
                      "Ascending",
                      "Descending",
                    ],
                    onSelected: (value) {
                      setState(() {
                        _sortType = SortType.LaunchDate;
                        _orderType = value == "Ascending"
                            ? OrderType.Ascending
                            : OrderType.Descending;
                      });
                    },
                  ),
                  PopupSubMenuItem<String>(
                    title: 'Sort By Misson Name',
                    subTitle: [
                      buildSubItemWidget("Ascending", SortType.MissionName,
                          OrderType.Ascending),
                      buildSubItemWidget("Descending", SortType.MissionName,
                          OrderType.Descending),
                    ],
                    values: [
                      "Ascending",
                      "Descending",
                    ],
                    onSelected: (value) {
                      setState(() {
                        _sortType = SortType.MissionName;
                        _orderType = value == "Ascending"
                            ? OrderType.Ascending
                            : OrderType.Descending;
                      });
                    },
                  ),
                ];
              },
            ),
          ],
        ),
        body: Selector<LaunchXProvider, int>(selector: (_, p) {
          return p.notifyAllDataUpdate;
        }, builder: (context, u, _) {
          var data = context.read<LaunchXProvider>().launchDataList;
          if (data.isNotEmpty) {
            return Scrollbar(
              child: GroupListView<Launch, String>(
                elements: data,
                groupBy: _sortType == SortType.None
                    ? null
                    : (item) {
                        switch (_sortType) {
                          case SortType.LaunchDate:
                            return item.launch_year ?? "unknown";
                          default:
                            return item.mission_name?[0] ?? "unknown";
                        }
                      },
                groupCompare: (value1, value2) {
                  var ret = value1.compareTo(value2);
                  return _orderType == OrderType.Ascending ? ret : -ret;
                },
                groupHeaderBuilder: (String groupByValue) => Center(
                    child: Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    groupByValue,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                )),
                itemCompare: compare(_sortType, order: _orderType),
                // optional
                itemBuilder: (context, item) {
                  return MinmalLaunchItem(item: item);
                },
              ),
            );
          } else {
            var err = context.read<LaunchXProvider>().errorState;
            return Center(
                child: (err?.isNotEmpty ?? false)
                    ? Center(
                        child: Text(
                        "$err",
                        style: TextStyle(fontSize: 20),
                      ))
                    : CircularProgressIndicator());
          }
        }));
  }

  Row buildSubItemWidget(String subTitle, SortType st, OrderType ot) {
    return Row(
      children: [
        Text(subTitle),
        Expanded(child: SizedBox()),
        if (_sortType == st && _orderType == ot)
          Icon(
            Icons.check,
            color: Colors.black87,
          )
      ],
    );
  }
}

class MinmalLaunchItem extends StatefulWidget {
  MinmalLaunchItem({Key? key, required this.item}) : super(key: key);
  final Launch item;
  @override
  _MinmalLaunchItemState createState() => _MinmalLaunchItemState();
}

class _MinmalLaunchItemState extends State<MinmalLaunchItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailInfor(launch: widget.item)));
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Number: ${widget.item.flight_number}"),
              Text("Mission Name: ${widget.item.mission_name}"),
              Text(
                  "Date: ${widget.item.launch_date_utc != null ? DateTime.parse(widget.item.launch_date_utc!).toLocal() : "unknown"}"),
              Text("Success: ${widget.item.launch_success}"),
            ],
          ),
        ),
      ),
    );
  }
}
