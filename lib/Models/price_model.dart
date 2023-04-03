import 'package:KiwiCity/Models/card_model.dart';

class PriceModel {
  String id = "";
  double cost = 0.0;
  int order = 2;
  String plan = "";
  double totalCost = 0.0;
  int usageTime = 0;
  String usageTimeUnit = "";

  PriceModel({
    required this.id,
    required this.cost,
    required this.order,
    required this.plan,
    required this.totalCost,
    required this.usageTime,
    required this.usageTimeUnit,
  });

  PriceModel.fromMap({required data}) {
    try {
      this.id = data['id'] ?? "";
      this.cost =
          data['cost'] != null ? double.parse(data['cost'].toString()) : 0.0;
      this.order =
          data['order'] != null ? int.parse(data['order'].toString()) : 0;
      this.plan = data['plan'] ?? "";
      this.totalCost = data['totalCost'] != null
          ? double.parse(data['totalCost'].toString())
          : 0.0;
      this.usageTime = data['usageTime'] != null
          ? int.parse(data['usageTime'].toString())
          : 0;
      this.usageTimeUnit = data['usageTimeUnit'] ?? "";
    } catch (e) {
      throw ("Couldn't get price data correctly");
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> returnedMap = {};
    returnedMap["id"] = this.id;
    returnedMap["cost"] = this.cost;
    returnedMap["order"] = this.order;
    returnedMap["plan"] = this.plan;
    returnedMap["totalCost"] = this.totalCost;
    returnedMap["usageTime"] = this.usageTime;
    returnedMap["usageTimeUnit"] = this.usageTimeUnit;

    return returnedMap;
  }
}
