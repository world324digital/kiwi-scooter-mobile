import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Network {
  /* Singleton Class */
  static Network _instance = new Network.internal();
  Network.internal();
  factory Network() => _instance;
  // final NavigationService _navigationService = locator<NavigationService>();

  /* Json Decoder */
  final JsonDecoder _decoder = new JsonDecoder();

  /* Get Http Call */
  Future<dynamic> get(String url, {Map<String, String>? headers}) async {
    return await http
        .get(Uri.parse(url), headers: headers)
        .then((http.Response response) async {
      final Map<dynamic, dynamic> res = _decoder.convert(response.body);

      if (res.containsKey("message") &&
          res["message"] is String &&
          res["message"].contains("Invalid Token sent")) {
        await clearSessionAndNavigate();
      } else {
        return res;
      }
    });
  }

  /* Post Http Call */
  Future<dynamic> post(String url,
      {Map<String, String>? header, body, encoding}) async {
    return await http
        .post(Uri.parse(url), body: body, headers: header, encoding: encoding)
        .then((http.Response response) async {
      final Map<dynamic, dynamic> res = _decoder.convert(response.body);

      if (res.containsKey("message") &&
          res["message"] is String &&
          res["message"].toString().contains("Invalid Token sent")) {
        await clearSessionAndNavigate();
      } else {
        return res;
      }
    });
  }

  /* Put Http Call */
  Future<dynamic> put(String url,
      {Map<String, String>? headers, body, encoding}) async {
    return await http
        .put(Uri.parse(url), body: body, headers: headers, encoding: encoding)
        .then((http.Response response) async {
      final Map<dynamic, dynamic> res = _decoder.convert(response.body);

      if (res.containsKey("message") &&
          res["message"].contains("Invalid Token sent")) {
        await clearSessionAndNavigate();
      } else {
        return res;
      }
    });
  }

  Future<void> clearSessionAndNavigate() async {
    await clearData();
    // ToastUtil().showMsg("Token expired, Please Login again...", Colors.black,
    // Colors.white, 12.0, "short", "bottom");
    Map<String, dynamic> data = {
      "data": {"from": 3}
    };
    // _navigationService.navigateTo(RouteConst.routeLoginPage, data);
  }

  clearData() async {
    // Global.availableLidCount.value = "0";
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.clear();
    // signOutWithGoogle();
    return true;
  }

  // sign out from google
  // Future signOutWithGoogle() async {
  //   try {
  //     GoogleSignIn _googleSignIn = GoogleSignIn(
  //       scopes: [
  //         'profile',
  //         'email',
  //       ],
  //     );
  //     try {
  //       await _googleSignIn.signOut();
  //     } catch (error) {}
  //   } catch (e) {}
  // }
}
