import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Helpers/helperUtility.dart';
import 'package:KiwiCity/Helpers/local_storage.dart';
import 'package:KiwiCity/Models/location_model.dart';
import 'package:KiwiCity/Models/price_model.dart';
import 'package:KiwiCity/Models/card_model.dart';
import 'package:KiwiCity/Models/transaction_model.dart';
import 'package:KiwiCity/Models/user_model.dart';
import 'package:KiwiCity/Pages/App/app_provider.dart';
import 'package:KiwiCity/Pages/MenuPage/main_menu.dart';
import 'package:KiwiCity/Pages/PaymentPage/payment_helper.dart';
import 'package:KiwiCity/Pages/StartRidingPage/start_riding_page.dart';
import 'package:KiwiCity/Routes/routes.dart';
import 'package:KiwiCity/services/firebase_service.dart';
import 'package:KiwiCity/Widgets/CachedNetworkTileProvider.dart';
import 'package:KiwiCity/Widgets/batteryStatusWidget.dart';
import 'package:KiwiCity/Widgets/primaryButton.dart';
import 'package:KiwiCity/Widgets/toast.dart';
import 'package:KiwiCity/Widgets/unableAlert.dart';
import 'package:KiwiCity/services/httpService.dart';
// import 'package:KiwiCity/services/local_notification_service.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_api/mapbox_api.dart';
import 'package:intl/intl.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RideNow extends StatefulWidget {
  RideNow({Key? key, this.data}) : super(key: key);
  dynamic data;
  @override
  _RideNowState createState() => _RideNowState();
}

class _RideNowState extends State<RideNow>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  final db = FirebaseFirestore.instance;

  bool _setuserLocation = false;
  bool _isShowingAddMoreDialog = false;
  bool positionStreamStarted = false;
  double distance = 0;
  Position? userLocation;
  bool _isLock = false;
  late Marker userLocationMarker;
  late final MapController _mapController;
  bool isMapReady = false;
  bool showProgressBar = false; // Show "Ride in Progress Bar"
  int currentHour = 0;
  bool isNoRideDialogOpen = false;
  bool isStarted = false;

  bool inProgress = true; // Ride in progress
  FirebaseService service = FirebaseService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Availabel Ride Time (seconds)
  Timer? _timer;

  // int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 300;
  // int _totalRidetime = 10;

  // late final NotificationService notificationService;

  /// is Show Init Start Riding Dialog
  bool isAllowDismiss = false;

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  bool isLightOn = true;
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  bool isLoading = true;
  bool isDone = false; // If user clikc "End ride", this will be ture, not flase

  //////////////////////////////////////////////
  /// START RIDING DIALOG WAITING TIME: 60s
  /// TOTAL RIDE TIME: SECOND
  /// NOTIFY TIME BEFORE OUT OF TIME : 5 * 60s
  /// USED SCOOTER TIME
  //////////////////////////////////////////////
  // int _totalRidetimeRidingWaitingTime = 60;
  // int _totalRidetime = 1 * 60; // 1 min
  int _notifyBeforeTime = 5 * 60; // 5 mins
  int _usedTime = 0;
  bool isFlag = true;
  bool _alertShown = false;
  List<Polygon> polygon = [];
  List<Map<String, dynamic>> points = [];
  @override
  void initState() {
    super.initState();
    getGeofencing();
    WidgetsBinding.instance.addObserver(this);
    debugPrint('asdsfsdf : $isLoading');
    if (widget.data != null) {
      recoveryData();
    } else {
      isLoading = false;
      // _totalRidetime = getDuraion();
    }

    _mapController = MapController();
    _toggleServiceStatusStream();
    _toggleListening();

    // notificationService = NotificationService();
    // listenToNotificationStream();
    // notificationService.initSetUp();
    if (widget.data == null)
      Future.delayed(const Duration(seconds: 0), () async {
        showRidingDialog();
      });
  }

  /************* Geofencing   ** */
  Future<void> getGeofencing() async {
    db.collection('geofence').snapshots().listen((event) {
      print("=== ${event.docs}");
      polygon = event.docs
          .map((e) => Polygon(
                points: (e.data()['points'] as List)
                    .map((e) => LatLng(e['la'], e['lo']))
                    .toList(),
                borderStrokeWidth: 2,
                borderColor: Colors.red,
                color: Colors.red.withOpacity(0.5),
              ))
          .toList();

      Geolocator.getPositionStream().listen((location) async {
        double lat = location.latitude;
        double lng = location.longitude;
        double minLat = double.infinity;
        double maxLat = -double.infinity;
        double minLng = double.infinity;
        double maxLng = -double.infinity;

        for (var i = 0; i < event.docs.length; i++) {
          for (var ii = 0;
              ii < (event.docs[i].data()['points'] as List).length;
              ii++) {
            double _eLat = (event.docs[i].data()['points'] as List)[ii]['la'];
            double _eLng = (event.docs[i].data()['points'] as List)[ii]['lo'];
            minLat = min(minLat, _eLat);
            maxLat = max(maxLat, _eLat);
            minLng = min(minLng, _eLng);
            maxLng = max(maxLng, _eLng);
          }
        }
        // if (lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng) {
        //   if (!_alertShown) {
        //     _alertShown = true;

        //     showNoRideDialog(context);
        //     if (!_isLock) {
        //       await changeLock(false, () {
        //         _isLock = true;
        //       });
        //       await sendRing();
        //     }
        //   }
        // } else {
        _alertShown = false;
        if (_isLock) {
          changeLock(true, () {
            _isLock = false;
          });
        }
        // }
      });
    });
  }

  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      /****************** When User close app forcely ***************/
      case AppLifecycleState.inactive:
        print("Inactive");
        if (isFlag) {
          _timer?.cancel();
          await storeDataToLocal(
              key: AppLocalKeys.PAUSE_TIME,
              value: DateTime.now().millisecondsSinceEpoch,
              type: StorableDataType.INT);
          // await storeDataToLocal(
          //     key: AppLocalKeys.TOTAL_RIDE_TIME,
          //     value: _totalRidetime,
          //     type: StorableDataType.INT);
          if (!isDone) await saveTempReview();
        }

        break;
      case AppLifecycleState.paused:
        print("PAUSED");

        _timer?.cancel();
        await storeDataToLocal(
            key: AppLocalKeys.PAUSE_TIME,
            value: DateTime.now().millisecondsSinceEpoch,
            type: StorableDataType.INT);
        // await storeDataToLocal(
        //     key: AppLocalKeys.TOTAL_RIDE_TIME,
        //     value: _totalRidetime,
        //     type: StorableDataType.INT);
        await saveTempReview();
        setState(() {
          isFlag = false;
        });

        break;
      case AppLifecycleState.detached:
        print("Detached");
        break;

      case AppLifecycleState.resumed:
        print("Resuemd");

        int pausedTime = await getDataInLocal(
            key: AppLocalKeys.PAUSE_TIME, type: StorableDataType.INT);
        int now = DateTime.now().millisecondsSinceEpoch;
        int gap_time = ((now - pausedTime) ~/ 1000).toInt();
        _usedTime = _usedTime + gap_time;
        startTimer();
        // Before showing "Add more time" Dialog
        // if (_totalRidetime - gap_time > 5 * 60) {
        //   _totalRidetime = _totalRidetime - gap_time;
        //   setState(() {
        //     _totalRidetime = _totalRidetime;
        //     isFlag = true;
        //   });
        //   startTimer();
        // } else if (_totalRidetime - gap_time > 0) {
        //   // During showing "Add more time" Dialog
        //   // if (_isShowingAddMoreDialog) {
        //   //   return;
        //   // }
        //   await addMoreTime();
        //   _totalRidetime = _totalRidetime - gap_time;
        //   setState(() {
        //     _totalRidetime = _totalRidetime;
        //     isFlag = true;
        //   });
        //   startTimer();
        // } else {
        //   _timer!.cancel();
        //   _totalRidetime = 0;
        //   setState(() {
        //     _totalRidetime = _totalRidetime;
        //     isFlag = true;
        //   });
        //   onDone();
        // }

        break;
    }
  }

  /**************************
   * @Auth: world324digital
   * @Date: 2023.04.04
   * @Desc: Get Usage Time Seconds
   */
  // int getDuraion() {
  //   PriceModel _currentPrice = AppProvider.of(context).selectedPrice!;
  //   int _duration = _currentPrice.totalCost ~/ _currentPrice.cost * 60;
  //   return _duration;
  // }

  // void listenToNotificationStream() =>
  //     notificationService.behaviorSubject.listen((payload) {
  //       print("============Notification Payload ============\r\n");
  //       print(payload);
  //     });

/********************
 * @Auth World324
 * @Date 2023.04.03
 * @Desc count down timer
 */
  Widget CountDownTimer({required int time_value, TextStyle? textStyle}) {
    String value = '';
    // if (time.days != null) {
    //   var days = _getNumberAddZero(time.days!);
    //   value = '$value$days days ';
    // }

    var hours = _getNumberAddZero((time_value / 3600).floor() ?? 0);
    value = '$value$hours:';
    time_value = time_value % 3600;
    var min = _getNumberAddZero((time_value / 60).floor() ?? 0);
    value = '$value$min:';
    time_value = time_value % 60;
    var sec = _getNumberAddZero(time_value ?? 0);
    value = '$value$sec';
    return Text(
      value,
      style: textStyle,
    );
  }

  /********************
 * @Auth World324
 * @Date 2023.04.03
 * @Desc count up timer
 */
  Widget CountUpTimer({required int time_value, TextStyle? textStyle}) {
    String value = '';
    // if (time.days != null) {
    //   var days = _getNumberAddZero(time.days!);
    //   value = '$value$days days ';
    // }

    var hours = _getNumberAddZero((time_value / 3600).floor() ?? 0);
    value = '$value$hours:';
    time_value = time_value % 3600;
    var min = _getNumberAddZero((time_value / 60).floor() ?? 0);
    value = '$value$min:';
    time_value = time_value % 60;
    var sec = _getNumberAddZero(time_value ?? 0);
    value = '$value$sec';
    return Text(
      value,
      style: textStyle,
    );
  }

/********************
 * @Auth World324
 * @Date 2023.04.02
 * @Desc Add zero to number
 * @exam  1->01
 */
  String _getNumberAddZero(int number) {
    if (number < 10) {
      return "0" + number.toString();
    }
    return number.toString();
  }

  /********************************************
   * @Auth: world.digital.dev@gmail.com
   * @Date: 2023.04.21
   * @Desc: Turn On/Off Light
   */
  Future<void> changeLightStatus(bool isOn) async {
    // ------------ Show Progress Dialog ----------
    // Dialogs.showLoadingDarkDialog(
    //   context: context,
    //   key: _keyLoader,
    //   title: "Please wait...",
    //   backgroundColor: Colors.white,
    //   indicatorColor: ColorConstants.cPrimaryBtnColor,
    //   textColor: ColorConstants.cPrimaryTitleColor,
    // );
    String imei = AppProvider.of(context).imei;
    try {
      var res = await HttpService().changeLightStatus(imei: imei, status: isOn);
      print(res);
      //------------ Dismiss Progress Dialog  -------------------
      // Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
      if (res['result']) {
        // showRingDialog();
      } else {
        unableAlert(
            scooterID: AppProvider.of(context).scooterID,
            error: res['message'],
            message: AppLocalizations.of(context).errorUnableScooter,
            context: context);
      }
    } catch (e) {
      print(e.toString());
      // //------------ Dismiss Progress Dialog  -------------------
      // Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
      unableAlert(
          scooterID: AppProvider.of(context).scooterID,
          error: e.toString(),
          message: AppLocalizations.of(context).errorUnableScooter,
          context: context);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _positionStreamSubscription?.pause();
    _positionStreamSubscription?.cancel();
    _serviceStatusStreamSubscription?.pause();
    _serviceStatusStreamSubscription?.cancel();
    _timer?.cancel();
    // notificationService.cancelAllNotification();
    WidgetsBinding.instance.removeObserver(this);

    Workmanager().cancelAll();
    super.dispose();
  }

  Future<void> showNoRideDialog(BuildContext context) {
    Dialog NoRideDialog = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding:
                const EdgeInsets.only(bottom: 15, left: 15, right: 15, top: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  child: Image.asset('assets/images/prohibit.png'),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10, top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          AppLocalizations.of(context).noRideZoneTitle,
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: FontStyles.fBold,
                            fontWeight: FontWeight.w600,
                            color: ColorConstants.cPrimaryTitleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  child: Text(
                    AppLocalizations.of(context).noRideZoneMsg,
                    style: TextStyle(
                      fontFamily: FontStyles.fMedium,
                      color: Color(0xffAD0505),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ========= PAYMENT PART =============
        ],
      ),
    );
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => NoRideDialog,
    );
  }

  Future<void> onPause() async {
    /************ Send command 73 ******** */
    await changeLock(false, () async {
      setState(() {
        inProgress = false;
      });
      _timer?.cancel();

      // Cancel All Notification
      // notificationService.cancelAllNotification();
    });
  }

  Future<void> onResume() async {
    /************ Send command 75 ******** */
    await changeLock(true, () async {
      setState(() {
        inProgress = true;
      });
      startTimer();

      // Cancel All Notification
      // notificationService.cancelAllNotification();
      // scheduleNotification(
      //     totalRideTime: _totalRidetime, notifyTimeBefore: _notifyBeforeTime);
    });
  }

  // Future<void> addMoreTime() async {
  //   _isShowingAddMoreDialog = true;
  //   await sendRing();
  //   showBottomDialog(
  //     img1: 'assets/images/almosttime.png',
  //     title: 'You\'re almost out of time',
  //     subtitle:
  //         'This scooter will automatically lock when the time is out. Please purchase addition time to keep riding.',
  //     btntxt: 'Add More Time',
  //     onTap: () async {
  //       // _timer?.cancel();
  //       _isShowingAddMoreDialog = false;
  //       final time = await Navigator.of(context).push(
  //         MaterialPageRoute(
  //             builder: (context) => const StartRiding(data: {"isMore": true})),
  //       );
  //       if (time != null) {
  //         setState(() {
  //           _totalRidetime = _totalRidetime + int.parse(time.toString());
  //         });
  //         storeDataToLocal(
  //           key: AppLocalKeys.RIDE_END_TIME,
  //           value:
  //               DateTime.now().millisecondsSinceEpoch + _totalRidetime * 1000,
  //           type: StorableDataType.INT,
  //         );

  //         print(_totalRidetime);
  //         Navigator.of(context).pop();
  //         scheduleNotification(
  //             totalRideTime: _totalRidetime,
  //             notifyTimeBefore: _notifyBeforeTime);
  //       }
  //     },
  //   );
  //   /********** Sound Scotter Alarm ************* */
  // }

  final mapbox = MapboxApi(
    accessToken: AppConstants.mapBoxAccessToken,
  );

  /******************************
   * @Auth: world324digital
   * @Date: 2023.04.05
   * @Desc: Calculate Riding distance
   */
  Future<void> calculateDistance(LatLng startPoint, LatLng endPoint) async {
    try {
      final response = await mapbox.directions.request(
        profile: NavigationProfile.CYCLING,
        overview: NavigationOverview.FULL,
        geometries: NavigationGeometries.GEOJSON,
        steps: true,
        coordinates: <List<double>>[
          <double>[
            startPoint.latitude, // latitude
            startPoint.longitude, // longitude
          ],
          <double>[
            endPoint.latitude, // latitude
            endPoint.longitude, // longitude
          ],
        ],
      );

      if (response.error != null) {
        if (response.error is NavigationNoRouteError) {
          // handle NoRoute response
        } else if (response.error is NavigationNoSegmentError) {
          // handle NoSegment response
        }
        return;
      }
      if (response.routes!.isNotEmpty) {
        final route = response.routes![0];
        distance = route.distance!;
      }
    } catch (e) {
      print("Calculate Distance Error ::::> ${e}");
    }
  }

  /******************************
   * @Auth: world324digital
   * @Date: 2023.04.10
   * @Desc: Calculate Riding distance between multiple points
   */
  Future<void> calculateDistanceFromPoints(
      List<Map<String, dynamic>> point_list) async {
    // List<List<double>> distancePoints = [];
    print("/////////////////calculating distance print///////////////");
    distance = 0;
    for (int i = 0; i < point_list.length - 1; i++) {
      final point1 = LatLng(point_list[i]["lat"], point_list[i]["long"]);
      final point2 =
          LatLng(point_list[i + 1]["lat"], point_list[i + 1]["long"]);
      distance += Distance().as(LengthUnit.Meter, point1, point2);
      // print(point_list[i]['lat']);
      // print(point_list[i]['long']);
      // distancePoints.add([
      //   point_list[i]['lat'], // latitude
      //   point_list[i]['long'], // longitude
      // ]);
    }
    // try {
    //   final response = await mapbox.directions.request(
    //     profile: NavigationProfile.CYCLING,
    //     overview: NavigationOverview.FULL,
    //     geometries: NavigationGeometries.GEOJSON,
    //     steps: true,
    //     coordinates: distancePoints,
    //     // coordinates: [
    //     //   [-77.03655, 38.8977], // Washington D.C.
    //     //   [-122.419416, 37.774929], // San Francisco, CA
    //     //   [-73.935242, 40.730610] // New York, NY
    //     // ],
    //   );

    //   if (response.error != null) {
    //     if (response.error is NavigationNoRouteError) {
    //       // handle NoRoute response
    //     } else if (response.error is NavigationNoSegmentError) {
    //       // handle NoSegment response
    //     }
    //     return;
    //   }
    //   if (response.routes!.isNotEmpty) {r
    //     final route = response.routes![0];
    //     distance = route.distance!;
    //   }
    // } catch (e) {
    //   print("Calculate Distance Error ::::> ${e}");
    // }
  }

  Future<void> onDone() async {
    if (ModalRoute.of(context)?.isCurrent != true) {
      print("_______________ Dialog Opened");
      Navigator.of(context).pop();
      await Future.delayed(const Duration(milliseconds: 500), () {});
    }
    _timer?.cancel();
    await changeLock(false, () {});

    // await changePower(false, () async {
    await changeLightStatus(false);
    // });

    await service.updateInUseStatus(
        imei: AppProvider.of(context).imei, useStatus: 'available');

    isAllowDismiss = false;
    showBottomDialog(
      img1: 'assets/images/almosttime.png',
      title: 'You\'re out of time',
      subtitle:
          'This scooter is locked and ride has ended. Please purchase addition time to keep riding.',
      btntxt: 'Done',
      isDismissible: false,
      enableDrag: false,
      onTap: () async {
        Navigator.of(context).pop();
        LocationModel _end = new LocationModel(
            lat: userLocation!.latitude, long: userLocation!.longitude);
        // Set User Ride End Time
        AppProvider.of(context).setEndRideTime(DateTime.now());
        AppProvider.of(context).setEndPoint(_end);
        AppProvider.of(context).setUsedTime(_usedTime);
        removeDataInLocal(AppLocalKeys.TEMP_REVIEW);
        setState(() {
          isDone = true;
        });

        // HelperUtility.goPageAllClear(
        //     context: context, routeName: Routes.PHOTO_SCOTTER);
        final cameras = await availableCameras();
        HelperUtility.goPageReplace(
            context: context,
            routeName: Routes.PHOTO_SCOTTER,
            arg: {'camera': cameras});
      },
    );
  }

// If user have still time, this runs
  Future<void> onEndRide() async {
    isStarted = false;
    double price_per_minute =
        AppProvider.of(context).selectedPrice?.costPerMinute ?? 0.0;
    double riding_price =
        double.parse((price_per_minute * _usedTime / 60.0).toStringAsFixed(2));

    showBottomDialog(
        img1: '',
        title: AppLocalizations.of(context).ridingPriceNote,
        subtitle: '€${riding_price.toString()}',
        btntxt: AppLocalizations.of(context).confirmEndRide,
        onTap: () async {
          Navigator.of(context).pop();
          _timer?.cancel();

          await changeLock(false, () {});
          // await changePower(false, () async {
          await changeLightStatus(false);
          // });

          await service.updateInUseStatus(
              imei: AppProvider.of(context).imei, useStatus: 'available');

          // Set User End Ride Time
          AppProvider.of(context).setEndRideTime(DateTime.now());
          AppProvider.of(context).setProgress(false);
          setState(() {
            showProgressBar = false;
            isAllowDismiss = false;
          });
          if (userLocation == null) return;
          LocationModel _end = new LocationModel(
              lat: userLocation!.latitude, long: userLocation!.longitude);

          AppProvider.of(context).setEndPoint(_end);
          AppProvider.of(context).setUsedTime(_usedTime);
          AppProvider.of(context).setPoints(points);
          removeDataInLocal(AppLocalKeys.TEMP_REVIEW);

          HelperUtility.showProgressDialog(
            context: context,
            key: _keyLoader,
            title: AppLocalizations.of(context).wait,
          );

          UserModel currentUser = AppProvider.of(context).currentUser;

          double user_balance = currentUser.balance;
          var res;
          var errorMsg = AppLocalizations.of(context).errorMsg;
          bool isPaidBalance = false;

          if (riding_price >= 0.5) {
            if (user_balance >= riding_price) {
              currentUser.balance = double.parse(
                  (currentUser.balance - riding_price).toStringAsFixed(2));
              isPaidBalance = true;
            } else {
              String rest_amount =
                  (riding_price - user_balance).toStringAsFixed(2);
              CardModel card = currentUser.card!;
              res = await HttpService().cardPay(
                  holderName: card.cardName,
                  cardNumber: card.cardNumber,
                  expiredMonth: card.expMonth,
                  expiredYear: card.expYear,
                  cvv: card.cvv,
                  amount: rest_amount);
              // amount: "0");
              print("Final Riding Stripe Result :::::::::::::>");
              print(res);
              if (!res['result']) {
                errorMsg = res['msg'];
              }
            }
          } else {
            currentUser.balance = double.parse(
                (currentUser.balance - riding_price).toStringAsFixed(2));
            isPaidBalance = true;
          }

          if (isPaidBalance || !isPaidBalance && res['result']) {
            await calculateDistanceFromPoints(points);
            print(distance);
            distance = double.parse(distance.toStringAsFixed(2));

            AppProvider.of(context).setDistance(distance);

            double amount_fixed =
                double.parse((riding_price + 1).toStringAsFixed(2));

            TransactionModel transaction = new TransactionModel(
              userId: currentUser.id,
              userName: currentUser.firstName + " " + currentUser.lastName,
              stripeId: "",
              stripeTxId: "",
              rideDistance: distance,
              rideTime: _usedTime,
              amount: amount_fixed,
              txType: "Ride",
            );
            await service.createTransaction(transaction);

            bool updateUserResult = await service.updateUser(currentUser);

            if (updateUserResult) {
              HelperUtility.closeProgressDialog(_keyLoader);
              HelperUtility.goPageReplace(
                context: context,
                routeName: Routes.HOWRIDE,
                arg: {"scooterPhoto": ""},
              );

              // final cameras = await availableCameras();
              // final firstCamera = cameras.first;
              // HelperUtility.goPageReplace(
              //     context: context,
              //     routeName: Routes.PHOTO_SCOTTER,
              //     arg: {'camera': cameras});
            }
          } else {
            HelperUtility.closeProgressDialog(_keyLoader);
            Alert.showMessage(
                type: TypeAlert.error,
                title: AppLocalizations.of(context).error,
                message: errorMsg);
          }
        });
  }

  Future<void> sendRing() async {
    try {
      var res = await HttpService()
          .sendRing(scooterImei: AppProvider.of(context).imei);
      if (res['result']) {
        // showRingDialog();
      } else {
        Alert.showMessage(
            type: TypeAlert.error,
            title: AppLocalizations.of(context).error,
            message: AppLocalizations.of(context).failAlarm);
      }
    } catch (e) {
      unableAlert(
          error: e.toString(),
          message: AppLocalizations.of(context).errorUnableScooter,
          context: context);
    }
  }

  bool isPointInsidePolygon(LatLng point, List<LatLng> polygon) {
    double x = point.latitude, y = point.longitude;

    bool inside = false;
    for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      double xi = polygon[i].latitude, yi = polygon[i].longitude;
      double xj = polygon[j].latitude, yj = polygon[j].longitude;

      bool intersect =
          ((yi > y) != (yj > y)) && (x < (xj - xi) * (y - yi) / (yj - yi) + xi);
      if (intersect) inside = !inside;
    }

    return inside;
  }

  // bool _rayCrossesSegment(LatLng point, LatLng vertA, LatLng vertB) {
  //   double aY = vertA.latitude;
  //   double bY = vertB.latitude;
  //   double aX = vertA.longitude;
  //   double bX = vertB.longitude;
  //   double pY = point.latitude;
  //   double pX = point.longitude;

  //   if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
  //     return false; // a and b can't both be above or below pt.y, and a or
  //     // b must be east of pt.x
  //   }

  //   double m = (aY - bY) / (aX - bX); // Rise over run
  //   double bee = (-aX) * m + aY; // y = mx + b
  //   double x = (pY - bee) / m; // algebra is neat!

  //   return x > pX;
  // }

  /*****************
   * Show "Start Ride" Dialog
   */
  void showRidingDialog() {
    isAllowDismiss = false;

    // // ========= Start Timer for closing this dialog
    // _timer = new Timer.periodic(
    //   Duration(seconds: _totalRidetimeRidingWaitingTime),
    //   (Timer timer) async {
    //     // After 60s, close modal, cancel this timer;
    //     _timer?.cancel();
    //     Navigator.of(context).pop();

    //     setState(() {
    //       showProgressBar = true;
    //       isAllowDismiss = true;
    //     });
    //     // Start Riding Timer
    //     // startTimer();
    //     startRiding();
    //   },
    // );
    showBottomDialog(
        img1: 'assets/images/nowbike.png',
        img2: 'assets/images/nowcheck.png',
        title: AppLocalizations.of(context).beginRide,
        subtitle: AppLocalizations.of(context).beginRideMsg,
        btntxt: AppLocalizations.of(context).startRiding,
        isDismissible: false,
        enableDrag: false,
        onTap: () {
          _timer?.cancel();
          AppProvider.of(context).setProgress(true);
          Navigator.of(context).pop();

          setState(() {
            showProgressBar = true;
            isAllowDismiss = true;
          });
          // startTimer();
          startRiding();
          isStarted = true;
          // _countTimeController.start();
        });
  }

/*************/

  void moveToUserLocation() {
    _animatedMapMove(
        LatLng(userLocation!.latitude, userLocation!.longitude), 15);
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final latTween = Tween<double>(
        begin: _mapController.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: _mapController.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: _mapController.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      _mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  void _toggleServiceStatusStream() {
    // if service is turn off
    if (_serviceStatusStreamSubscription == null) {
      // Request service turn on
      final serviceStatusStream = _geolocatorPlatform.getServiceStatusStream();
      _serviceStatusStreamSubscription =
          serviceStatusStream.handleError((error) {
        // If error exist , Turn off service
        _serviceStatusStreamSubscription?.cancel();
        _serviceStatusStreamSubscription = null;
      }).listen((serviceStatus) {
        String serviceStatusValue;

        if (serviceStatus == ServiceStatus.enabled) {
          // If Service is enable, Start user's position tracking
          if (positionStreamStarted) {
            _toggleListening();
          }
          serviceStatusValue = 'enabled';
        } else {
          // If Service is disable, turn off service
          if (_positionStreamSubscription != null) {
            setState(() {
              _positionStreamSubscription?.cancel();
              _positionStreamSubscription = null;
            });
          }
          serviceStatusValue = 'disabled';
        }
        // _updatePositionList(
        //   _PositionItemType.log,
        //   'Location service has been $serviceStatusValue',
        // );
      });
    }
  }

  double _getHeadingFromBearing(double bearing) {
    // Convert the bearing from degrees to radians
    double radians = bearing * (pi / 180);
    // Return the rotation angle in radians
    return radians;
  }

  void checkRidingZone(Position position) {
    print(">>>>>>>>>>>>>>>>>>>>inside check result >>>>>>>>>>>>>>>>");

    int intersectCount = 0;
    for (int i = 0; i < polygon.length; i++) {
      if (isPointInsidePolygon(
          LatLng(position.latitude, position.longitude), polygon[i].points)) {
        intersectCount++;
      }
    }

    if (intersectCount == 0 && isStarted) {
      if (inProgress && !isNoRideDialogOpen) {
        isNoRideDialogOpen = true;
        showBottomDialog(
            img1: 'assets/images/prohibit1.png',
            title: AppLocalizations.of(context).noRideZoneTitle,
            subtitle: AppLocalizations.of(context).noRideZoneMsg,
            btntxt: AppLocalizations.of(context).okay,
            onTap: () async {
              isNoRideDialogOpen = false;

              _timer?.cancel();
              await onPause();
              return Navigator.of(context).pop();
            });
        print("aaaaaaaaaaaaaaaaaa");
      } else {
        print("bbbbbbbbbbbbbbbbbb");
      }
    }
  }

  void _toggleListening() {
    if (_positionStreamSubscription == null) {
      final positionStream = _geolocatorPlatform.getPositionStream();
      _positionStreamSubscription = positionStream.handleError((error) {
        _positionStreamSubscription?.cancel();
        _positionStreamSubscription = null;
      }).listen((position) => {
            print(position.toString()),
            checkRidingZone(position),
            setState(() {
              _setuserLocation = true;
              moveToUserLocation();
              if (userLocation?.latitude != position.latitude &&
                  userLocation?.longitude != position.longitude) {
                points.add(LocationModel(
                        lat: position.latitude, long: position.longitude)
                    .toMap());
              }
              userLocation = position;
              isMapReady = true;
              // position = LatLng(37.31936, 101.94528);
              userLocationMarker = Marker(
                width: 50.0,
                height: 50.0,
                point: LatLng(position.latitude, position.longitude),
                builder: (ctx) => Transform.rotate(
                  angle: _getHeadingFromBearing(position.heading),
                  child: Container(
                      child: Stack(children: <Widget>[
                    Image.asset('assets/images/user_marker.png'),
                  ])),
                ),
              );
            }),
          });
      _positionStreamSubscription?.pause();
    }

    setState(() {
      if (_positionStreamSubscription == null) {
        return;
      }

      String statusDisplayValue;
      if (_positionStreamSubscription?.isPaused ?? false) {
        _positionStreamSubscription?.resume();
        statusDisplayValue = 'resumed';
      } else {
        _positionStreamSubscription?.pause();
        statusDisplayValue = 'paused';
      }
    });
  }

  /********************************
   * @Auth: world324digital
   * @Date: 2023.04.16
   * @Desc: Handle Back Button
   */
  Future<bool> _handleBackButton() async {
    // ======= If Start Riding Dialog is opened

    return isAllowDismiss;
  }

  /**********************************
   * @Auth: world324digital
   * @Date: 2023.04.16
   * @Desc: Start Riding
   */
  Future<void> startRiding() async {
    print(AppProvider.of(context).imei);
    bool result = await service.updateInUseStatus(
        imei: AppProvider.of(context).imei, useStatus: 'taken');
    if (result) {
      // await changePower(true, () async {
      // scheduleNotification(
      //   totalRideTime: _totalRidetime,
      //   notifyTimeBefore: _notifyBeforeTime,
      // );
      LocationModel _start = new LocationModel(
          lat: userLocation!.latitude, long: userLocation!.longitude);

      // Set User Start Ride Time
      AppProvider.of(context).setStartRideTime(DateTime.now());
      AppProvider.of(context).setStartPoint(_start);
      // storeDataToLocal(
      //   key: AppLocalKeys.RIDE_END_TIME,
      //   value: DateTime.now().millisecondsSinceEpoch + _totalRidetime * 1000,
      //   type: StorableDataType.INT,
      // );
      await changeLock(true, () {
        _isLock = false;
      });
      await changeLightStatus(false);
      isLightOn = false;
      startTimer();
      // });
    } else {
      await unableAlert(
        context: context,
        message: AppLocalizations.of(context).errorUnableInuse,
        error: "",
        scooterID: AppProvider.of(context).scooterID,
      );
    }
  }

  /*********************************
   * @Auth: world324digital.
   * @Date: 2023.04.27
   * @Desc: Save Tempreivew on Local storag when user close app forcely
   */

  Future<void> saveTempReview() async {
    // ["String user_id", "String scooter_id", "DateTime startRidetime", "int _totalRidetime", "int _usedTime",
    // Price Model start_price, LocationModel startPoint, int pausedtime]
    var appProvider = AppProvider.of(context);

    /****************************
   * @Desc Save Model type to localstorage
   * 
   */
    Map<String, dynamic> point = appProvider.startPoint.toMap();
    Map<String, dynamic> price = appProvider.selectedPrice!.toMap();

    String startPoint = jsonEncode(point);
    String start_price = jsonEncode(price);

    int pausedTime = await getDataInLocal(
        key: AppLocalKeys.PAUSE_TIME, type: StorableDataType.INT);

    List<String> value = [
      appProvider.currentUser.id,
      appProvider.scooterID,
      dateFormat.format(appProvider.startRideTime),
      // _totalRidetime.toString(),
      _usedTime.toString(),
      start_price,
      startPoint,
      pausedTime.toString()
    ];

    storeDataToLocal(
      key: AppLocalKeys.TEMP_REVIEW,
      value: value,
      type: StorableDataType.STRINGLIST,
    );
  }

  /*********************************
   * @Auth: world.digital.dev@gmail.com
   * @Date: 2023.04.16
   * @Desc: Schedule Notification
   */
  // void scheduleNotification(
  //     {required int totalRideTime,
  //     required int notifyTimeBefore,
  //     bool isRemove = true}) async {
  //   if (isRemove) {
  //     await notificationService.cancelAllNotification();
  //     Workmanager().cancelAll();
  //   }

  //   // Schedule Background Service
  //   //  Workmanager().registerOneOffTask("scooter", "simpleTask");
  //   Workmanager().registerOneOffTask(
  //     "scooter",
  //     Platform.isAndroid
  //         ? AppConstants.backServiceIdenitfier
  //         : "scooter", // Ignored on iOS
  //     initialDelay: Duration(seconds: totalRideTime),
  //     constraints: Constraints(
  //       // connected or metered mark the task as requiring internet
  //       networkType: NetworkType.connected,
  //       // x        // requiresCharging: true,
  //     ),
  //     // inputData: null // fully supported
  //   );

  //   notificationService.showScheduledLocalNotification(
  //       id: 0,
  //       title: "Time is Up!",
  //       body:
  //           "This scooter is locked and ride has ended. Please purchase addition time to keep riding.",
  //       payload: "",
  //       seconds: totalRideTime);

  //   if (totalRideTime - notifyTimeBefore > 0)
  //     notificationService.showScheduledLocalNotification(
  //         id: 1,
  //         title: "You\'re almost out of time",
  //         body:
  //             "This scooter will automatically lock when the time is out. Please purchase addition time to keep riding.",
  //         payload: "",
  //         seconds: totalRideTime - notifyTimeBefore);
  // }

  /***************************
   * @Auth: world324digital
   * @Auth: 2022.12.16
   * @Desc: Lock/ Unlock Scooter
   */

  // Scooter Lock and UnLock
  Future<void> changeLock(bool isUnlock, Function callback) async {
    HelperUtility.showProgressDialog(
      context: context,
      key: _keyLoader,
      title: isUnlock
          ? AppLocalizations.of(context).unlocking
          : AppLocalizations.of(context).locking,
      // title: inProgress ? "Pause..." : "Resume...",
    );

    String scooterImei = AppProvider.of(context).imei;

    print('change lock imei');
    print(scooterImei);
    var res = await HttpService()
        .changeLockStatus(imei: scooterImei, status: isUnlock);
    HelperUtility.closeProgressDialog(_keyLoader);
    print(res);
    if (res['result']) {
      return callback();
    } else {
      await unableAlert(
        context: context,
        message: AppLocalizations.of(context).errorUnableScooter,
        error: res['message'],
        scooterID: AppProvider.of(context).scooterID,
      );
    }
  }

  // Scooter Power on and Off

  Future<void> changePower(bool isUnlock, Function callback) async {
    HelperUtility.showProgressDialog(
      context: context,
      key: _keyLoader,
      title: isUnlock
          ? AppLocalizations.of(context).unlocking
          : AppLocalizations.of(context).locking,
      // title: inProgress ? "Pause..." : "Resume...",
    );

    String scooterID = AppProvider.of(context).scooterID;

    var res = await HttpService()
        .changePowerStatus(scooterID: scooterID, status: isUnlock.toString());
    HelperUtility.closeProgressDialog(_keyLoader);
    if (res['result']) {
      return callback();
    } else {
      await unableAlert(
        context: context,
        message: AppLocalizations.of(context).errorUnableScooter,
        error: res['message'],
        scooterID: AppProvider.of(context).scooterID,
      );
    }
  }

  /****************** 
   * @Auth: world324digital
   * @Date: 2023.04.02
   * @Desc: ShowBottomDialog
   * *************************/
  void showBottomDialog({
    required String img1,
    String? img2,
    required String title,
    required String subtitle,
    required String btntxt,
    required Function onTap,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? color,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async {
            return await _handleBackButton();
            // return true;
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                  margin:
                      const EdgeInsets.only(bottom: 20, left: 15, right: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (img1 != '')
                        Container(
                          child: Image.asset(img1),
                        ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 10, top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            img2 != null ? Image.asset(img2) : Container(),
                            Container(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'Montserrat-SemiBold',
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 20),
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontFamily: 'Montserrat-Medium',
                            color: color,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      PrimaryButton(
                          width: HelperUtility.screenWidth(context),
                          context: context,
                          onTap: () {
                            onTap();
                          },
                          horizontalPadding: 0,
                          title: btntxt)
                    ],
                  )),

              // ========= PAYMENT PART =============
            ],
          ),
        );
      },
    );
  }

/***********************************************
 * @Auth World324
 * @Date 2023.04.03
 * @Desc Start Timer
 */
  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) async {
        final now = DateTime.now();
        int hour = now.hour;
        setState(() {
          // _totalRidetime--;
          _usedTime++;
          currentHour = hour;
        });

        debugPrint('isLighton ==== ${isLightOn}');
        debugPrint('hour uis ==== ${currentHour}');
        // debugPrint('_totalRidetime uis ==== ${_totalRidetime}');
        // if (isLightOn && hour > 6 && hour < 18) {
        //   debugPrint("should turn off");
        //   changeLightStatus(false);
        //   isLightOn = false;
        // } else if ((!isLightOn && hour >= 18 && hour <= 24) ||
        //     (!isLightOn && hour >= 0 && hour <= 6)) {
        //   debugPrint("should turn on");
        //   changeLightStatus(true);
        //   isLightOn = true;
        // }
        // if (_totalRidetime == _notifyBeforeTime) {
        //   await addMoreTime();
        // } else if (_totalRidetime <= 0) {
        //   setState(() {
        //     timer.cancel();
        //   });
        //   await onDone();
        // }
      },
    );
  }

  Future<void> recoveryData() async {
    // ["String user_id", "String scooter_id", "DateTime startRidetime", "int _totalRidetime", "int _usedTime",
    // Price Model start_price, LocationModel startPoint, int pausedtime]
    Position currentLocation = await Geolocator.getCurrentPosition();
    List<String> tempReview = widget.data;
    if (tempReview.length > 0) {
      String userId = tempReview[0];
      String scooterId = tempReview[1];
      DateTime startRideTime = dateFormat.parse(tempReview[2]);
      // _totalRidetime = int.parse(tempReview[3]);
      int _usedTime = int.parse(tempReview[4]);
      int pausedtime = int.parse(tempReview[7]);
      int gaptime =
          (DateTime.now().millisecondsSinceEpoch - pausedtime) ~/ 1000;
      setState(() {
        _usedTime = _usedTime + gaptime;
        // _totalRidetime = _totalRidetime - gaptime;
      });
      String price = tempReview[5];
      String point = tempReview[6];
      /**** Get Model from String */
      PriceModel start_price = PriceModel.fromMap(data: jsonDecode(price));
      LocationModel startPoint = LocationModel.fromMap(data: jsonDecode(point));
      UserModel? userModel = await service.getUser(userId);
      if (userModel != null) {
        await storeDataToLocal(
            key: AppLocalKeys.IS_LOGIN,
            value: true,
            type: StorableDataType.BOOL);
        await storeDataToLocal(
            key: AppLocalKeys.UID,
            value: userId,
            type: StorableDataType.String);

        AppProvider.of(context).setCurrentUser(userModel);
        AppProvider.of(context).setLogined(true);
        // AppProvider.of(context).setLoginType(LoginType.EMAIL);
        AppProvider.of(context).setScooterID(scooterId);
        AppProvider.of(context).setStartRideTime(startRideTime);
        AppProvider.of(context).setPriceModel(start_price);
        AppProvider.of(context).setStartPoint(startPoint);

        int reservationTime = await getDataInLocal(
            key: AppLocalKeys.RIDE_END_TIME, type: StorableDataType.INT);
        int remainTime =
            reservationTime - DateTime.now().millisecondsSinceEpoch;
        // if (remainTime > 0) {
        //   setState(() {
        //     // _totalRidetime = remainTime ~/ 1000;
        //     startTimer();
        //   });
        // } else {
        //   onDone();
        // }

        setState(() {
          isLoading = false;
          _setuserLocation = true;
          userLocation = currentLocation;
        });

        //go with start_price
      }

      // await service.getUser(userId).then((userModel) async {
      //   print("Login User Model");
      //   print(userModel);

      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    var appContext = AppProvider.of(context);

    // ["String user_id", "String scooter_totalRidetime_id", "DateTime startRidetime", "int ", "int _usedTime"

    if (appContext.lastUserLocation != null) {
      userLocation =
          userLocation == null ? appContext.lastUserLocation! : userLocation;
      _setuserLocation = true;
    }
    debugPrint("context loading: $isLoading");

    return new WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
          child: Scaffold(
            backgroundColor: Colors.white,
            key: _scaffoldKey,
            drawer: Drawer(
              child: MainMenu(
                pageIndex: -1,
              ),
            ),
            body: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Container(
                    child: Stack(children: <Widget>[
                      if (_setuserLocation && userLocation != null)
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            onMapReady: () {
                              setState(() {
                                isMapReady = true;
                              });
                            },
                            center: LatLng(userLocation!.latitude,
                                userLocation!.longitude),
                            zoom: 15,
                            maxZoom: 18,
                            minZoom: 3,
                            interactiveFlags: InteractiveFlag.pinchZoom |
                                InteractiveFlag.drag,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: AppConstants.urlTemplate,
                              tileProvider: CachedNetworkTileProvider(),
                            ),
                            PolygonLayer(polygons: polygon),
                            MarkerLayer(markers: [
                              Marker(
                                width: 50.0,
                                height: 50.0,
                                point: LatLng(userLocation!.latitude,
                                    userLocation!.longitude),
                                builder: (ctx) => Transform.rotate(
                                  angle: _getHeadingFromBearing(
                                      userLocation!.heading),
                                  child: Container(
                                    child: InkWell(
                                      onTap: () async {
                                        // show No Ride Zone Dialog

                                        // showNoRideDialog(context);
                                      },
                                      child: Stack(children: <Widget>[
                                        Image.asset(
                                            'assets/images/user_marker.png'),
                                      ]),
                                    ),
                                  ),
                                ),
                              ),
                            ])
                          ],
                        ),
                      Row(
                        children: <Widget>[
                          if (showProgressBar)
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(left: 10),
                                margin: const EdgeInsets.only(
                                  top: 45,
                                  right: 10,
                                ),
                                height: 45,
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: OutlinedButton.icon(
                                  icon: Container(
                                      child: Image.asset(
                                          'assets/images/RideInProgressIcon.png')),
                                  label: Text(
                                    inProgress
                                        ? AppLocalizations.of(context)
                                            .rideProgress
                                        : AppLocalizations.of(context)
                                            .ridePause,
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16.0,
                                        fontFamily: 'Montserrat-SemiBold',
                                        fontWeight: FontWeight.w400),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    textStyle: TextStyle(color: Colors.grey),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          MediaQuery.of(context).size.width *
                                              0.025),
                                      side:
                                          const BorderSide(color: Colors.white),
                                    ),
                                  ),
                                  onPressed: () {
                                    // showBottomDialog(
                                    //     img1: 'assets/images/stilltime.png',
                                    //     title: 'You still have time',
                                    //     subtitle:
                                    //         'You\'re about to end this ride with time remaining. You won\'t be reimbursed for unused time. Please',
                                    //     btntxt: 'Confirm End Ride',
                                    //     onTap: () {
                                    //       return Navigator.of(context).pop();
                                    //     });
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () => moveToUserLocation(),
                                child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 12, bottom: 12),
                                    alignment: Alignment.bottomRight,
                                    width: 120,
                                    height: 60,
                                    child: Image.asset(
                                        'assets/images/zoomimg.png')),
                              )
                            ],
                          ),
                          //0000000000000000000000000000000000000000000
                          Container(
                            margin: const EdgeInsets.all(16),
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  flex: 12,
                                  child: Container(
                                    // margin: EdgeInsets.all(14),
                                    child: BatteryStatus(),
                                  ),
                                ),
                                SizedBox(width: 10),
                                SizedBox(width: 10),
                                Expanded(
                                  flex: 9,
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: Column(
                                      children: [
                                        Container(
                                          child: Image.asset(
                                            'assets/images/timericon.png',
                                            width: 24,
                                            height: 24,
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(
                                            top: 10,
                                          ),
                                          child: CountUpTimer(
                                            time_value: _usedTime,
                                            textStyle: TextStyle(
                                              fontFamily: FontStyles.fMedium,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            color: Colors.white,
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 10, bottom: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                          child: Image.asset(
                                        'assets/images/scooter.png',
                                        width: 30,
                                        height: 30,
                                      )),
                                      Container(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: Container(
                                            height: 30,
                                            padding: const EdgeInsets.only(
                                                left: 10,
                                                top: 5,
                                                right: 10,
                                                bottom: 5),
                                            color: Colors.grey[300],
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 5),
                                                  child: Text(
                                                      "#${appContext.scooterID}",
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontFamily: FontStyles
                                                              .fMedium,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Color.fromRGBO(
                                                              102,
                                                              102,
                                                              102,
                                                              1))),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 14, bottom: 10, right: 14),
                                  child: Divider(
                                    color: Colors.grey[400],
                                  ),
                                ),
                                Row(
                                  children: [
                                    PrimaryButton(
                                        width:
                                            HelperUtility.screenWidth(context) *
                                                0.5,
                                        context: context,
                                        margin: EdgeInsets.only(bottom: 30),
                                        color: Colors.white,
                                        txtColor: ColorConstants.cTxtColor2,
                                        onTap: () async {
                                          await inProgress
                                              ? onPause()
                                              : onResume();
                                        },
                                        title: inProgress
                                            ? AppLocalizations.of(context).lock
                                            : AppLocalizations.of(context)
                                                .unlock,
                                        icon: Image.asset(
                                          inProgress
                                              ? 'assets/images/lock.png'
                                              : 'assets/images/unlock.png',
                                          width: 25,
                                        ),
                                        borderColor: Colors.grey[400]),
                                    PrimaryButton(
                                      width:
                                          HelperUtility.screenWidth(context) *
                                              0.5,
                                      context: context,
                                      margin: EdgeInsets.only(bottom: 30),
                                      onTap: () async {
                                        await onEndRide();
                                      },
                                      title:
                                          AppLocalizations.of(context).endRide,
                                      icon: Container(
                                        child: Image.asset(
                                          'assets/images/endride.png',
                                          width: 30,
                                          height: 30,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ),
          ),
        ));
  }
}
