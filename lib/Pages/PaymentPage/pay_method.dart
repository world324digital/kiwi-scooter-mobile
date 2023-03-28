import 'dart:convert';
import 'dart:io';

import 'package:Move/Helpers/constant.dart';
import 'package:Move/Helpers/helperUtility.dart';
import 'package:Move/Models/card_model.dart';
import 'package:Move/Models/price_model.dart';
import 'package:Move/Models/user_model.dart';
import 'package:Move/Pages/App/app_provider.dart';
import 'package:Move/Pages/PaymentPage/payment_helper.dart';
import 'package:Move/Pages/UnlockPage/unlock.dart';
import 'package:Move/Routes/routes.dart';
import 'package:Move/Widgets/primaryButton.dart';
import 'package:Move/Widgets/toast.dart';
import 'package:Move/services/httpService.dart';
import 'package:Move/services/firebase_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:pay/pay.dart';

import '../MenuPage/main_menu.dart';
import 'applePayButtonWidget.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as FlutterStripe;
import 'package:pay/pay.dart' as pay;

class PayMethod extends StatefulWidget {
  const PayMethod({Key? key, required this.data}) : super(key: key);
  final dynamic data;

  @override
  State<PayMethod> createState() => _PayMethod();
}

class _PayMethod extends State<PayMethod> {
  var _cardNumberController = TextEditingController();
  var _cardHolderNamerController = TextEditingController();
  var _cardExpiractionController = TextEditingController();
  var _cardSecurityCodeController = TextEditingController();
  var _cardZipCodeController = TextEditingController();
  bool isExistCard = false;
  bool isShowCardSection = false;
  String card_number = '1234********2525';

  final _formKey = GlobalKey<FormState>();

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  bool isUnlocking = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderNamerController.dispose();
    _cardExpiractionController.dispose();
    _cardSecurityCodeController.dispose();
    _cardZipCodeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    stripeInitialize();
  }

  Future<void> stripeInitialize() async {
    FlutterStripe.Stripe.publishableKey = AppConstants.publishKey;
    FlutterStripe.Stripe.merchantIdentifier =
        'merchant.com.ridemoveisland.stripe';
    await FlutterStripe.Stripe.instance.applySettings();
  }

  /****************************
   * @Auth: geniusdev0813
   * @Date: 2022.12.12
   * @Desc: Complete Payment
   */
  Future<void> paySubmit(CardModel card) async {
    print(card.cardType);
    String scooterID = AppProvider.of(context).scooterID;
    String amount = AppProvider.of(context).selectedPrice!.totalCost.toString();

    setState(() {
      isUnlocking = true;
    });

    try {
      var res = await HttpService().cardPay(
          holderName: card.cardName,
          cardNumber: card.cardNumber,
          expiredMonth: card.expMonth,
          expiredYear: card.expYear,
          cvv: card.cvv,
          amount: amount);
      print("Stripe Result :::::::::::::>");
      print(res);

      if (res['result']) {
        // String scooterID = AppProvider.of(context).scooterID;

        // var powerOn = await HttpService()
        //     .changePowerStatus(scooterID: scooterID, status: "true");
        // print("POWER STATUS:::::::::::>");
        // print(powerOn);

        // if (powerOn['result']) {
        // await powerOnScooter();

        // Card Informatin Save
        UserModel currentUser = AppProvider.of(context).currentUser;

        card.id = currentUser.id;
        currentUser.card = card;

        FirebaseService service = FirebaseService();
        bool updateCardResult = await service.updateCard(currentUser);
        if (updateCardResult) {
          // setState(() {
          //   isUnlocking = false;
          // });

          // ========== Calculate Ride Time ===========
          PriceModel _priceModel = AppProvider.of(context).selectedPrice!;
          int _time = (_priceModel.totalCost / _priceModel.cost).toInt() * 60;

          if (widget.data['isMore']) {
            Navigator.of(context).pop(_time);
          } else {
            Future.delayed(const Duration(milliseconds: 200), () {
              AppProvider.of(context).setCurrentUser(currentUser);
              HelperUtility.goPageReplace(
                  context: context,
                  routeName: Routes.TERMS_OF_SERVICE,
                  arg: {"viaPayment": true});
            });
          }
        } else {
          Alert.showMessage(
              type: TypeAlert.error,
              title: "ERROR",
              message: Messages.ERROR_MSG);
        }
        // } else {
        //   if (mounted) {
        //     setState(() {
        //       isUnlocking = false;
        //     });
        //     Alert.showMessage(
        //         type: TypeAlert.error,
        //         title: "ERROR",
        //         message: powerOn['message'] ?? Messages.ERROR_MSG);
        //   }
        // }
      } else {
        if (mounted)
          setState(() {
            isUnlocking = false;
          });
        Alert.showMessage(
            type: TypeAlert.error,
            title: "ERROR",
            message: res['msg'] ?? Messages.ERROR_MSG);
      }
    } catch (e) {
      // print(e);
      if (mounted)
        setState(() {
          isUnlocking = false;
        });
      Alert.showMessage(
          type: TypeAlert.error, title: "ERROR", message: e.toString());
    }
  }

// Apple Pay
  Future<void> _handlePayPress() async {
    try {
      // 1. Present Apple Pay sheet
      // await FlutterStripe.Stripe.instance.resetPaymentSheetCustomer();
      await FlutterStripe.Stripe.instance.presentApplePay(
        params: FlutterStripe.ApplePayPresentParams(
          cartItems: [
            FlutterStripe.ApplePayCartSummaryItem.immediate(
              label: 'Move eMobility',
              amount:
                  AppProvider.of(context).selectedPrice!.totalCost.toString(),
            ),
          ],
          requiredShippingAddressFields: [],
          shippingMethods: [],
          country: 'US',
          currency: 'USD',
        ),
      );

      // 2. fetch Intent Client Secret from backend
      final response = await fetchPaymentIntentClientSecret(
          paymethod: PayMethodStr.APPLE_PAY);
      if (response['result']) {
        final clientSecret = response['data'];

        // 2. Confirm apple pay payment
        await FlutterStripe.Stripe.instance
            .confirmApplePayPayment(clientSecret);

        Alert.showMessage(
            type: TypeAlert.success,
            title: "SUCCESS",
            message: "Apple pay Success!");
        await payWithAppleGoogle();
      } else {}
    } catch (e) {
      print(e);
      String message = "Something Went Wrong. Please retry!";
      if (e is PlatformException) {
        PlatformException error = e as PlatformException;
        message = error.code == "Canceled" ? error.message.toString() : message;
      }
      Alert.showMessage(
          type: TypeAlert.error, title: "ERROR", message: message);
    }
  }

// Google Pay
  Future<void> onGooglePayResult(paymentResult) async {
    try {
      // 1. Add your stripe publishable key to assets/google_pay_payment_profile.json
      debugPrint(paymentResult.toString());
      // 2. fetch Intent Client Secret from backend
      final response = await fetchPaymentIntentClientSecret(
          paymethod: PayMethodStr.GOOGLE_PAY);
      HelperUtility.showProgressDialog(
        context: context,
        key: _keyLoader,
        title: " Please wait...",
        // title: inProgress ? "Pause..." : "Resume...",
      );
      if (response['result']) {
        final clientSecret = response['data'];
        final token =
            paymentResult['paymentMethodData']['tokenizationData']['token'];
        final tokenJson = Map.castFrom(json.decode(token));
        print(tokenJson);

        final params = PaymentMethodParams.cardFromToken(
          paymentMethodData: PaymentMethodDataCardFromToken(
            token: tokenJson['id'], // TODO extract the actual token
          ),
        );

        // 3. Confirm Google pay payment method
        await Stripe.instance.confirmPayment(
          paymentIntentClientSecret: clientSecret,
          data: params,
        );
        HelperUtility.closeProgressDialog(_keyLoader);
        Alert.showMessage(
            type: TypeAlert.success,
            title: "SUCCESS",
            message: 'Google Pay payment succesfully completed');
        await payWithAppleGoogle();
      } else {
        HelperUtility.closeProgressDialog(_keyLoader);
        Alert.showMessage(
            type: TypeAlert.error,
            title: "ERROR",
            message: 'Something went wrong. Please retry!');
      }
    } catch (e) {
      HelperUtility.closeProgressDialog(_keyLoader);

      String message = "Something Went Wrong. Please retry!";
      if (e is PlatformException) {
        PlatformException error = e as PlatformException;
        message = error.code == "Canceled" ? error.message.toString() : message;
      }
      Alert.showMessage(
          type: TypeAlert.error, title: "ERROR", message: message);
    }
  }

  // Future<void> debugChangedStripePublishableKey() async {
  //   if (kDebugMode) {
  //     final profile =
  //         await rootBundle.loadString('assets/google_pay_payment_profile.json');
  //     final isValidKey = !profile.contains(AppConstants.publishKey);
  //     assert(
  //       isValidKey,
  //       'No stripe publishable key added to assets/googlepay.json',
  //     );
  //   }
  // }

  Future<Map<String, dynamic>> fetchPaymentIntentClientSecret({
    required String paymethod,
  }) async {
    return await HttpService().nativePay(
      amount: AppProvider.of(context).selectedPrice!.totalCost.toString(),
      email: AppProvider.of(context).currentUser.email,
      paymethod: paymethod,
    );
  }

  /******************************
   * @Auth: geniusdev0813@gmail.com
   * @Date: 2022.12.13
   * @Desc: Power On Scooter
   */
  Future<void> payWithAppleGoogle() async {
    print("----- Goole Apple Pay Functions");
    // ========== Calculate Ride Time ===========
    PriceModel _priceModel = AppProvider.of(context).selectedPrice!;
    int _time = _priceModel.totalCost ~/ _priceModel.cost * 60;
    CardModel extracard;

    if (Platform.isAndroid) {
      extracard = new CardModel(
          id: AppProvider.of(context).currentUser.id,
          cardName: "",
          cardNumber: "",
          expMonth: '',
          expYear: '',
          cvv: '',
          cardType: "GooglePay");
    } else {
      extracard = new CardModel(
          id: AppProvider.of(context).currentUser.id,
          cardName: "",
          cardNumber: "",
          expMonth: '',
          expYear: '',
          cvv: '',
          cardType: "ApplePay");
    }

    UserModel currentUser = AppProvider.of(context).currentUser;
    currentUser.card = extracard;
    AppProvider.of(context).setCurrentUser(currentUser);

    if (widget.data['isMore']) {
      Navigator.of(context).pop(_time);
    } else {
      setState(() {
        isUnlocking = false;
      });
      HelperUtility.goPageReplace(
          context: context,
          routeName: Routes.TERMS_OF_SERVICE,
          arg: {"viaPayment": true});

      // String scooterID = AppProvider.of(context).scooterID;

      // var powerOn = await HttpService()
      //     .changePowerStatus(scooterID: scooterID, status: "true");
      // print("POWER STATUS:::::::::::>");
      // print(powerOn);

      // if (powerOn['result']) {
      //   HelperUtility.goPageReplace(
      //       context: context,
      //       routeName: Routes.TERMS_OF_SERVICE,
      //       arg: {"viaPayment": true});
      // } else {
      //   setState(() {
      //     isUnlocking = false;
      //   });
      //   Alert.showMessage(
      //       type: TypeAlert.error,
      //       title: "ERROR",
      //       message: powerOn['message'] ?? Messages.ERROR_MSG);
      // }
      // HelperUtility.goPageReplace(
      //     context: context,
      //     routeName: Routes.TERMS_OF_SERVICE,
      //     arg: {"viaPayment": true});
    }
  }

  /******************************
   * Get Price Item
   */
  List<PaymentItem> getPriceItem() {
    return [
      PaymentItem(
        label: 'RideMove',
        amount: AppProvider.of(context).selectedPrice!.totalCost.toString(),
        status: PaymentItemStatus.final_price,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    isExistCard =
        AppProvider.of(context).currentUser.card != null ? true : false;

    // Check if  ApplePay and Google Pay
    var cardType = AppProvider.of(context).currentUser.card?.cardType;
    if (cardType == 'ApplePay' || cardType == 'GooglePay') {
      isExistCard = false;
    }

    var platform = Theme.of(context).platform;
    var appProvider = AppProvider.of(context);

    /*********************
     * @Auth: leopard
     * @Date: 2022.12.12
     * @Desc: Selected Card Section
     */
    Widget paySection = InkWell(
      onTap: () async {
        await paySubmit(appProvider.currentUser.card!);
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 12, left: 20, right: 20),
        child: Column(children: [
          Container(
            height: 72,
            padding: const EdgeInsets.only(
              top: 5,
              bottom: 5,
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
                  if (appProvider.currentUser.card != null)
                    Container(
                      margin: EdgeInsets.only(left: 20, bottom: 20),
                      child: CardUtils.getCardIcon(
                        appProvider.currentUser.card!.cardType,
                      ),
                    ),
                  if (appProvider.currentUser.card != null)
                    Container(
                      margin: const EdgeInsets.only(left: 10, top: 10),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 5),
                              child: Text(
                                appProvider.currentUser.card!.cardType != ""
                                    ? appProvider.currentUser.card!.cardType
                                    : "Others",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xff0B0B0B),
                                  fontFamily: FontStyles.fMedium,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (appProvider.currentUser.card != null)
                              Text(
                                HelperUtility.getNickCardNumber(
                                    appProvider.currentUser.card!.cardNumber),
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Color.fromRGBO(102, 102, 102, 1),
                                    fontFamily: ' Montserrat-Bold'),
                              )
                          ]),
                    ),
                ])),
                Container(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    margin:
                        const EdgeInsets.only(top: 15, bottom: 15, right: 20),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Color.fromRGBO(229, 249, 224, 1),
                    ),
                    child: Text(
                      'SELECTED',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Montserrat-Bold',
                          color: Color.fromRGBO(52, 202, 52, 1)),
                    ),
                  ),
                )
              ],
            ),
          )
        ]),
      ),
    );

    /*********************
     * @Auth: leopard
     * @Date: 2022.12.12
     * @Desc: Card Input Section
     */
    Widget cardSection = Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color.fromRGBO(181, 181, 181, 1))),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(left: 15, top: 20, bottom: 15),
              child: Text(
                'Add New Credit Card',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xff0B0B0B),
                  fontFamily: FontStyles.fMedium,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            //------------- Card Holder Name --------------
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(top: 10, bottom: 10, left: 12),
              child: Text(
                'Card Holder Name',
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Color.fromRGBO(11, 11, 11, 1),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Montserrat-Medium'),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: _cardHolderNamerController,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.only(left: 15, top: 5, bottom: 5, right: 5),
                  hintText: 'John Doe',
                  hintStyle: TextStyle(
                      color: Color.fromRGBO(181, 181, 181, 1),
                      fontFamily: 'Montserrat-Regular',
                      fontSize: 14),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1, color: Color.fromRGBO(181, 181, 181, 1)),
                      borderRadius: BorderRadius.circular(15.0)),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(15.0)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.green,
                    ),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                autocorrect: false,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == "") {
                    return "Please enter holder name";
                  } else if (value!.length > 100) {
                    return "Name should be less than 100 characters";
                  }

                  return null;
                },
                // inputFormatters: [
                //   FilteringTextInputFormatter.digitsOnly,
                //   LengthLimitingTextInputFormatter(16),
                //   CardNumberInputFormatter(),
                // ],
              ),
            ),

            //------------- Card Number --------------
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(top: 10, bottom: 10, left: 12),
              child: Text(
                'Card Number',
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Color.fromRGBO(11, 11, 11, 1),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Montserrat-Medium'),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: _cardNumberController,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.only(left: 15, top: 5, bottom: 5, right: 5),
                  hintText: 'Card Number',
                  hintStyle: TextStyle(
                      color: Color.fromRGBO(181, 181, 181, 1),
                      fontFamily: 'Montserrat-Regular',
                      fontSize: 14),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1, color: Color.fromRGBO(181, 181, 181, 1)),
                      borderRadius: BorderRadius.circular(15.0)),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(15.0)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.green,
                    ),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                autocorrect: false,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  String number = value!.trim();
                  CardType type = CardUtils.getCardTypeFrmNumber(number);
                  if (type == CardType.Invalid) {
                    return "Invalid card number";
                  }
                  // if (value?.isEmpty ?? true) {
                  //   return 'Email Required';
                  // }
                  // if (!isEmail(value!)) {
                  //   return 'Invalid Email';
                  // }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  CardNumberInputFormatter(),
                ],
              ),
            ),

            /****************** Card Expire & Security Code Part *********** */
            Container(
                child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      padding: const EdgeInsets.only(left: 12, bottom: 12),
                      child: Text(
                        'Expiration date',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Montserrat-Medium'),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.39,
                      margin: const EdgeInsets.only(
                          bottom: 10, left: 12, right: 12),
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: _cardExpiractionController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 15, right: 5),
                          hintText: 'MM/YY',
                          hintStyle: TextStyle(
                              color: Color.fromRGBO(181, 181, 181, 1),
                              fontFamily: 'Montserrat-Regular',
                              fontSize: 14),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 1,
                                  color: Color.fromRGBO(181, 181, 181, 1)),
                              borderRadius: BorderRadius.circular(15.0)),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(15.0)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.green,
                            ),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                        autocorrect: false,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(5),
                          CardMonthInputFormatter(),
                        ],
                        validator: (value) {
                          // String number = value!.trim();
                          // String type = CardUtils.getCardTypeFrmNumber(number);
                          // if (type == "Invalid") {
                          //   return "Invalid card number";
                          // }
                          // if (value?.isEmpty ?? true) {
                          //   return 'Email Required';
                          // }
                          // if (!isEmail(value!)) {
                          //   return 'Invalid Email';
                          // }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.topRight,
                      padding: const EdgeInsets.only(left: 12, bottom: 12),
                      child: Text(
                        'Security Code',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Montserrat-Medium'),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.38,
                      margin: const EdgeInsets.only(bottom: 10, right: 12),
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: _cardSecurityCodeController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 15, right: 5),
                          hintText: '123',
                          hintStyle: TextStyle(
                              color: Color.fromRGBO(181, 181, 181, 1),
                              fontFamily: 'Montserrat-Regular',
                              fontSize: 14),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 1,
                                  color: Color.fromRGBO(181, 181, 181, 1)),
                              borderRadius: BorderRadius.circular(15.0)),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(15.0)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.green,
                            ),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                        autocorrect: false,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          // Limit the input
                          LengthLimitingTextInputFormatter(4),
                        ],
                        validator: (value) {
                          String number = value!.trim();

                          if (value.length < 3) {
                            return "Invalid code";
                          }
                          // if (value?.isEmpty ?? true) {
                          //   return 'Email Required';
                          // }
                          // if (!isEmail(value!)) {
                          //   return 'Invalid Email';
                          // }
                          return null;
                        },
                      ),
                    )
                  ],
                ),
              ],
            )),

            //------------- Complete Payment  Button --------------
            Container(
              margin: EdgeInsets.only(bottom: 10, top: 10),
              child: PrimaryButton(
                  context: context,
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      String cardName = _cardHolderNamerController.text;
                      String cardNumber = _cardNumberController.text;
                      String card_exp = _cardExpiractionController.text;
                      String cardExpMonth = card_exp.split('/')[0];
                      String cardExpYear = card_exp.split('/')[1];
                      String zipCode = _cardZipCodeController.text;
                      String cvv = _cardSecurityCodeController.text;
                      CardModel card = CardModel(
                        id: AppProvider.of(context).currentUser.id,
                        cardName: cardName,
                        cardNumber: cardNumber,
                        expMonth: cardExpMonth,
                        expYear: cardExpYear,
                        cvv: cvv,
                        cardType: CardUtils.getCardTypeName(
                          CardUtils.getCardTypeFrmNumber(
                              _cardNumberController.text),
                        ),
                      );
                      // AppProvider.of(context).setCardInfo(card);
                      await paySubmit(card);
                    }
                  },
                  title: "Complete Payment",
                  height: 50,
                  borderRadius: BorderRadius.circular(12)),
            )
          ],
        ),
      ),
    );

    /*********************
     * @Auth: leopard
     * @Date: 2022.12.12
     * @Desc: Add Payment Button
     */
    Widget plusSection = Container(
      height: 55,
      margin: const EdgeInsets.only(top: 10, bottom: 10, left: 25, right: 25),
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Container(
            child: Image.asset(
          'assets/images/plus.png',
          width: 30,
          height: 30,
        )),
        label: const Text('Add Another Payment',
            style: TextStyle(
                fontSize: 16.0,
                color: Color.fromRGBO(102, 102, 102, 1),
                fontFamily: 'Montserrat-Medium')),
        style: OutlinedButton.styleFrom(
          padding:
              const EdgeInsets.only(top: 12, bottom: 12, left: 18, right: 18),
          textStyle:
              const TextStyle(color: Colors.grey, fontFamily: 'Montserrat'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13.0),
            // side: const BorderSide(color: Color.fromRGBO(255, 175, 164, 1), width: 2),
          ),
        ).copyWith(
          side: MaterialStateProperty.resolveWith<BorderSide>(
            (Set<MaterialState> states) {
              return BorderSide(
                color: Color.fromRGBO(181, 181, 181, 1),
                width: 1,
              );
              // Defer to the widget's default.
            },
          ),
        ),
        onPressed: () async {
          print(_cardNumberController.text);
          setState(() {
            isShowCardSection = true;
          });
        },
      ),
    );

    return isUnlocking
        ? UnLock(isMore: widget.data['isMore'])
        : AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
            ),
            child: Scaffold(
              drawer: Drawer(
                child: MainMenu(pageIndex: 2),
              ),
              backgroundColor: Colors.white,
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
                  'Payment Method',
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
              body: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        if (AppProvider.of(context).selectedPrice != null)
                          // applePayWidget(),
                          platform == TargetPlatform.iOS
                              ? ApplePayButtonWidget(
                                  padding: EdgeInsets.all(16),
                                  children: [
                                    FlutterStripe.ApplePayButton(
                                      onPressed: _handlePayPress,
                                    )
                                  ],
                                )
                              : pay.GooglePayButton(
                                  paymentConfigurationAsset:
                                      'google_pay_live.json',
                                  paymentItems: getPriceItem(),
                                  margin: const EdgeInsets.only(
                                      top: 15, right: 20, left: 20, bottom: 20),
                                  onPaymentResult: onGooglePayResult,
                                  loadingIndicator: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  onPressed: () async {
                                    // 1. Add your stripe publishable key to assets/google_pay_payment_profile.json
                                    // await debugChangedStripePublishableKey();
                                  },
                                  childOnError: Text(
                                      'Google Pay is not available in this device'),
                                  onError: (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'There was an error while trying to perform the payment'),
                                      ),
                                    );
                                  },
                                ),
                        isExistCard ? paySection : Container(),
                        (isExistCard && !isShowCardSection)
                            ? Container()
                            : cardSection,
                      ],
                    ),
                  ),
                  isExistCard ? plusSection : Container(),
                  SizedBox(
                    height: 30,
                  )
                ],
              ),
            ),
          );
  }
}
