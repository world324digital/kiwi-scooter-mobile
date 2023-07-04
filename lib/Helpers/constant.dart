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
  // static const String urlTemplate =
  //     'https://api.mapbox.com/styles/v1/rolandz/clg0n8s1o002101myonakrjgu/wmts?access_token=pk.eyJ1Ijoicm9sYW5keiIsImEiOiJjbGcwbXkyOXgxZGo1M2VxeW1nM2ttc2QxIn0.XhSysU0eukqhSWbAdgKmjg';

  static const String backServiceIdenitfier = "kiwiCityTask";
  static const String publishKey =
      'pk_live_51MokUqEaT93AOXiCFJ8Ok2JDAcu5QoqM97C1hq9eNUpFAErI0VodhHNrtIMKL7eJrK8Hpc8liK6jKkn6tpGJNLj300l5JXN5VD';
  // static const String publishKey =
  //     'pk_test_51MokUqEaT93AOXiCQMSJpNLJmuaRx6T8iSY8CKz0YTrXC02zgA8ONQ8svjLhElqUNeq2DNjRqj3HexbwDUVEyhdh009ZyJCNe3';

  static const String googlePayMerchantName = "Kiwi City";
  static const String googlePayMerchantId = "BCR2DN4TZLD733BD";
}

class URLS {
  static const String BASE_URL = "http://185.96.163.118:8443";
  static const String API_PREFIX = "/api";
  static const String MQTT_PREFIX = "/mqtt";

  static const String SEND_REPORT_EMAIL = "/sendReport";
  static const String SEND_INVOICE_EMAIL = "/sendinvoice";
  static const String SEND_RING_ON = "/alarmon";
  static const String SEND_RING_OFF = "/alarmoff";
  static const String CARD_PAY = "/cardPay";
  static const String NATIVE_PAY = "/create-payment-intent";
  static const String CHANGE_POWER_STATUS = "/changePowerStatus";
  static const String LOCK = "/lock";
  static const String UNLOCK = "/unlock";
  static const String TURN_ON_LIGHTS = "/turnonlights";
  static const String TURN_OFF_LIGHTS = "/turnofflights";

  static const String TERMS_CONDITION_URL =
      "https://www.kiwi-city.com/";
  static const String PRIVACY_URL = "https://www.kiwi-city.com/privacy-policy.html";
  static const String SUPPORTT_URL = "https://www.kiwi-city.com/";
}

class TextConstants {
  static const Map<String, String> rideDetailLabel = {
    "en": "Ride Detail",
    "el": "Λεπτομέρεια διαδρομής",
    "lv": "Brauciena detaļas"
  };
  static const Map<String, String> startPriceLabel = {
    "en": "Start Price",
    "el": "Τιμή έναρξης",
    "lv": "Sākuma cena"
  };
  static const Map<String, String> ridingPriceLabel = {
    "en": "Riding Price",
    "el": "Τιμή ιππασίας",
    "lv": "Izjādes cena"
  };
  static const Map<String, String> startTimeLabel = {
    "en": "Start Time",
    "el": "Ώρα έναρξης",
    "lv": "Sākuma laiks"
  };
  static const Map<String, String> endTimeLabel = {
    "en": "End Time",
    "el": "Ώρα λήξης",
    "lv": "Beigu laiks"
  };
  static const Map<String, String> durationLabel = {
    "en": "Duration",
    "el": "Διάρκεια",
    "lv": "Ilgums"
  };
  static const Map<String, String> totalAmountLabel = {
    "en": "Total Amount",
    "el": "Συνολικό ποσό",
    "lv": "Kopā summa"
  };
  static const Map<String, String> scooterCodeLabel = {
    "en": "eScooter Code",
    "el": "Κωδικός eScooter",
    "lv": "eScooter kods"
  };
  static const Map<String, String> scooterTypeLabel = {
    "en": "eScooter Type",
    "el": "Τύπος eScooter",
    "lv": "eScooter tips"
  };
}

class Messages {
  static const String SUCCESS_SEND_REPORT =
      "Thank you. Email sent successfully! ";

  static const String SUCCESS_DEPOSIT = "Deposit was succeed! ";

  static const String NETWORK_ERROR =
      "Network error. Please check your connection!";
  static const String ERROR_MSG = "Something went wrong. Please retry!";

  static const String ERROR_UNABLE_FAR_AWAY =
      "You are too far from this vehicle and need to be closer to ride it.";

  static const String ERROR_UNABLE_SCOOTER =
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

  static const String WALLET_ACTIVE = "assets/images/wallet_active.png";
  static const String WALLET = "assets/images/wallet.png";

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
