import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Widgets/primaryButton.dart';
import 'package:KiwiCity/Routes/routes.dart';
// import 'package:KiwiCity/Widgets/primaryButton.dart';
import 'package:KiwiCity/Widgets/toast.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AllowNotificationPage extends StatefulWidget {
  const AllowNotificationPage({super.key});

  @override
  State<AllowNotificationPage> createState() => _AllowNotificationPage();
}

class _AllowNotificationPage extends State<AllowNotificationPage> {
  String _authStatus = 'Unknown';
  @override
  void initState() {
    super.initState();
    initPlugin();
  }

  @override
  void dispose() {
    super.dispose();
  }

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

  Future<void> showCustomTrackingDialog(BuildContext context) async =>
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Dear User'),
          content: const Text(
            'We care about your privacy and data security. We keep this app free by showing ads. '
            'Can we continue to use your data to tailor ads for you?\n\nYou can change your choice anytime in the app settings. '
            'Our partners will collect data and use a unique identifier on your device to show you ads.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue'),
            ),
          ],
        ),
      );

  Future<void> requestAuthorize(BuildContext context) async =>
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Warning'),
          content: const Text(
              'Please go to Settings app and change the tracking settings'),
          actions: [
            TextButton(
              onPressed: () async {
                await openAppSettings();
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                _showPermissionDialog();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );

  /*****************************
   * @Auth: world324digital
   * @Date: 2023.04.03
   * @Desc: Show permission Dialog when disalbe permission of location 
   */

  Future<void> _showPermissionDialog() async {
    Widget cancelButton = TextButton(
      child: Text("Maybe Later"),
      onPressed: () {
        Navigator.of(context).pop();

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
      child: Text("Maybe Later"),
      onPressed: () {
        Navigator.of(context).pop();

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

  @override
  void allowNotification() async {
    // if (_authStatus == "TrackingStatus.authorized") {
    //   checkNotificationPermission();
    // } else {
    //   requestAuthorize(context);
    // }
    checkNotificationPermission();
  }

  Future<void> checkNotificationPermission() async {
    PermissionStatus status;
    status = await Permission.notification.status;

    if (!status.isGranted) {
      status = await Permission.notification.request();
      print(status);
      if (status.isGranted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.HOME,
          (Route<dynamic> route) => false,
        );
      } else if (status.isDenied) {
        Alert.showMessage(
            type: TypeAlert.warning,
            title: "WARNING",
            message: Messages.WARNING_PERMISSION_CANCEL);
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.HOME,
          (Route<dynamic> route) => false,
        );
      } else {
        _showPermissionDialog();
      }
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.HOME,
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget headerSection = Container(
      padding: const EdgeInsets.only(top: 32, bottom: 12),
      child: Column(
        children: [
          Container(
            // height: 165,
            height: MediaQuery.of(context).size.height * 0.4,
            margin: const EdgeInsets.only(bottom: 30),
            child: Image.asset(
              'assets/images/bigbell.png',
              height: MediaQuery.of(context).size.height * 0.4,
            ),
          ),
          Text(
            'Allow Notification',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontFamily: FontStyles.fSemiBold,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              height: 1,
            ),
          ),
        ],
      ),
    );
    Widget titleSection = Container(
        padding: const EdgeInsets.only(bottom: 32, left: 50, right: 50),
        child: Row(children: [
          Expanded(
            /*1*/
            child: Container(
                alignment: Alignment.center,
                child: Text(
                  'Get important ride notifications from KiwiCity by turning on the notification feature.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: FontStyles.fSemiBold,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(102, 102, 102, 1),
                      fontSize: 14,
                      height: 1.6),
                )),
          )
        ]));
    Widget allowSection = Center(
        child: Align(
      alignment: Alignment.bottomCenter,
      child: Column(children: <Widget>[
        PrimaryButton(
            context: context,
            onTap: allowNotification,
            title: 'Allow Notification'),
        Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.HOME,
                  (Route<dynamic> route) => false,
                );
              },
              child: Text(
                'Maybe Later',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: FontStyles.fBold,
                    fontStyle: FontStyle.normal,
                    height: 1.6,
                    color: Colors.black),
              ),
            )),
        SizedBox(
          height: 30,
        )
      ]),
    ));
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter layout demo',
        home: Container(
            color: Colors.white,
            child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Column(
                  children: [
                    Expanded(
                        child: ListView(
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
