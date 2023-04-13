import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Helpers/helperUtility.dart';
import 'package:KiwiCity/Models/location_model.dart';
import 'package:KiwiCity/Models/review_model.dart';
import 'package:KiwiCity/Pages/App/app_provider.dart';
import 'package:KiwiCity/Services/firebase_service.dart';
import 'package:KiwiCity/Pages/PaymentPage/payment_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_api/mapbox_api.dart';

class RideDetail extends StatefulWidget {
  RideDetail({super.key, required this.data});
  dynamic data;

  @override
  State<RideDetail> createState() => _RideDetail();
}

class _RideDetail extends State<RideDetail> {
  List<LatLng> points = [];

  final mapbox = MapboxApi(
    accessToken: AppConstants.mapBoxAccessToken,
  );

  FirebaseService service = FirebaseService();
  @override
  void initState() {
    super.initState();
    getPoints();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getPoints() async {
    ReviewModel _review = widget.data["review"];
    String? reviewId = _review.id;
    List<dynamic> route_points = await service.getPoints(reviewId);
    points = await getRoute(route_points);
    setState(() {});
  }

  Future<List<LatLng>> getRoute(List<dynamic> route_points) async {
    try {
      route_points.forEach((point) {
        points.add(LatLng(point["lat"], point["long"]));
      });
      return points;
    } catch (e) {
      print("Get Route Error ::::> ${e}");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Can't get correct route. Please retry!")),
      );
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    ReviewModel _review = widget.data["review"];
    Widget Items({
      required String name,
      required String value,
      required double top,
      double? padding = 0,
    }) {
      return Container(
        margin: EdgeInsets.only(top: top),
        child: Row(children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                name,
                style: TextStyle(
                    color: Color.fromRGBO(102, 102, 102, 1),
                    fontSize: 14,
                    fontFamily: 'Montserrat-Medium',
                    fontWeight: FontWeight.w500,
                    height: 1.25),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(right: 20),
            child: Text(
              value,
              style: TextStyle(
                  color: Color.fromRGBO(11, 11, 11, 1),
                  fontSize: 14,
                  fontFamily: 'Montserrat-Medium',
                  fontWeight: FontWeight.w500,
                  height: 1.25),
            ),
          )
        ]),
      );
    }

    // Scooter type and Code Section
    Widget detailSection({required ReviewModel review}) {
      return Container(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(children: [
          RatingBar.builder(
            initialRating: review.rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Color(0xffFFBC11),
              size: 100,
            ),
            onRatingUpdate: (rating) {
              print(rating);
              setState(() {
                rating = rating;
              });
            },
          ),
          Items(name: 'eScooter Code', value: review.scooterId, top: 30),
          Items(name: 'eScooter Type', value: review.scooter_type, top: 10),
          Container(
            padding: const EdgeInsets.only(top: 15, left: 22, right: 12),
            child: Row(children: const <Widget>[
              Expanded(
                  child: Divider(
                thickness: 2,
              )),
            ]),
          ),
          Items(
              name: 'Start Time',
              value: HelperUtility.getFormattedTime(
                  DateTime.fromMillisecondsSinceEpoch(review.startTime),
                  "dd MMM yyyy E kk:mm"),
              top: 10),
          Items(
              name: 'End Time',
              value: HelperUtility.getFormattedTime(
                  DateTime.fromMillisecondsSinceEpoch(review.endTime),
                  "dd MMM yyyy E kk:mm"),
              top: 10),
          Items(
              name: 'Duration',
              value: HelperUtility.getDayFromSeconds(review.duration),
              top: 10),
          Container(
              padding: const EdgeInsets.only(
                  top: 15, left: 22, right: 12, bottom: 10),
              child: Row(children: const <Widget>[
                Expanded(
                    child: Divider(
                  thickness: 2,
                )),
              ]))
        ]),
      );
    }

    Widget priceSection({required ReviewModel review}) {
      return Card(
          margin: const EdgeInsets.only(left: 20, right: 20),
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Colors.grey.shade300,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(15)),
          ),
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(children: [
              Items(
                name: "Start Price",
                value: "\€${review.start_price.toString()}",
                top: 0,
              ),
              Items(
                name: "Riding Price",
                value: "\€${review.riding_price.toString()}",
                top: 10,
              ),
              Items(
                name: "VAT(%21)",
                value: "\€${review.vat_price.toString()}",
                top: 10,
              ),
              Container(
                padding: const EdgeInsets.all(12),
                child: Row(children: const <Widget>[
                  Expanded(
                      child: Divider(
                    thickness: 2,
                  )),
                ]),
              ),
              Row(children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 20, bottom: 10),
                    child: Text(
                      'Total Amount',
                      style: TextStyle(
                          color: ColorConstants.cPrimaryTitleColor,
                          fontSize: 16,
                          fontFamily: FontStyles.fSemiBold,
                          fontWeight: FontWeight.w600,
                          height: 1.25),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(right: 20, bottom: 10),
                  child: Text(
                    "\€${review.total_price.toString()}",
                    style: TextStyle(
                        color: ColorConstants.cPrimaryTitleColor,
                        fontSize: 16,
                        fontFamily: FontStyles.fSemiBold,
                        fontWeight: FontWeight.w600,
                        height: 1.25),
                  ),
                )
              ]),
            ]),
          ));
    }

    Widget visaSection({required ReviewModel review}) {
      return Container(
          height: 72,
          margin: const EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
          ),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Color.fromRGBO(181, 181, 181, 1)),
              color: Colors.white),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Row(children: [
                  Container(
                    margin: const EdgeInsets.only(left: 20, bottom: 20),
                    child: CardUtils.getCardIcon(
                      AppProvider.of(context).currentUser.card!.cardType,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10, top: 10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 5),
                            child: Text(
                              review.card_type,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontFamily: 'Montserrat-Medium'),
                            ),
                          ),
                          Text(
                            review.card_number,
                            style: TextStyle(
                                fontSize: 12,
                                color: Color.fromRGBO(102, 102, 102, 1),
                                fontFamily: ' Montserrat-Bold'),
                          )
                        ]),
                  ),
                ]),
              ),
              Container(
                child: Container(
                  margin: const EdgeInsets.only(
                    top: 15,
                    bottom: 15,
                    right: 20,
                  ),
                  child: Text(
                    '- \€${review.total_price.toString()}',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat-Bold',
                        color: Colors.black),
                  ),
                ),
              )
            ],
          ));
    }

    LocationModel? startPoint = _review.startPoint;
    LocationModel? endPoint = _review.endPoint;
    double center_lat = startPoint!.lat + (endPoint!.lat - startPoint.lat) / 2;
    double center_long =
        startPoint.long + (endPoint.long - startPoint.long) / 2;
    if (points.length > 0) {
      int centerIndex = (points.length ~/ 2).toInt();
      center_lat = points[centerIndex].latitude;
      center_long = points[centerIndex].longitude;
      print("cener location...........................");
      print(points[centerIndex]);
    }
    return Scaffold(
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
          'Ride Detail',
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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                SizedBox(
                  height: 30,
                ),
                // detailSection,
                Container(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  height: 230,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: FlutterMap(
                      options: MapOptions(
                        center: LatLng(center_lat, center_long),
                        interactiveFlags:
                            InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                        zoom: 15,
                        minZoom: 10,
                        maxZoom: 18,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: AppConstants.urlTemplate,
                          userAgentPackageName:
                              'dev.fleaflet.flutter_map.example',
                        ),
                        PolylineLayer(
                          polylineCulling: true,
                          polylines: [
                            Polyline(
                              points: points,
                              strokeWidth: 2,
                              color: ColorConstants.cPrimaryBtnColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                detailSection(review: _review),
                priceSection(review: _review),
                // visaSection(review: _review),
                SizedBox(
                  height: 20,
                )
                // userdetailSection,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
