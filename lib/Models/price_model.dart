import 'package:KiwiCity/Models/card_model.dart';

class PriceModel {
  String id = "";
  double startCost = 0.0;
  String plan = "";
  double costPerMinute = 0.0;

  PriceModel({
    required this.id,
    required this.startCost,
    required this.plan,
    required this.costPerMinute,
  });

  PriceModel.fromMap({required data}) {
    try {
      this.startCost =
          data['startCost'] != null ? double.parse(data['startCost']) : 0.0;
      this.plan = data['plan'] ?? "";
      this.costPerMinute = data['costPerMinute'] != null
          ? double.parse(data['costPerMinute'])
          : 0.0;
    } catch (e) {
      throw ("Couldn't get price data correctly");
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> returnedMap = {};
    returnedMap["id"] = this.id;
    returnedMap["startCost"] = this.startCost;
    returnedMap["plan"] = this.plan;
    returnedMap["costPerMinute"] = this.costPerMinute;

    return returnedMap;
  }
}
