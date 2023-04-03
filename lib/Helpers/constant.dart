import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class ColorConstants {
  static const Color cPrimaryBtnColor = const Color(0xff3668EF);
  static const Color cPrimaryBackColor = Colors.white;
  static const Color cPrimaryShadowColor = const Color(0xffC6D5F6);
  static const Color cPrimaryTitleColor = const Color(0xff0B0B0B);
  static const Color cTxtColor2 = const Color(0xff666666);
}

class ApiURLS {}

class FontStyles {
  static TextStyle fTitleStyle = TextStyle(
    color: ColorConstants.cPrimaryTitleColor,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static TextStyle fPBtnStyle = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontFamily: 'Montserrat-SemiBold',
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static TextStyle fPDescStyle = TextStyle(
    color: ColorConstants.cTxtColor2,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static String fSemiBold = "Montserrat-SemiBold";
  static String fBold = "Montserrat-Bold";
  static String fNormal = "Montserrat";
  static String fLight = "Montserrat-Light";
  static String fMedium = "Montserrat-Medium";
}

enum LoginType {
  NONE,
  EMAIL,
  GOOGLE,
  APPLE,
}

class AppConstants {
  static const String mapBoxAccessToken =
      'pk.eyJ1Ijoicm9sYW5keiIsImEiOiJjbGcwbXkyOXgxZGo1M2VxeW1nM2ttc2QxIn0.XhSysU0eukqhSWbAdgKmjg';
  // static const String mapBoxAccessToken =
  //     'pk.eyJ1IjoicmlkZW1vdmUiLCJhIjoiY2xhaXc1d2hqMDB6aDNxbzVycm1xcXl3MiJ9.W2LLRXE5nDkh9OcNa999lw';  // For Nick

  // static const String mapBoxStyleId = 'claixbrwy000014pmbypc3qzp';

  static const String mapBoxStyleId = 'clg0n8s1o002101myonakrjgu';

  static const username = 'rolandsz';

  static final myLocation = LatLng(56.95231867792938, 21.99634696058461);
  static int lowBatteryLevel = 15;
  static double scooterSpeedPerSeconds = 12.5; // Unit is second
  /**************** Nick Token */
  // static const String urlTemplate =
  //     'https://api.mapbox.com/styles/v1/${AppConstants.username}/${AppConstants.mapBoxStyleId}/tiles/256/{z}/{x}/{y}@2x?access_token=${AppConstants.mapBoxAccessToken}';
  static const String urlTemplate =
      'https://api.mapbox.com/styles/v1/rolandz/clg0n8s1o002101myonakrjgu/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoicm9sYW5keiIsImEiOiJjbGcwbXkyOXgxZGo1M2VxeW1nM2ttc2QxIn0.XhSysU0eukqhSWbAdgKmjg';

  static const String backServiceIdenitfier = "rideMoveTask";
  // static const String publishKey =
  // "pk_live_51LcxWOBr5GZ1QA4FUKLGbxwWyBfQ0weDenecr2ej8ZMo3m9X4cIVilIHyXdf89B1yXlIkj2iWfv1QhB1xX7BFiTf00ZQnAi3G1";
  static const String publishKey =
      'pk_test_51LcxWOBr5GZ1QA4FPir30ahW1nqCZh50TbIAzOxu8Z7EQvKLIDOmfnvesfLvIC9sCezfagywgU7pEGCHHxx4Hlsp00DgiWVH9B';
}

class URLS {
  static const String BASE_URL = "http://185.96.163.118:4000";
  static const String API_PREFIX = "/api";
  static const String MQTT_PREFIX = "/mqtt";

  static const String SEND_REPORT_EMAIL = "/sendReport";
  static const String SEND_RING_ON = "/alarmon";
  static const String CARD_PAY = "/cardPay";
  static const String NATIVE_PAY = "/create-payment-intent";
  static const String CHANGE_POWER_STATUS = "/changePowerStatus";
  static const String CHANGE_LOCK_STATUS = "/changeLockStatus";
  static const String CHANGE_LIGHT_STATUS = "/changeLightStatus";

  static const String TERMS_CONDITION_URL =
      "https://ridemove.co/terms-of-service";
  static const String PRIVACY_URL = "https://ridemove.co/privacy-policy/";
  static const String SUPPORTT_URL = "https://ridemove.co/support/";
}

class Messages {
  static const String SUCCESS_SEND_REPORT =
      "Thank you. Email sent successfully! ";

  static const String NETWORK_ERROR =
      "Network error. Please check your connection!";
  static const String ERROR_MSG = "Something went wrong. Please retry!";

  static const String ERROR_UNABLE_FAR_AWAY =
      "You are too far from this vehicle and need to be closer to reserve it.";

  static const String ERROR_UNABLE_BIKE =
      "We are unable to process this request. Please try again later.";

  static const String ERROR_UNABLE_INUSE = "Failed to change inUse status.";

  static const String ERROR_INVALID_SCOOTERID =
      "The scooter code is invalid. Please try again.";

  static const String WARNING_PERMISSION_CANCEL =
      "Permission denined. You can change it later.";
  static const String WARNING_PERMISSION_DENIND_PERMENANT_MSG =
      "Do you want to open Setting to change it?";

  static const String WARNING_PERMISSION_DENIND_PERMENANT_TITLE =
      "Permission denied permanently";
  static const String NOTIFY_MESSAGE =
      "This app needs location permission to find scooter near you";
  static const String INSUFFICIENT_BALANCE =
      "Insufficient balance. Please add more money to your account before proceeding.";
}

class ImageConstants {
  static const String RIDE_HISTORY_ACTIVE = "assets/images/history_active.png";
  static const String RIDE_HISTORY = "assets/images/history.png";

  static const String PAYMENT_ACTIVE = "assets/images/paybike_active.png";
  static const String PAYMENT = "assets/images/paybike.png";

  static const String RIDE_NOW_ACTIVE = "assets/images/ridebike.png";
  static const String RIDE_NOW = "assets/images/ridenowbike.png";

  static const String HOW_TO_RIDE_ACTIVE = "assets/images/rideicon_active.png";
  static const String HOW_TO_RIDE = "assets/images/rideicon.png";

  static const String TERMS_ACTIVE = "assets/images/services_active.png";
  static const String TERMS = "assets/images/services.png";

  static const String SUPPORT_ACTIVE = "assets/images/support_active.png";
  static const String SUPPORT = "assets/images/support.png";

  static const String SETTINGS_ACTIVE = "assets/images/setting_active.png";
  static const String SETTINGS = "assets/images/setting.png";

  static const String HIGH_BATTERY = "assets/images/high_battery.png";
  static const String MIDDLE_BATTERY = "assets/images/middle_battery.png";
  static const String LOW_BATTERY = "assets/images/low_battery.png";
}

class PayMethodStr {
  static const String GOOGLE_PAY = "google";
  static const String APPLE_PAY = "apple";
}
