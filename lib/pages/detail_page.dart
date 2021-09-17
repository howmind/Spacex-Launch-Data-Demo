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
                return Text("meet error");
              } else {
                var both = snapshot.data;
                return Container(
                  child: Text("${both?.item1}}\n\n${both?.item2}"),
                );
              }
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
