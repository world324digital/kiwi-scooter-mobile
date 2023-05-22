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
import 'package:KiwiCity/Widgets/toast.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';

import 'package:KiwiCity/Helpers/helperUtility.dart';
import 'package:KiwiCity/Models/user_model.dart';
import 'package:KiwiCity/Routes/routes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  String startPrice = "1";
  String ridePrice = "0.25";

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
      PriceModel priceItem = _prices[0];
      startPrice = priceItem.startCost.toString();
      ridePrice = priceItem.costPerMinute.toString();

      // print("=========================================");
      // print(_prices);
      // if (_prices.length > 0) {
      setState(() {
        isLoading = false;
        isError = false;
      });
      // } else {
      //   setState(() {
      //     isLoading = false;
      //     isError = true;
      //   });
      // }
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
    var appProvider = AppProvider.of(context);

    Widget headerSection = Container(
      padding: EdgeInsets.only(top: platform == TargetPlatform.iOS ? 40 : 10),
      child: Text(
        AppLocalizations.of(context).startRidingMsg(startPrice),
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Color(0xff0B0B0B),
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: FontStyles.fSemiBold,
            height: 1.4),
      ),
    );

    /*********************
     * @Auth: world324digital
     * @Date: 2023.04.02
     * @Desc: Balance Section
     */
    Widget balanceSection = Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 15, top: 20, bottom: 15),
            child: Text(
              AppLocalizations.of(context).balance,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xff0B0B0B),
                fontFamily: FontStyles.fMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 15, top: 10, bottom: 15),
            child: Text(
              '€' + appProvider.currentUser.balance.toString(),
              style: TextStyle(
                fontSize: 24,
                color: ColorConstants.cPrimaryBtnColor,
                fontFamily: FontStyles.fMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Container(
          //   alignment: Alignment.topLeft,
          //   padding: const EdgeInsets.only(left: 15, top: 0, bottom: 15),
          //   child: Text(
          //     'More rides, more discount',
          //     style: TextStyle(
          //       fontSize: 14,
          //       color: Color(0xff666666),
          //       fontFamily: FontStyles.fMedium,
          //       fontWeight: FontWeight.w500,
          //     ),
          //   ),
          // ),
        ],
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
                    AppLocalizations.of(context)
                        .startRidingDescription(ridePrice),
                    textAlign: TextAlign.center,
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
      padding: EdgeInsets.symmetric(horizontal: 0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Column(children: <Widget>[
          // Container(
          //   width: double.infinity,
          //   height: platform == TargetPlatform.iOS ? 32 : 28,
          //   margin: const EdgeInsets.only(bottom: 10, left: 15, right: 15),
          //   // padding: const EdgeInsets.only(left: 25, right: 25),
          //   decoration: BoxDecoration(
          //     color: Color.fromRGBO(255, 223, 111, 1),
          //     borderRadius: BorderRadius.circular(16),
          //   ),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: [
          //       Icon(
          //         Icons.info_outline,
          //         color: const Color(0xff666666),
          //         size: 14,
          //       ),
          //       Text(
          //         '  it\'s cheaper than a taxi ( \$5 / KM)',
          //         style: TextStyle(
          //           color: Color.fromRGBO(102, 102, 102, 1),
          //           fontSize: 12.0,
          //           fontWeight: FontWeight.w500,
          //           fontFamily: FontStyles.fMedium,
          //         ),
          //       )
          //     ],
          //   ),
          // ),
          PrimaryButton(
              context: context,
              onTap: () async {
                setState(() {
                  isLoading = true;
                  isError = false;
                });
                PriceModel selectedPrice = _prices[0];

                //============ Save Price ==========
                AppProvider.of(context).setPriceModel(selectedPrice);
                UserModel currentUser = AppProvider.of(context).currentUser;
                double balance = currentUser.balance;
                
                bool isReservation = widget.data['isReservation'] == null
                    ? false
                    : widget.data['isReservation'];
                if (balance >= 1) {
                  currentUser.balance = balance - 1;

                  FirebaseService service = FirebaseService();
                  bool updateUserResult = await service.updateUser(currentUser);
                  if (updateUserResult) {
                    Future.delayed(const Duration(milliseconds: 200), () {
                      setState(() {
                        isLoading = false;
                      });
                      AppProvider.of(context).setCurrentUser(currentUser);
                      HelperUtility.goPageReplace(
                        context: context,
                        routeName: Routes.TERMS_OF_SERVICE,
                        arg: {
                          "viaPayment": true,
                          "isReservation": isReservation
                        },
                      );
                    });
                    // HelperUtility.goPage(
                    //     context: context,
                    //     routeName: Routes.PAYMENT_METHODS,
                    //     arg: {"isStart": true});
                  } else {
                    setState(() {
                      isLoading = false;
                    });
                    Alert.showMessage(
                      type: TypeAlert.error,
                      title: AppLocalizations.of(context).error,
                      message: AppLocalizations.of(context).errorMsg,
                    );
                  }
                } else {
                  setState(() {
                    isLoading = false;
                  });

                  HelperUtility.goPage(
                    context: context,
                    routeName: Routes.PAYMENT_METHODS,
                    arg: {
                      "isStart": true,
                      "deposit": false,
                      "isMore": false,
                      "isReservation": isReservation
                    },
                  );
                  // Alert.showMessage(
                  //     type: TypeAlert.error,
                  //     title: AppLocalizations.of(context).error,
                  //     message: Messages.INSUFFICIENT_BALANCE);
                }

                // if (widget.data['isMore'] ?? false) {
                //   final time = await Navigator.of(context).push(
                //     MaterialPageRoute(
                //         builder: (context) =>
                //             const PayMethod(data: {"isMore": true})),
                //   );

                //   Navigator.of(context).pop(time);
                // } else {
                // HelperUtility.goPage(
                //     context: context,
                //     routeName: Routes.PAYMENT_METHODS,
                //     arg: {"isMore": false});
                // }
              },
              title: AppLocalizations.of(context).continueLabel,
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
                    HelperUtility.goPageAllClear(
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
                    child: CircularProgressIndicator(
                        color: ColorConstants.cPrimaryBtnColor),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            headerSection,
                            titleSection,
                            balanceSection,
                            SizedBox(
                                height:
                                    platform == TargetPlatform.iOS ? 40 : 30),
                            // Expanded(
                            //   child: Container(
                            //     // margin: EdgeInsets.only(bottom: 25),
                            //     // height: HelperUtility.screenHeight(context) * 0.5,
                            //     width: HelperUtility.screenWidth(context) * 0.8,
                            //     decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.circular(24),
                            //       color: Colors.white,
                            //       boxShadow: [
                            //         BoxShadow(
                            //           color: Colors.grey.withOpacity(0.8),
                            //           spreadRadius: 8,
                            //           blurRadius: 16,
                            //           offset: Offset(0,
                            //               3), // changes position of shadow
                            //         ),
                            //       ],
                            //     ),
                            //     child: Text(
                            //       'Start Price',
                            //       textAlign: TextAlign.center,
                            //       style: TextStyle(
                            //           color: Colors.black,
                            //           fontSize: 20,
                            //           fontWeight: FontWeight.w200,
                            //           fontFamily: 'Montserrat-Medium'),
                            //     ),
                            //   ),
                            // ),
                            SizedBox(
                                height:
                                    platform == TargetPlatform.iOS ? 50 : 30),
                            // Container(
                            //   alignment: Alignment.center,
                            //   child: CarouselIndicator(
                            //     activeColor:
                            //         ColorConstants.cPrimaryBtnColor,
                            //     width: 10,
                            //     height: 3,
                            //     count: _prices.length,
                            //     index: pageIndex,
                            //     color: Colors.grey,
                            //   ),
                            // ),
                            SizedBox(
                                height:
                                    platform == TargetPlatform.iOS ? 40 : 30),
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
