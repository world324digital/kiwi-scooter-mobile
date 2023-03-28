import 'package:flutter/material.dart';

class LocationModel {
  String id = "";
  double lat = 0.0;
  double long = 0.0;

  LocationModel({
    required this.lat,
    required this.long,
  });

  LocationModel.fromMap({required Map data}) {
    try {
      this.lat = data['lat'] ?? 0.0;
      this.long = data['long'] ?? 0.0;
    } catch (e) {
      throw ("Couldn't get user data correctly");
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> returnedMap = {};
    returnedMap["lat"] = this.lat;
    returnedMap["long"] = this.long;
    return returnedMap;
  }
}
