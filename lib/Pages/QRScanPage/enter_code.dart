import 'dart:io';

import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Helpers/helperUtility.dart';
import 'package:KiwiCity/Helpers/local_storage.dart';
import 'package:KiwiCity/Pages/App/app_provider.dart';
import 'package:KiwiCity/Routes/routes.dart';
import 'package:KiwiCity/Widgets/toast.dart';
import 'package:KiwiCity/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../StartRidingPage/start_riding_page.dart';
import 'qr_scan_page.dart';

class EnterCode extends StatefulWidget {
  const EnterCode({super.key});

  @override
  State<EnterCode> createState() => _EnterCode();
}

class _EnterCode extends State<EnterCode> {
  final TextEditingController _codeController = TextEditingController();

  String get _code => _codeController.text;
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /************************
   * @Auth: world.digital.dev@gmail.com
   * @Date: 2023.04.02
   * @Desc: Confirm Scooter ID
   */
  Future<void> confirmScooterID() async {
    if (_code.isNotEmpty) {
      // ========= Check Scooter ID is valid =======
      HelperUtility.showProgressDialog(context: context, key: _keyLoader);
      FirebaseService service = FirebaseService();
      try {
        var code = _code.toUpperCase();
        String imei = await service.isValidScooterID(scooterID: code);

        Future.delayed(const Duration(milliseconds: 500), () async {
          HelperUtility.closeProgressDialog(_keyLoader);
          if (imei != "") {
            // Save Scooter ID and IMEI
            AppProvider.of(context).setScooterID(code);
            AppProvider.of(context).setScooterImei(imei);
            await storeDataToLocal(
                key: AppLocalKeys.SCOOTER_ID,
                value: code,
                type: StorableDataType.String);
            await storeDataToLocal(
                key: AppLocalKeys.IMEI,
                value: imei,
                type: StorableDataType.String);

            //============== Go to Start Riding Page ====
            HelperUtility.goPage(
                context: context,
                routeName: Routes.START_RIDING,
                arg: {
                  "isMore": false,
                });
          } else {
            Alert.showMessage(
                type: TypeAlert.error,
                title: AppLocalizations.of(context).error,
                message: Messages.ERROR_INVALID_SCOOTERID);
          }
        });
      } catch (e) {
        print(e);
        Future.delayed(const Duration(milliseconds: 500), () {
          HelperUtility.closeProgressDialog(_keyLoader);
          Alert.showMessage(
              type: TypeAlert.error,
              title: AppLocalizations.of(context).error,
              message: e.toString());
        });
      }
    } else {
      Alert.showMessage(
        type: TypeAlert.warning,
        title: AppLocalizations.of(context).error,
        message: AppLocalizations.of(context).enterScooterCodeMsg1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // final _screen = MediaQuery.of(context).size;
    Widget headerSection = Container(
      padding:
          const EdgeInsets.only(top: 50, bottom: 50, left: 100, right: 100),
      child: Text(
        AppLocalizations.of(context).enterScooterCodeMsg2,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Montserrat-SemiMedium'),
      ),
    );
    Widget inputSection = Container(
        padding: EdgeInsets.only(
            top: 32,
            bottom: 12,
            left: HelperUtility.screenWidth(context) * 0.2,
            right: HelperUtility.screenWidth(context) * 0.2),
        child: Container(
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(color: ColorConstants.cPrimaryBtnColor)),
          child: TextField(
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                height: 0.8,
                letterSpacing: -0.08,
                fontFamily: FontStyles.fMedium,
                color: Colors.black),
            controller: _codeController,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(top: 5),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: ColorConstants.cPrimaryBtnColor,
                ),
                borderRadius: BorderRadius.circular(15.0),
              ),
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(15.0)),
            ),
            autocorrect: true,
            textInputAction: TextInputAction.next,
          ),
        ));
    Widget confirmSection = Container(
      width: double.infinity,
      height: HelperUtility.screenHeight(context) * 0.06,
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.only(left: 14, right: 14),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorConstants.cPrimaryBtnColor,
          textStyle:
              const TextStyle(color: Colors.black, fontFamily: 'Montserrat'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                HelperUtility.screenWidth(context) * 0.04),
            // side: const BorderSide(
            //     color: Color.fromRGBO(255, 219, 209, 1),
            //     style: BorderStyle.solid),
          ),
        ),
        onPressed: () async {
          await confirmScooterID();
        },
        child: Text(AppLocalizations.of(context).confirm,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontFamily: 'Montserrat-Bold',
                fontWeight: FontWeight.w700)),
      ),
    );
    Widget continueSection = Center(
        child: Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: HelperUtility.screenWidth(context) * 0.5,
            height: HelperUtility.screenHeight(context) * 0.065,
            margin: EdgeInsets.only(top: 20, bottom: Platform.isIOS ? 40 : 20),
            padding: const EdgeInsets.only(left: 20, right: 10),
            child: OutlinedButton.icon(
              icon: Container(
                  child: Image.asset(
                'assets/images/cancel.png',
                width: 30,
                height: 30,
              )),
              label: Text(AppLocalizations.of(context).cancel,
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Color.fromRGBO(255, 175, 164, 1),
                      fontFamily: 'Montserrat-Bold')),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.only(
                    top: 12, bottom: 12, left: 18, right: 18),
                textStyle: const TextStyle(
                    color: Color.fromRGBO(255, 175, 164, 1),
                    fontFamily: 'Montserrat'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13.0),
                  // side: const BorderSide(color: Color.fromRGBO(255, 175, 164, 1), width: 2),
                ),
              ).copyWith(
                side: MaterialStateProperty.resolveWith<BorderSide>(
                  (Set<MaterialState> states) {
                    return BorderSide(
                      color: Color.fromRGBO(255, 175, 164, 1),
                      width: 1,
                    );
                    // Defer to the widget's default.
                  },
                ),
              ),
              onPressed: () {
                HelperUtility.goPageAllClear(
                    context: context, routeName: Routes.HOME);
              },
            ),
          ),
          Container(
            width: HelperUtility.screenWidth(context) * 0.5,
            height: HelperUtility.screenHeight(context) * 0.065,
            margin: EdgeInsets.only(top: 20, bottom: Platform.isIOS ? 40 : 20),
            padding: const EdgeInsets.only(left: 10, right: 20),
            child: OutlinedButton.icon(
                icon: Container(
                    child: Image.asset(
                  'assets/images/scanimg.png',
                  width: 30,
                  height: 30,
                )),
                label: Text(AppLocalizations.of(context).scan,
                    style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                        fontFamily: 'Montserrat-Bold')),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.only(
                      top: 12, bottom: 12, left: 18, right: 18),
                  textStyle: const TextStyle(
                      color: Colors.white, fontFamily: 'Montserrat'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13.0),
                    side: const BorderSide(color: Colors.white, width: 0),
                  ),
                ).copyWith(
                  side: MaterialStateProperty.resolveWith<BorderSide>(
                    (Set<MaterialState> states) {
                      return BorderSide(width: 0, style: BorderStyle.none);
                      // Defer to the widget's default.
                    },
                  ),
                ),
                onPressed: () {
                  HelperUtility.goPageReplace(
                    context: context,
                    routeName: Routes.QR_SCAN,
                  );
                }),
          ),
        ],
      ),
    ));
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Color.fromRGBO(102, 102, 102, 1),
        body: Column(
          children: [
            Expanded(
                child: ListView(
              children: [headerSection, inputSection, confirmSection],
            )),
            continueSection
          ],
        ),
      ),
    );
  }
}
