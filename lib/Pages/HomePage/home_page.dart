import 'dart:async';
import 'dart:math';

import 'package:Move/Helpers/constant.dart';
import 'package:Move/Helpers/helperUtility.dart';
import 'package:Move/Helpers/local_storage.dart';
import 'package:Move/Models/scooterObject.dart';
import 'package:Move/Pages/App/app_provider.dart';
import 'package:Move/Pages/MenuPage/main_menu.dart';
import 'package:Move/Routes/routes.dart';
import 'package:Move/Widgets/CachedNetworkTileProvider.dart';
import 'package:Move/Widgets/batteryBar.dart';
import 'package:Move/Widgets/primaryButton.dart';
import 'package:Move/Widgets/toast.dart';
import 'package:Move/Widgets/unableAlert.dart';
import 'package:Move/services/httpService.dart';
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
   * @Auth: geniusdev0813@gmail.com
   * @Date: 2022.12.5
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

  //---- Selected Bike-----------
  String _selectedBikeID = '0';
  bool _bikeSelected = false;
  late scooterObject _selectedBike;
  List<LatLng> points = [];
  double distance = 0;
  bool showPolyine = false;

  bool isMapReady = false;

  bool isAllowLocation = false;

  String _authStatus = 'Unknown'; // For iOS
  // String _authStatus = "TrackingStatus.authorized"; // For Andriod

  /***********************************
   * @Auth: geniusdev0813@gmail.com
   * @Date: 2022.12.5)
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
              scooterID: change.doc.id ?? '',
              address: change.doc.data()!['address'] ?? '',
              b: change.doc.data()!['b'] ?? 0,
              c: change.doc.data()!['c'] ?? 0,
              g: change.doc.data()!['g'] ?? '',
              lat: change.doc.data()!['lat'] ?? '',
              lng: change.doc.data()!['lng'] ?? '',
              r: change.doc.data()!['r'] ?? 0,
              s: change.doc.data()!['s'] ?? 0,
              t: change.doc.data()!['t'] ?? 0,
              v: change.doc.data()!['v'] ?? 0,
              x: change.doc.data()!['x'] ?? 0,
              inuse: change.doc.data()!['inUse'] == null
                  ? 'false'
                  : change.doc.data()!['inUse']
                      ? 'true'
                      : 'false',
            ));
            break;
          case DocumentChangeType.modified:
            print("Modified City: ${change.doc.data()}");
            markerObject.removeWhere(
                (element) => element.scooterID == change.doc.data()!['i']);
            print(change.doc.data());
            markerObject.add(scooterObject(
              scooterID: change.doc.id ?? '',
              address: change.doc.data()!['address'] ?? '',
              b: change.doc.data()!['b'] ?? 0,
              c: change.doc.data()!['c'] ?? 0,
              g: change.doc.data()!['g'] ?? '',
              lat: change.doc.data()!['lat'] ?? '',
              lng: change.doc.data()!['lng'] ?? '',
              r: change.doc.data()!['r'] ?? 0,
              s: change.doc.data()!['s'] ?? 0,
              t: change.doc.data()!['t'] ?? 0,
              v: change.doc.data()!['v'] ?? 0,
              x: change.doc.data()!['x'] ?? 0,
              inuse: change.doc.data()!['inUse'] == null
                  ? 'false'
                  : change.doc.data()!['inUse']
                      ? 'true'
                      : 'false',
            ));
            break;
          case DocumentChangeType.removed:
            print("Removed City: ${change.doc.data()}");
            markerObject
                .removeWhere((element) => element.scooterID == change.doc.id);
            break;
        }
      }

      /**********************
       * Display Bike Markers
       */
      var tempmarkers = <Marker>[];
      markerObject.forEach((element) {
        int battery = int.parse(element.b.toString());
        if ((element.lat.isNotEmpty) &&
            (element.lng.isNotEmpty) &&
            element.inuse != 'true') {
          print(
              ":::::: Scooter Position ::::: ${element.lat} , ${element.lng}, abc , ${element.inuse}, ${element.scooterID}");
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
   * Get Bike Image
   */
  Widget getBike({required scooterObject scooter}) {
    int battery = int.parse(scooter.b.toString());

    late Widget bikeImage;
    if (_selectedBikeID != scooter.scooterID) {
      if (battery > 65)
        bikeImage = Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/bikemarker.png'),
                fit: BoxFit.fill),
          ),
        );
      else if (battery > 35)
        bikeImage = Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/greenbike.png'),
                fit: BoxFit.fill),
          ),
        );
      else
        bikeImage = Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/redbike.png'),
                fit: BoxFit.fill),
          ),
        );
    } else {
      if (battery > 65)
        bikeImage = Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/selectedbike.png'),
                fit: BoxFit.fill),
          ),
        );
      else if (battery > 35)
        bikeImage = Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/greenSelectedbike.png'),
                fit: BoxFit.fill),
          ),
        );
      else
        bikeImage = Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/redSelectedBike.png'),
                fit: BoxFit.fill),
          ),
        );
    }
    return bikeImage;
  }

  /****************************
   * @softwinner813
   * @2022.12.7
   * @Draw Map Scooter Marker
   */
  showMarker({required scooterObject scooter}) {
    return Marker(
      height: 60,
      width: 60,
      point: new LatLng(double.parse(scooter.lat), double.parse(scooter.lng)),
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
                    double.parse(scooter.lat),
                    double.parse(scooter.lng));
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
                      double.parse(scooter.lat),
                      double.parse(scooter.lng),
                    ),
                  );
                }

                // ========= Zoom out for Bike Location ======
                _animatedMapMove(
                    LatLng(double.parse(scooter.lat) - 0.002,
                        double.parse(scooter.lng)),
                    16);

                setState(
                  () {
                    _selectedBike = scooter;

                    _selectedBikeID = scooter.scooterID;
                    // AppProvider.of(context)
                    //     .setScooter(scooter, isNotifiable: false);
                    _bikeSelected = true;
                    statusMarker = Marker(
                      width: 250,
                      height: 106,
                      anchorPos: AnchorPos.align(AnchorAlign.right),
                      point: LatLng(double.parse(scooter.lat) - 0.0004,
                          double.parse(scooter.lng) - 0.0005),
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
                                color: Color.fromRGBO(52, 204, 52, 1),
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

                showBikeDetailModal();
              },
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [getBike(scooter: scooter)],
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
   * @Auth: Leopard
   * @Date: 2022.12.5
   * @Desc: Get Route between user and selected Bike
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
   * @Auth: geniusdev0813@gmail.com
   * @Date: 2022.12.5
   * @Desc: Show Bottom Sheet for Scooter Detail
   */
  void showBikeDetailModal() {
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

            // ========= BIKE DETAIL PART ===============
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
                        // ======= BIKE IMAGE ==========
                        Container(
                          // height: 100,
                          // width: 100,
                          child: Image.asset(
                            'assets/images/clearbike.png',
                            // height: 100,
                            // width: 100,
                          ),
                        ),

                        // ========= BIKE INFORMATION ===========
                        Container(
                          margin: const EdgeInsets.only(left: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyFont.text(
                                // _selectedBike.g,
                                "Move eScooter",
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
                                  // '#3451A - Christ Church',
                                  "#${_selectedBike.scooterID} ${_selectedBike.address.split(",")[0]}",
                                  color: ColorConstants.cTxtColor2,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                  fontFamily: FontStyles.fLight,
                                ),
                              ),
                              Row(children: [
                                BatteryBar(
                                    level:
                                        int.parse(_selectedBike.b.toString())),
                                MyFont.text(
                                  // '84km (92%)'
                                  " ${_selectedBike.b.toString()}%",
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
                                  InkWell(
                                    onTap: () {
                                      showModalBottomSheet<String>(
                                        backgroundColor: Colors.transparent,
                                        context: context,
                                        builder: (BuildContext context) =>
                                            Dialog(
                                          backgroundColor: Colors.transparent,
                                          alignment: Alignment.bottomCenter,
                                          elevation: 0,
                                          insetPadding: EdgeInsets.zero,
                                          child: Container(
                                            width: ScreenUtil().screenWidth,
                                            height:
                                                ScreenUtil().screenHeight * 0.4,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      left: 15,
                                                      right: 15,
                                                      bottom: 20),
                                                  padding: EdgeInsets.fromLTRB(
                                                      20, 25, 20, 0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      24,
                                                    ),
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        width: ScreenUtil()
                                                            .screenWidth,
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 20),
                                                        child: MyFont.text(
                                                          'Report Scooter',
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      Form(
                                                        key: formKey,
                                                        child: Container(
                                                          width:
                                                              double.infinity,
                                                          // height: 500,
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  bottom: 10),
                                                          child: TextFormField(
                                                            validator: (value) {
                                                              if (value ==
                                                                      null ||
                                                                  value
                                                                      .isEmpty) {
                                                                return 'Please enter some text';
                                                              }
                                                              return null;
                                                            },
                                                            controller:
                                                                reportTxtCtl,
                                                            decoration:
                                                                InputDecoration(
                                                              hintStyle: TextStyle(
                                                                  color: ColorConstants
                                                                      .cPrimaryTitleColor,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  height: 1.42,
                                                                  fontFamily:
                                                                      FontStyles
                                                                          .fMedium),
                                                              hintText:
                                                                  'Please tell us what\'s wrong',
                                                              border: OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: Colors
                                                                          .black),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15.0)),
                                                            ),
                                                            autocorrect: false,
                                                            keyboardType:
                                                                TextInputType
                                                                    .name,
                                                            textInputAction:
                                                                TextInputAction
                                                                    .next,
                                                            onChanged: (text) {
                                                              setState(() {
                                                                _reportText =
                                                                    text;
                                                                isReportError = !formKey
                                                                    .currentState!
                                                                    .validate();
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      PrimaryButton(
                                                        margin: const EdgeInsets
                                                                .only(
                                                            left: 0,
                                                            right: 0,
                                                            bottom: 20),
                                                        width: double.infinity,
                                                        horizontalPadding: 0,
                                                        context: context,
                                                        onTap: () async {
                                                          if (formKey
                                                              .currentState!
                                                              .validate()) {
                                                            // If the form is valid, display a snackbar. In the real world,
                                                            // you'd often call a server or save the information in a database.
                                                            // ScaffoldMessenger.of(context)
                                                            //     .showSnackBar(
                                                            //   const SnackBar(
                                                            //       content: Text(
                                                            //           'Processing Data')),
                                                            // );
                                                            Navigator.pop(
                                                                context, 'OK');
                                                            await sendReportEmail(
                                                                _selectedBikeID,
                                                                reportTxtCtl
                                                                    .text);
                                                          }
                                                        },
                                                        title: "Send Report",
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 48,
                                      height: 40,
                                      margin: const EdgeInsets.only(left: 10),
                                      padding: const EdgeInsets.only(
                                          top: 8, right: 10, bottom: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Color(0xffFF7A75),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 10),
                                            child: Image.asset(
                                                'assets/images/warning.png'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
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
                        color: Color.fromRGBO(229, 249, 224, 1),
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: Color.fromRGBO(229, 249, 224, 1),
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
                                    text: 'Ride for less than ',
                                    style: TextStyle(
                                      color: ColorConstants.cTxtColor2,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: FontStyles.fLight,
                                      letterSpacing: 0.16,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '\$0.25 ',
                                    style: TextStyle(
                                      color: ColorConstants.cPrimaryTitleColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: FontStyles.fSemiBold,
                                      height: 1.67,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' per minute',
                                    style: TextStyle(
                                      color: ColorConstants.cTxtColor2,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: FontStyles.fLight,
                                      letterSpacing: 0.16,
                                    ),
                                  ),
                                ],
                              ))
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
                        'assets/images/whitebike.png',
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
        _bikeSelected = false;
        _selectedBikeID = '0';
        showPolyine = false;
      });
    });
  }

  /******************************************
   * @Auth: geniusdev0813@gmail.com
   * @Date: 2022.12.5
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
   * @Auth: geniusdev0813@gmail.com
   * @Date: 2022.12.5
   * @Desc: Show Bottom Sheet for Scooter Detail
   */
  Future<void> sendRing() async {
    print("::::::::::::Send Ring :::::::::::::: $_selectedBikeID");
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
      var res = await HttpService().sendRing(scooterID: _selectedBikeID);
      print(res['message']);
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
          message: Messages.ERROR_UNABLE_BIKE,
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

  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      print("ads");
      PM.PermissionStatus status;
      status = await PM.Permission.location.status;
      print("===============");
      print(status);

      if (!status.isPermanentlyDenied) {
        Position currentLocation = await Geolocator.getCurrentPosition();
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
            builder: (ctx) => Container(
                child: Stack(children: <Widget>[
              Image.asset('assets/images/usermarker.png'),
            ])),
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
   * @Auth: Leopard
   * @Date: 2022.12.18
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
   * @Auth: Leopard
   * @Date: 2022.12.18
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
   * @Auth: Leopard
   * @Date: 2022.12.5
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
   * @Auth: Leopard
   * @Date: 2022.12.5
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
   * @Auth: geniusdev
   * @Date: 2022.12.5
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
   * @Auth: geniusdev
   * @Date: 2022.12.5
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
                  // position = LatLng(37.31936, 101.94528);
                  userLocationMarker = Marker(
                    width: 50.0,
                    height: 50.0,
                    point: LatLng(position.latitude, position.longitude),
                    builder: (ctx) => Container(
                        child: Stack(children: <Widget>[
                      Image.asset('assets/images/usermarker.png'),
                    ])),
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
   * @Auth: geniusdev
   * @Date: 2022.12.5
   * @Desc: Go Back to User's Location on Map
   */
  void moveToUserLocation() {
    _animatedMapMove(LatLng(userLocation.latitude, userLocation.longitude), 16);
  }

  /********************************
   * @Auth: geniusdev
   * @Date: 2022.12.6
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
          height: ScreenUtil().screenHeight * 0.45,
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
                  onTap: () {
                    onPressed:
                    () => Navigator.pop(context, 'OK');
                  },
                  title: "Stop Ringing",
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
                    zoom: 3,
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
                                  isDotted: true),
                            ],
                          )
                        : Container(),
                    MarkerLayer(
                      markers: markers,
                    ),
                    MarkerLayer(
                      markers: <Marker>[userLocationMarker],
                    ),
                    if (_bikeSelected && isMapReady && statusMarker != null)
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
                  child: CircularProgressIndicator(color: Colors.green),
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
      //   String _selectedBikeID = '0';
      // bool _bikeSelected = false;
      // late scooterObject _selectedBike;
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
