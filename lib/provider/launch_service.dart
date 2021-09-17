import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:spacex_launch/model/launchX.dart';

enum SortType { None, LaunchDate, MissionName }

class LaunchXProvider extends ChangeNotifier {
  List<Launch> cacheDataList = [];
  List<Launch> launchDataList = [];
  int notifyAllDataUpdate = 0;

  int currentSelectIdx = 0;

  SortType sortByType = SortType.None;

  String? errorState;

  qureyAllLaunch() async {
    var url = Uri.parse('https://api.spacexdata.com/v3/launches');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      try {
        var data = jsonDecode(response.body);
        launchDataList = List<Launch>.from(data.map((e) {
          var l = Launch.fromJson(e);
          print(l);
          return l;
        }));
        cacheDataList = List<Launch>.from(launchDataList);
        errorState = null;
      } catch (e) {
        print("Error when handle json string!");
        print(e);
        errorState = "Error when handle json string!\n $e";
      }
    }
    notifyAllDataUpdate++;
    notifyListeners();
  }

//https://api.spacexdata.com/v3/launches/{{flight_number}}
  Future<Launch?> qureyLaunch(int flightNumber) async {
    var url = Uri.parse('https://api.spacexdata.com/v3/launches/$flightNumber');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      try {
        var data = jsonDecode(response.body);
        var l = Launch.fromJson(data);
        errorState = null;
        return l;
      } catch (e) {
        print("Error when handle json string!");
        print(e);
        errorState = "Error when handle json string!\n $e";
      }
    }
  }

//https://api.spacexdata.com/v3/rockets/{{rocket_id}}
  Future<Rocket?> queryRocket(String rocketId) async {
    var url = Uri.parse('https://api.spacexdata.com/v3/rockets/$rocketId');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      try {
        var data = jsonDecode(response.body);
        errorState = null;
        var r = Rocket.fromJson(data);
        errorState = null;
        return r;
      } catch (e) {
        print("Error when handle json string!");
        print(e);
        errorState = "Error when handle json string!\n $e";
      }
    }
  }

  Future<void> sortLaunchData(SortType newType,
      {bool isForce = false, bool ascending = true}) async {
    if (!isForce && sortByType == newType) return;
    sortByType = newType;
    switch (newType) {
      case SortType.LaunchDate:
        launchDataList.sort((a, b) {
          if (a.launch_date_utc == null && b.launch_date_utc == null) return 0;
          if (a.launch_date_utc == null && b.launch_date_utc != null)
            return ascending ? 1 : -1;
          if (a.launch_date_utc != null && b.launch_date_utc == null)
            return ascending ? -1 : 1;

          var timeA = DateTime.parse(a.launch_date_utc!);
          var timeB = DateTime.parse(b.launch_date_utc!);
          var ret = timeA.compareTo(timeB);
          return ascending ? ret : -ret;
        });
        break;
      case SortType.MissionName:
        launchDataList.sort((a, b) {
          if (a.mission_name == null && b.mission_name == null) return 0;
          if (a.mission_name == null && b.mission_name != null) return 1;
          if (a.mission_name != null && b.mission_name == null) return -1;

          var nameA = a.mission_name!;
          var nameB = b.mission_name!;
          return nameA.compareTo(nameB);
        });
        break;
      default:
    }
    notifyAllDataUpdate++;
    notifyListeners();
  }

  filterLaunchSuccess(bool needFilter) async {
    print("--filterLaunchSuccess");
    if (needFilter) {
      launchDataList = launchDataList
          .where((element) => element.launch_success ?? false)
          .toList();
    } else {
      launchDataList = List<Launch>.from(cacheDataList);
      sortLaunchData(sortByType, isForce: true);
    }

    notifyAllDataUpdate++;
    notifyListeners();
  }
}
