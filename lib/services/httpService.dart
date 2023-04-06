import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:math';
import 'package:KiwiCity/Helpers/constant.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../Network/Network.dart';

class HttpService {
  Network _network = new Network();
  Map<String, String> paramsKeyVal = new Map<String, String>();
  Map<String, String> paramsKeyHeaderVal = new Map<String, String>();

  String basicUrl = URLS.BASE_URL;
  String apiPrefix = URLS.API_PREFIX;
  String mqttPrefix = URLS.MQTT_PREFIX;
  /*******************************
   * @Auth: world324digital@gmail.com
   * @Date: 2023.04.06
   * @Desc: SetHeader
   */
  Future<Map<String, String>> getHeader(
      {required Map<String, String> data, bool isMultiPart = false}) async {
    Map<String, String> headers = new Map<String, String>();

    // if (isTokenRequired) {
    //   if (token != null && token != "") {
    //     data["Authorization"] = "$token";
    //   }
    // }

    Map<String, String> tempMap = data;
    tempMap.addAll(headers);
    var sortedData = Map.fromEntries(
      tempMap.entries.toList()
        ..sort(
          (e1, e2) => e1.key.compareTo(e2.key),
        ),
    );

    String hashString = await httpBuildQuery(sortedData);

    // Muli-Part for File Upload
    if (isMultiPart == true) {
      headers['Content-Type'] =
          'multipart/form-data; boundary=<calculated when request is sent>';
    } else {
      headers['Content-Type'] = 'application/json';
      headers['Accept'] = 'application/json';
    }

    return headers;
  }

  /*********************************
   * @Auth: world324digital@gmail.com
   * @Date: 2023.04.03
   * @Desc: Create Http tails
   */
  Future<String> httpBuildQuery(Map<String, String> data) async {
    Uri httpsUri = Uri(scheme: '', host: '', path: '', queryParameters: data);

    String hashString = httpsUri.toString();
    hashString = hashString.replaceFirst("//?", "");
    print(hashString);
    return hashString;
  }

  /*********************************
   * @Auth: world324digital@gmail.com
   * @Date: 2023.04.05
   * @Desc: Check Network connectivity
   */
  Future<bool> checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  /*********************************
   * @Auth: world324digital@gmail.com
   * @Date: 2023.04.05
   * @Desc: Send Report Email
   */
  Future sendReportEmail(
      {required String scooterID, required String content}) async {
    return await checkInternetConnection().then((internet) async {
      if (internet != null && internet) {
        return await getHeader(data: {}).then((header) async {
          paramsKeyHeaderVal = header;

          paramsKeyVal["content"] = "$content";
          paramsKeyVal["scooterID"] = "$scooterID";
          return await _network
              .post(
            "${URLS.BASE_URL}${URLS.API_PREFIX}${URLS.SEND_REPORT_EMAIL}",
            body: utf8.encode(json.encode(paramsKeyVal)),
            header: paramsKeyHeaderVal,
          )
              .then((dynamic res) {
            return res;
          });
        });
      } else {
        return {"result": false, "message": Messages.NETWORK_ERROR};
      }
    });
  }

  /*********************************
   * @Auth: world324digital@gmail.com
   * @Date: 2023.04.05
   * @Desc: Send Ring Command
   */
  Future sendRing({required String scooterImei}) async {
    return await checkInternetConnection().then((internet) async {
      if (internet != null && internet) {
        return await getHeader(data: {}).then((header) async {
          paramsKeyHeaderVal = header;

          return await _network
              .get(
            "${URLS.BASE_URL}${URLS.MQTT_PREFIX}${URLS.SEND_RING_ON}?imei=${scooterImei}",
            headers: paramsKeyHeaderVal,
          )
              .then((dynamic res) {
            // return res;
            return {"result": true, "message": ""};
          });
        });
      } else {
        return {"result": false, "message": Messages.NETWORK_ERROR};
      }
    });
  }

  /*********************************
   * @Auth: world324digital@gmail.com
   * @Date: 2023.04.05
   * @Desc: Stop Ringing
   */
  Future stopRing({required String scooterImei}) async {
    return await checkInternetConnection().then((internet) async {
      if (internet != null && internet) {
        return await getHeader(data: {}).then((header) async {
          paramsKeyHeaderVal = header;

          return await _network
              .get(
            "${URLS.BASE_URL}${URLS.MQTT_PREFIX}${URLS.SEND_RING_OFF}?imei=${scooterImei}",
            headers: paramsKeyHeaderVal,
          )
              .then((dynamic res) {
            // return res;
            return {"result": true, "message": ""};
          });
        });
      } else {
        return {"result": false, "message": Messages.NETWORK_ERROR};
      }
    });
  }

  /*********************************
   * @Auth: world.digital.dev@gmail.com
   * @Date: 2023.04.02
   * @Desc: Stripe Card Pay
   */
  Future cardPay({
    required String holderName,
    required String cardNumber,
    required String expiredMonth,
    required String expiredYear,
    required String cvv,
    required String amount,
  }) async {
    return await checkInternetConnection().then((internet) async {
      if (internet != null && internet) {
        return await getHeader(data: {}).then((header) async {
          paramsKeyHeaderVal = header;

          paramsKeyVal["holderName"] = "$holderName";
          paramsKeyVal["cardNumber"] = "$cardNumber";
          paramsKeyVal["expiredMonth"] = "$expiredMonth";
          paramsKeyVal["expiredYear"] = "$expiredYear";
          paramsKeyVal["cvv"] = "$cvv";
          paramsKeyVal["amount"] = "$amount";
          return await _network
              .post(
            "${URLS.BASE_URL}${URLS.API_PREFIX}${URLS.CARD_PAY}",
            body: utf8.encode(json.encode(paramsKeyVal)),
            header: paramsKeyHeaderVal,
          )
              .then((dynamic res) {
            return res;
          });
        });
      } else {
        return {"result": false, "message": Messages.NETWORK_ERROR};
      }
    });
  }

  Future nativePay({
    required String amount,
    required String email,
    required String paymethod,
  }) async {
    final url =
        Uri.parse('${URLS.BASE_URL}${URLS.API_PREFIX}${URLS.NATIVE_PAY}');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'currency': 'eur',
        'amount': amount,
        'email': email,
        'paymethod': paymethod,
      }),
    );
    return json.decode(response.body);
  }

  /*********************************
   * @Auth: world.digital.dev@gmail.com
   * @Date: 2023.04.02
   * @Desc: Change Power Status ( On/Off ) of scooter
   */
  Future changePowerStatus({
    required String scooterID,
    required String status,
  }) async {
    return await checkInternetConnection().then((internet) async {
      if (internet != null && internet) {
        return await getHeader(data: {}).then((header) async {
          paramsKeyHeaderVal = header;

          paramsKeyVal["scooterID"] = "$scooterID";
          paramsKeyVal["status"] = "$status";
          return await _network
              .post(
            "${URLS.BASE_URL}${URLS.API_PREFIX}${URLS.CHANGE_POWER_STATUS}",
            body: utf8.encode(json.encode(paramsKeyVal)),
            header: paramsKeyHeaderVal,
          )
              .then((dynamic res) {
            return res;
          });
        });
      } else {
        return {"result": false, "message": Messages.NETWORK_ERROR};
      }
    });
  }

  /*********************************
   * @Auth: world.digital.dev@gmail.com
   * @Date: 2023.04.02
   * @Desc: Change Power Status ( On/Off ) of scooter
   */
  Future changeLockStatus({
    required String imei,
    required bool status,
  }) async {
    return await checkInternetConnection().then((internet) async {
      if (internet != null && internet) {
        return await getHeader(data: {}).then((header) async {
          paramsKeyHeaderVal = header;

          String endpoint = status ? URLS.UNLOCK : URLS.LOCK;
          return await _network
              .get(
            "${URLS.BASE_URL}${URLS.MQTT_PREFIX}${endpoint}?imei=${imei}",
            headers: paramsKeyHeaderVal,
          )
              .then((dynamic res) {
            // return res;
            return {"result": true, "message": ""};
          }).onError((error, stackTrace) {
            return {"result": false, "message": error.toString()};
          });
        });
      } else {
        return {"result": false, "message": Messages.NETWORK_ERROR};
      }
    });
  }

  /*********************************
   * @Auth: world.digital.dev@gmail.com
   * @Date: 2023.04.02
   * @Desc: Change Power Status ( On/Off ) of scooter
   */
  Future changeLightStatus({
    required String imei,
    required bool status,
  }) async {
    return await checkInternetConnection().then((internet) async {
      if (internet != null && internet) {
        return await getHeader(data: {}).then((header) async {
          paramsKeyHeaderVal = header;

          String endpoint = status ? URLS.TURN_ON_LIGHTS : URLS.TURN_OFF_LIGHTS;
          return await _network
              .get(
            "${URLS.BASE_URL}${URLS.MQTT_PREFIX}${endpoint}?imei=${imei}",
            headers: paramsKeyHeaderVal,
          )
              .then((dynamic res) {
            // return res;
            return {"result": true, "message": ""};
          }).onError((error, stackTrace) {
            return {"result": false, "message": error.toString()};
          });
        });
      } else {
        return {"result": false, "message": Messages.NETWORK_ERROR};
      }
    });
  }
}
