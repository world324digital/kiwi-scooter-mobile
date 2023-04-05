import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Helpers/helperUtility.dart';
import 'package:KiwiCity/Helpers/local_storage.dart';
import 'package:KiwiCity/Pages/App/app_provider.dart';
import 'package:KiwiCity/Pages/StartRidingPage/start_riding_page.dart';
import 'package:KiwiCity/Routes/routes.dart';
import 'package:KiwiCity/Widgets/toast.dart';
import 'package:KiwiCity/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart' as QRSCAN;
import 'package:permission_handler/permission_handler.dart' as PM;

import 'enter_code.dart';

class QRScanPage extends StatefulWidget {
  QRScanPage({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  String code = '';
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  bool isConfirming = false;
  // Imagine that this function is more complex and slow.

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  bool isCameraAvailable = false;
  bool isShowError = false;
  MobileScannerController cameraController = MobileScannerController(
      // torchEnabled: true,
      );
  // @override
  // void reassemble() {
  //   super.reassemble();
  //   if (Platform.isAndroid) {
  //     controller!.pauseCamera();
  //   }
  //   controller!.resumeCamera();
  // }

  @override
  void initState() {
    super.initState();
    getCameraPermission();
  }

  @override
  void dispose() {
    // controller?.dispose();
    cameraController.dispose();
    super.dispose();
  }

  Future<void> getCameraPermission() async {
    PermissionStatus status = await Permission.camera.status;
    if (!status.isGranted) {
      // Alert.showMessage(
      //     type: TypeAlert.warning,
      //     title: "Camera permission denined.",
      //     message: "Please allow your camera to scan QR code.");
      // HelperUtility.goPage(context: context, routeName: Routes.ALLOW_CAMERA);
      status = await Permission.camera.request();
      if (!status.isGranted) {
        Alert.showMessage(
            type: TypeAlert.warning,
            title: "Camera permission denined.",
            message: "Please allow your camera to scan QR code.");
        setState(() {
          isCameraAvailable = false;
        });
      } else {
        setState(() {
          isCameraAvailable = true;
        });
      }
    } else {
      setState(() {
        isCameraAvailable = true;
      });
    }
  }

  /************************
   * @Auth: world.digital.dev@gmail.com
   * @Date: 2023.03.29
   * @Desc: Confirm Scooter ID
   */
  Future<void> confirmScooterID(String _code) async {
    if (_code.isNotEmpty) {
      cameraController.stop();
      print("??????????????????????? $_code");

      Future.delayed(const Duration(seconds: 1), () async {
        try {
          // ========= Check Scooter ID is valid =======
          FirebaseService service = FirebaseService();

          String imei =
              await service.isValidScooterID(scooterID: _code.toUpperCase());

          if (imei != '') {
            HelperUtility.showProgressDialog(context: context, key: _keyLoader);
            cameraController.stop();

            // Save Scooter ID and IMEI
            AppProvider.of(context).setScooterID(_code);
            AppProvider.of(context).setScooterImei(imei);
            await storeDataToLocal(
                key: AppLocalKeys.SCOOTER_ID,
                value: _code,
                type: StorableDataType.String);
            await storeDataToLocal(
                key: AppLocalKeys.IMEI,
                value: imei,
                type: StorableDataType.String);

            HelperUtility.closeProgressDialog(_keyLoader);
            Future.delayed(const Duration(milliseconds: 100), () {
              HelperUtility.goPageReplace(
                  context: context,
                  routeName: Routes.START_RIDING,
                  arg: {
                    "isMore": false,
                  });
            });
          } else {
            setState(() {
              isShowError = true;
            });

            // showDialog<String>(
            //   context: context,
            //   builder: (BuildContext context) => AlertDialog(
            //     title: Text(
            //       'Scan Scooter QR',
            //       style: TextStyle(
            //         color: ColorConstants.cPrimaryTitleColor,
            //         fontSize: 20,
            //         fontFamily: FontStyles.fSemiBold,
            //       ),
            //     ),
            //     content: const Text('Invalid Scooter ID'),
            //     actions: <Widget>[
            //       TextButton(
            //         onPressed: () {
            //           Navigator.pop(context, 'Cancel');
            //           Future.delayed(const Duration(milliseconds: 1000), () {
            //             cameraController.start();
            //           });
            //         },
            //         child: const Text('RETRY'),
            //       ),
            //       TextButton(
            //         onPressed: () {
            //           Navigator.pop(context, 'OK');
            //           Navigator.pop(context);
            //         },
            //         child: const Text('CANCEL'),
            //       ),
            //     ],
            //   ),
            // );
            // Alert.showMessage(
            //     type: TypeAlert.error,
            //     title: "ERROR",
            //     message: Messages.ERROR_INVALID_SCOOTERID);
            // setState(() {
            //   isConfirming = false;
            // });
          }
        } catch (e) {
          print(e);
          cameraController.start();

          // setState(() {
          //   isConfirming = false;
          // });
          // HelperUtility.closeProgressDialog(_keyLoader);
          // Alert.showMessage(
          //     type: TypeAlert.error, title: "ERROR", message: e.toString());
        }
      });
    } else {
      // setState(() {
      //   isConfirming = false;
      // });
      // Alert.showMessage(
      //     type: TypeAlert.warning,
      //     title: "ERROR",
      //     message: "Please enter code");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: <Widget>[
            Container(
              width: HelperUtility.screenWidth(context),
              height: HelperUtility.screenHeight(context),
              child: MobileScanner(
                // fit: BoxFit.contain,
                controller: cameraController,
                onDetect: (capture) async {
                  final List<Barcode> barcodes = capture.barcodes;
                  String code = "";
                  for (final barcode in barcodes) {
                    debugPrint('Barcode found! ${barcode.rawValue}');
                    if (barcode.rawValue != null) {
                      code = barcode.rawValue!;
                      break;
                    }
                  }

                  print(">>>>>>>>>>>>>>>> Code : $code");

                  var codearr = code.split("/");
                  String deviceID = codearr.last;

                  await confirmScooterID(deviceID);
                },
              ),
            ),
            /******************************************************
               * For iOS, Please use this code
               * child: MobileScanner(
                // fit: BoxFit.contain,
                controller: cameraController,
                onDetect: (capture) async {
                  final List<Barcode> barcodes = capture.barcodes;
                  String code = "";
                  for (final barcode in barcodes) {
                    debugPrint('Barcode found! ${barcode.rawValue}');
                    if (barcode.rawValue != null) {
                      code = barcode.rawValue!;
                      break;
                    }
                  }
                  await confirmScooterID(code);
                },
              ),

              **************************************\
              For Android , Please use this code
              MobileScanner(
                // fit: BoxFit.contain,
                controller: cameraController,
                onDetect: (capture, arg) async {
                  String code = "";
                  debugPrint('Barcode found! ${capture.rawValue}');
                  if (capture.rawValue != null) {
                    code = capture.rawValue!;
                  }
                  await confirmScooterID(code);
                },
              ),
            ),
               */

            Padding(
              padding: EdgeInsets.zero,
              child: Container(
                decoration: ShapeDecoration(
                  color: Colors.transparent,
                  shape: QRSCAN.QrScannerOverlayShape(
                    cutOutBottomOffset: 0,
                    borderColor: Colors.white,
                    overlayColor:
                        ColorConstants.cPrimaryTitleColor.withOpacity(0.75),
                    borderRadius: 24,
                    borderLength: 50,
                    borderWidth: 15,
                    cutOutHeight: 280,
                    cutOutWidth: 280,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 80, left: 60, right: 60),
              alignment: Alignment.topCenter,
              child: Text(
                  textAlign: TextAlign.center,
                  'Scan QR Code or Enter Code displayed on the scooter',
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                      fontFamily: 'Montserrat-SemiBold',
                      height: 1.25)),
            ),
            isShowError
                ? Container(
                    padding: const EdgeInsets.only(top: 150),
                    alignment: Alignment.topCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          textAlign: TextAlign.center,
                          'Invalid QR code',
                          style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.red,
                              fontFamily: 'Montserrat-',
                              height: 1.25),
                        ),
                        // TextButton(
                        //   onPressed: () {
                        //     setState(() {
                        //       isShowError = false;
                        //     });
                        //     Future.delayed(const Duration(milliseconds: 1000),
                        //         () {
                        //       cameraController.start();
                        //     });
                        //   },
                        //   child: Container(
                        //     padding: EdgeInsets.only(top: 5),
                        //     child: Text(
                        //       'Retry',
                        //       style: TextStyle(
                        //         fontSize: 10,
                        //         decoration: TextDecoration.underline,
                        //         color: Colors.red,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  )
                : Container(),
            Container(
              alignment: Alignment.bottomRight,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: HelperUtility.screenWidth(context) * 0.5,
                          height: HelperUtility.screenHeight(context) * 0.065,
                          margin: EdgeInsets.only(
                              bottom:
                                  HelperUtility.screenHeight(context) * 0.06),
                          padding: const EdgeInsets.only(left: 20, right: 10),
                          child: OutlinedButton.icon(
                            icon: Container(
                                child: Image.asset(
                              'assets/images/cancel.png',
                              width: 30,
                              height: 30,
                            )),
                            label: const Text('Cancel',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    color: Color.fromRGBO(255, 175, 164, 1),
                                    fontFamily: 'Montserrat-SemiBold')),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.only(
                                  top: 12, bottom: 12, left: 18, right: 9),
                              textStyle: const TextStyle(
                                  color: Color.fromRGBO(255, 175, 164, 1),
                                  fontFamily: 'Montserrat'),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13.0),
                                // side: const BorderSide(color: Color.fromRGBO(255, 175, 164, 1), width: 2),
                              ),
                            ).copyWith(
                              side:
                                  MaterialStateProperty.resolveWith<BorderSide>(
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
                              cameraController.stop();

                              Future.delayed(const Duration(milliseconds: 100),
                                  () async {
                                HelperUtility.goPageAllClear(
                                    context: context, routeName: Routes.HOME);
                              });
                            },
                          ),
                        ),
                        Container(
                          width: HelperUtility.screenWidth(context) * 0.5,
                          height: HelperUtility.screenHeight(context) * 0.065,
                          margin: EdgeInsets.only(
                              bottom:
                                  HelperUtility.screenHeight(context) * 0.06),
                          padding: const EdgeInsets.only(left: 10, right: 20),
                          child: OutlinedButton.icon(
                            icon: Container(
                                child: Image.asset(
                              'assets/images/flashlight.png',
                              width: 30,
                              height: 30,
                            )),
                            label: const Text('Flashlight',
                                style: TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.white,
                                    fontFamily: 'Montserrat-SemiBold')),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.only(
                                  top: 12, bottom: 12, left: 9, right: 18),
                              textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Montserrat'),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13.0),
                                // side: const BorderSide(color: Colors.white, width: 2),
                              ),
                            ).copyWith(
                              side:
                                  MaterialStateProperty.resolveWith<BorderSide>(
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
                              await cameraController.toggleTorch();
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    Container(
                      alignment: Alignment.center,
                      height: HelperUtility.screenHeight(context) * 0.065,
                      margin: const EdgeInsets.only(bottom: 30),
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: OutlinedButton.icon(
                        icon: Container(
                            child: Image.asset(
                          'assets/images/entercode.png',
                          width: 50,
                          height: 30,
                        )),
                        label: const Text('Manually Enter code',
                            style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.white,
                                fontFamily: 'Montserrat-SemiBold')),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          textStyle: const TextStyle(
                              color: Colors.transparent,
                              fontFamily: 'Montserrat'),
                        ).copyWith(
                          side: MaterialStateProperty.resolveWith<BorderSide>(
                            (Set<MaterialState> states) {
                              return BorderSide(
                                style: BorderStyle.none,
                                width: 0,
                              );
                              // Defer to the widget's default.
                            },
                          ),
                        ),
                        onPressed: () {
                          cameraController.stop();
                          Future.delayed(const Duration(milliseconds: 100), () {
                            HelperUtility.goPageReplace(
                                context: context, routeName: Routes.ENTERCODE);
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
