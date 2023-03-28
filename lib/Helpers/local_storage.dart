import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum StorableDataType {
  String,
  BOOL,
  DOUBLE,
  INT,
  STRINGLIST,
}

class AppLocalKeys {
  // isLogin
  static String IS_LOGIN = "isLogin";

  // LOGINED EMAIL
  static String EMAIL = 'email';

  // LOGINED user ID
  static String UID = 'uid';

  // login type
  static String LOGIN_TYPE = 'loginType';

  static String RIDE_END_TIME = 'rideEndTime';

  static String TEMP_REVIEW = 'tempReiview';

  static String PAUSE_TIME = 'pasueTime';

  static String TOTAL_RIDE_TIME = "totalrideTime";
  static String SCOOTER_ID = "scooterID";
}

Future<void> storeDataToLocal({
  required String key,
  required dynamic value,
  required StorableDataType type,
}) async {
  SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
  switch (type) {
    case StorableDataType.String:
      bool result = await _sharedPreferences.setString(key, value);
      break;
    case StorableDataType.BOOL:
      bool result = await _sharedPreferences.setBool(key, value);
      break;
    case StorableDataType.INT:
      bool result = await _sharedPreferences.setInt(key, value);
      break;
    case StorableDataType.DOUBLE:
      bool result = await _sharedPreferences.setDouble(key, value);
      break;
    case StorableDataType.STRINGLIST:
      bool result = await _sharedPreferences.setStringList(key, value);
      break;
    default:
  }
}

Future<dynamic> getDataInLocal(
    {required String key, required StorableDataType type}) async {
  SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
  switch (type) {
    case StorableDataType.String:
      return _sharedPreferences.getString(key);
    case StorableDataType.BOOL:
      return _sharedPreferences.getBool(key);
    case StorableDataType.INT:
      return _sharedPreferences.getInt(key);
    case StorableDataType.DOUBLE:
      return _sharedPreferences.getDouble(key);
    case StorableDataType.STRINGLIST:
      return _sharedPreferences.getStringList(key);
    default:
      return null;
  }
}

Future<dynamic> removeDataInLocal(@required String key) async {
  SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
  _sharedPreferences.remove(key);
}
