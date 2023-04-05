import 'package:KiwiCity/Models/card_model.dart';
import 'package:KiwiCity/Models/location_model.dart';
import 'package:KiwiCity/Models/price_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class ReviewModel {
  String id = "";
  String userId = "";
  String scooter_type = "";
  int startTime = DateTime.now().millisecondsSinceEpoch;
  int endTime = DateTime.now().millisecondsSinceEpoch;
  int duration = 0;

  double riding_price = 0.0;
  double start_price = 0.0;
  double vat_price = 0.0;
  double total_price = 0.0;
  String card_type = "";
  String card_number = "";
  double rating = 0.0;
  String scooterImg = "";
  late LocationModel? startPoint;
  late LocationModel? endPoint;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.scooter_type,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.riding_price,
    required this.start_price,
    required this.vat_price,
    required this.total_price,
    required this.card_type,
    required this.card_number,
    required this.rating,
    required this.scooterImg,
    required this.startPoint,
    required this.endPoint,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> returnedMap = {};
    returnedMap["id"] = this.id;
    returnedMap["userId"] = this.userId;
    returnedMap["scooter_type"] = this.scooter_type;
    returnedMap["startTime"] = this.startTime;
    returnedMap["endTime"] = this.endTime;
    returnedMap["duration"] = this.duration;
    returnedMap["riding_price"] = this.riding_price;
    returnedMap["start_price"] = this.start_price;
    returnedMap["vat_price"] = this.vat_price;
    returnedMap["total_price"] = this.total_price;
    returnedMap["card_type"] = this.card_type;
    returnedMap["card_number"] = this.card_number;
    returnedMap["rating"] = this.rating;
    returnedMap["scooterImg"] = this.scooterImg;
    returnedMap["startPoint"] =
        (this.startPoint != null) ? this.startPoint!.toMap() : null;
    returnedMap["endPoint"] =
        (this.endPoint != null) ? this.endPoint!.toMap() : null;
    return returnedMap;
  }

  ReviewModel.fromMap({required data}) {
    try {
      this.id = data['id'] ?? "";
      this.userId = data['userId'] ?? "";
      this.scooter_type =
          data['scooter_type'] != null ? data['scooter_type'].toString() : "";
      this.startTime = data['startTime'] != null
          ? int.parse(data['startTime'].toString())
          : DateTime.now().millisecondsSinceEpoch;
      this.endTime =
          data['endTime'] != null ? int.parse(data['endTime'].toString()) : 0;
      this.duration = data['duration'] != null ? data['duration'] : 0;
      this.riding_price =
          data['riding_price'] != null ? data['riding_price'] : 0.0;
      this.start_price = data['start_price'] != null ? data['start_price'] : 0.0;
      this.vat_price = data['vat_price'] != null ? data['vat_price'] : 0.0;
      this.total_price =
          data['total_price'] != null ? data['total_price'] : 0.0;
      this.card_type = data['card_type'] != null ? data['card_type'] : "";
      this.card_number = data['card_number'] != null ? data['card_number'] : "";

      this.scooterImg = data['scooterImg'] != null ? data['scooterImg'] : "";
      this.rating = data['rating'] != null ? data['rating'] : 0.0;

      this.startPoint = data['startPoint'] != null
          ? LocationModel.fromMap(data: data['startPoint'])
          : null;
      this.endPoint = data['endPoint'] != null
          ? LocationModel.fromMap(data: data['endPoint'])
          : null;
      ;
      ;
    } catch (e) {
      print(e);
      throw ("Couldn't get review  data correctly");
    }
  }
}
