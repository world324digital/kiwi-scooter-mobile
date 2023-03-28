import 'package:flutter/material.dart';

class CardModel {
  late String id;
  String cardName = "";
  String cardNumber = "";
  String expMonth = "";
  String expYear = "";
  String cvv = "";
  String cardType = "";

  CardModel({
    required this.id,
    required this.cardName,
    required this.cardNumber,
    required this.expMonth,
    required this.expYear,
    required this.cvv,
    required this.cardType,
  });

  CardModel.fromMap({required Map data, required String id}) {
    try {
      this.id = id;
      this.cardName = data['cardName'] ?? "";
      this.cardNumber = data['cardNumber'] ?? "";
      this.expMonth = data['expMonth'] ?? "";
      this.expYear = data['expYear'] ?? "";
      this.cvv = data['cvv'] ?? "";
      this.cardType = data['cardType'] ?? "";
    } catch (e) {
      throw ("Couldn't get user data correctly");
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> returnedMap = {};
    returnedMap["id"] = this.id;
    returnedMap["cardName"] = this.cardName;
    returnedMap["cardNumber"] = this.cardNumber;
    returnedMap["expMonth"] = this.expMonth;
    returnedMap["expYear"] = this.expYear;
    returnedMap["cvv"] = this.cvv;
    returnedMap["cardType"] = this.cardType;
    return returnedMap;
  }
}
