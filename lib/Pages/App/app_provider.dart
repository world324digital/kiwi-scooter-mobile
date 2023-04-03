import 'dart:convert';
import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Models/location_model.dart';
import 'package:KiwiCity/Models/review_model.dart';
import 'package:KiwiCity/Models/card_model.dart';
import 'package:KiwiCity/Models/price_model.dart';
import 'package:KiwiCity/Models/scooterObject.dart';
import 'package:KiwiCity/Models/term_model.dart';
import 'package:KiwiCity/Models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
// import 'package:within/Models/index.dart';

class AppProvider extends ChangeNotifier {
  static AppProvider of(BuildContext context, {bool listen = false}) =>
      Provider.of<AppProvider>(context, listen: listen);

  // Address
  String _address = "";
  String get getAddress => _address;
  void setAddress(String address, {bool isNotifiable = true}) {
    _address = address;
    if (isNotifiable) notifyListeners();
  }

  // Address
  scooterObject? _scooter;
  scooterObject? get getScooter => _scooter;
  void setScooter(scooterObject scooter, {bool isNotifiable = true}) {
    _scooter = scooter;
    if (isNotifiable) notifyListeners();
  }

  // Drawer index
  int _index = 3;
  int get index => _index;
  void setIndex(int _int, {bool isNotifiable = true}) {
    _index = _int;
    if (isNotifiable) notifyListeners();
  }

  // Used Time
  int _usedTime = 0;
  int get usedTime => _usedTime;
  void setUsedTime(int usedTime, {bool isNotifiable = true}) {
    _usedTime = usedTime;
    if (isNotifiable) notifyListeners();
  }

  // Logined User
  late UserModel _user;
  UserModel get currentUser => _user;
  void setCurrentUser(UserModel user, {bool isNotifiable = true}) {
    _user = user;
    if (isNotifiable) notifyListeners();
  }

  // isLogin
  bool _isLogin = false;
  bool get isLogin => _isLogin;
  void setLogined(bool login, {bool isNotifiable = true}) {
    _isLogin = login;
    if (isNotifiable) notifyListeners();
  }

  // loginType
  LoginType _loginType = LoginType.NONE;
  LoginType get loginType => _loginType;
  void setLoginType(LoginType loginType, {bool isNotifiable = true}) {
    _loginType = loginType;
    if (isNotifiable) notifyListeners();
  }

  // Selected Bike ID
  String _scooterID = "";
  String get scooterID => _scooterID;
  void setScooterID(String scooterID, {bool isNotifiable = true}) {
    _scooterID = scooterID;
    if (isNotifiable) notifyListeners();
  }

  // Selected Scooter IMEI
  String _imei = "";
  String get imei => _imei;
  void setScooterImei(String imei, {bool isNotifiable = true}) {
    _imei = imei;
    if (isNotifiable) notifyListeners();
  }

  // Selected Price ID
  PriceModel? _priceModel;
  PriceModel? get selectedPrice => _priceModel;
  void setPriceModel(PriceModel price, {bool isNotifiable = true}) {
    _priceModel = price;
    if (isNotifiable) notifyListeners();
  }

  //Selected Review Info

  late ReviewModel _review;
  ReviewModel get reviewInfo => _review;
  void setReview(ReviewModel reviewInfo, {bool isNotifiable = true}) {
    _review = reviewInfo;
    if (isNotifiable) notifyListeners();
  }

  //Selected Card Info

  late CardModel _card;
  CardModel get cardInfo => _card;
  void setCardInfo(CardModel cardInfo, {bool isNotifiable = true}) {
    _card = cardInfo;
    if (isNotifiable) notifyListeners();
  }

  // Last User Location
  Position? _lastUserLocation;
  Position? get lastUserLocation => _lastUserLocation;
  void setLastUserLocation(Position position, {bool isNotifiable = true}) {
    _lastUserLocation = position;
    if (isNotifiable) notifyListeners();
  }

  //  User Location Marker
  Marker? _userMarker;
  Marker? get userMarker => _userMarker;
  void setUserMarker(Marker marker, {bool isNotifiable = true}) {
    _userMarker = marker;
    if (isNotifiable) notifyListeners();
  }

  // Start Ride Time
  DateTime _startRideTime = DateTime.now();
  DateTime get startRideTime => _startRideTime;
  void setStartRideTime(DateTime startRideTime, {bool isNotifiable = true}) {
    _startRideTime = startRideTime;
    if (isNotifiable) notifyListeners();
  }

  // End Ride Time
  DateTime _endRideTime = DateTime.now();
  DateTime get endRideTime => _endRideTime;
  void setEndRideTime(DateTime endRideTime, {bool isNotifiable = true}) {
    _endRideTime = endRideTime;
    if (isNotifiable) notifyListeners();
  }

  // Terms Model
  late List<TermsModel> _termList;
  List<TermsModel> get termLists => _termList;
  void setTermsLists(List<TermsModel> termLists, {bool isNotifiable = true}) {
    _termList = termLists;
    if (isNotifiable) notifyListeners();
  }

  // Location Model for StartPoint
  late LocationModel _startPoint;
  LocationModel get startPoint => _startPoint;
  void setStartPoint(LocationModel startPoint, {bool isNotifiable = true}) {
    _startPoint = startPoint;
    if (isNotifiable) notifyListeners();
  }

  // Location Model for EndPoint
  late LocationModel _endPoint;
  LocationModel get endPoint => _endPoint;
  void setEndPoint(LocationModel endPoint, {bool isNotifiable = true}) {
    _endPoint = endPoint;
    if (isNotifiable) notifyListeners();
  }

  // Check if Ride in Progree or not
  bool _isProgress = false;
  bool get isProgress => _isProgress;
  void setProgress(bool isProgress, {bool isNotifiable = true}) {
    _isProgress = isProgress;
    if (isNotifiable) notifyListeners();
  }
}
