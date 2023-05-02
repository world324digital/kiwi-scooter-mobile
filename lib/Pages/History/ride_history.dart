import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Helpers/helperUtility.dart';
import 'package:KiwiCity/Models/location_model.dart';
import 'package:KiwiCity/Models/review_model.dart';
import 'package:KiwiCity/Pages/App/app_provider.dart';
import 'package:KiwiCity/Routes/routes.dart';
import 'package:KiwiCity/Services/firebase_service.dart';
import 'package:KiwiCity/Pages/History/ride_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_api/mapbox_api.dart';
import '../MenuPage/main_menu.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RideHistory extends StatefulWidget {
  const RideHistory({super.key});

  @override
  State<RideHistory> createState() => _RideHistory();
}

class _RideHistory extends State<RideHistory> {
  List<ReviewModel> _reviews = [];
  List<Widget> reviewWidget = [];
  bool isLoading = true;
  bool isError = false;
  bool isMapReady = false;
  List<LatLng> points = [];
  List pointList = [];
  final mapbox = MapboxApi(
    accessToken: AppConstants.mapBoxAccessToken,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<ReviewModel>> getReviews(String userId) async {
    FirebaseService service = FirebaseService();
    _reviews = await service.getReviews(userId);
    return _reviews;
  }

  Widget Item({
    required BuildContext context,
    required ReviewModel review,
    // required List<LatLng> points,
  }) {
    // LocationModel? startPoint = review.startPoint;
    // LocationModel? endPoint = review.endPoint;
    String distanceForDisplay = "";

    // double distance = review.duration * AppConstants.scooterSpeedPerSeconds;
    double distance = review.distance;
    if (distance > 1000) {
      distance = distance / 1000;
      distanceForDisplay = distance.toString() + " km";
    } else {
      distanceForDisplay = distance.toString() + " m";
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.only(top: 5, left: 25, right: 25, bottom: 15),
      elevation: 3,
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RideDetail(
                data: {
                  "review": review,
                },
              ),
            ),
          );
          // HelperUtility.goPage(
          //     context: context,
          //     routeName: Routes.RIDE_DETAIL,
          //     arg: {"review": review});
        },
        child: Container(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(children: [
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(left: 25, top: 20),
              child: Text(
                HelperUtility.getFormattedTime(
                    DateTime.fromMillisecondsSinceEpoch(review.startTime),
                    "dd MMMM yyyy"),
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: FontStyles.fMedium,
                    fontWeight: FontWeight.w600,
                    color: ColorConstants.cPrimaryTitleColor),
              ),
            ),
            Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.only(left: 25, top: 10, bottom: 20),
                child: Row(
                  children: [
                    Text(
                      '\#${review.scooterId}',
                      style: TextStyle(
                          fontSize: 20,
                          color: ColorConstants.cPrimaryBtnColor,
                          fontFamily: 'Montserrat-Bold',
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '  \€${review.total_price}',
                      style: TextStyle(
                          fontSize: 20,
                          color: ColorConstants.cPrimaryTitleColor,
                          fontFamily: 'Montserrat-SemiBold',
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                )),
            Container(
                padding: const EdgeInsets.only(left: 20),
                child: Row(children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                          padding: const EdgeInsets.only(
                              left: 10, top: 5, right: 10, bottom: 5),
                          color: Colors.grey[300],
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/clockdetail.png',
                                width: 15,
                                height: 15,
                                color: const Color(0xff666666),
                              ),
                              Container(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                    HelperUtility.getDayFromSeconds(
                                        review.duration),
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Montserrat-SemiBold',
                                        color:
                                            Color.fromRGBO(102, 102, 102, 1))),
                              )
                            ],
                          ))),
                  Container(
                    padding: const EdgeInsets.only(left: 10),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                            padding: const EdgeInsets.only(
                                left: 10, top: 5, right: 10, bottom: 5),
                            color: Colors.grey[300],
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(distanceForDisplay,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Montserrat-SemiBold',
                                          fontWeight: FontWeight.w600,
                                          color: Color.fromRGBO(
                                              102, 102, 102, 1))),
                                )
                              ],
                            ))),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 10, top: 5, right: 10, bottom: 5),
                        color: Colors.grey[300],
                        child: Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(),
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                  HelperUtility.getFormattedTime(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          review.startTime),
                                      "kk:mm"),
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: 'Montserrat-SemiBold',
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromRGBO(102, 102, 102, 1))),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ]))
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        color: Colors.white,
        child: Scaffold(
            drawer: Drawer(
              child: MainMenu(pageIndex: 1),
            ),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: const Color(0xffB5B5B5),
                ),
              ),
              title: Text(
                AppLocalizations.of(context).rideHistory,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Montserrat-SemiBold',
                  fontWeight: FontWeight.w600,
                  color: ColorConstants.cPrimaryTitleColor,
                  height: 1.4,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            body: Column(
              children: [
                Expanded(
                  // child: ListView(
                  //   children: reviewWidget,
                  // ),
                  child: FutureBuilder(
                      future:
                          getReviews(AppProvider.of(context).currentUser.id),
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.connectionState ==
                            ConnectionState.done) {
                          return Container(
                            child: ListView.builder(
                                itemCount: snapshot.data.length,
                                scrollDirection: Axis.vertical,
                                itemBuilder: (BuildContext context, int index) {
                                  // return Text(
                                  //     '${snapshot.data[index].card_number}');
                                  return Item(
                                    context: context,
                                    review: snapshot.data[index],
                                  );
                                  // points: pointList[index],);
                                }),
                          );
                        } else {
                          return Text(
                            AppLocalizations.of(context).noHistory,
                            style: TextStyle(fontSize: 20),
                          );
                        }
                      }),
                ),
              ],
            )
            // : Center(
            //     child: Text(
            //       "NO HISTORY",
            //       style: TextStyle(fontSize: 20),
            //     ),
            //   ),
            ),
      ),
    );
  }
}
