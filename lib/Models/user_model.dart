import 'package:Move/Models/card_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  late String id;
  String firstName = "";
  String lastName = "";
  String email = "";
  String dob = "";
  late CardModel? card;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.dob,
    required this.card,
  });

  UserModel.fromMap({required dynamic data, required String id}) {
    try {
      this.id = id;
      this.firstName = data.data()['firstName'] ?? "";
      this.lastName = data.data()['lastName'] ?? "";
      this.email = data.data()['email'] ?? "";
      this.dob = data.data()['dob'] ?? "";
      this.card = data.data()['card'] != null
          ? CardModel.fromMap(data: data.data()['card'], id: id)
          : null;
    } catch (e) {
      throw ("Couldn't get user data correctly");
    }
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> returnedMap = {};
    returnedMap["id"] = this.id;
    returnedMap["firstName"] = this.firstName;
    returnedMap["lastName"] = this.lastName;
    returnedMap["email"] = this.email;
    returnedMap["dob"] = this.dob;
    returnedMap["card"] = (this.card != null) ? this.card!.toMap() : null;
    return returnedMap;
  }
}
