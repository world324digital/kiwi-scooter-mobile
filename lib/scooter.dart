import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'Helpers/constant.dart';
import 'Pages/MenuPage/main_menu.dart';

class Scotter extends StatefulWidget {
  @override
  _ScotterState createState() => _ScotterState();
}

class _ScotterState extends State<Scotter> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final mapStyleId = AppConstants.mapBoxStyleId;
  final mapBoxAccessToken = AppConstants.mapBoxAccessToken;
  final username = AppConstants.username;
  String _reportText = '';
  int resevePossibility = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: MainMenu(),
      ),
      body: Container(
          child: Stack(children: <Widget>[
        FlutterMap(
          options:
              MapOptions(center: LatLng(-12.069783, -77.034057), zoom: 13.0),
          children: [
            TileLayer(
                urlTemplate:
                    'https://api.mapbox.com/styles/v1/${AppConstants.username}/${mapStyleId}/tiles/256/{z}/{x}/{y}@2x?access_token=${mapBoxAccessToken}'),
            MarkerLayer(markers: [
              Marker(
                  width: 50.0,
                  height: 50.0,
                  point: LatLng(-12.069783, -77.034057),
                  builder: (ctx) => Container(
                          child: Stack(children: <Widget>[
                        Image.asset('assets/images/user_marker.png'),
                      ])
                          //   child: Container(
                          // child: Icon(
                          //   Icons.location_on,
                          //   color: Colors.blueAccent,
                          //   size: 40,
                          // ),
                          )),
              Marker(
                  width: 60,
                  height: 60,
                  point: LatLng(-12.073884, -77.038158),
                  builder: (ctx) => Container(
                          child: Stack(
                        children: <Widget>[
                          Image.asset(''
                              'assets/images/blackbike.png')
                        ],
                      ))),
              Marker(
                  width: 60,
                  height: 60,
                  point: LatLng(-12.064884, -77.028158),
                  builder: (ctx) => Container(
                          child: Stack(
                        children: <Widget>[
                          Image.asset(''
                              'assets/images/bikemarker.png')
                        ],
                      ))),
              Marker(
                  width: 60,
                  height: 60,
                  point: LatLng(-12.060884, -77.020158),
                  builder: (ctx) => Container(
                          child: Stack(
                        children: <Widget>[
                          Image.asset(''
                              'assets/images/bikemarker.png')
                        ],
                      ))),
              Marker(
                  width: 50.0,
                  height: 50.0,
                  point: LatLng(-12.079783, -77.014057),
                  builder: (ctx) => Container(
                          child: Stack(children: <Widget>[
                        Image.asset('assets/images/redbike.png'),
                      ])
                          //   child: Container(
                          // child: Icon(
                          //   Icons.location_on,
                          //   color: Colors.blueAccent,
                          //   size: 40,
                          // ),
                          )),
              Marker(
                  width: 50.0,
                  height: 50.0,
                  point: LatLng(-12.059783, -77.034057),
                  builder: (ctx) => Container(
                          child: Stack(children: <Widget>[
                        Image.asset('assets/images/redbike.png'),
                      ])
                          //   child: Container(
                          // child: Icon(
                          //   Icons.location_on,
                          //   color: Colors.blueAccent,
                          //   size: 40,
                          // ),
                          )),
              Marker(
                  width: 50.0,
                  height: 50.0,
                  point: LatLng(-12.08783, -77.024057),
                  builder: (ctx) => Container(
                          child: Stack(children: <Widget>[
                        Image.asset('assets/images/midbike.png'),
                      ])
                          //   child: Container(
                          // child: Icon(
                          //   Icons.location_on,
                          //   color: Colors.blueAccent,
                          //   size: 40,
                          // ),
                          )),
              Marker(
                  width: 100,
                  height: 100,
                  point: LatLng(-12.08783, -77.034057),
                  builder: (ctx) => Container(
                          child: Stack(children: <Widget>[
                        Positioned(
                            left: 35,
                            top: 5,
                            child: Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: ColorConstants.cPrimaryBtnColor),
                              child: Text(
                                '5',
                                style: TextStyle(
                                    fontSize: 24.0,
                                    color: Colors.white,
                                    fontFamily: 'Montserrat'),
                              ),
                            )),
                        Image.asset(
                            width: 50.0,
                            height: 50.0,
                            'assets/images/midbike.png'),
                      ])
                          //   child: Container(
                          // child: Icon(
                          //   Icons.location_on,
                          //   color: Colors.blueAccent,
                          //   size: 40,
                          // ),
                          )),
              Marker(
                  width: 100,
                  height: 100,
                  point: LatLng(-12.08783, -77.014057),
                  builder: (ctx) => Container(
                          child: Stack(children: <Widget>[
                        Positioned(
                            left: 35,
                            top: 5,
                            child: Container(
                              alignment: Alignment.center,
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: ColorConstants.cPrimaryBtnColor),
                              child: Text(
                                '15',
                                style: TextStyle(
                                    fontSize: 24.0,
                                    color: Colors.white,
                                    fontFamily: 'Montserrat'),
                              ),
                            )),
                        Image.asset(
                            width: 50.0,
                            height: 50.0,
                            'assets/images/midbike.png'),
                      ])
                          //   child: Container(
                          // child: Icon(
                          //   Icons.location_on,
                          //   color: Colors.blueAccent,
                          //   size: 40,
                          // ),
                          ))
            ])
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
                margin: const EdgeInsets.only(top: 32, right: 20),
                width: 120,
                height: 60,
                child: Image.asset('assets/images/logo.png'))
          ],
        ),
        Row(
          children: <Widget>[
            Container(
                alignment: Alignment.topLeft,
                margin: const EdgeInsets.only(top: 32, left: 12),
                width: 120,
                height: 60,
                child: Image.asset('assets/images/menuimg.png'))
          ],
        ),
        Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                  margin: const EdgeInsets.only(right: 12, bottom: 12),
                  alignment: Alignment.bottomRight,
                  width: 120,
                  height: 60,
                  child: Image.asset('assets/images/zoomimg.png'))
            ],
          ),
          Container(
              margin: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(children: [
                Container(
                  child: Image.asset('assets/images/clearbike.png'),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text('Kiwi eScooter',
                            style: TextStyle(fontSize: 20)),
                      ),
                      Container(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Text('#KW0001',
                            style: TextStyle(color: Colors.grey)),
                      ),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.only(right: 10),
                          child: Image.asset('assets/images/bar.png'),
                        ),
                        Text('84km (92%)')
                      ]),
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 15),
                            padding: const EdgeInsets.only(
                                left: 10, top: 8, right: 10, bottom: 8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey)),
                            child: Row(
                              children: [
                                Image.asset('assets/images/bell.png'),
                                GestureDetector(
                                  onTap: () {
                                    showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                        alignment: Alignment.bottomLeft,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(32.0))),
                                        contentPadding: EdgeInsets.only(
                                            left: 20.0, right: 20, top: 20),
                                        content: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.9,
                                            height: 210,
                                            // width: double.infinity,
                                            child: Column(
                                              children: [
                                                Container(
                                                  child: Image.asset(
                                                      'assets/images/ringbike.png'),
                                                ),
                                                Container(
                                                  child: Text(
                                                    'eScooter is Ringing',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontFamily:
                                                            'Montserrat-Medium'),
                                                  ),
                                                )
                                              ],
                                            )),
                                        actions: <Widget>[
                                          Container(
                                            width: double.infinity,
                                            alignment: Alignment.center,
                                            margin: const EdgeInsets.only(
                                                left: 10,
                                                right: 10,
                                                bottom: 10),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                color: Colors.red),
                                            child: TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, 'OK'),
                                              child: const Text(
                                                'Stop Ringing',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily:
                                                        'Montserrat-Bold',
                                                    fontSize: 16),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      'Ring',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                              margin: const EdgeInsets.only(left: 10, top: 15),
                              padding: const EdgeInsets.only(
                                  top: 8, right: 10, bottom: 8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Color.fromRGBO(255, 122, 117, 1))),
                              child: Row(children: [
                                GestureDetector(
                                  onTap: () {
                                    showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                        alignment: Alignment.bottomLeft,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(32.0))),
                                        contentPadding: EdgeInsets.only(
                                            left: 20.0, right: 20, top: 20),
                                        content: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.9,
                                            height: 120,
                                            // width: double.infinity,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 20),
                                                  child: Text('Report Scooter',
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 20,
                                                          fontFamily:
                                                              'Montserrat-SemiBold')),
                                                ),
                                                Container(
                                                  width: double.infinity,
                                                  margin: const EdgeInsets.only(
                                                      bottom: 10),
                                                  child: TextField(
                                                    decoration: InputDecoration(
                                                      hintStyle: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Montserrat-Medium'),
                                                      hintText:
                                                          'Please tell us what\'s wrong',
                                                      border: OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .black),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15.0)),
                                                    ),
                                                    autocorrect: false,
                                                    keyboardType:
                                                        TextInputType.name,
                                                    textInputAction:
                                                        TextInputAction.next,
                                                    onChanged: (text) {
                                                      setState(() {
                                                        _reportText = text;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            )),
                                        actions: <Widget>[
                                          Container(
                                            width: double.infinity,
                                            alignment: Alignment.center,
                                            margin: const EdgeInsets.only(
                                                left: 10,
                                                right: 10,
                                                bottom: 20),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                color: Color.fromRGBO(
                                                    52, 202, 52, 1)),
                                            child: TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, 'OK'),
                                              child: const Text(
                                                'Send Report',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 10),
                                    child: Image.asset(
                                        'assets/images/warning.png'),
                                  ),
                                ),
                              ]))
                        ],
                      )
                    ],
                  ),
                )
              ])),
          Container(
            padding: const EdgeInsets.only(top: 10),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 25),
                      padding: const EdgeInsets.only(
                          left: 15, top: 5, bottom: 5, right: 75),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/pay.png',
                            width: 20,
                            height: 20,
                          ),
                          Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Text(
                              'Payment',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ),
                          Image.asset('assets/images/arrow2.png')
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 30),
                      child: Row(
                        children: [
                          Image.asset('assets/images/promo.png'),
                          Container(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Text(
                              'Promo Code',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          Image.asset('assets/images/arrow2.png')
                        ],
                      ),
                    )
                  ],
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 5, left: 25, right: 25),
                  child: Container(
                    padding: const EdgeInsets.only(left: 20),
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(229, 249, 224, 1),
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: Color.fromRGBO(229, 249, 224, 1),
                        )),
                    child: Row(
                      children: [
                        Container(
                            child:
                                Image.asset('assets/images/exclamation.png')),
                        RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: '\&1.25',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                                TextSpan(
                                    text: ' for first 5 minute +',
                                    style: TextStyle(color: Colors.grey)),
                                TextSpan(
                                  text: '\&0.15 ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                                TextSpan(
                                  text: 'per minute ',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ))
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.only(left: 25, bottom: 0, right: 25),
                  child: ElevatedButton.icon(
                    icon: Container(
                        child: Image.asset(
                      'assets/images/whitebike.png',
                      width: 30,
                      height: 30,
                    )),
                    label: const Text('Ride Now',
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      textStyle: const TextStyle(
                          color: ColorConstants.cPrimaryBackColor, fontFamily: 'Montserrat'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        side: const BorderSide(
                            color: Colors.white),
                      ),
                    ),
                    onPressed: () {
                      if (resevePossibility == 1) {
                      } else {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            alignment: Alignment.bottomLeft,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(32.0))),
                            contentPadding:
                                EdgeInsets.only(left: 20.0, right: 20, top: 20),
                            content: Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                height: 100,
                                // width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding:
                                          const EdgeInsets.only(bottom: 20),
                                      child: Text('Unable to reserve'),
                                    ),
                                    Container(
                                      padding:
                                          const EdgeInsets.only(bottom: 20),
                                      child: Text(
                                          'You are too far from this vehicle and need to be closer to reserve it'),
                                    ),
                                  ],
                                )),
                            actions: <Widget>[
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(
                                    left: 10, right: 10, bottom: 20),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.white),
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context, 'OK'),
                                  child: const Text(
                                    'Got it',
                                    style: TextStyle(
                                        fontFamily: 'Montserrat-SemiBold',
                                        fontSize: 16,
                                        color: Colors.white),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      }
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => const QRViewExample()),
                      // );
                    },
                  ),
                ),
              ],
            ),
          ),
        ])
      ])),
    );
  }
}
