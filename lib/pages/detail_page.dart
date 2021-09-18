import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spacex_launch/model/launchX.dart';
import 'package:spacex_launch/provider/launch_service.dart';
import 'package:tuple/tuple.dart';

class DetailInfor extends StatefulWidget {
  DetailInfor({Key? key, required this.launch}) : super(key: key);
  final Launch launch;
  @override
  _DetailInforState createState() => _DetailInforState();
}

class _DetailInforState extends State<DetailInfor> {
  late Future<Tuple2<Launch?, Rocket?>?> details;
  @override
  void initState() {
    super.initState();
    details = queryLanchAndRocket();
  }

  Future<Tuple2<Launch?, Rocket?>?> queryLanchAndRocket() async {
    if (widget.launch.flight_number != null &&
        widget.launch.rocket_id != null) {
      var lauch = await context
          .read<LaunchXProvider>()
          .qureyLaunch(widget.launch.flight_number!);
      var rocket = await context
          .read<LaunchXProvider>()
          .queryRocket(widget.launch.rocket_id!);
      return Tuple2(lauch, rocket);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
      ),
      body: FutureBuilder<Tuple2<Launch?, Rocket?>?>(
          initialData: null,
          future: details,
          builder: (BuildContext context,
              AsyncSnapshot<Tuple2<Launch?, Rocket?>?> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text("Meet Error!");
              } else {
                var both = snapshot.data;
                return Scrollbar(
                  isAlwaysShown: true,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Text("Launch Details",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("Flight Number: ${both?.item1?.flight_number}\n"
                            "Misson Name: ${both?.item1?.mission_name}\n"
                            "Launch Year: ${both?.item1?.launch_year}\n"),
                        Text("More: ${both?.item1?.jsonString}}"),
                        SizedBox(
                          height: 20,
                        ),
                        Text("Rocket Details",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("Active: ${both?.item2?.active}\n"
                            "Stages: ${both?.item2?.stages}\n"
                            "Description: ${both?.item2?.description}\n"),
                        Text("More: ${both?.item2?.jsonString}"),
                      ],
                    ),
                  ),
                );
              }
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
