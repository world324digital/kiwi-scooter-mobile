import 'dart:async';
import 'dart:io';
import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Helpers/helperUtility.dart';
import 'package:KiwiCity/Pages/App/app_provider.dart';
import 'package:KiwiCity/Routes/routes.dart';
import 'package:KiwiCity/Widgets/unableAlert.dart';
import 'package:KiwiCity/services/firebase_service.dart';
import 'package:camerawesome/camerawesome_plugin.dart' as CameraAwesome;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'license_scan_overlay.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

// A screen that allows users to take a picture using a given camera.
// ignore: must_be_immutable
class PhotoScooterOld extends StatefulWidget {
  // Obtain a list of the available cameras on the device.

  PhotoScooterOld({
    super.key,
    Object? data,
    // required this.camera,
  });

  // final CameraDescription camera;

  @override
  PhotoScooterOldState createState() => PhotoScooterOldState();
}

class PhotoScooterOldState extends State<PhotoScooterOld> {
  CameraController? _controller;
  late List<CameraDescription> _cameras;
  int UploadPossibility = 0;
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  @override
  void initState() {
    super.initState();
    print("camerea======");
    // print(widget.data["camera"]);
    // To display the current output from the Camera,
    // create a CameraController.
    // _controller = CameraController(
    //   // Get a specific camera from the list of available cameras.
    //   widget.data["camera"],
    //   // Define the resolution to use.
    //   ResolutionPreset.medium,
    // );

    // // Next, initialize the controller. This returns a Future.
    // _initializeControllerFuture = _controller.initialize();
    // getCamera();
  }

  Future<void> getCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras.first, ResolutionPreset.max);
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller?.dispose();
    super.dispose();
  }

  Future<void> takePhoto(CameraAwesome.PhotoCameraState picState) async {
    String path = await picState.takePhoto();

    debugPrint('======= Take Photo Path is : ${path}');

    // we need to first of all define a path before taking the photo

    await uploadPhoto(picState, path);
  }

  Future<String> getStorageDirectory() async {
    if (Platform.isAndroid) {
      return (await getTemporaryDirectory()).path;
      // OR return "/storage/emulated/0/Download";
    } else {
      String tempStr = (await getTemporaryDirectory()).path;
      String str = '';
      if (tempStr.length > 0) {
        str = tempStr.substring(0, tempStr.length - 15);
        print(str);
      }
      return str;
    }
  }

  /******************************************
   * @Auth: world324digital
   * @Date: 2023.03.16
   * @Desc: Upload Image into FireStore
   */
  Future<void> uploadPhoto(
      CameraAwesome.PhotoCameraState picState, String path) async {
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
            await takePhoto(picState);
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    double cutWidth = MediaQuery.of(context).size.width - 50;
    double cutHeight = MediaQuery.of(context).size.height * 0.6;
    double offSet = 0;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        // statusBarColor: Colors.transparent,
        statusBarColor: const Color.fromRGBO(11, 11, 11, 0.55),
        statusBarIconBrightness: Brightness.dark,
      ),
      child: new WillPopScope(
        onWillPop: () async {
          // HelperUtility.goPageReplace(
          //     context: context, routeName: Routes.HOWRIDE);
          return false;
        },
        child: Scaffold(
          body: CameraAwesome.CameraAwesomeBuilder.custom(
            builder: (cameraState) {
              return Stack(
                children: [
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
                          borderWidth: 13,
                          cutOutHeight: cutHeight,
                          cutOutWidth: cutWidth,
                          overlayColor: ColorConstants.cPrimaryTitleColor
                              .withOpacity(0.75),
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
                              left: (MediaQuery.of(context).size.width -
                                      cutWidth) /
                                  2,
                              right: (MediaQuery.of(context).size.width -
                                      cutWidth) /
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
                                  color: Colors.white,
                                  fontFamily: 'Montserrat'),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                                side: const BorderSide(color: Colors.white),
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
                              cameraState.when(onPhotoMode: (picState) async {
                                await takePhoto(picState);
                              });
                            },
                          ),
                        ),

                        // =========== TURN FLASH ON/ OFF  BUTTON
                        Container(
                          height: 20,
                          child: OutlinedButton(
                            onPressed: () async {
                              if (CameraAwesome.FlashMode == FlashMode.off) {
                                await _controller!
                                    .setFlashMode(FlashMode.always);
                              } else {
                                await _controller!.setFlashMode(FlashMode.off);
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
                ],
              );
            },
            saveConfig: CameraAwesome.SaveConfig.photo(
              pathBuilder: () async {
                // final Directory extDir = await getTemporaryDirectory();
                String dir = await getStorageDirectory();
                debugPrint(
                    "========================== app store image path =====, $dir");
                final testDir =
                    await Directory('${dir}/ridemove').create(recursive: true);
                return '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
              },
            ),
          ),
        ),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
