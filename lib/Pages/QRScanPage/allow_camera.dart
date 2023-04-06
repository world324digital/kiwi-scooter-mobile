import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Helpers/helperUtility.dart';
import 'package:KiwiCity/Routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:permission_handler/permission_handler.dart';

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
      child: Text("Enter Code"),
      onPressed: () {
        Navigator.of(context).pop();
        HelperUtility.goPage(context: context, routeName: Routes.ENTERCODE);
      },
    );
    Widget okButton = TextButton(
      child: Text("Open"),
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
          title: const Text('WARNING'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "${Messages.WARNING_PERMISSION_DENIND_PERMENANT_TITLE}",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: FontStyles.fLight,
                  ),
                ),
                Text(
                  "${Messages.WARNING_PERMISSION_DENIND_PERMENANT_MSG}",
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
      child: Text("Maybe Later"),
      onPressed: () {
        Navigator.of(context).pop();
        HelperUtility.goPage(context: context, routeName: Routes.ENTERCODE);
      },
    );
    Widget okButton = TextButton(
      child: Text("Restart"),
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
          title: const Text('Alert'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('If you changed permission, Pleast restart app'),
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
            margin: const EdgeInsets.only(top: 100, bottom: 30),
            child: Image.asset('assets/images/allowcamera.png'),
          ),
          const Text(
            'Camera Access',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20,
                fontFamily: 'Montserrat-Bold',
                fontWeight: FontWeight.w600),
          ),
          const Text(
            'Required To Scan Code',
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
              'We will need to access your camera \nso you can scan the QR code.',
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
          height: MediaQuery.of(context).size.height * 0.06,
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstants.cPrimaryBtnColor,
              textStyle: const TextStyle(
                  color: Colors.white, fontFamily: 'Montserrat'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13.0),
                side: const BorderSide(color: ColorConstants.cPrimaryBtnColor),
              ),
            ),
            onPressed: () async {
              await allowCamera();
            },
            child: const Text(
              'Allow Camera',
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
                'No, I\'ll enter code manually',
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
