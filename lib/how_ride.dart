import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Helpers/helperUtility.dart';
import 'package:KiwiCity/Models/location_model.dart';
import 'package:KiwiCity/Models/review_model.dart';
import 'package:KiwiCity/Pages/App/app_provider.dart';
import 'package:KiwiCity/Pages/PaymentPage/payment_helper.dart';
import 'package:KiwiCity/Routes/routes.dart';
import 'package:KiwiCity/Services/firebase_service.dart';
import 'package:KiwiCity/Widgets/primaryButton.dart';
import 'package:KiwiCity/Widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:latlong2/latlong.dart';

class HowRide extends StatefulWidget {
  const HowRide({Key? key, required this.data}) : super(key: key);

  final dynamic data;
  @override
  State<HowRide> createState() => _HowRide();
}

class _HowRide extends State<HowRide> {
  String scooterImgUrl = "";
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  @override
  // late ReviewModel _review;
  void initState() {
    scooterImgUrl = widget.data['scooterPhoto'];
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  FirebaseService service = FirebaseService();

  /****************************
   * @Auth: world324digital
   * @Date: 2023.04.02
   * @Desc: Save Scooter Review
   */
  Future<void> saveReview(ReviewModel review, List<Map<String, dynamic>> _points) async {
    try {
      HelperUtility.showProgressDialog(context: context, key: _keyLoader);
      // String docId = await service.createReview(review);
      await service.updateReview(review);
      await service.saveRidePoints(review.id, _points);
      HelperUtility.closeProgressDialog(_keyLoader);
      Alert.showMessage(
          type: TypeAlert.success,
          title: "SUCCESS",
          message: "Thank you for feedback");
      HelperUtility.goPage(context: context, routeName: Routes.HOME);
    } catch (e) {
      print(e);
      HelperUtility.closeProgressDialog(_keyLoader);

      Alert.showMessage(
        type: TypeAlert.error,
        title: "ERROR",
        message: Messages.ERROR_MSG,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var appProvider = AppProvider.of(context);
    var card = appProvider.currentUser.card;
    String scooter_id = appProvider.scooterID;
    String user_id = appProvider.currentUser.id;
    String scooter_type = "Kiwi eScooter";
    DateTime start_time = appProvider.startRideTime;
    DateTime end_time = appProvider.endRideTime;
    int duration = appProvider.usedTime;
    double price_per_minute = appProvider.selectedPrice?.costPerMinute ?? 0.0;
    double riding_price =
        double.parse((price_per_minute * duration / 60).toStringAsFixed(2));
    double start_price = appProvider.selectedPrice?.startCost ?? 0.0;

    double start_vat_price = double.parse((start_price * 0.21).toStringAsFixed(2));
    double start_normal_price = double.parse((start_price - start_vat_price).toStringAsFixed(2));
    
    double riding_vat_price = double.parse((riding_price * 0.21).toStringAsFixed(2));
    double riding_normal_price = double.parse((riding_price - riding_vat_price).toStringAsFixed(2));

    double vat_price =
        double.parse(((start_price + riding_price) * 0.21).toStringAsFixed(2));
    double total_price = double.parse(
        (riding_price + start_price).toStringAsFixed(2));
    ;
    String card_type = card?.cardType ?? "";
    String card_number = card?.cardNumber ?? "";
    double _rating = 5.0;
    LocationModel _startPoint = appProvider.startPoint;
    LocationModel _endPoint = appProvider.endPoint;
    List<Map<String, dynamic>> _points = appProvider.points;
    double _distance = appProvider.distance;

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
              margin: const EdgeInsets.only(left: 20),
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
            margin: const EdgeInsets.only(right: 20),
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
    Widget detailSection = Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(children: [
        RatingBar.builder(
          initialRating: _rating,
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
            _rating = rating;
          },
        ),
        Items(name: 'eScooter Code', value: scooter_id, top: 30),
        Items(name: 'eScooter Type', value: scooter_type, top: 10),
        Container(
          padding: const EdgeInsets.only(top: 15, left: 22, right: 12),
          child: Row(children: const <Widget>[
            Expanded(child: Divider()),
          ]),
        ),
        Items(
            name: 'Start Time',
            value: HelperUtility.getFormattedTime(
                start_time, "dd MMM yyyy E kk:mm"),
            top: 10),
        Items(
            name: 'End Time',
            value:
                HelperUtility.getFormattedTime(end_time, "dd MMM yyyy E kk:mm"),
            top: 10),
        Items(
            name: 'Duration',
            value: HelperUtility.getDayFromSeconds(duration),
            top: 10),
        Container(
            margin:
                const EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 10),
            child: Row(children: const <Widget>[
              Expanded(child: Divider()),
            ]))
      ]),
    );
    Widget priceSection = Card(
        margin: const EdgeInsets.only(left: 20, right: 20),
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Colors.grey.shade300,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(15)),
        ),
        child: Container(
          padding: const EdgeInsets.all(0),
          child: Column(children: [
            SizedBox(height: 20),
            Items(
              name: "Start Price",
              value: "\€${start_price.toString()} = €${start_normal_price.toString()} + €${start_vat_price.toString()}(VAT %21)",
              top: 0,
            ),
            Items(
              name: "Riding Price",
              value: "\€${riding_price.toString()} = €${riding_normal_price.toString()} + €${riding_vat_price.toString()}(VAT %21)",
              top: 10,
            ),
            // Items(
            //   name: "VAT(%21)",
            //   value: "\€${vat_price.toString()}",
            //   top: 10,
            // ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(children: const <Widget>[
                Expanded(child: Divider()),
              ]),
            ),
            Row(children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(left: 20, bottom: 20),
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
                padding: const EdgeInsets.only(right: 20, bottom: 20),
                child: Text(
                  "\€${total_price.toString()}",
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
    Widget visaSection = Container(
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
                margin: const EdgeInsets.only(left: 20, bottom: 28),
                // child: Image.asset('assets/images/visa.png')),
                child: CardUtils.getCardIcon(
                  AppProvider.of(context).currentUser.card?.cardType ?? "",
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
                          "${card_type}",
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontFamily: 'Montserrat-Medium'),
                        ),
                      ),
                      Text(
                        HelperUtility.getNickCardNumber(card_number),
                        style: TextStyle(
                            fontSize: 12,
                            color: Color.fromRGBO(102, 102, 102, 1),
                            fontFamily: ' Montserrat-Bold'),
                      )
                    ]),
              ),
            ])),
            Container(
              child: Container(
                margin: const EdgeInsets.only(top: 15, bottom: 15, right: 20),
                child: Text(
                  '-\€$total_price',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      fontFamily: FontStyles.fMedium,
                      color: ColorConstants.cPrimaryTitleColor),
                ),
              ),
            )
          ],
        ));
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
          body: Column(
            children: [
              Expanded(
                  child: ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 32, bottom: 16),
                    child: Text(
                      'How was your ride?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: FontStyles.fBold,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  detailSection,
                  priceSection,
                  // visaSection
                ],
              )),
              Container(
                padding: EdgeInsets.only(bottom: 30),
                child: PrimaryButton(
                    context: context,
                    onTap: () async {
                      AppProvider.of(context).setIndex(3);
                      print("Here is Start Point and End Point ===========");
                      print(_startPoint);

                      print(_endPoint);

                      String reviewId = await service.createReview();
                      ReviewModel review = new ReviewModel(
                        id: reviewId,
                        scooterId: scooter_id,
                        userId: user_id,
                        scooter_type: scooter_type,
                        startTime: start_time.millisecondsSinceEpoch,
                        endTime: end_time.millisecondsSinceEpoch,
                        duration: duration,
                        riding_price: riding_price,
                        start_price: start_price,
                        vat_price: vat_price,
                        total_price: total_price,
                        card_type: card_type,
                        card_number: card_number,
                        rating: _rating,
                        scooterImg: scooterImgUrl,
                        startPoint: _startPoint,
                        endPoint: _endPoint,
                        // points: _points,
                        distance: _distance,
                      );

                      await saveReview(review, _points);
                    },
                    title: "Done"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
