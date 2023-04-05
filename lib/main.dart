import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Helpers/local_storage.dart';
import 'package:KiwiCity/Pages/App/app.dart';
import 'package:KiwiCity/Pages/App/app_provider.dart';
import 'package:KiwiCity/services/httpService.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:workmanager/workmanager.dart';
// import 'package:workmanager/workmanager.dart';
import 'firebase_options.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as FlutterStripe;

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("=============== Native called background task: $task");
    switch (task) {
      case AppConstants.backServiceIdenitfier:
        // Code to run in background
        await changeLock(false, () {});

        await changePower(false, () async {
          await changeLightStatus(false);
        });
        break;
    }
    return Future.value(true);
  });
}

// Scooter Lock and UnLock
Future<void> changeLock(bool isUnlock, Function callback) async {
  String imei = await getDataInLocal(
          key: AppLocalKeys.IMEI, type: StorableDataType.String) ??
      "";

  if (imei != "") {
    var res = await HttpService()
        .changeLockStatus(imei: imei, status: isUnlock);

    if (res['result']) {
      return callback();
    } else {}
  }
}

// Scooter Power on and Off

Future<void> changePower(bool isUnlock, Function callback) async {
  String scooterID = await getDataInLocal(
          key: AppLocalKeys.SCOOTER_ID, type: StorableDataType.String) ??
      "";
  if (scooterID != "") {
    var res = await HttpService()
        .changePowerStatus(scooterID: scooterID, status: isUnlock.toString());

    if (res['result']) {
      return callback();
    } else {}
  }
}

/********************************************
   * @Auth: world.digital.dev@gmail.com
   * @Date: 2023.03.28
   * @Desc: Turn On/Off Light
   */
Future<void> changeLightStatus(bool isOn) async {
  String imei = await getDataInLocal(
          key: AppLocalKeys.IMEI, type: StorableDataType.String) ??
      "";
  try {
    if (imei != "") {
      var res = await HttpService()
          .changeLightStatus(imei: imei, status: isOn);
      print(res['message']);
      //------------ Dismiss Progress Dialog  -------------------
      // Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
      if (res['result']) {
        // showRingDialog();
      } else {}
    }
  } catch (e) {
    print(e.toString());
    // //------------ Dismiss Progress Dialog  -------------------
    // Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // FlutterStripe.Stripe.publishableKey = AppConstants.publishKey;
  // FlutterStripe.Stripe.merchantIdentifier = 'merchant.com.rideisland.move';
  // await FlutterStripe.Stripe.instance.applySettings();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  runApp(App());
}
