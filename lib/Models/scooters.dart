import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  getScooters(){
    final db = FirebaseFirestore.instance;
    db.collection("scooters").snapshots();
  }
}