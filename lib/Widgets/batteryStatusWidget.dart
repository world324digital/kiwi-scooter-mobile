import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Models/scooterObject.dart';
import 'package:KiwiCity/Pages/App/app_provider.dart';
import 'package:KiwiCity/services/firebase_service.dart';
import 'package:KiwiCity/services/httpService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BatteryStatus extends StatefulWidget {
  const BatteryStatus({super.key});

  @override
  State<BatteryStatus> createState() => _BatteryStatusState();
}

class _BatteryStatusState extends State<BatteryStatus> {
  scooterObject? _scooter;

  /*********************************
   * Get Schooter By ID
   */
  Future<void> getScooterByID() async {
    String scooterID = AppProvider.of(context).scooterID;
    await FirebaseFirestore.instance
        .collection('scooters')
        .doc(scooterID)
        .snapshots()
        .listen((event) {
      var data = event.data();
      if (data != null && data.isNotEmpty) {
        setState(() {
          _scooter = scooterObject(
            scooterID: event.id ?? '',
            address: data['address'] ?? '',
            soc: data['soc'] ?? 0,
            // c: data['c'] ?? 0,
            // g: data['g'] ?? '',
            lat: data['lat'] ?? '',
            lng: data['lng'] ?? '',
            // r: data['r'] ?? 0,
            // s: data['s'] ?? 0,
            // t: data['t'] ?? 0,
            // v: data['v'] ?? 0,
            // x: data['x'] ?? 0,
            status: data['status'] ?? '',
          );
        });

        if (_scooter!.soc < AppConstants.lowBatteryLevel) {
          HttpService()
              .sendReportEmail(scooterID: scooterID, content: "Low Baterry!");
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getScooterByID();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            // margin:
            //     const EdgeInsets.only(left: 10, top: 20, bottom: 5, right: 10),
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: _scooter != null
                  ? (_scooter!.soc > 65)
                      ? const Color(0xff34CC34)
                      : (_scooter!.soc > 35)
                          ? Color.fromARGB(255, 144, 209, 144)
                          : Colors.red
                  : Colors.red,
            ),

            // child:  Image.asset('assets/images/bar1.png'),
          ),
          Container(
            margin: const EdgeInsets.only(
              // left: 10,
              top: 12,
              // bottom: 20,
              // right: 10,
            ),
            child: Text(
              '${_scooter != null ? (_scooter!.soc * 0.92).toStringAsFixed(2) : 0}km (${_scooter != null ? _scooter!.soc : 0}%)',
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  height: 1,
                  fontFamily: FontStyles.fMedium),
            ),
          ),
        ],
      ),
    );
  }
}
