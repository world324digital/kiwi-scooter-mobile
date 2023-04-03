import 'dart:core';
import 'dart:io';

import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Models/price_model.dart';
import 'package:KiwiCity/Pages/App/app_provider.dart';
import 'package:KiwiCity/Pages/PaymentPage/pay_method.dart';
import 'package:KiwiCity/Widgets/primaryButton.dart';
import 'package:KiwiCity/Widgets/slideItem.dart';
import 'package:KiwiCity/services/firebase_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../Helpers/helperUtility.dart';
import '../../Routes/routes.dart';
import '../../carousel_indicator.dart';

class StartRiding extends StatefulWidget {
  const StartRiding({Key? key, required this.data}) : super(key: key);

  final dynamic data;
  @override
  State<StartRiding> createState() => _StartRiding();
}

class _StartRiding extends State<StartRiding> {
  List<PriceModel> _prices = [];
  bool isLoading = true;
  bool isError = false;

  List<Widget> getList(List<PriceModel> prices) {
    List<Widget> slideList = [];
    for (PriceModel price in prices) {
      slideList.add(SlideItem(context: context, priceModel: price));
    }

    return slideList;
  }

  int pageIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPrices();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getPrices() async {
    setState(() {
      isLoading = true;
      isError = false;
    });
    try {
      FirebaseService service = FirebaseService();
      _prices = await service.getPrices();
      setState(() {
        isLoading = false;
        isError = false;
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var platform = Theme.of(context).platform;

    Widget headerSection = Container(
      padding: EdgeInsets.only(top: platform == TargetPlatform.iOS ? 40 : 10),
      child: Text(
        'How much time do you need?',
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Color(0xff0B0B0B),
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: FontStyles.fSemiBold,
            height: 1.4),
      ),
    );
    Widget titleSection = Container(
      padding: const EdgeInsets.only(top: 15, left: 25, right: 25),
      child: Row(
        children: [
          Expanded(
            /*1*/
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /*2*/
                Container(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    'You can always add more time later',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: Color(0xff666666),
                        fontSize: 14,
                        fontFamily: 'Montserrat-SemiBold',
                        height: 1.6,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    Widget continueSection = Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Column(children: <Widget>[
          Container(
            width: double.infinity,
            height: platform == TargetPlatform.iOS ? 32 : 28,
            margin: const EdgeInsets.only(bottom: 10, left: 15, right: 15),
            // padding: const EdgeInsets.only(left: 25, right: 25),
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 223, 111, 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  color: const Color(0xff666666),
                  size: 14,
                ),
                Text(
                  '  it\'s cheaper than a taxi ( \$5 / KM)',
                  style: TextStyle(
                    color: Color.fromRGBO(102, 102, 102, 1),
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                    fontFamily: FontStyles.fMedium,
                  ),
                )
              ],
            ),
          ),
          PrimaryButton(
              context: context,
              onTap: () async {
                PriceModel selectedPrice = _prices[pageIndex];

                //============ Save Price ==========
                AppProvider.of(context).setPriceModel(selectedPrice);
                if (widget.data['isMore'] ?? false) {
                  final time = await Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) =>
                            const PayMethod(data: {"isMore": true})),
                  );

                  Navigator.of(context).pop(time);
                } else {
                  HelperUtility.goPage(
                      context: context,
                      routeName: Routes.PAYMENT_METHODS,
                      arg: {"isMore": false});
                }
              },
              title: 'Start Riding',
              margin: EdgeInsets.only(bottom: Platform.isIOS ? 40 : 25))
        ]),
      ),
    );

    return new WillPopScope(
      onWillPop: () async {
        // Navigator.of(context).pop();
        // Navigator.of(context).pop();
        return false;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: Container(
          color: Colors.white,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              leading: Container(
                padding: platform == TargetPlatform.iOS
                    ? EdgeInsets.only(left: 30, top: 30)
                    : EdgeInsets.only(left: 25),
                child: IconButton(
                  onPressed: () {
                    widget.data['isMore']
                        ? Navigator.of(context).pop(false)
                        : HelperUtility.goPageAllClear(
                            context: context, routeName: Routes.HOME);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: ColorConstants.cPrimaryBtnColor,
                  ),
                ),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
            ),
            body: isLoading
                ? Center(
                    child: CircularProgressIndicator(color: ColorConstants.cPrimaryBtnColor),
                  )
                : isError
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              Messages.ERROR_MSG,
                              style: TextStyle(
                                color: Colors.red,
                                fontFamily: FontStyles.fBold,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            PrimaryButton(
                              margin: EdgeInsets.only(top: 10),
                              context: context,
                              onTap: () async {
                                await getPrices();
                              },
                              title: "RETRY",
                            )
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                headerSection,
                                titleSection,
                                SizedBox(
                                    height: platform == TargetPlatform.iOS
                                        ? 40
                                        : 30),
                                Expanded(
                                  child: Container(
                                    // margin: EdgeInsets.only(bottom: 25),
                                    // height: HelperUtility.screenHeight(context) * 0.5,
                                    // width: HelperUtility.screenWidth(context) * 0.8,
                                    child: CarouselSlider(
                                      items: getList(_prices),
                                      options: CarouselOptions(
                                        // viewportFraction: 0.8,
                                        height: double.infinity,
                                        viewportFraction: 0.85,
                                        enlargeCenterPage: false,
                                        onPageChanged: (index, reason) {
                                          setState(() {
                                            pageIndex = index;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    height: platform == TargetPlatform.iOS
                                        ? 50
                                        : 30),
                                Container(
                                  alignment: Alignment.center,
                                  child: CarouselIndicator(
                                    activeColor: ColorConstants.cPrimaryBtnColor,
                                    width: 10,
                                    height: 3,
                                    count: _prices.length,
                                    index: pageIndex,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(
                                    height: platform == TargetPlatform.iOS
                                        ? 40
                                        : 30),
                                continueSection
                              ],
                            ),
                          ),
                          // continueSection,
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}
