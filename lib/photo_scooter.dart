import 'package:KiwiCity/preview_page.dart';

import 'dart:async';
import 'dart:io';
import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Helpers/helperUtility.dart';
import 'package:KiwiCity/Pages/App/app_provider.dart';
import 'package:KiwiCity/Routes/routes.dart';
import 'package:KiwiCity/Widgets/unableAlert.dart';
import 'package:KiwiCity/services/firebase_service.dart';
import 'package:flutter/services.dart';
import 'license_scan_overlay.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class PhotoScooter extends StatefulWidget {
  PhotoScooter({Key? key, required this.data}) : super(key: key);
  dynamic data;

  @override
  State<PhotoScooter> createState() => _PhotoScooterState();
}

class _PhotoScooterState extends State<PhotoScooter> {
  late CameraController _cameraController;
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  bool flashOn = false;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initCamera(widget.data['camera']![0]);
  }

  Future takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    if (_cameraController.value.isTakingPicture) {
      return null;
    }
    try {
      await _cameraController.setFlashMode(FlashMode.off);
      XFile picture = await _cameraController.takePicture();
      String path = picture.path;
      debugPrint("path is ${path}");
      print(path);
      await uploadPhoto(path);
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  Future<void> uploadPhoto(String path) async {
    HelperUtility.showProgressDialog(
        context: context, key: _keyLoader, title: "Uploading...");
    try {
      String url = await FirebaseService().uploadImage(
          file: File(path),
          fileName:
              "${AppProvider.of(context).scooterID}${DateTime.now().millisecondsSinceEpoch}");
      print(url);
      HelperUtility.closeProgressDialog(_keyLoader);

      HelperUtility.goPageReplace(
          context: context,
          routeName: Routes.HOWRIDE,
          arg: {"scooterPhoto": url});
    } catch (e) {
      print(e);
      HelperUtility.closeProgressDialog(_keyLoader);
      unableAlert(
          context: context,
          message: "Unable to take a photo of your scooter. Please try again.",
          btnTxt: "Try Again",
          title: 'Unable to upload',
          onTap: () async {
            await takePicture();
          });
    }
  }

  Future initCamera(CameraDescription cameraDescription) async {
    _cameraController = CameraController(
        cameraDescription, ResolutionPreset.high,
        enableAudio: false);
    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("camera error $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double cutWidth = MediaQuery.of(context).size.width - 50;
    double cutHeight = MediaQuery.of(context).size.height * 0.55;
    double offSet = 0;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: const Color.fromRGBO(11, 11, 11, 0.55),
        statusBarIconBrightness: Brightness.dark,
      ),
      child: new WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(children: <Widget>[
              (_cameraController.value.isInitialized)
                  ? Container(
                      width: HelperUtility.screenWidth(context),
                      height: HelperUtility.screenHeight(context),
                      child: CameraPreview(_cameraController))
                  : Container(
                      width: HelperUtility.screenWidth(context),
                      height: HelperUtility.screenHeight(context),
                      color: ColorConstants.cPrimaryBtnColor,
                      child: const Center(child: CircularProgressIndicator())),
              Padding(
                padding: EdgeInsets.zero,
                child: Container(
                  decoration: ShapeDecoration(
                    color: Colors.transparent,
                    shape: QrScannerOverlayShape(
                      cutOutBottomOffset: offSet,
                      borderColor: Colors.white,
                      borderRadius: 24,
                      borderLength: 100,
                      borderWidth: 15,
                      cutOutHeight: cutHeight,
                      cutOutWidth: cutWidth,
                      overlayColor:
                          ColorConstants.cPrimaryTitleColor.withOpacity(0.75),
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.08),
                alignment: Alignment.topCenter,
                child: Text(
                    textAlign: TextAlign.center,
                    'Take a shot of the eScooter\n parked properly',
                    style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat-SemiBold')),
              ),
              Positioned(
                bottom: 30,
                left: 0,
                child: Column(
                  children: [
                    // ============ Take Photo Button
                    Container(
                      height: HelperUtility.screenHeight(context) * 0.08,
                      width: HelperUtility.screenWidth(context),
                      padding: EdgeInsets.only(
                          bottom: 12,
                          left: (MediaQuery.of(context).size.width - cutWidth) /
                              2,
                          right:
                              (MediaQuery.of(context).size.width - cutWidth) /
                                  2),
                      child: OutlinedButton.icon(
                        icon: Container(
                          width: 15,
                          height: 15,
                          child: Image.asset('assets/images/camera.png'),
                        ),
                        label: const Text('Take a shot',
                            style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.white,
                                fontFamily: 'Montserrat-SemiBold',
                                fontWeight: FontWeight.w700)),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(0, 0, 0, 0),
                          textStyle: const TextStyle(
                              color: Colors.white, fontFamily: 'Montserrat'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            side: const BorderSide(color: Colors.white),
                          ),
                        ).copyWith(
                          side: MaterialStateProperty.resolveWith<BorderSide>(
                            (Set<MaterialState> states) {
                              return BorderSide(
                                color: Colors.white,
                                width: 1,
                              );
                              // Defer to the widget's default.
                            },
                          ),
                        ),
                        onPressed: () async {
                          await takePicture();
                        },
                      ),
                    ),

                    // =========== TURN FLASH ON/ OFF  BUTTON
                    Container(
                      height: 20,
                      child: OutlinedButton(
                        onPressed: () async {
                          if (flashOn) {
                            _cameraController.setFlashMode(FlashMode.always);
                          } else {
                            _cameraController.setFlashMode(FlashMode.off);
                          }
                        },
                        child: Text(
                          'TURN ON FLASH',
                          style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Montserrat-Bold',
                              color: Colors.white),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
