import 'dart:io';

import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Helpers/helperUtility.dart';
import 'package:KiwiCity/Helpers/local_storage.dart';
import 'package:KiwiCity/Models/user_model.dart';
import 'package:KiwiCity/Pages/App/app_provider.dart';
import 'package:KiwiCity/Routes/routes.dart';
import 'package:KiwiCity/Widgets/primaryButton.dart';
import 'package:KiwiCity/Widgets/toast.dart';
import 'package:KiwiCity/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:validators/validators.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  FirebaseService service = FirebaseService();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  /***********************
   * @Auth: world.digital.dev@gmail.com
   * @Date: 2023.03.29
   * @Desc: SignIn with Google
   */
  Future<void> googleSignIn() async {
    try {
      var res = await service.signInwithGoogle();
      print("+++++++++++++++++++++++++++++++++\r\n");
      print(res!.user);
      if (res != null) {
        String _username = res.user!.displayName ?? "";
        List<String> tempArr = _username.split(" ");

        String firstName = tempArr[0];
        String lastName = tempArr.length > 1 ? tempArr[1] : '';
        // --------- Get User Profile ---------------
        HelperUtility.showProgressDialog(context: context, key: _keyLoader);
        print("++++++++++++++++++++++++");
        print(res.user);
        UserModel? userModel = await service.getUser(res.user!.uid);
        print("-------------User Info \r\n ");
        print(userModel);

        if (userModel != null) {
          //========== Store Logined to local Storage ========
          await storeDataToLocal(
              key: AppLocalKeys.IS_LOGIN,
              value: true,
              type: StorableDataType.BOOL);
          await storeDataToLocal(
              key: AppLocalKeys.UID,
              value: userModel.id,
              type: StorableDataType.String);

          AppProvider.of(context).setCurrentUser(userModel);
          AppProvider.of(context).setLogined(true);
          AppProvider.of(context).setLoginType(LoginType.GOOGLE);

          // ------- Close Progress Dialog ---------------
          HelperUtility.closeProgressDialog(_keyLoader);

          if (await Permission.camera.isGranted) {
            HelperUtility.goPageReplace(
              context: context,
              routeName: Routes.QR_SCAN,
            );
          } else {
            HelperUtility.goPageReplace(
              context: context,
              routeName: Routes.ALLOW_CAMERA,
            );
          }
        } else {
          UserModel userModel = new UserModel(
            id: res.user!.uid,
            firstName: firstName,
            lastName: lastName,
            email: res.user!.email!,
            dob: "",
            card: null,
            balance: 0.0,
          );

          bool createRes = await service.createUser(userModel);
          print(createRes);

          // ------- Close Progress Dialog ---------------
          HelperUtility.closeProgressDialog(_keyLoader);

          if (createRes) {
            //========== Store Logined to local Storage ========
            await storeDataToLocal(
                key: AppLocalKeys.IS_LOGIN,
                value: true,
                type: StorableDataType.BOOL);
            await storeDataToLocal(
                key: AppLocalKeys.UID,
                value: userModel.id,
                type: StorableDataType.String);

            AppProvider.of(context).setCurrentUser(userModel);
            AppProvider.of(context).setLogined(true);
            AppProvider.of(context).setLoginType(LoginType.GOOGLE);

            Alert.showMessage(
                type: TypeAlert.success,
                title: "SUCCESS",
                message: "SignUp Success.");

            HelperUtility.goPage(
              context: context,
              routeName: Routes.ALLOW_CAMERA,
            );
          } else {
            Alert.showMessage(
              type: TypeAlert.error,
              title: "ERROR",
              message: Messages.ERROR_MSG,
            );
          }
        }
      } else {
        Alert.showMessage(
          type: TypeAlert.error,
          title: "ERROR",
          message: Messages.ERROR_MSG,
        );
      }
    } catch (e) {
      print(e);
      Alert.showMessage(
        type: TypeAlert.error,
        title: "ERROR",
        message: e.toString(),
      );
    }
  }

  /***********************************
   * @Auth: world.digital.dev@gmail.com
   * @Date: 2023.03.29
   * @Desc: SignIn With Apple
   */
  Future<void> appleSignIn() async {
    try {
      User res = await service.signInWithApple();
      if (res != null) {
        String firstName =
            res.displayName != null ? res.displayName!.split(" ")[0] : '';
        String lastName =
            res.displayName != null ? res.displayName!.split(" ")[1] : '';
        firstName = firstName == "null" ? "" : firstName;
        lastName = lastName == "null" ? "" : lastName;
        // --------- Get User Profile ---------------
        HelperUtility.showProgressDialog(context: context, key: _keyLoader);
        UserModel? userModel = await service.getUser(res.uid);

        if (userModel != null) {
          //========== Store Logined to local Storage ========
          await storeDataToLocal(
              key: AppLocalKeys.IS_LOGIN,
              value: true,
              type: StorableDataType.BOOL);
          await storeDataToLocal(
              key: AppLocalKeys.UID,
              value: userModel.id,
              type: StorableDataType.String);

          AppProvider.of(context).setCurrentUser(userModel);
          AppProvider.of(context).setLogined(true);
          AppProvider.of(context).setLoginType(LoginType.APPLE);

          // ------- Close Progress Dialog ---------------
          HelperUtility.closeProgressDialog(_keyLoader);

          if (await Permission.camera.isGranted) {
            HelperUtility.goPageReplace(
              context: context,
              routeName: Routes.QR_SCAN,
            );
          } else {
            HelperUtility.goPageReplace(
              context: context,
              routeName: Routes.ALLOW_CAMERA,
            );
          }
        } else {
          UserModel userModel = new UserModel(
            id: res.uid,
            firstName: firstName,
            lastName: lastName,
            email: res.email!,
            dob: "",
            card: null,
            balance: 0,
          );

          bool createRes = await service.createUser(userModel);
          print(createRes);

          Future.delayed(const Duration(milliseconds: 500), () async {
            // ------- Close Progress Dialog ---------------
            HelperUtility.closeProgressDialog(_keyLoader);

            if (createRes) {
              //========== Store Logined to local Storage ========
              await storeDataToLocal(
                  key: AppLocalKeys.IS_LOGIN,
                  value: true,
                  type: StorableDataType.BOOL);
              await storeDataToLocal(
                  key: AppLocalKeys.UID,
                  value: userModel.id,
                  type: StorableDataType.String);

              AppProvider.of(context).setCurrentUser(userModel);
              AppProvider.of(context).setLogined(true);
              AppProvider.of(context).setLoginType(LoginType.APPLE);

              Alert.showMessage(
                  type: TypeAlert.success,
                  title: "SUCCESS",
                  message: "SignUp Success.");

              HelperUtility.goPage(
                context: context,
                routeName: Routes.ALLOW_CAMERA,
              );
            } else {
              Alert.showMessage(
                type: TypeAlert.error,
                title: "ERROR",
                message: Messages.ERROR_MSG,
              );
            }
          });
        }
      } else {
        Alert.showMessage(
          type: TypeAlert.error,
          title: "ERROR",
          message: Messages.ERROR_MSG,
        );
      }
    } catch (e) {
      Future.delayed(const Duration(milliseconds: 500), () {
        // ------- Close Progress Dialog ---------------
        HelperUtility.closeProgressDialog(_keyLoader);
        print(e);
        Alert.showMessage(
          type: TypeAlert.error,
          title: "ERROR",
          message: "You are failed. Please retry!",
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //for title
    Widget titleSection = Container(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.03,
          bottom: 10,
          left: 32,
          right: 32),
      color: Colors.white,
      child: Row(
        children: [
          /*1*/
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /*2*/
                Text(
                  'Fuel prices are high! Save time and money \n '
                  'by renting eScooters for less than \$0.25/min \n'
                  'to explore your destination!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: FontStyles.fMedium,
                      fontWeight: FontWeight.w400,
                      color: ColorConstants.cTxtColor2,
                      fontSize: 14,
                      height: 1.4,
                      letterSpacing: -0.01),
                )
              ],
            ),
          ),
        ],
      ),
    );
    // for signIn section

    Widget buttonSection = Column(
      children: <Widget>[
        PrimaryButton(
            context: context,
            onTap: () {
              HelperUtility.goPage(
                  context: context, routeName: Routes.LOGIN_INPUT);
            },
            title: "Continue With Email",
            margin: EdgeInsets.only(bottom: 5)),
        if (Platform.isAndroid)
          FutureBuilder(
            future: service.initializeFirebase(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error initializing Firebase');
              } else if (snapshot.connectionState == ConnectionState.done) {
                return PrimaryButton(
                  context: context,
                  onTap: () async {
                    await googleSignIn();
                  },
                  title: "Continue With Google",
                  icon: Image.asset(
                    "assets/images/google_icon.png",
                    width: 20,
                    height: 20,
                  ),
                  color: ColorConstants.cPrimaryTitleColor,
                );
              }
              return CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white,
                ),
              );
            },
          )
        else if (Platform.isIOS)
          PrimaryButton(
            context: context,
            onTap: () async {
              await appleSignIn();
            },
            title: "Sign In With Apple",
            icon: Icon(Icons.apple_sharp),
            color: ColorConstants.cPrimaryTitleColor,
          ),
        // SignInWithAppleButton(
        //   onPressed: () async {},
        //   borderRadius: BorderRadius.circular(16),
        // ),
        SizedBox(
          height: HelperUtility.screenHeight(context) * 0.03,
        )
      ],
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(children: [
            Expanded(
              child: ListView(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 80),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: MediaQuery.of(context).size.width * 0.48,
                      height: MediaQuery.of(context).size.height * 0.07,
                    ),
                  ),
                  titleSection,
                  Container(
                      margin: const EdgeInsets.only(top: 40),
                      width: double.infinity,
                      child: Image.asset(
                        'assets/images/bikerun.png',
                        // width: MediaQuery.of(context).size.width * 0.48,
                        height: MediaQuery.of(context).size.height * 0.40,
                        // fit: BoxFit.fill
                      ))
                ],
              ),
            ),
            buttonSection
          ])),
    );
  }
}
