import 'package:Move/Helpers/constant.dart';
import 'package:Move/Helpers/local_storage.dart';
import 'package:Move/Pages/App/app.dart';
import 'package:Move/Pages/App/app_provider.dart';
import 'package:Move/services/httpService.dart';
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
  String scooterID = await getDataInLocal(
          key: AppLocalKeys.SCOOTER_ID, type: StorableDataType.String) ??
      "";

  if (scooterID != "") {
    var res = await HttpService()
        .changeLockStatus(scooterID: scooterID, status: isUnlock.toString());

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
   * @Auth: geniusdev0813@gmail.com
   * @Date: 2022.12.21
   * @Desc: Turn On/Off Light
   */
Future<void> changeLightStatus(bool isOn) async {
  String scooterID = await getDataInLocal(
          key: AppLocalKeys.SCOOTER_ID, type: StorableDataType.String) ??
      "";
  try {
    if (scooterID != "") {
      var res = await HttpService()
          .changeLightStatus(scooterID: scooterID, status: isOn.toString());
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
