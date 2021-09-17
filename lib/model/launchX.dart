//https://api.spacexdata.com/v3/launches
class Launch {
  String? flight_id;
  int? flight_number;
  String? mission_name;
  String? launch_year;
  String? launch_date_utc;
  bool? launch_success;

  String? rocket_id;

  Launch(
      {this.flight_id,
      this.launch_year,
      this.launch_date_utc,
      this.launch_success});

  @override
  String toString() {
    return "{flight_id:$flight_number, mission_name:$mission_name, launch_year:$launch_year, launch_date_utc:$launch_date_utc, launch_success:$launch_success, rocket_id:$rocket_id}";
  }

  Launch.fromJson(Map<String, dynamic> map) {
    flight_id = map["flight_id"];
    flight_number = map["flight_number"];
    mission_name = map["mission_name"];
    launch_year = map["launch_year"];
    launch_date_utc = map["launch_date_utc"];
    launch_success = map["launch_success"];

    rocket_id = map["rocket"] != null ? map["rocket"]["rocket_id"] : null;
  }
}

class Rocket {
  int? id;
  bool? active;
  int? stages;
  String? description;

  Rocket({this.id});

  @override
  String toString() {
    return "{id:$id, active:$active, stages:$stages, description:$description}";
  }

  Rocket.fromJson(Map<String, dynamic> map) {
    id = map["id"];
    active = map["active"];
    stages = map["stages"];
    description = map["description"];
  }
}
