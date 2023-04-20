import 'dart:async';

import 'package:KiwiCity/Helpers/helperUtility.dart';

import 'package:KiwiCity/Helpers/local_storage.dart';
import 'package:KiwiCity/Models/term_model.dart';
import 'package:KiwiCity/Models/user_model.dart';
import 'package:KiwiCity/Pages/App/app.dart';
import 'package:KiwiCity/Pages/App/app_provider.dart';

import 'package:KiwiCity/Routes/routes.dart';
import 'package:KiwiCity/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    splash();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> splash() async {
    Future.delayed(Duration(milliseconds: 30), () async {
      await getUser();
      await detectRoute();
    });
  }

  Future<void> detectRoute() async {
    bool allow_location = await allowLocation();
    // bool allow_notification = await allowNotification();
    // final isRideInProgress =
    //     await HelperUtility.checkForInProgressRides(context);

    List<String>? tempReview = await getDataInLocal(
        key: AppLocalKeys.TEMP_REVIEW, type: StorableDataType.STRINGLIST);

    // List<String>? tempReview =
    //     await _sharedPreferences.getStringList(AppLocalKeys.TEMP_REVIEW);
    // if (tempReview!.length > 0) {
    //   HelperUtility.goPage(
    //     context: context,
    //     routeName: Routes.RIDE_NOW,
    //     arg: tempReview,
    //   );
    // }
    // if (tempReview!.length > 0) {
    //   HelperUtility.goPage(
    //     context: context,
    //     routeName: Routes.RIDE_NOW,
    //     arg: tempReview,
    //   );
    // } else
    if (allow_location) {
      // if (allow_notification) {
        // if ride is in-progress
        // redirect to Routes.START_RIDING
        print("=========================");
        print(tempReview);
        if (tempReview != null) {
          HelperUtility.goPage(
            context: context,
            routeName: Routes.RIDE_NOW,
            arg: tempReview,
          );
        } else {
          HelperUtility.goPage(
            context: context,
            routeName: Routes.HOME,
          );
        }
      // } else {
      //   HelperUtility.goPageReplace(
      //       context: context,
      //       routeName: Routes.ALLOW_PERMISSION,
      //       arg: {'index': 1});
      // }
    } else {
      HelperUtility.goPageReplace(
          context: context,
          routeName: Routes.ALLOW_PERMISSION,
          arg: {'index': 0});
    }

    // Timer(Duration(seconds: 2), () {});
  }

  /********************************
   * @Auth: 
   * @Date: 
   * @Desc:
   */

  Future<bool> allowLocation() async {
    PermissionStatus status;
    status = await Permission.location.status;
    print(status);
    if (status.isGranted) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> allowNotification() async {
    PermissionStatus status;
    status = await Permission.notification.status;
    if (status.isGranted) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> getUser() async {
    bool isLogin = await getDataInLocal(
            key: AppLocalKeys.IS_LOGIN, type: StorableDataType.BOOL) ??
        false;
    String? uid = await getDataInLocal(
        key: AppLocalKeys.UID, type: StorableDataType.String);

    if (isLogin && uid != null) {
      try {
        FirebaseService service = new FirebaseService();
        var userModel = await service.getUser(uid);

        if (userModel != null) {
          AppProvider.of(context).setCurrentUser(userModel);
          AppProvider.of(context).setLogined(true);
        }
      } catch (e) {
        storeDataToLocal(
            key: AppLocalKeys.IS_LOGIN,
            value: false,
            type: StorableDataType.BOOL);
        AppProvider.of(context).setLogined(false);
      }
    } else {
      await storeDataToLocal(
          key: AppLocalKeys.IS_LOGIN,
          value: false,
          type: StorableDataType.BOOL);
      await storeDataToLocal(
          key: AppLocalKeys.UID, value: "", type: StorableDataType.String);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/4.png'), fit: BoxFit.fill),
          ),
        ));
  }
}
