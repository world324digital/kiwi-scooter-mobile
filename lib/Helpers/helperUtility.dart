import 'dart:math';

import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Helpers/local_storage.dart';
import 'package:KiwiCity/Models/user_model.dart';
import 'package:KiwiCity/Pages/App/app_provider.dart';
import 'package:KiwiCity/Routes/routes.dart';
import 'package:KiwiCity/Widgets/dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class HelperUtility {
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static void goPage(
      {required BuildContext context,
      required String routeName,
      dynamic? arg}) {
    Navigator.pushNamed(context, routeName, arguments: arg);
  }

  static void goPageReplace(
      {required BuildContext context, required String routeName, Map? arg}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arg);
  }

  static void goPageAllClear(
      {required BuildContext context, required String routeName, String? arg}) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (Route<dynamic> route) => false,
      arguments: arg,
    );
  }

  static void goPageRemoveUntil(
      {required BuildContext context,
      required String routeName,
      required String untilRouteName,
      String? arg}) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      ModalRoute.withName(untilRouteName),
      arguments: arg,
    );
  }

  /***************************
   * @Auth: world.digital.dev@gmail.com
   * @Date: 2023.04.05
   * @Desc: Show Circle Progress Dialog
   */
  static void showProgressDialog(
      {required BuildContext context,
      required GlobalKey<State> key,
      String? title}) {
    Dialogs.showLoadingDarkDialog(
      context: context,
      key: key,
      title: title ?? "Please wait...",
      backgroundColor: Colors.white,
      indicatorColor: ColorConstants.cPrimaryBtnColor,
      textColor: ColorConstants.cPrimaryTitleColor,
    );
  }

  /************************
   * @Auth: world324digital
   * @Date:2022.12.17
   * @Desc: get Card Number Trim
   */
  static String getNickCardNumber(String cardNumber) {
    if (cardNumber != "") {
      return cardNumber.substring(0, 4) +
          "********" +
          cardNumber.substring(11, 16);
    } else {
      return "";
    }
  }

  /******************************
   * Convert DateTime Format
   */
  static String getFormattedTime(DateTime date, String format) {
    String formattedDate =
        DateFormat(format ?? 'dd MMM yyyy E kk:mm').format(date);
    return formattedDate;
  }

  static void closeProgressDialog(GlobalKey<State> _keyLoader) {
    Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
  }

  static double getDistanceFromLatLonInKm(
      double lat1, double lon1, double lat2, double lon2) {
    var R = 6371; // Radius of the earth in km
    var dLat = deg2rad(lat2 - lat1); // deg2rad below
    var dLon = deg2rad(lon2 - lon1);
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = R * c; // Distance in km
    return d;
  }

  static double deg2rad(deg) {
    var p = 0.017453292519943295;
    return deg * p;
  }

  static Future<bool> checkForInProgressRides(BuildContext context) async {
    final timestamp = await getDataInLocal(
          key: AppLocalKeys.RIDE_END_TIME,
          type: StorableDataType.INT,
        ) ??
        0;

    print("timestamp: $timestamp");
    print("DateTime.now(): ${DateTime.now()}");

    print(
        "is ride in progress: ${timestamp > DateTime.now().millisecondsSinceEpoch}");

    return (timestamp > DateTime.now().millisecondsSinceEpoch);
  }

  static String getDayFromSeconds(int value) {
    int h, m, s;
    h = value ~/ 3600;
    m = ((value - h * 3600)) ~/ 60;
    s = value - (h * 3600) - (m * 60);
    String result = "";
    if (h > 0) {
      result = "${h} hour";
    }
    if (m > 0) {
      result = result + "${m} min";
    }
    if (s > 0) {
      result = result + "${s} sec";
    }

    return result;
  }
}

class MyFont {
  static Text text(
    title, {
    double? fontSize = 12,
    Color? color = ColorConstants.cPrimaryTitleColor,
    FontWeight? fontWeight = FontWeight.w400,
    double? lineHeight,
    String? fontFamily,
  }) {
    return Text(
      title,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontFamily: fontFamily ?? FontStyles.fSemiBold,
        height: lineHeight ?? 1,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// class ReUsableFunctions {
//   Future<void> getCurrentUserFromServer(String user_id, BuildContext context, GlobalKey<State> _keyLoader) async{
//     await service.getUser(user_id).then((userModel) async {
//             print("Login User Model");
//             print(userModel);
//             if (userModel != null) {
//               // UserModel userModel =
//               //     UserModel.fromMap(data: user, id: result.user!.uid);

//               //========== Store Logined to local ========
//               await storeDataToLocal(
//                   key: AppLocalKeys.IS_LOGIN,
//                   value: true,
//                   type: StorableDataType.BOOL);
//               await storeDataToLocal(
//                   key: AppLocalKeys.UID,
//                   value: user_id,
//                   type: StorableDataType.String);

//               AppProvider.of(context).setCurrentUser(userModel);
//               AppProvider.of(context).setLogined(true);
//               AppProvider.of(context).setLoginType(LoginType.EMAIL);

//               // ================== Close Progress Dialog ============
//               HelperUtility.closeProgressDialog(_keyLoader);

//               // Navigator.of(context).pop();

//               if (await Permission.camera.isGranted) {
//                 HelperUtility.goPageReplace(
//                   context: context,
//                   routeName: Routes.QR_SCAN,
//                 );
//               } else {
//                 HelperUtility.goPageReplace(
//                     context: context, routeName: Routes.ALLOW_CAMERA);
//               }
//             } else {
//               UserModel userModel = new UserModel(
//                 id: result.user!.uid,
//                 firstName: "",
//                 lastName: "",
//                 email: _email,
//                 dob: "",
//                 card: null,
//               );
//               await service.createUser(userModel);

//               //========== Store Logined to local ========
//               await storeDataToLocal(
//                   key: AppLocalKeys.IS_LOGIN,
//                   value: true,
//                   type: StorableDataType.BOOL);
//               await storeDataToLocal(
//                   key: AppLocalKeys.UID,
//                   value: result.user!.uid,
//                   type: StorableDataType.String);

//               AppProvider.of(context).setCurrentUser(userModel);
//               AppProvider.of(context).setLogined(true);
//               AppProvider.of(context).setLoginType(LoginType.EMAIL);

//               // ================== Close Progress Dialog ============
//               HelperUtility.closeProgressDialog(_keyLoader);

//               // Navigator.of(context).pop();
//               if (await Permission.camera.isGranted) {
//                 HelperUtility.goPageReplace(
//                   context: context,
//                   routeName: Routes.QR_SCAN,
//                 );
//               } else {
//                 HelperUtility.goPageReplace(
//                     context: context, routeName: Routes.ALLOW_CAMERA);
//               }
//             }
//           });
        
//   }
// }
