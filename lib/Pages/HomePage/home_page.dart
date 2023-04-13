import 'dart:async';
import 'dart:math';

import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Helpers/helperUtility.dart';
import 'package:KiwiCity/Helpers/local_storage.dart';
import 'package:KiwiCity/Models/scooterObject.dart';
import 'package:KiwiCity/Pages/App/app_provider.dart';
import 'package:KiwiCity/Pages/MenuPage/main_menu.dart';
import 'package:KiwiCity/Routes/routes.dart';
import 'package:KiwiCity/Widgets/CachedNetworkTileProvider.dart';
import 'package:KiwiCity/Widgets/batteryBar.dart';
import 'package:KiwiCity/Widgets/primaryButton.dart';
import 'package:KiwiCity/Widgets/toast.dart';
import 'package:KiwiCity/Widgets/unableAlert.dart';
import 'package:KiwiCity/services/httpService.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
// import 'package:openstreetmap/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_api/mapbox_api.dart';
import 'package:permission_handler/permission_handler.dart' as PM;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // final mapStyleId = AppConstants.mapBoxStyleId;
  // final mapBoxAccessToken = AppConstants.mapBoxAccessToken;
  final username = AppConstants.username;
  final db = FirebaseFirestore.instance;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var markers = <Marker>[];
  List<scooterObject> markerObject = [];

  late final MapController _mapController;

  TextEditingController reportTxtCtl = TextEditingController();

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  final formKey = GlobalKey<FormState>();

  bool isReportError = false;

  /***********************************
   * @Auth: world.digital.dev@gmail.com
   * @Date: 2023.04.03
   * @Desc: Get User's Location Information
   */
  late Position userLocation;
  late Marker userLocationMarker;
  late Marker? statusMarker = null;
  bool _setuserLocation = false;
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;
  bool positionStreamStarted = false;

  //---- Selected Scooter-----------
  String _selectedScooterID = '0';
  String _selectedScooterImei = '0';
  bool _scooterSelected = false;
  late scooterObject _selectedScooter;
  List<LatLng> points = [];
  double distance = 0;
  bool showPolyine = false;

  bool isMapReady = false;

  bool isAllowLocation = false;

  String _authStatus = 'Unknown'; // For iOS
  // String _authStatus = "TrackingStatus.authorized"; // For Andriod

  /***********************************
   * @Auth: world.digital.dev@gmail.com
   * @Date: 2023.04.03)
   * @Desc: Get Scooters from Firebase at?
   */
  bool _alertShown = false;
  List<Polygon> polygon = [];
  Future<bool> getScooters() async {
    // db.collection('geofences').snapshots().listen((event) {
    //   print("=== ${event.docs}");

    //   polygon = event.docs
    //       .map((e) => Polygon(
    //             points: (e.data()['PointLists'] as List)
    //                 .map((e) => LatLng(e['lat'], e['long']))
    //                 .toList(),
    //             borderStrokeWidth: 2,
    //             borderColor: Colors.red,
    //             color: Colors.red.withOpacity(0.5),
    //           ))
    //       .toList();

    //   Geolocator.getPositionStream().listen((location) async {
    //     double lat = location.latitude;
    //     double lng = location.longitude;
    //     double minLat = double.infinity;
    //     double maxLat = -double.infinity;
    //     double minLng = double.infinity;
    //     double maxLng = -double.infinity;
    //     for (var i = 0; i < event.docs.length; i++) {
    //       for (var ii = 0;
    //           ii < (event.docs[i].data()['PointLists'] as List).length;
    //           ii++) {
    //         double _eLat =
    //             (event.docs[i].data()['PointLists'] as List)[ii]['lat'];
    //         double _eLng =
    //             (event.docs[i].data()['PointLists'] as List)[ii]['long'];
    //         minLat = min(minLat, _eLat);
    //         maxLat = max(maxLat, _eLat);
    //         minLng = min(minLng, _eLng);
    //         maxLng = max(maxLng, _eLng);
    //       }
    //     }
    //     if (lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng) {
    //       if (!_alertShown) {
    //         _alertShown = true;
    //         await showDialog<void>(
    //           context: context,
    //           builder: (BuildContext context) => NoRideDialog,
    //         );
    //         _alertShown = false;
    //       }
    //     }
    //   });
    // });
    await db.collection('scooters').snapshots().listen((event) {
      for (var change in event.docChanges) {
        print(change.doc.data());
        switch (change.type) {
          case DocumentChangeType.added:
            markerObject.add(scooterObject(
              scooterID: change.doc.data()!['id'] ?? '',
              imei: change.doc.data()!['imei'] ?? '',
              address: change.doc.data()!['address'] ?? '',
              soc: change.doc.data()!['soc'] ?? 0,
              lat: change.doc.data()!['la'] ?? 0,
              lng: change.doc.data()!['lo'] ?? 0,
              status: change.doc.data()!['status'] ?? '',
            ));
            break;
          case DocumentChangeType.modified:
            print("Modified City: ${change.doc.data()}");
            markerObject.removeWhere(
                (element) => element.scooterID == change.doc.data()!['id']);
            print(change.doc.data());
            markerObject.add(scooterObject(
              scooterID: change.doc.data()!['id'] ?? '',
              imei: change.doc.data()!['imei'] ?? '',
              address: change.doc.data()!['address'] ?? '',
              soc: change.doc.data()!['soc'] ?? 0,
              lat: change.doc.data()!['la'] ?? 0,
              lng: change.doc.data()!['lo'] ?? 0,
              status: change.doc.data()!['status'] ?? '',
            ));
            break;
          case DocumentChangeType.removed:
            print("Removed City: ${change.doc.data()}");
            markerObject
                .removeWhere((element) => element.imei == change.doc.id);
            break;
        }
      }

      /**********************
       * Display Scooter Markers
       */
      var tempmarkers = <Marker>[];
      markerObject.forEach((element) {
        // int battery = int.parse(element.b.toString());
        int battery = element.soc;
        if ((element.lat != 0) &&
            (element.lng != 0) &&
            // element.inuse != 'true') {
            element.status == 'available') {
          print("-----------");
          print(
              ":::::: Scooter Position ::::: ${element.lat} , ${element.lng}, abc , ${element.status}, ${element.scooterID}");
          tempmarkers.add(showMarker(scooter: element));
        }
      });
      print("***** Temp Markers ******");
      print(tempmarkers);
      print(tempmarkers.length);
      setState(() {
        markers = tempmarkers;
      });
    });
    return false;
  }

  /********************
   * Get Scooter Image
   */
  Widget getScooter({required scooterObject scooter}) {
    // int battery = int.parse(scooter.b.toString());
    int battery = scooter.soc;

    late Widget scooterImage;
    if (_selectedScooterID != scooter.scooterID) {
      if (battery > 65)
        scooterImage = Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/greenscooter.png'),
                fit: BoxFit.fill),
          ),
        );
      else if (battery > 35)
        scooterImage = Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/yellowscooter.png'),
                fit: BoxFit.fill),
          ),
        );
      else
        scooterImage = Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/redscooter.png'),
                fit: BoxFit.fill),
          ),
        );
    } else {
      if (battery > 65)
        scooterImage = Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/selectedbike.png'),
                fit: BoxFit.fill),
          ),
        );
      else if (battery > 35)
        scooterImage = Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/selectedbike.png'),
                fit: BoxFit.fill),
          ),
        );
      else
        scooterImage = Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/selectedbike.png'),
                fit: BoxFit.fill),
          ),
        );
    }
    return scooterImage;
  }

  /****************************
   * @world324digtal
   * @2022.04.03
   * @Draw Map Scooter Marker
   */
  showMarker({required scooterObject scooter}) {
    return Marker(
      height: 60,
      width: 60,
      // point: new LatLng(double.parse(scooter.lat), double.parse(scooter.lng)),
      point: new LatLng(scooter.lat + 0.00005, scooter.lng - 0.00005),
      builder: (ctx) => Container(
        child: Stack(
          children: <Widget>[
            GestureDetector(
              onTap: () async {
                if (!isMapReady) {
                  print(":::::::::::::::: Map Is NOt Ready!!!");
                  const snackBar = SnackBar(
                    content: Text('Map is not ready yet.'),
                  );

                  // Find the ScaffoldMessenger in the widget tree
                  // and use it to show a SnackBar.
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  return;
                }

                //====== Check Distance ============
                // double dist = HelperUtility.getDistanceFromLatLonInKm(
                distance = Geolocator.distanceBetween(
                    userLocation.latitude,
                    userLocation.longitude,
                    // double.parse(scooter.lat),
                    // double.parse(scooter.lat),
                    scooter.lat,
                    scooter.lng);
                print("DISTANCE::::::::::\r\n");
                print(distance);

                if (distance > 1000) {
                  reservePossibility = 0;
                  // await unableAlert(
                  //   context: context,
                  //   message: Messages.ERROR_UNABLE_FAR_AWAY,
                  // );
                  // return;z
                } else {
                  reservePossibility = 1;
                  setState(() {
                    showPolyine = true;
                  });
                  getRoute(
                    LatLng(userLocation.latitude, userLocation.longitude),
                    LatLng(
                      // double.parse(scooter.lat),
                      // double.parse(scooter.lng),
                      scooter.lat,
                      scooter.lng,
                    ),
                  );
                }

                // ========= Zoom out for Scooter Location ======
                _animatedMapMove(
                    // LatLng(double.parse(scooter.lat) - 0.002,
                    //     double.parse(scooter.lng)),
                    // 16);
                    LatLng(scooter.lat - 0.002, scooter.lng),
                    16);

                setState(
                  () {
                    _selectedScooter = scooter;

                    _selectedScooterID = scooter.scooterID;
                    _selectedScooterImei = scooter.imei;
                    // AppProvider.of(context)
                    //     .setScooter(scooter, isNotifiable: false);
                    _scooterSelected = true;
                    statusMarker = Marker(
                      width: 250,
                      height: 106,
                      anchorPos: AnchorPos.align(AnchorAlign.right),
                      // point: LatLng(double.parse(scooter.lat) - 0.0004,
                      //     double.parse(scooter.lng) - 0.0005),
                      point: LatLng(scooter.lat - 0.0004, scooter.lng - 0.0005),
                      builder: (ctx) => Container(
                        margin: const EdgeInsets.only(top: 70),
                        // height: 120,
                        color: Colors.transparent,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.fromLTRB(15, 3, 15, 3),
                              height: 36,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: ColorConstants.cPrimaryBtnColor,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset('assets/images/man.png'),
                                  Container(
                                    // padding: const EdgeInsets.only(left: 5),
                                    child: distance < 2400
                                        ? Text(
                                            '  ${(distance / 40).round()}min (${distance.round()}m) ',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontFamily: FontStyles.fMedium,
                                              fontWeight: FontWeight.w600,
                                              // overflow: TextOverflow.fade,
                                            ),
                                          )
                                        : Text(
                                            '  ${(distance / 2400).round()} hours (${(distance / 1000).round()}km) ',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontFamily: FontStyles.fMedium,
                                              fontWeight: FontWeight.w600,
                                              // overflow: TextOverflow.fade,
                                            ),
                                          ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );

                showScooterDetailModal();
              },
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [getScooter(scooter: scooter)],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /*****************************
   * Calculate Distance
   */
  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  int reservePossibility = 0;
  String _reportText = '';

  final mapbox = MapboxApi(
    accessToken: AppConstants.mapBoxAccessToken,
  );

  /******************************
   * @Auth: world324digital
   * @Date: 2023.04.05
   * @Desc: Get Route between user and selected scooter
   */
  Future<void> getRoute(LatLng userPos, LatLng destination) async {
    try {
      final response = await mapbox.directions.request(
        profile: NavigationProfile.CYCLING,
        overview: NavigationOverview.FULL,
        geometries: NavigationGeometries.GEOJSON,
        steps: true,
        coordinates: <List<double>>[
          <double>[
            userPos.latitude, // latitude
            userPos.longitude, // longitude
          ],
          <double>[
            destination.latitude, // latitude
            destination.longitude, // longitude
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
        print("Routes Data::::::> ${response.routes}");
        final route = response.routes![0];
        final eta = Duration(
          seconds: route.duration!.toInt(),
        );
        final legs = route.legs;
        print("Routes Data::::::> ${legs![0].steps!.length}");

        points = [];
        // setState(){
        //   points = [];
        // };
        for (var leg in legs!) {
          var steps = leg.steps;
          for (var element in steps!) {
            var maneuvar = element.maneuver;
            var startPoint = maneuvar?.location;
            var lng = startPoint?[0];
            var lat = startPoint?[1];
            print("${lat} , ${lng}");
            if (lat != null && lng != null) {
              points.add(LatLng(lat, lng));
            }
            // setState() {
            //   points.add(LatLng(lat!, lng!));
            // };
          }
        }
        distance = route.distance!;
        if (distance > 1000)
          reservePossibility = 0;
        else
          reservePossibility = 1;
        // print(route.distance.toString());
        // print(eta.toString());
      }
    } catch (e) {
      print("Get Route Error ::::> ${e}");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Can't get correct route. Please retry!")),
      );
    }
  }

  /******************************************
   * @Auth: world.digital.dev@gmail.com
   * @Date: 2023.04.03
   * @Desc: Show Bottom Sheet for Scooter Detail
   */
  void showScooterDetailModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.05),
      elevation: 0,
      constraints: BoxConstraints(
          minHeight: HelperUtility.screenHeight(context),
          maxHeight: HelperUtility.screenHeight(context)),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              width: HelperUtility.screenWidth(context),
              margin: EdgeInsets.only(left: 12, right: 10, bottom: 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () => moveToUserLocation(),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/zoomimg.png',
                        ),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ========= SCOOTER DETAIL PART ===============
            Container(
              margin: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
              padding: const EdgeInsets.symmetric(vertical: 20),
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Gray Dot
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: const Color(0xffEEEEEE),
                            borderRadius: BorderRadius.circular(5)),
                        width: 40,
                        height: 4,
                      )
                    ],
                  ),

                  Container(
                    padding: EdgeInsets.only(
                      top: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ======= SCOOTER IMAGE ==========
                        Container(
                          // height: 100,
                          // width: 100,
                          child: Image.asset(
                            'assets/images/clearbike.png',
                            // height: 100,
                            // width: 100,
                          ),
                        ),

                        // ========= SCOOTER INFORMATION ===========
                        Container(
                          margin: const EdgeInsets.only(left: 15),
                          width: ScreenUtil().screenWidth * 0.55,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyFont.text(
                                // _selectedScooter.g,
                                "Kiwi eScooter",
                                color: ColorConstants.cPrimaryTitleColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                lineHeight: 1.25,
                                fontFamily: FontStyles.fBold,
                              ),
                              Container(
                                width: ScreenUtil().screenWidth * 0.6,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: MyFont.text(
                                  "#${_selectedScooter.scooterID}",
                                  color: ColorConstants.cTxtColor2,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                  fontFamily: FontStyles.fLight,
                                ),
                              ),
                              Row(children: [
                                Image.asset(
                                  ((_selectedScooter.soc > 65)
                                      ? ImageConstants.HIGH_BATTERY
                                      : (_selectedScooter.soc > 35)
                                          ? ImageConstants.MIDDLE_BATTERY
                                          : ImageConstants.LOW_BATTERY),
                                  width: 25,
                                  height: 25,
                                ),
                                MyFont.text(
                                  " ${_selectedScooter.soc.toString()}%",
                                  color: ColorConstants.cPrimaryTitleColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: FontStyles.fLight,
                                )
                              ]),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  //======= RING BUTTON =========
                                  GestureDetector(
                                    onTap: () async {
                                      await sendRing();
                                    },
                                    child: Container(
                                      width: 90,
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(
                                        // horizontal: 10,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Color(0xffB5B5B5),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Image.asset('assets/images/bell.png'),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 10),
                                            child: Text(
                                              'Ring',
                                              style: TextStyle(
                                                color:
                                                    ColorConstants.cTxtColor2,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                fontFamily:
                                                    FontStyles.fSemiBold,
                                                height: 1.42,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),

                                  // ========== ALERT BUTTON ===========
                                  // InkWell(
                                  //   onTap: () {
                                  //     showModalBottomSheet<String>(
                                  //       backgroundColor: Colors.transparent,
                                  //       context: context,
                                  //       builder: (BuildContext context) =>
                                  //           Dialog(
                                  //         backgroundColor: Colors.transparent,
                                  //         alignment: Alignment.bottomCenter,
                                  //         elevation: 0,
                                  //         insetPadding: EdgeInsets.zero,
                                  //         child: Container(
                                  //           width: ScreenUtil().screenWidth,
                                  //           height:
                                  //               ScreenUtil().screenHeight * 0.4,
                                  //           child: Column(
                                  //             mainAxisAlignment:
                                  //                 MainAxisAlignment.end,
                                  //             children: [
                                  //               Container(
                                  //                 margin: EdgeInsets.only(
                                  //                     left: 15,
                                  //                     right: 15,
                                  //                     bottom: 20),
                                  //                 padding: EdgeInsets.fromLTRB(
                                  //                     20, 25, 20, 0),
                                  //                 decoration: BoxDecoration(
                                  //                   color: Colors.white,
                                  //                   borderRadius:
                                  //                       BorderRadius.circular(
                                  //                     24,
                                  //                   ),
                                  //                 ),
                                  //                 child: Column(
                                  //                   children: [
                                  //                     Container(
                                  //                       width: ScreenUtil()
                                  //                           .screenWidth,
                                  //                       padding:
                                  //                           const EdgeInsets
                                  //                                   .only(
                                  //                               bottom: 20),
                                  //                       child: MyFont.text(
                                  //                         'Report Scooter',
                                  //                         fontSize: 20,
                                  //                         fontWeight:
                                  //                             FontWeight.w600,
                                  //                       ),
                                  //                     ),
                                  //                     Form(
                                  //                       key: formKey,
                                  //                       child: Container(
                                  //                         width:
                                  //                             double.infinity,
                                  //                         // height: 500,
                                  //                         padding:
                                  //                             const EdgeInsets
                                  //                                     .only(
                                  //                                 bottom: 10),
                                  //                         child: TextFormField(
                                  //                           validator: (value) {
                                  //                             if (value ==
                                  //                                     null ||
                                  //                                 value
                                  //                                     .isEmpty) {
                                  //                               return 'Please enter some text';
                                  //                             }
                                  //                             return null;
                                  //                           },
                                  //                           controller:
                                  //                               reportTxtCtl,
                                  //                           decoration:
                                  //                               InputDecoration(
                                  //                             hintStyle: TextStyle(
                                  //                                 color: ColorConstants
                                  //                                     .cPrimaryTitleColor,
                                  //                                 fontSize: 14,
                                  //                                 fontWeight:
                                  //                                     FontWeight
                                  //                                         .w400,
                                  //                                 height: 1.42,
                                  //                                 fontFamily:
                                  //                                     FontStyles
                                  //                                         .fMedium),
                                  //                             hintText:
                                  //                                 'Please tell us what\'s wrong',
                                  //                             border: OutlineInputBorder(
                                  //                                 borderSide: BorderSide(
                                  //                                     color: Colors
                                  //                                         .black),
                                  //                                 borderRadius:
                                  //                                     BorderRadius
                                  //                                         .circular(
                                  //                                             15.0)),
                                  //                           ),
                                  //                           autocorrect: false,
                                  //                           keyboardType:
                                  //                               TextInputType
                                  //                                   .name,
                                  //                           textInputAction:
                                  //                               TextInputAction
                                  //                                   .next,
                                  //                           onChanged: (text) {
                                  //                             setState(() {
                                  //                               _reportText =
                                  //                                   text;
                                  //                               isReportError = !formKey
                                  //                                   .currentState!
                                  //                                   .validate();
                                  //                             });
                                  //                           },
                                  //                         ),
                                  //                       ),
                                  //                     ),
                                  //                     PrimaryButton(
                                  //                       margin: const EdgeInsets
                                  //                               .only(
                                  //                           left: 0,
                                  //                           right: 0,
                                  //                           bottom: 20),
                                  //                       width: double.infinity,
                                  //                       horizontalPadding: 0,
                                  //                       context: context,
                                  //                       onTap: () async {
                                  //                         if (formKey
                                  //                             .currentState!
                                  //                             .validate()) {
                                  //                           // If the form is valid, display a snackbar. In the real world,
                                  //                           // you'd often call a server or save the information in a database.
                                  //                           // ScaffoldMessenger.of(context)
                                  //                           //     .showSnackBar(
                                  //                           //   const SnackBar(
                                  //                           //       content: Text(
                                  //                           //           'Processing Data')),
                                  //                           // );
                                  //                           Navigator.pop(
                                  //                               context, 'OK');
                                  //                           await sendReportEmail(
                                  //                               _selectedScooterID,
                                  //                               // _selectedScooterImei,
                                  //                               reportTxtCtl
                                  //                                   .text);
                                  //                         }
                                  //                       },
                                  //                       title: "Send Report",
                                  //                     ),
                                  //                   ],
                                  //                 ),
                                  //               ),
                                  //             ],
                                  //           ),
                                  //         ),
                                  //       ),
                                  //     );
                                  //   },
                                  //   child: Container(
                                  //     width: 48,
                                  //     height: 40,
                                  //     margin: const EdgeInsets.only(left: 10),
                                  //     padding: const EdgeInsets.only(
                                  //         top: 8, right: 10, bottom: 8),
                                  //     decoration: BoxDecoration(
                                  //       borderRadius: BorderRadius.circular(12),
                                  //       border: Border.all(
                                  //         color: Color(0xffFF7A75),
                                  //       ),
                                  //     ),
                                  //     child: Row(
                                  //       mainAxisAlignment:
                                  //           MainAxisAlignment.center,
                                  //       crossAxisAlignment:
                                  //           CrossAxisAlignment.center,
                                  //       children: [
                                  //         Container(
                                  //           margin:
                                  //               const EdgeInsets.only(left: 10),
                                  //           child: Image.asset(
                                  //               'assets/images/warning.png'),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // )
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ========= PAYMENT PART =============
            Container(
              padding: const EdgeInsets.only(
                  // top: 15,
                  bottom: 25,
                  left: 15,
                  right: 15),
              color: Colors.white,
              child: Column(
                children: [
                  // ------ Price Description Row ---------
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: ColorConstants.cPrimaryShadowColor,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: ColorConstants.cPrimaryShadowColor,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Container(
                          //     child:
                          //         Image.asset('assets/images/exclamation.png')),
                          RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: '\€1 ',
                                    style: TextStyle(
                                      color: ColorConstants.cPrimaryTitleColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: FontStyles.fSemiBold,
                                      height: 1.67,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'before riding + ',
                                    style: TextStyle(
                                      color: ColorConstants.cTxtColor2,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: FontStyles.fLight,
                                      letterSpacing: 0.16,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '\€0.25 ',
                                    style: TextStyle(
                                      color: ColorConstants.cPrimaryTitleColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: FontStyles.fSemiBold,
                                      height: 1.67,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'per minute after riding',
                                    style: TextStyle(
                                      color: ColorConstants.cTxtColor2,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: FontStyles.fLight,
                                      letterSpacing: 0.16,
                                    ),
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ),
                  ),
                  PrimaryButton(
                    horizontalPadding: 0,
                    context: context,
                    // margin: EdgeInsets.only(bottom: 20),
                    onTap: () async {
                      if (reservePossibility == 1) {
                        var user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          // ====== If logined, go to payment page ====
                          bool granted = await PM.Permission.camera.isGranted;

                          print(granted);
                          if (granted) {
                            HelperUtility.goPage(
                              context: context,
                              routeName: Routes.QR_SCAN,
                            );
                          } else {
                            HelperUtility.goPage(
                                context: context,
                                routeName: Routes.ALLOW_CAMERA);
                          }
                        } else {
                          // ====== else go to login page
                          HelperUtility.goPage(
                              context: context, routeName: Routes.LOGIN);
                        }
                      } else {
                        await unableAlert(
                          context: context,
                          message: Messages.ERROR_UNABLE_FAR_AWAY,
                        );
                      }
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => const QRViewExample()),
                      // );
                    },
                    title: "Ride Now",
                    icon: Container(
                      child: Image.asset(
                        'assets/images/ridenowbike.png',
                        width: 30,
                        height: 30,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      },
    ).whenComplete(() {
      print(" close bottom dialog");
      setState(() {
        _scooterSelected = false;
        _selectedScooterID = '0';
        _selectedScooterID = '0';
        showPolyine = false;
      });
    });
  }

  /******************************************
   * @Auth: world.digital.dev@gmail.com
   * @Date: 2023.04.03
   * @Desc: Show Bottom Sheet for Scooter Detail
   */
  Future<void> sendReportEmail(String scooterID, String content) async {
    print(":::::::::::::::::::::::::: $content");

    // ------------ Show Progress Dialog ----------
    HelperUtility.showProgressDialog(context: context, key: _keyLoader);
    try {
      var res = await HttpService()
          .sendReportEmail(scooterID: scooterID, content: content);
      print(res['message']);

      //------------ Dismiss Progress Dialog  -------------------
      HelperUtility.closeProgressDialog(_keyLoader);

      if (res['result']) {
        setState(() {
          reportTxtCtl.text = "";
        });
        Alert.showMessage(
            type: TypeAlert.success,
            title: "SUCCESS",
            message: Messages.SUCCESS_SEND_REPORT);
      } else {
        Alert.showMessage(
            type: TypeAlert.error,
            title: "ERROR",
            message: res['message'] ?? Messages.ERROR_MSG);
      }
    } catch (e) {
      //------------ Dismiss Progress Dialog  -------------------
      HelperUtility.closeProgressDialog(_keyLoader);
      Alert.showMessage(
          type: TypeAlert.error, title: "ERROR", message: e.toString());
    }
  }

  /******************************************
   * @Auth: world.digital.dev@gmail.com
   * @Date: 2023.04.03
   * @Desc: Show Bottom Sheet for Scooter Detail
   */
  Future<void> sendRing() async {
    print("::::::::::::Send Ring :::::::::::::: $_selectedScooterImei");
    // ------------ Show Progress Dialog ----------
    // Dialogs.showLoadingDarkDialog(
    //   context: context,
    //   key: _keyLoader,
    //   title: "Please wait...",
    //   backgroundColor: Colors.white,
    //   indicatorColor: ColorConstants.cPrimaryBtnColor,
    //   textColor: ColorConstants.cPrimaryTitleColor,
    // );
    try {
      var res = await HttpService().sendRing(scooterImei: _selectedScooterImei);
      print(res['message']);
      //------------ Dismiss Progress Dialog  -------------------
      // Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
      if (res['result']) {
        showRingDialog();
      } else {
        Alert.showMessage(
            type: TypeAlert.success,
            title: "ERROR",
            message: res['message'] ?? Messages.ERROR_MSG);
      }
    } catch (e) {
      print(e.toString());
      //------------ Dismiss Progress Dialog  -------------------
      // Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
      unableAlert(
          error: e.toString(),
          message: Messages.ERROR_UNABLE_SCOOTER,
          context: context);
    }
  }

  /******************************************
   * @Auth: world.digital.dev@gmail.com
   * @Date: 2023.04.03
   * @Desc: Show Bottom Sheet for Scooter Detail
   */
  Future<void> stopRing() async {
    print("::::::::::::Stop Ringing :::::::::::::: $_selectedScooterImei");
    try {
      var res = await HttpService().stopRing(scooterImei: _selectedScooterImei);
      //------------ Dismiss Progress Dialog  -------------------
      // Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
      if (res['result']) {
        // showRingDialog();
      } else {
        Alert.showMessage(
            type: TypeAlert.success,
            title: "ERROR",
            message: res['message'] ?? Messages.ERROR_MSG);
      }
    } catch (e) {
      print(e.toString());
      //------------ Dismiss Progress Dialog  -------------------
      // Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
      unableAlert(
          error: e.toString(),
          message: Messages.ERROR_UNABLE_SCOOTER,
          context: context);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _mapController = MapController();
    Future.delayed(const Duration(seconds: 0), () async {
      await setUserLocationAndMarker();
      /***************** For iOS */
      // await checkTrackingPermission();

      /******************For Android **** */
      await checkPermission();
    });

    _toggleServiceStatusStream();
    _toggleListening();
    getScooters();
    _checkForInProgressRides();
    // getCurrentLocation();
  }

  double _getHeadingFromBearing(double bearing) {
    // Convert the bearing from degrees to radians
    double radians = bearing * (pi / 180);
    // Return the rotation angle in radians
    return radians;
  }

  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      print("ads");
      PM.PermissionStatus status;
      status = await PM.Permission.location.status;
      print("===============");
      print(status);

      if (!status.isPermanentlyDenied) {
        Position currentLocation = await Geolocator.getCurrentPosition();
        print(currentLocation.heading);
        AppProvider.of(context)
            .setLastUserLocation(currentLocation, isNotifiable: false);
        setState(() {
          isAllowLocation = true;
          userLocation = currentLocation;
          _setuserLocation = true;

          userLocationMarker = Marker(
            width: 50.0,
            height: 50.0,
            point: LatLng(currentLocation.latitude, currentLocation.longitude),
            builder: (ctx) => Transform.rotate(
              angle: _getHeadingFromBearing(currentLocation.heading),
              child: Container(
                  child: Stack(children: <Widget>[
                Image.asset('assets/images/user_marker.png'),
              ])),
            ),
          );
          AppProvider.of(context)
              .setUserMarker(userLocationMarker, isNotifiable: false);
        });
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _mapController.dispose();
    _serviceStatusStreamSubscription?.cancel();
    print("Position Stream HomePage End:::::::\r\n ");
    _positionStreamSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /*****************************
   * @Auth: world324digital
   * @Date: 2023.04.04
   * @Desc: Check Permission
   */
  Future<void> setUserLocationAndMarker() async {
    if (AppProvider.of(context).lastUserLocation != null &&
        AppProvider.of(context).userMarker != null) {
      setState(() {
        _setuserLocation = true;
        userLocation = AppProvider.of(context).lastUserLocation!;
        isAllowLocation = true;
        userLocationMarker = AppProvider.of(context).userMarker!;
      });
    }
  }

  Future<void> checkTrackingPermission() async {
    final TrackingStatus status =
        await AppTrackingTransparency.trackingAuthorizationStatus;
    setState(() => _authStatus = '$status');
    // if (status == TrackingStatus.denied) {
    //   requestAppTrackingPermission(context);
    // } else if (status == TrackingStatus.authorized) {
    await checkPermission();
    // }
  }

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
                        "NO RIDE ZONE",
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
                  "You can be fined for riding in this zone. This scooter will remain lock until you leave this zone.",
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

  /*****************************
   * @Auth: world324digital
   * @Date: 2023.04.04
   * @Desc: Check App Tracking Permission
   */

  Future<void> requestAppTrackingPermission(BuildContext context) async =>
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('WARNING'),
          content: const Text(
              'App Tracking Permission is denined!\r\n\r\nNeed to access your location tracking to find eScooter near you and to track your location while riding the eScooter. \r\n\r\nWould you go to Settings and allow it?'),
          actions: [
            TextButton(
              onPressed: () async {
                await PM.openAppSettings();
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                // await checkPermission();
              },
              child: const Text('Maybe Later'),
            ),
          ],
        ),
      );

  Future<void> checkPermission() async {
    // bool status = await allowLocation();
    PM.PermissionStatus status;
    status = await PM.Permission.location.status;
    print("===============");
    print(status);
    if (!status.isGranted) {
      print("here=====");
      _showPermissionDialog();
    } else {
      setState(() {
        isAllowLocation = true;
      });
    }
  }

  Future<void> requestAuthorize(BuildContext context) async =>
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('WARNING'),
          content: const Text(
              'App Tracking Permission is denined!\r\n\r\nNeed to access your location tracking to find eScooter near you and to track your location while riding the eScooter. \r\n\r\nWould you go to Settings and allow it?'),
          actions: [
            TextButton(
              onPressed: () async {
                await PM.openAppSettings();
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  isAllowLocation = false;
                });
              },
              child: const Text('Maybe Later'),
            ),
          ],
        ),
      );

  /*****************************
   * @Auth: world324digital
   * @Date: 2023.04.03
   * @Desc: Show permission Dialog when disalbe permission of location 
   */

  Future<void> _showPermissionDialog() async {
    Widget cancelButton = TextButton(
      child: Text("Maybe later"),
      onPressed: () {
        setState(() {
          isAllowLocation = false;
        });
        Navigator.of(context).pop();
      },
    );
    Widget okButton = TextButton(
      child: Text("Allow"),
      onPressed: () async {
        Navigator.of(context).pop();
        bool status = await PM.openAppSettings();
        // if (status) _showRestartDialog();
      },
    );
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Let \'s begin'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'We need to allow location permission so we can find a scooter near you.',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: FontStyles.fLight,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[cancelButton, okButton],
        );
      },
    );
  }

  /*****************************
   * @Auth: world324digital
   * @Date: 2023.04.03
   * @Desc: Restart app when set permissions of App
   */

  // Future<void> _showRestartDialog() async {
  //   Widget cancelButton = TextButton(
  //     child: Text("Maybe later"),
  //     onPressed: () {
  //       Navigator.of(context).pop();
  //     },
  //   );
  //   Widget okButton = TextButton(
  //     child: Text("Restart"),
  //     onPressed: () async {
  //       Navigator.of(context).pop();
  //       // await PM.openAppSettings();

  //       Phoenix.rebirth(context);
  //     },
  //   );
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: false, // user must tap button!
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Alert'),
  //         content: SingleChildScrollView(
  //           child: ListBody(
  //             children: const <Widget>[
  //               Text('If you changed permission, Pleast restart app'),
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[cancelButton, okButton],
  //       );
  //     },
  //   );
  // }

  /*****************************
   * @Auth: world324digital
   * @Date: 2023.04.03
   * @Desc: Enable/Disable User's Geolocation service 
   */
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

  /*****************************
   * @Auth: world324digital
   * @Date: 2023.04.03
   * @Desc: User's Geolocation Position Tracking 
   */
  void _toggleListening() {
    if (_positionStreamSubscription == null) {
      final positionStream = _geolocatorPlatform.getPositionStream();
      _positionStreamSubscription = positionStream.handleError((error) {
        _positionStreamSubscription?.cancel();
        _positionStreamSubscription = null;
      }).listen((position) => {
            print("Position Stream HomePage Start:::::::\r\n "),
            print(position.toString()),
            AppProvider.of(context)
                .setLastUserLocation(position, isNotifiable: false),
            if (mounted)
              {
                setState(() {
                  _setuserLocation = true;
                  userLocation = position;
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
                  AppProvider.of(context)
                      .setUserMarker(userLocationMarker, isNotifiable: false);
                }),
              }
          });
      _positionStreamSubscription?.pause();
    }

    setState(() {
      if (_positionStreamSubscription == null) {
        return;
      }

      String statusDisplayValue;
      if (_positionStreamSubscription!.isPaused) {
        _positionStreamSubscription!.resume();
        statusDisplayValue = 'resumed';
      } else {
        _positionStreamSubscription!.pause();
        statusDisplayValue = 'paused';
      }
    });
  }

  /*************************
   * @Auth: world324digital
   * @Date: 2023.04.03
   * @Desc: Go Back to User's Location on Map
   */
  void moveToUserLocation() {
    _animatedMapMove(LatLng(userLocation.latitude, userLocation.longitude), 16);
  }

  /********************************
   * @Auth: world324digital
   * @Date: 2023.04.06
   * @Desc: Show Stop Ring Dialog
   */
  void showRingDialog() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Container(
          width: ScreenUtil().screenWidth,
          height: ScreenUtil().screenHeight * 0.5,
          // width: double.infinity,
          padding: EdgeInsets.fromLTRB(15, 25, 15, 20),
          margin: EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                child: Image.asset('assets/images/ringbike.png'),
              ),
              Container(
                margin: EdgeInsets.only(top: 20, bottom: 40),
                child: MyFont.text(
                  'eScooter is Ringing',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              PrimaryButton(
                  context: context,
                  // onTap: () {
                  //   onPressed:
                  //   () => ({Navigator.pop(context, 'OK'), stopRing()});
                  // },
                  onTap: () {
                    Navigator.pop(context, 'OK');
                    stopRing();
                  },
                  title: "Stop Ringing",
                  borderColor: const Color(0xffFF525B),
                  color: const Color(0xffFF525B)),
              // Container(
              //   width: double.infinity,
              //   alignment: Alignment.center,
              //   margin: const EdgeInsets.only(left: 0, right: 0, bottom: 10),
              //   decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(15), color: Colors.red),
              //   child: TextButton(
              //     onPressed: () => Navigator.pop(context, 'OK'),
              //     child: MyFont.text('Stop Ringing',
              //         color: Colors.white,
              //         fontWeight: FontWeight.w700,
              //         fontSize: 16),
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
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
        duration: const Duration(milliseconds: 1000), vsync: this);
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

  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        drawer: Drawer(
          child: MainMenu(pageIndex: -1),
        ),
        body: Container(
          child: Stack(
            children: <Widget>[
              //========= Map  PART ============

              if (_setuserLocation && isAllowLocation)
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    onMapReady: () {
                      setState(() {
                        isMapReady = true;
                      });
                    },
                    center:
                        LatLng(userLocation.latitude, userLocation.longitude),
                    interactiveFlags:
                        InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                    zoom: 10,
                    maxZoom: 18,
                    minZoom: 1,

                    onTap: (tapPosition, point) {
                      setState(() {
                        debugPrint("onTap Location: ${point.toString()}");
                      });
                    },
                    // onMapEvent: (p0) {
                    //   print("here-------------");
                    //   print(p0.zoom);
                    // },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: AppConstants.urlTemplate,
                      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                      tileProvider: CachedNetworkTileProvider(),
                    ),
                    PolygonLayer(polygons: polygon),
                    showPolyine
                        ? PolylineLayer(
                            polylineCulling: true,
                            polylines: [
                              Polyline(
                                points: points,
                                strokeWidth: 4,
                                color: ColorConstants.cPrimaryBtnColor,
                                isDotted: true,
                                strokeJoin: StrokeJoin.bevel,
                              ),
                            ],
                          )
                        : Container(),
                    MarkerLayer(
                      markers: markers,
                    ),
                    MarkerLayer(
                      markers: <Marker>[userLocationMarker],
                    ),
                    if (_scooterSelected && isMapReady && statusMarker != null)
                      MarkerLayer(markers: <Marker>[statusMarker!])
                  ],
                )
              else if (!isAllowLocation)
                Container(
                  width: HelperUtility.screenWidth(context),
                  height: HelperUtility.screenHeight(context),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Map is not available",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontFamily: FontStyles.fLight,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "You may need to allow location permission to use map.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontFamily: FontStyles.fLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Center(
                  child: CircularProgressIndicator(
                      color: ColorConstants.cPrimaryBtnColor),
                ),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                      margin: const EdgeInsets.only(top: 40, right: 20),
                      width: 120,
                      height: 60,
                      child: Image.asset('assets/images/logo.png'))
                ],
              ),
              Row(
                children: <Widget>[
                  InkWell(
                    onTap: () => _scaffoldKey.currentState!.openDrawer(),
                    child: Container(
                        alignment: Alignment.topLeft,
                        margin: const EdgeInsets.only(top: 40, left: 12),
                        width: 120,
                        height: 60,
                        child: Image.asset('assets/images/menuimg.png')),
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_setuserLocation)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () => moveToUserLocation(),
                          child: Container(
                            margin:
                                const EdgeInsets.only(right: 12, bottom: 12),
                            alignment: Alignment.bottomRight,
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                  'assets/images/zoomimg.png',
                                ),
                                fit: BoxFit.fill,
                              ),
                            ),
                            // child: Image.asset(
                            //   'assets/images/zoomimg.png',
                            // ),
                          ),
                        )
                      ],
                    ),

                  // ===== Scan Ride Button ==========
                  Container(
                    margin: const EdgeInsets.only(bottom: 40),
                    child: PrimaryButton(
                      context: context,
                      onTap: () async {
                        _toggleListening();
                        bool isLogin = AppProvider.of(context).isLogin;
                        if (isLogin) {
                          bool granted = await PM.Permission.camera.isGranted;

                          print(granted);
                          if (granted) {
                            HelperUtility.goPage(
                              context: context,
                              routeName: Routes.QR_SCAN,
                            );
                          } else {
                            HelperUtility.goPage(
                                context: context,
                                routeName: Routes.ALLOW_CAMERA);
                          }
                        } else {
                          HelperUtility.goPage(
                              context: context, routeName: Routes.LOGIN);
                        }
                      },
                      title: "Scan to ride",
                      fontFamily: FontStyles.fBold,
                      icon: Container(
                        child: Image.asset(
                          'assets/images/scanimg.png',
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _checkForInProgressRides() async {
    if ((await HelperUtility.checkForInProgressRides(context))) {
      //   String _selectedScooterID = '0';
      // bool _scooterSelected = false;
      // late scooterObject _selectedScooter;
      // List<LatLng> points = [];
      // double distance = 0;

      // Here you have to add your logic to assign all the fields
      // so that ride can be in-progress

      // set the timer duration to endTime - DateTime.now()
      final endTime = await getDataInLocal(
        key: AppLocalKeys.RIDE_END_TIME,
        type: StorableDataType.INT,
      );

      final diff = DateTime.fromMillisecondsSinceEpoch(endTime)
          .difference(DateTime.now());

      final timerDuration = diff.inSeconds;

      // Its 2:45 AM here. I am really sleepy...
      // Okay, I will go to sleep.
      // Hopefully you will be able to figure the rest
      // Bye bye
      //So  can 't you resolve it?
      // I have implemented the logic to see if the ride is in progress
      // Just set the variables,
      // hello, tha main problem is not set in progress variable. The main proble is...
      //Anyway,  I think you need to r that
    }
  }
}
