import 'package:KiwiCity/Helpers/constant.dart';
// import 'package:KiwiCity/Helpers/helperUtility.dart';
import 'package:KiwiCity/Widgets/toast.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:KiwiCity/Routes/routes.dart';
// import 'package:KiwiCity/Pages/AllowPermissionPage/screens/allow_notification_page.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:KiwiCity/Widgets/primaryButton.dart';
// import 'package:KiwiCity/firebase_options.dart';

class AllowLocationPage extends StatefulWidget {
  const AllowLocationPage({super.key, required this.onNext()});
  final Function onNext;

  @override
  State<AllowLocationPage> createState() => _AllowLocationPage();
}

class _AllowLocationPage extends State<AllowLocationPage> {
  String _authStatus = 'Unknown';

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 300), (() async {
      /*** For Andorid */
      // _showNotifyDialog();
    }));

    /******* For IOS */
    initPlugin();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /*****************************
   * @Auth: world324digital
   * @Date: 2023.04.01
   * @Desc: Show permission Dialog when disalbe permission of location 
   */

  Future<void> _showNotifyDialog() async {
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () async {
        Navigator.of(context).pop();
      },
    );
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Notice',
            style: TextStyle(
              color: ColorConstants.cPrimaryBtnColor,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  "${Messages.NOTIFY_MESSAGE}",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: FontStyles.fLight,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[okButton],
        );
      },
    );
  }

  Future<void> _showPermissionDialog() async {
    Widget cancelButton = TextButton(
      child: Text("Maybe Later"),
      onPressed: () {
        Navigator.of(context).pop();

        // return widget.onNext();
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.HOME,
          (Route<dynamic> route) => false,
        );
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
   * @Date: 2023.04.01
   * @Desc: Restart app when set permissions of App
   */

  Future<void> _showRestartDialog() async {
    Widget cancelButton = TextButton(
      child: Text("Maybe Later"),
      onPressed: () {
        Navigator.of(context).pop();

        // return widget.onNext();

        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.HOME,
          (Route<dynamic> route) => false,
        );
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

  /***************************
   * @Auth: world324digital
   * @Date: 2023.04.01
   * @Desc: Allow Location
   */
  Future<void> initPlugin() async {
    final TrackingStatus status =
        await AppTrackingTransparency.trackingAuthorizationStatus;
    setState(() => _authStatus = '$status');
    // If the system can show an authorization request dialog
    if (status == TrackingStatus.notDetermined) {
      // Show a custom explainer dialog before the system dialog
      // await showCustomTrackingDialog(context);
      // Wait for dialog popping animation
      await Future.delayed(const Duration(milliseconds: 200));
      // Request system's tracking authorization dialog
      final TrackingStatus status =
          await AppTrackingTransparency.requestTrackingAuthorization();

      setState(() => _authStatus = '$status');
    }

    final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();

    print("UUID: $uuid");
    print(_authStatus);
  }

  // Future<void> showCustomTrackingDialog(BuildContext context) async =>
  //     await showDialog<void>(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: const Text('Dear User'),
  //         content: const Text(
  //           'We care about your privacy and data security. We keep this app free by showing ads. '
  //           'Can we continue to use your data to tailor ads for you?\n\nYou can change your choice anytime in the app settings. '
  //           'Our partners will collect data and use a unique identifier on your device to show you ads.',
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text('Continue'),
  //           ),
  //         ],
  //       ),
  //     );

  Future<void> allowLocation() async {
    checkLocatioPermission();
  }

  Future<void> checkLocatioPermission() async {
    PermissionStatus status;
    status = await Permission.location.status;

    final permission = await Geolocator.requestPermission();
    print(permission);
    if (permission == LocationPermission.denied) {
      Alert.showMessage(
          type: TypeAlert.warning,
          title: "WARNING",
          message: Messages.WARNING_PERMISSION_CANCEL);
    }
    // return widget.onNext();

    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.HOME,
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget headerSection = Container(
      padding: const EdgeInsets.only(top: 32, bottom: 12),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 30),
            child: Image.asset(
              'assets/images/Frame 6264.png',
              height: MediaQuery.of(context).size.height * 0.4,
            ),
          ),
          const Text(
            'Allow Location',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20,
                fontFamily: 'Montserrat-SemiBold',
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                height: 1),
          ),
        ],
      ),
    );
    Widget titleSection = Container(
      padding: const EdgeInsets.only(bottom: 32, left: 30, right: 30),
      child: Row(
        children: [
          Expanded(
            /*1*/
            child: Container(
                alignment: Alignment.center,
                child: const Text(
                  "To provide the best possible experience and help you find eScooters quickly, KiwiCity requires access to your device's location.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Montserrat-SemiBold',
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(102, 102, 102, 1),
                      fontSize: 14,
                      height: 1.5),
                )),
          ),
        ],
      ),
    );
    Widget allowSection = Center(
        child: Align(
      alignment: Alignment.bottomCenter,
      child: Column(children: <Widget>[
        PrimaryButton(
          context: context,
          title: "Allow Location",
          onTap: () {
            allowLocation();
          },
        ),
        Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () {
                // // Navigator.push(
                // //   context,
                // //   MaterialPageRoute(builder: (context) => Notificate1()),
                // // );
                // if (_authStatus == "TrackingStatus.authorized") {
                // widget.onNext();

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.HOME,
                  (Route<dynamic> route) => false,
                );
                // } else {
                //   requestAppTrackingPermission(context);
                // }
              },
              child: Text(
                'Maybe Later',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: FontStyles.fBold,
                    fontStyle: FontStyle.normal,
                    color: Colors.black),
              ),
            ))
      ]),
    ));

    return Column(
      children: [
        Expanded(
            child: ListView(
          children: [
            headerSection,
            titleSection,
          ],
        )),
        allowSection,
        SizedBox(
          height: 30,
        )
        // AllowLocationPage()
      ],
    );
  }
}
