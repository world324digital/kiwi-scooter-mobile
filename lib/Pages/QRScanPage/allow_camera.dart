import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Helpers/helperUtility.dart';
import 'package:KiwiCity/Routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AllowCamera extends StatefulWidget {
  const AllowCamera({super.key});

  @override
  State<AllowCamera> createState() => _AllowCamera();
}

class _AllowCamera extends State<AllowCamera> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // ======= Check Camera permission =======
    // getCameraPermission();
  }

  void dispose() {
    super.dispose();
  }

  Future<void> getCameraPermission() async {
    bool granted = await Permission.camera.isGranted;

    print(granted);
    if (granted) {
      HelperUtility.goPageReplace(
        context: context,
        routeName: Routes.QR_SCAN,
      );
    } else {}
  }

  /************************************
   * @Auth: world324digital
   * @Date: 2023.04.19
   * @Desc: Allow Camera Permission
   */
  Future<void> allowCamera() async {
    PermissionStatus status = await Permission.camera.request();

    print(status);
    if (status.isGranted) {
      HelperUtility.goPageReplace(context: context, routeName: Routes.QR_SCAN);
    } else {
      _showPermissionDialog();
    }
  }

  /*****************************
   * @Auth: world324digital
   * @Date: 2023.04.03
   * @Desc: Show permission Dialog when disalbe permission of location 
   */

  Future<void> _showPermissionDialog() async {
    Widget cancelButton = TextButton(
      child: Text(AppLocalizations.of(context).enterCode),
      onPressed: () {
        Navigator.of(context).pop();
        HelperUtility.goPage(context: context, routeName: Routes.ENTERCODE);
      },
    );
    Widget okButton = TextButton(
      child: Text(AppLocalizations.of(context).open),
      onPressed: () async {
        Navigator.of(context).pop();
        bool status = await openAppSettings();
        if (status) _showRestartDialog();
      },
    );
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).warning),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "${AppLocalizations.of(context).warningPermissionDenindPermenantTitle}",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: FontStyles.fLight,
                  ),
                ),
                Text(
                  "${AppLocalizations.of(context).warningPermissionDenindPermenantMsg}",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: FontStyles.fLight,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[cancelButton, okButton],
        );
      },
    );
  }

  /*****************************
   * @Auth: world324digital
   * @Date: 2023.04.03
   * @Desc: Restart app when set permissions of App
   */

  Future<void> _showRestartDialog() async {
    Widget cancelButton = TextButton(
      child: Text(AppLocalizations.of(context).maybeLater),
      onPressed: () {
        Navigator.of(context).pop();
        HelperUtility.goPage(context: context, routeName: Routes.ENTERCODE);
      },
    );
    Widget okButton = TextButton(
      child: Text(AppLocalizations.of(context).restart),
      onPressed: () async {
        Navigator.of(context).pop();
        // await PM.openAppSettings();
        Phoenix.rebirth(context);
      },
    );
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).alert),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(AppLocalizations.of(context).alertMsg),
              ],
            ),
          ),
          actions: <Widget>[cancelButton, okButton],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget headerSection = Container(
      padding: const EdgeInsets.only(top: 32, bottom: 12),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 50, bottom: 30),
            child: Image.asset('assets/images/allowcamera.png'),
          ),
          Text(
            AppLocalizations.of(context).cameraAccess,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20,
                fontFamily: 'Montserrat-Bold',
                fontWeight: FontWeight.w600),
          ),
          Text(
            AppLocalizations.of(context).requireScanCode,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20,
                fontFamily: 'Montserrat-Bold',
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
    Widget titleSection = Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(bottom: 32, left: 30, right: 30),
        child: Container(
          child: Text(
              textAlign: TextAlign.center,
              AppLocalizations.of(context).accessCameraMsg,
              style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Montserrat-Medium',
                  color: Color.fromRGBO(102, 102, 102, 1))),
        ));

    Widget allowSection = Center(
        child: Align(
      alignment: Alignment.bottomCenter,
      child: Column(children: <Widget>[
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.075,
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstants.cPrimaryBtnColor,
              textStyle: const TextStyle(
                  color: Colors.white, fontFamily: 'Montserrat'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: const BorderSide(color: ColorConstants.cPrimaryBtnColor),
              ),
            ),
            onPressed: () async {
              await allowCamera();
            },
            child: Text(
              AppLocalizations.of(context).allowCamera,
              style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'Montserrat-Bold',
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
        Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.1),
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () {
                HelperUtility.goPage(
                    context: context, routeName: Routes.ENTERCODE);
              },
              child: Text(
                AppLocalizations.of(context).enterCodeMsg,
                style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Montserrat-Bold',
                    fontWeight: FontWeight.w700),
              ),
            ))
      ]),
    ));
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        ),
        child: Container(
            color: Colors.white,
            child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Column(
                  children: [
                    Expanded(
                        child: Column(
                      children: [
                        headerSection,
                        titleSection,
                      ],
                    )),
                    allowSection
                  ],
                ))));
  }
}
