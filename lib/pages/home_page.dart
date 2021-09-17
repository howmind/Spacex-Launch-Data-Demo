import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spacex_launch/model/launchX.dart';
import 'package:spacex_launch/pages/detail_page.dart';
import 'package:spacex_launch/provider/launch_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _needFilter = false;
  @override
  void initState() {
    super.initState();
    context.read<LaunchXProvider>().qureyAllLaunch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
                onPressed: () {
                  _needFilter = !_needFilter;
                  context
                      .read<LaunchXProvider>()
                      .filterLaunchSuccess(_needFilter);
                },
                icon: Icon(Icons.filter_1)),
            PopupMenuButton<String>(
              onSelected: (sel) {
                if (sel == "Launch Date") {
                  context
                      .read<LaunchXProvider>()
                      .sortLaunchData(SortType.LaunchDate);
                } else if (sel == "Misson Name") {
                  context
                      .read<LaunchXProvider>()
                      .sortLaunchData(SortType.MissionName);
                }
              },
              itemBuilder: (BuildContext context) {
                return {'Launch Date', 'Misson Name'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: Selector<LaunchXProvider, int>(selector: (_, p) {
          return p.notifyAllDataUpdate;
        }, builder: (context, u, _) {
          var data = context.read<LaunchXProvider>().launchDataList;
          if (data.isNotEmpty) {
            return ListView.builder(
              itemBuilder: (context, index) {
                return MinmalLaunchItem(item: data[index]);
              },
              itemCount: data.length,
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailInfor(launch: widget.item)));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(child: Text("${widget.item}", softWrap: true)),
          ],
        ),
      ),
    );
  }
}
