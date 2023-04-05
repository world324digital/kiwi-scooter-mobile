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
   * Get Scooter By ID
   */
  Future<void> getScooterByID() async {
    String imei = AppProvider.of(context).imei;
    await FirebaseFirestore.instance
        .collection('scooters')
        .doc(imei)
        .snapshots()
        .listen((event) {
      if (event.exists) {
        var data = event.data();
        // if (data != null && data.isNotEmpty) {
        setState(() {
          _scooter = scooterObject(
            scooterID: data?['id'] ?? '',
            imei: data?['imei'] ?? '',
            address: data?['address'] ?? '',
            soc: data?['soc'] ?? 0,
            lat: data?['la'] ?? 0,
            lng: data?['lo'] ?? 0,
            status: data?['address'] ?? '',
            // c: data['c'] ?? 0,
            // g: data['g'] ?? '',
            // r: data['r'] ?? 0,
            // s: data['s'] ?? 0,
            // t: data['t'] ?? 0,
            // v: data['v'] ?? 0,
            // x: data['x'] ?? 0,
          );
        });

        if (_scooter!.soc < AppConstants.lowBatteryLevel) {
          // HttpService()
          //     .sendReportEmail(scooterID: scooterID, content: "Low Baterry!");
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
            height: 24,
            width: double.infinity,
            // decoration: BoxDecoration(
            //   borderRadius: BorderRadius.circular(24),
            // ),

            child: Image.asset(
              _scooter != null
                  ? (_scooter!.soc > 65)
                      ? ImageConstants.HIGH_BATTERY
                      : (_scooter!.soc > 35)
                          ? ImageConstants.MIDDLE_BATTERY
                          : ImageConstants.LOW_BATTERY
                  : ImageConstants.LOW_BATTERY,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              // left: 10,
              top: 12,
              // bottom: 20,
              // right: 10,
            ),
            child: Text(
              // '${_scooter?.soc}%)',
              '${_scooter != null ? (_scooter!.soc * 0.45).toStringAsFixed(2) : 0}km (${_scooter != null ? _scooter!.soc : 0}%)',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                  height: 1,
                  fontFamily: FontStyles.fMedium),
            ),
          ),
        ],
      ),
    );
  }
}
