import 'dart:io';

import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Helpers/helperUtility.dart';
import 'package:KiwiCity/Models/user_model.dart';
import 'package:KiwiCity/Pages/App/app_provider.dart';
import 'package:KiwiCity/Routes/routes.dart';
import 'package:KiwiCity/Widgets/primaryButton.dart';
import 'package:KiwiCity/Widgets/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:validators/validators.dart';
import '../../Services/auth.dart';
import '../../services/firebase_service.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPage();
}

class _ForgetPasswordPage extends State<ForgetPasswordPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final TextEditingController _emailController = TextEditingController();
  String _email = '';
  bool isSent = false;
  FirebaseService service = FirebaseService();
  AuthMethods authMethods = new AuthMethods();

  final _formKey = GlobalKey<FormState>();

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  /*******************************
   * @Auth: world.digital.dev@gmail.com
   * @Date: 2023.03.29
   * @Desc: Login with Email
   */

  Future<void> forgetPassword() async {
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.

      //===== Show Progress Dialog ==========
      HelperUtility.showProgressDialog(context: context, key: _keyLoader);

      try {
        await service.resetPassword(email: _email);
        HelperUtility.closeProgressDialog(_keyLoader);
        setState(() {
          isSent = true;
        });
        Alert.showMessage(
            type: TypeAlert.success, title: "Success", message: "Email sent!");
      } on FirebaseAuthException catch (e) {
        print("AAAAAAAA");

        // ================== Close Progress Dialog ============
        HelperUtility.closeProgressDialog(_keyLoader);
        if (e.code == 'user-not-found') {
          print('user_not_found');

          Alert.showMessage(
              type: TypeAlert.error,
              title: "ERROR",
              message: "This user could not be found!");
        } else if (e.code == 'invalid-email') {
          print(e.code == 'invalid-email');
          Alert.showMessage(
              type: TypeAlert.error,
              title: "ERROR",
              message: "This email is invalid.");
        } else {
          Alert.showMessage(
              type: TypeAlert.error,
              title: "ERROR",
              message: Messages.ERROR_MSG);
        }
      } catch (e) {
        HelperUtility.closeProgressDialog(_keyLoader);
        Alert.showMessage(
            type: TypeAlert.error, title: "ERROR", message: e.toString());
      }
      // HelperUtility.closeProgressDialog(_keyLoader);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget emailForm = Form(
      key: _formKey,
      child: Container(
          padding:
              const EdgeInsets.only(top: 32, bottom: 12, left: 25, right: 25),
          child: !isSent
              ? Row(
                  children: [
                    Expanded(
                      /*1*/
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /*2*/
                          Container(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Text(
                              'Email Address',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  height: 1.4,
                                  letterSpacing: -0.01,
                                  fontFamily: 'Montserrat-Medium'),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 5),
                            child: TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              controller: _emailController,
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Montserrat-Regular',
                                    color: Color.fromRGBO(181, 181, 181, 1)),
                                contentPadding: const EdgeInsets.only(left: 10),
                                hintText: 'Email Address',
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red),
                                    borderRadius: BorderRadius.circular(15.0)),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorConstants.cPrimaryBtnColor,
                                  ),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: const Color(0xffEEEEEE)),
                                    borderRadius: BorderRadius.circular(15.0)),
                              ),
                              autocorrect: false,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Email Required';
                                }
                                if (!isEmail(value!)) {
                                  return 'Invalid Email';
                                }
                                return null;
                              },
                              onChanged: (text) {
                                setState(() {
                                  _email = text;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      Text(
                        "We have sent you a reset password link. Please check your email.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: FontStyles.fMedium,
                            fontWeight: FontWeight.w400,
                            height: 1.6,
                            fontSize: 12,
                            color: ColorConstants.cTxtColor2),
                      ),
                      Text(
                        _emailController.text,
                        style: TextStyle(
                            fontFamily: FontStyles.fMedium,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                            fontSize: 14,
                            color: ColorConstants.cPrimaryBtnColor),
                      ),
                    ],
                  ),
                )),
    );
    Widget nextButton = Center(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Column(children: <Widget>[
          PrimaryButton(
              margin: EdgeInsets.only(bottom: Platform.isIOS ? 20 : 10),
              context: context,
              onTap: () async {
                if (!isSent) {
                  await forgetPassword();
                } else {
                  Navigator.of(context).pop();
                }
              },
              title: !isSent ? "Next" : "Done"),
        ]),
      ),
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
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
          title: Container(
            padding: EdgeInsets.only(left: 40),
            child: Text(
              'Forget Password',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontFamily: FontStyles.fSemiBold,
                fontWeight: FontWeight.w700,
                color: ColorConstants.cPrimaryTitleColor,
                height: 1.4,
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            Positioned(
              bottom: Platform.isIOS ? 95 : 75,
              right: 0,
              child: Image.asset('assets/images/bikees.png'),
            ),
            // Container(
            //   width: HelperUtility.screenWidth(context),
            //   height: HelperUtility.screenHeight(context),
            //   padding: EdgeInsets.only(
            //     top: 80,
            //   ),
            //   child: Text(
            //     'Forget Password',
            //     textAlign: TextAlign.center,
            //     style: TextStyle(
            //         fontSize: 20,
            //         fontWeight: FontWeight.w700,
            //         fontFamily: FontStyles.fBold,
            //         height: 1.2,
            //         color: ColorConstants.cPrimaryTitleColor),
            //   ),
            // ),
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [emailForm, nextButton],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
