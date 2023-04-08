import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Helpers/helperUtility.dart';
import 'package:KiwiCity/Models/card_model.dart';
import 'package:KiwiCity/Models/price_model.dart';
import 'package:KiwiCity/Models/user_model.dart';
import 'package:KiwiCity/Pages/App/app_provider.dart';
import 'package:KiwiCity/Pages/PaymentPage/payment_helper.dart';
import 'package:KiwiCity/Pages/UnlockPage/unlock.dart';
import 'package:KiwiCity/Routes/routes.dart';
import 'package:KiwiCity/Widgets/primaryButton.dart';
import 'package:KiwiCity/Widgets/toast.dart';
import 'package:KiwiCity/services/httpService.dart';
import 'package:KiwiCity/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:pay/pay.dart';

import '../MenuPage/main_menu.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  State<WalletPage> createState() => _WalletPage();
}

class _WalletPage extends State<WalletPage> {
  var _amountController = TextEditingController();
  // var _cardNumberController = TextEditingController();
  // var _cardHolderNamerController = TextEditingController();
  // var _cardExpiractionController = TextEditingController();
  // var _cardSecurityCodeController = TextEditingController();
  // var _cardZipCodeController = TextEditingController();
  // bool isExistCard = false;
  // bool isShowCardSection = false;
  // String card_number = '1234********2525';

  final _formKey = GlobalKey<FormState>();

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  bool isUnlocking = false;

  @override
  void dispose() {
    _amountController.dispose();
    // _cardNumberController.dispose();
    // _cardHolderNamerController.dispose();
    // _cardExpiractionController.dispose();
    // _cardSecurityCodeController.dispose();
    // _cardZipCodeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  /****************************
   * @Auth: world324digital
   * @Date: 2023.04.02
   * @Desc: Complete Payment
   */
  Future<void> paySubmit(CardModel card) async {
    print(card.cardType);
    String scooterID = AppProvider.of(context).scooterID;
    // String amount = AppProvider.of(context).selectedPrice!.totalCost.toString();

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
          // amount: amount);
          amount: "0");
      print("Stripe Result :::::::::::::>");
      print(res);

      if (res['result']) {
        String scooterID = AppProvider.of(context).scooterID;
        var powerOn = await HttpService()
            .changePowerStatus(scooterID: scooterID, status: "true");
        print("POWER STATUS:::::::::::>");
        print(powerOn);

        if (powerOn['result']) {
          await powerOnScooter();

          // Card Informatin Save
          UserModel currentUser = AppProvider.of(context).currentUser;

          card.id = currentUser.id;
          currentUser.card = card;

          FirebaseService service = FirebaseService();
          bool updateCardResult = await service.updateCard(currentUser);
          print(updateCardResult);
          if (updateCardResult) {
            // setState(() {
            //   isUnlocking = false;
            // });

            // ========== Calculate Ride Time ===========
            PriceModel _priceModel = AppProvider.of(context).selectedPrice!;
            // int _time = (_priceModel.totalCost / _priceModel.cost).toInt() * 60;

            Future.delayed(const Duration(milliseconds: 200), () {
              AppProvider.of(context).setCurrentUser(currentUser);
              HelperUtility.goPageReplace(
                  context: context,
                  routeName: Routes.TERMS_OF_SERVICE,
                  arg: {"viaPayment": true});
            });
          } else {
            Alert.showMessage(
                type: TypeAlert.error,
                title: "ERROR",
                message: Messages.ERROR_MSG);
          }
        } else {
          if (mounted) {
            setState(() {
              isUnlocking = false;
            });
            Alert.showMessage(
                type: TypeAlert.error,
                title: "ERROR",
                message: powerOn['message'] ?? Messages.ERROR_MSG);
          }
        }
      } else {
        if (mounted)
          setState(() {
            isUnlocking = false;
          });
        Alert.showMessage(
            type: TypeAlert.error,
            title: "ERROR",
            message: res['message'] ?? Messages.ERROR_MSG);
      }
    } catch (e) {
      print(e);
      if (mounted)
        setState(() {
          isUnlocking = false;
        });
      Alert.showMessage(
          type: TypeAlert.error, title: "ERROR", message: e.toString());
    }
  }

  /******************************
   * @Auth: world.digital.dev@gmail.com
   * @Date: 2023.04.13
   * @Desc: Power On Scooter
   */
  Future<void> powerOnScooter() async {
    String scooterID = AppProvider.of(context).scooterID;
    var powerOn = await HttpService()
        .changePowerStatus(scooterID: scooterID, status: "true");
    print("POWER STATUS:::::::::::>");
    print(powerOn);

    if (powerOn['result']) {
      // HelperUtility.goPageReplace(
      //     context: context, routeName: Routes.TERMS_OF_SERVICE, arg: {"viaPayment": true});
    } else {
      setState(() {
        isUnlocking = false;
      });
      Alert.showMessage(
          type: TypeAlert.error,
          title: "ERROR",
          message: powerOn['message'] ?? Messages.ERROR_MSG);
    }
  }

  /***************************
   * Change Card Payment
   */
  Future<void> changeCard(CardModel card) async {
    try {
      HelperUtility.showProgressDialog(context: context, key: _keyLoader);
      // Card Informatin Save
      UserModel currentUser = AppProvider.of(context).currentUser;

      card.id = currentUser.id;
      currentUser.card = card;

      FirebaseService service = FirebaseService();
      bool updateCardResult = await service.updateCard(currentUser);
      print(updateCardResult);

      HelperUtility.closeProgressDialog(_keyLoader);

      if (updateCardResult) {
        Alert.showMessage(
            type: TypeAlert.success,
            title: "SUCCESS",
            message: "Operation success!");
      } else {
        Alert.showMessage(
            type: TypeAlert.error, title: "ERROR", message: Messages.ERROR_MSG);
      }
    } catch (e) {
      print(e);
      HelperUtility.closeProgressDialog(_keyLoader);
      Alert.showMessage(
          type: TypeAlert.error, title: "ERROR", message: Messages.ERROR_MSG);
    }
  }

  @override
  Widget build(BuildContext context) {
    // isExistCard =
    //     AppProvider.of(context).currentUser.card != null ? true : false;

    var platform = Theme.of(context).platform;
    var appProvider = AppProvider.of(context);

    /*********************
     * @Auth: world324digital
     * @Date: 2023.04.02
     * @Desc: Header Section
     */
    Widget headerSection = Container(
        padding: const EdgeInsets.only(top: 10, bottom: 12),
        child: Row(
          children: [
            Expanded(
                child: Row(children: [
              Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Image.asset('assets/images/arrow.png'))),
              Text(
                'My Wallet',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Montserrat-SemiBold',
                    fontWeight: FontWeight.w600,
                    height: 1.4),
              ),
            ])),
            // Container(
            //     child: Image.asset(
            //   'assets/images/note.png',
            //   width: 30,
            //   height: 30,
            // ))
          ],
        ));


    /*********************
     * @Auth: world324digital
     * @Date: 2023.04.02
     * @Desc: Balance Section
     */
    Widget balanceSection = Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(left: 0, top: 20, bottom: 15),
              child: Text(
                'Available Balance',
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
              padding: const EdgeInsets.only(left: 0, top: 10, bottom: 15),
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
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(left: 0, top: 20, bottom: 15),
              child: Text(
                'Add Money',
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
              padding: const EdgeInsets.only(left: 0, top: 0, bottom: 15),
              child: Text(
                'More rides, more discount',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xff666666),
                  fontFamily: FontStyles.fMedium,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            //------------- Deposit amount --------------
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.only(top: 10, bottom: 10, left: 0),
              child: Text(
                'Enter amount',
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Color.fromRGBO(11, 11, 11, 1),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Montserrat-Medium'),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 12, left: 0, right: 0),
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: _amountController,
                decoration: InputDecoration(
                  contentPadding:
                      EdgeInsets.only(left: 15, top: 5, bottom: 5, right: 5),
                  hintText: '0',
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
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a deposit balance';
                  }
                  final deposit = num.tryParse(value ?? '0');
                  if (deposit == null || deposit <= 0) {
                    return 'Please enter a valid deposit amount';
                  }
                  return null;
                },
              ),
            ),

            //------------- Pay Now  Button --------------
            Container(
              margin: EdgeInsets.only(bottom: 10, top: 10),
              child: PrimaryButton(
                context: context,
                onTap: () async {
                  if (_formKey.currentState!.validate()) {
                    String amount = _amountController.text;

                    // await paySubmit(card);
                    HelperUtility.goPage(
                        context: context,
                        routeName: Routes.PAYMENT_METHODS,
                        arg: {
                          "deposit": true,
                          "amount": amount,
                          "isMore": false
                        });
                  }
                },
                title: "Pay Now",
                horizontalPadding: 0,
              ),
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
          // print(_cardNumberController.text);
          setState(() {
            // isShowCardSection = true;
          });
        },
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
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
            'My Wallet',
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
                  balanceSection,
                  // isExistCard ? paySection : Container(),
                  // (isExistCard && !isShowCardSection)
                  //     ? Container()
                  //     : cardSection,
                ],
              ),
            ),
            // isExistCard ? plusSection : Container(),
            SizedBox(
              height: 30,
            )
          ],
        ),
      ),
    );
  }
}
