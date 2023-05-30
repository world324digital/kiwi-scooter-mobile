import 'dart:convert';
import 'dart:io';

import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Helpers/helperUtility.dart';
import 'package:KiwiCity/Models/card_model.dart';
import 'package:KiwiCity/Models/price_model.dart';
import 'package:KiwiCity/Models/user_model.dart';
import 'package:KiwiCity/Models/transaction_model.dart';
import 'package:KiwiCity/Pages/App/app_provider.dart';
import 'package:KiwiCity/Pages/PaymentPage/payment_helper.dart';
import 'package:KiwiCity/Pages/UnlockPage/unlock.dart';
import 'package:KiwiCity/Routes/routes.dart';
import 'package:KiwiCity/Widgets/primaryButton.dart';
import 'package:KiwiCity/Widgets/toast.dart';
import 'package:KiwiCity/services/httpService.dart';
import 'package:KiwiCity/services/firebase_service.dart';
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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  bool isLoading = false;
  String card_number = '1234********2525';
  String amount = "0";

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
    FlutterStripe.Stripe.merchantIdentifier = 'merchant.com.kiwi-city.kiwicity';
    await FlutterStripe.Stripe.instance.applySettings();
  }

  /****************************
   * @Auth: world324digital
   * @Date: 2023.04.02
   * @Desc: Complete Payment
   */
  Future<void> paySubmit(CardModel card) async {
    print(card.cardType);
    String scooterID = AppProvider.of(context).scooterID;
    if (widget.data["isStart"]) {
      amount = AppProvider.of(context).selectedPrice!.startCost.toString();
      print("//////////");
      print(amount);
    }

    setState(() {
      isLoading = true;
    });
    print(widget.data);

    if (widget.data['deposit']) {
      try {
        String amount = widget.data['amount'];
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
          UserModel currentUser = AppProvider.of(context).currentUser;

          currentUser.balance = double.parse(
              (currentUser.balance + double.parse(amount)).toStringAsFixed(2));
          FirebaseService service = FirebaseService();
          String amount_fixed = double.parse(amount).toStringAsFixed(2);
          TransactionModel transaction = new TransactionModel(
            userId: currentUser.id,
            userName: currentUser.firstName + " " + currentUser.lastName,
            stripeId: res['data']['id'] ?? "",
            stripeTxId: res['data']['balance_transaction'] ?? "",
            rideDistance: 0.0,
            rideTime: 0,
            amount: double.parse(amount_fixed),
            txType: "Deposit",
          );
          await service.createTransaction(transaction);

          card.id = currentUser.id;
          currentUser.card = card;

          bool updateUserResult = await service.updateUser(currentUser);
          if (updateUserResult) {
            Alert.showMessage(
                type: TypeAlert.success,
                title: AppLocalizations.of(context).success,
                message: Messages.SUCCESS_DEPOSIT);
            Future.delayed(const Duration(milliseconds: 200), () {
              AppProvider.of(context).setCurrentUser(currentUser);
              HelperUtility.goPageReplace(
                context: context,
                routeName: Routes.WALLET,
              );
            });

            setState(() {
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
            Alert.showMessage(
                type: TypeAlert.error,
                title: AppLocalizations.of(context).error,
                message: AppLocalizations.of(context).errorMsg);
          }
        } else {
          setState(() {
            isLoading = false;
          });
          Alert.showMessage(
              type: TypeAlert.error,
              title: AppLocalizations.of(context).error,
              message: res['msg'] ?? AppLocalizations.of(context).errorMsg);
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        Alert.showMessage(
            type: TypeAlert.error,
            title: AppLocalizations.of(context).error,
            message: e.toString());
      }
    } else if (widget.data["isStart"]) {
      // setState(() {
      //   isUnlocking = true;
      // });

      try {
        UserModel currentUser = AppProvider.of(context).currentUser;
        double user_balance = currentUser.balance;
        String rest_amount = (double.parse(amount)).toStringAsFixed(2);
        if (user_balance >= 0) {
          rest_amount =
              (double.parse(amount) - user_balance).toStringAsFixed(2);
        }
        var res = await HttpService().cardPay(
          holderName: card.cardName,
          cardNumber: card.cardNumber,
          expiredMonth: card.expMonth,
          expiredYear: card.expYear,
          cvv: card.cvv,
          amount: rest_amount,
        );
        // amount: "0");
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

          card.id = currentUser.id;
          // currentUser.balance = 0.0;
          currentUser.card = card;

          FirebaseService service = FirebaseService();
          bool updateCardResult = await service.updateCard(currentUser);
          if (updateCardResult) {
            // setState(() {
            //   isUnlocking = false;
            // });
            // ========== Calculate Ride Time ===========
            PriceModel _priceModel = AppProvider.of(context).selectedPrice!;
            // int _time = (_priceModel.totalCost / _priceModel.cost).toInt() * 60;

            if (widget.data['isMore']) {
              // Navigator.of(context).pop(_time);
            } else {
              Future.delayed(const Duration(milliseconds: 200), () {
                AppProvider.of(context).setCurrentUser(currentUser);
                HelperUtility.goPageReplace(
                  context: context,
                  routeName: Routes.TERMS_OF_SERVICE,
                  arg: {
                    "viaPayment": true,
                    "isReservation": widget.data["isReservation"],
                  },
                );
              });
            }
          } else {
            setState(() {
              isLoading = false;
            });
            Alert.showMessage(
                type: TypeAlert.error,
                title: AppLocalizations.of(context).error,
                message: AppLocalizations.of(context).errorMsg);
          }
          // } else {
          //   if (mounted) {
          //     setState(() {
          //       isUnlocking = false;
          //     });
          //     Alert.showMessage(
          //         type: TypeAlert.error,
          //         title: AppLocalizations.of(context).error,
          //         message: powerOn['message'] ?? AppLocalizations.of(context).errorMsg);
          //   }
          // }
        } else {
          setState(() {
            isLoading = false;
          });
          if (mounted)
            setState(() {
              isUnlocking = false;
            });
          Alert.showMessage(
              type: TypeAlert.error,
              title: AppLocalizations.of(context).error,
              message: res['msg'] ?? AppLocalizations.of(context).errorMsg);
        }
      } catch (e) {
        // print(e);
        if (mounted)
          setState(() {
            isUnlocking = false;
          });
        Alert.showMessage(
            type: TypeAlert.error,
            title: AppLocalizations.of(context).error,
            message: e.toString());
      }
    }
  }

// Apple Pay
  Future<void> _handlePayPress() async {
    try {
      // 1. Present Apple Pay sheet
      // await FlutterStripe.Stripe.instance.resetPaymentSheetCustomer();

      if (widget.data["isStart"]) {
        amount = AppProvider.of(context).selectedPrice!.startCost.toString();
        print("For google pay option");
        print(amount);
      } else if (widget.data["deposit"]) {
        amount = widget.data["amount"];
      }

      UserModel currentUser = AppProvider.of(context).currentUser;
      double user_balance = currentUser.balance;
      String rest_amount =
          (double.parse(amount) - user_balance).toStringAsFixed(2);

      if (widget.data["deposit"]) {
        rest_amount = amount;
      }

      print("before present apple pay");
      await FlutterStripe.Stripe.instance.presentApplePay(
        params: FlutterStripe.ApplePayPresentParams(
          cartItems: [
            FlutterStripe.ApplePayCartSummaryItem.immediate(
              label: 'Kiwi City',
              amount:
                  // AppProvider.of(context).selectedPrice!.totalCost.toString(),
                  // "0",
                  rest_amount,
            ),
          ],
          requiredShippingAddressFields: [],
          shippingMethods: [],
          country: 'LV',
          currency: 'EUR',
        ),
      );

      print("after present apple pay");

      // 2. fetch Intent Client Secret from backend
      final response = await fetchPaymentIntentClientSecret(
          paymethod: PayMethodStr.APPLE_PAY);
      print("fetch payment intent");
      print(response);
      if (response['result']) {
        final clientSecret = response['data'];
        // 2. Confirm apple pay payment
        await FlutterStripe.Stripe.instance
            .confirmApplePayPayment(clientSecret);
        bool updateUserResult = false;
        if (widget.data["deposit"]) {
          currentUser.balance = double.parse(
              (currentUser.balance + double.parse(amount)).toStringAsFixed(2));
          FirebaseService service = FirebaseService();
          String amount_fixed = double.parse(amount).toStringAsFixed(2);
          TransactionModel transaction = new TransactionModel(
            userId: currentUser.id,
            userName: currentUser.firstName + " " + currentUser.lastName,
            stripeId: clientSecret ?? "",
            stripeTxId: "Apple Pay",
            rideDistance: 0.0,
            rideTime: 0,
            amount: double.parse(amount_fixed),
            txType: "Deposit",
          );
          print("before create transaction");
          await service.createTransaction(transaction);
          print("after create transaction");
          updateUserResult = await service.updateUser(currentUser);
          print(updateUserResult);
        } else if (widget.data["isStart"]) {
          updateUserResult = true;
        }

        
        print("updateResult");
        print(updateUserResult);

        if (updateUserResult) {
          Alert.showMessage(
            type: TypeAlert.success,
            title: AppLocalizations.of(context).success,
            message: AppLocalizations.of(context).applePaySuccess,
          );
          await payWithAppleGoogle();
        } else {
          Alert.showMessage(
            type: TypeAlert.error,
            title: AppLocalizations.of(context).error,
            message: AppLocalizations.of(context).errorMsg,
          );
        }
      } else {}
    } catch (e) {
      print(e);
      String message = AppLocalizations.of(context).errorMsg;
      if (e is PlatformException) {
        PlatformException error = e as PlatformException;
        message = error.code == "Canceled" ? error.message.toString() : message;
      }
      Alert.showMessage(
          type: TypeAlert.error,
          title: AppLocalizations.of(context).error,
          message: message);
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
        title: AppLocalizations.of(context).wait,
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

        bool updateUserResult = false;
        if (widget.data["deposit"]) {
          UserModel currentUser = AppProvider.of(context).currentUser;
          String amount = "0";
          if (widget.data["isStart"]) {
            amount =
                AppProvider.of(context).selectedPrice!.startCost.toString();
          } else if (widget.data["deposit"]) {
            amount = widget.data["amount"];
          }
          currentUser.balance = double.parse(
              (currentUser.balance + double.parse(amount)).toStringAsFixed(2));
          FirebaseService service = FirebaseService();
          String amount_fixed = double.parse(amount).toStringAsFixed(2);
          TransactionModel transaction = new TransactionModel(
            userId: currentUser.id,
            userName: currentUser.firstName + " " + currentUser.lastName,
            stripeId: response['data']['id'] ?? "",
            stripeTxId: "Google Pay",
            rideDistance: 0.0,
            rideTime: 0,
            amount: double.parse(amount_fixed),
            txType: "Deposit",
          );
          await service.createTransaction(transaction);

          updateUserResult = await service.updateUser(currentUser);
        } else if (widget.data["isStart"]) {
          updateUserResult = true;
        }
        if (updateUserResult) {
          Alert.showMessage(
            type: TypeAlert.success,
            title: AppLocalizations.of(context).success,
            message: AppLocalizations.of(context).googlePaySuccess,
          );
          await payWithAppleGoogle();
        } else {
          Alert.showMessage(
            type: TypeAlert.error,
            title: AppLocalizations.of(context).error,
            message: AppLocalizations.of(context).errorMsg,
          );
        }
      } else {
        HelperUtility.closeProgressDialog(_keyLoader);
        Alert.showMessage(
          type: TypeAlert.error,
          title: AppLocalizations.of(context).error,
          message: AppLocalizations.of(context).errorMsg,
        );
      }
    } catch (e) {
      HelperUtility.closeProgressDialog(_keyLoader);

      String message = AppLocalizations.of(context).errorMsg;
      if (e is PlatformException) {
        PlatformException error = e as PlatformException;
        message = error.code == "Canceled" ? error.message.toString() : message;
      }
      Alert.showMessage(
          type: TypeAlert.error,
          title: AppLocalizations.of(context).error,
          message: message);
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
    String amount = "0";
    if (widget.data["isStart"]) {
      amount = AppProvider.of(context).selectedPrice!.startCost.toString();
    } else if (widget.data["deposit"]) {
      amount = widget.data["amount"];
    }
    return await HttpService().nativePay(
      // amount: AppProvider.of(context).selectedPrice!.totalCost.toString(),
      amount: amount,
      email: AppProvider.of(context).currentUser.email,
      paymethod: paymethod,
    );
  }

  /******************************
   * @Auth: world.digital.dev@gmail.com
   * @Date: 2023.04.13
   * @Desc: Power On Scooter
   */
  Future<void> payWithAppleGoogle() async {
    print("----- Google Apple Pay Functions");
    // ========== Calculate Ride Time ===========
    // PriceModel _priceModel = AppProvider.of(context).selectedPrice!;
    // int _time = _priceModel.totalCost ~/ _priceModel.cost * 60;
    CardModel extracard;

    if (Platform.isAndroid) {
      extracard = new CardModel(
        id: AppProvider.of(context).currentUser.id,
        cardName: "",
        cardNumber: "",
        expMonth: '',
        expYear: '',
        cvv: '',
        cardType: "GooglePay",
      );
    } else {
      extracard = new CardModel(
        id: AppProvider.of(context).currentUser.id,
        cardName: "",
        cardNumber: "",
        expMonth: '',
        expYear: '',
        cvv: '',
        cardType: "ApplePay",
      );
    }

    UserModel currentUser = AppProvider.of(context).currentUser;
    currentUser.card = extracard;
    AppProvider.of(context).setCurrentUser(currentUser);

    if (widget.data['deposit']) {
      HelperUtility.goPageReplace(
        context: context,
        routeName: Routes.WALLET,
      );
    } else if (widget.data['isStart']) {
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
      //       title: AppLocalizations.of(context).error,
      //       message: powerOn['message'] ?? AppLocalizations.of(context).errorMsg);
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
    if (widget.data["isStart"]) {
      amount = AppProvider.of(context).selectedPrice!.startCost.toString();
      print("For google pay option");
      print(amount);
    } else if (widget.data["deposit"]) {
      amount = widget.data["amount"];
    }

    UserModel currentUser = AppProvider.of(context).currentUser;
    double user_balance = currentUser.balance;
    String rest_amount =
        (double.parse(amount) - user_balance).toStringAsFixed(2);

    return [
      PaymentItem(
        label: 'Kiwi City',
        // amount: AppProvider.of(context).selectedPrice!.totalCost.toString(),
        // amount: "0",
        amount: rest_amount,
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

    // isExistCard = true;

    var platform = Theme.of(context).platform;
    var appProvider = AppProvider.of(context);

    /*********************
     * @Auth: world324digital
     * @Date: 2023.04.02
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
                                    : AppLocalizations.of(context).others,
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
                      color: Color(0xffC6D5F6),
                    ),
                    child: Text(
                      AppLocalizations.of(context).selected,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Montserrat-Bold',
                          color: ColorConstants.cPrimaryBtnColor),
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
     * @Auth: world324digital
     * @Date: 2023.04.02
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
                AppLocalizations.of(context).addNewCard,
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
                AppLocalizations.of(context).cardHolderName,
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
                      color: ColorConstants.cPrimaryBtnColor,
                    ),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                autocorrect: false,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == "") {
                    return AppLocalizations.of(context).cardHolderError;
                  } else if (value!.length > 100) {
                    return AppLocalizations.of(context).cardHolderLengthError;
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
                AppLocalizations.of(context).cardNumber,
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
                  hintText: AppLocalizations.of(context).cardNumber,
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
                      color: ColorConstants.cPrimaryBtnColor,
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
                    return AppLocalizations.of(context).cardNumberError;
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
                        AppLocalizations.of(context).expDate,
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
                              color: ColorConstants.cPrimaryBtnColor,
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
                        AppLocalizations.of(context).securityCode,
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
                              color: ColorConstants.cPrimaryBtnColor,
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
                            return AppLocalizations.of(context).invalidCode;
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
                  title: AppLocalizations.of(context).completePayment,
                  height: 50,
                  borderRadius: BorderRadius.circular(12)),
            )
          ],
        ),
      ),
    );

    /*********************
     * @Auth: world324digital
     * @Date: 2023.04.02
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
        label: Text(AppLocalizations.of(context).addPayment,
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

    // return isUnlocking
    //     ? UnLock(isMore: widget.data['isMore']):
    return isLoading
        ? Center(
            child: CircularProgressIndicator(
                color: ColorConstants.cPrimaryBtnColor),
          )
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
                  AppLocalizations.of(context).paymentMethod,
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
                        if (AppProvider.of(context).selectedPrice != null ||
                            widget.data["deposit"])
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
                                    AppLocalizations.of(context).googlePayError,
                                  ),
                                  onError: (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppLocalizations.of(context)
                                              .googlePayUnavailable,
                                        ),
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
