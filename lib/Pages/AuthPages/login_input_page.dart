import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Helpers/helperUtility.dart';
import 'package:KiwiCity/Helpers/local_storage.dart';
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

class LoginInputPage extends StatefulWidget {
  const LoginInputPage({super.key});

  @override
  State<LoginInputPage> createState() => _LoginInputPage();
}

class _LoginInputPage extends State<LoginInputPage> {
  final TextEditingController _emailController = TextEditingController();

  String _email = '';
  String _errormessge = '';
  String _password = '';
  FirebaseService service = FirebaseService();
  AuthMethods authMethods = new AuthMethods();

  bool _passwordVisible = false;
  final _formKey = GlobalKey<FormState>();

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /*******************************
   * @Auth: world.digital.dev@gmail.com
   * @Date: 2023.03.29
   * @Desc: Login with Email
   */
  Future<void> loginWithEmail() async {
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar.
      // In the real world,
      // you'd often call a server or save the information in a database.

      FocusManager.instance.primaryFocus?.unfocus();
      await service.initializeFirebase();

      //===== Show Progress Dialog ==========
      HelperUtility.showProgressDialog(context: context, key: _keyLoader);
      try {
        await service
            .signInWithEmail(email: _email, password: _password)
            .then((UserCredential result) async {
          print("Sign In Response::::::::::::> ${result}");

          // ============ Get Current User Profile
          await service.getUser(result.user!.uid).then((userModel) async {
            print("Login User Model");
            print(userModel);
            if (userModel != null) {
              // UserModel userModel =
              //     UserModel.fromMap(data: user, id: result.user!.uid);

              //========== Store Logined to local ========
              await storeDataToLocal(
                  key: AppLocalKeys.IS_LOGIN,
                  value: true,
                  type: StorableDataType.BOOL);
              await storeDataToLocal(
                  key: AppLocalKeys.UID,
                  value: result.user!.uid,
                  type: StorableDataType.String);

              AppProvider.of(context).setCurrentUser(userModel);
              AppProvider.of(context).setLogined(true);
              AppProvider.of(context).setLoginType(LoginType.EMAIL);

              // ================== Close Progress Dialog ============
              HelperUtility.closeProgressDialog(_keyLoader);

              // Navigator.of(context).pop();

              if (await Permission.camera.isGranted) {
                HelperUtility.goPageReplace(
                  context: context,
                  routeName: Routes.QR_SCAN,
                );
              } else {
                HelperUtility.goPageReplace(
                    context: context, routeName: Routes.ALLOW_CAMERA);
              }
            } else {
              UserModel userModel = new UserModel(
                id: result.user!.uid,
                firstName: "",
                lastName: "",
                email: _email,
                dob: "",
                card: null,
                balance: 0.0,
              );
              await service.createUser(userModel);

              //========== Store Logined to local ========
              await storeDataToLocal(
                  key: AppLocalKeys.IS_LOGIN,
                  value: true,
                  type: StorableDataType.BOOL);
              await storeDataToLocal(
                  key: AppLocalKeys.UID,
                  value: result.user!.uid,
                  type: StorableDataType.String);

              AppProvider.of(context).setCurrentUser(userModel);
              AppProvider.of(context).setLogined(true);
              AppProvider.of(context).setLoginType(LoginType.EMAIL);

              // ================== Close Progress Dialog ============
              HelperUtility.closeProgressDialog(_keyLoader);

              // Navigator.of(context).pop();
              if (await Permission.camera.isGranted) {
                HelperUtility.goPageReplace(
                  context: context,
                  routeName: Routes.QR_SCAN,
                );
              } else {
                HelperUtility.goPageReplace(
                    context: context, routeName: Routes.ALLOW_CAMERA);
              }
            }
          });
        });
      } on FirebaseAuthException catch (e) {
        // ================== Close Progress Dialog ============
        HelperUtility.closeProgressDialog(_keyLoader);
        if (e.code == 'user-not-found') {
          print('user_not_found');

          Alert.showMessage(
              type: TypeAlert.error,
              title: "ERROR",
              message: "This user could not be found!");
        } else if (e.code == 'wrong-password') {
          print('wrong password');
          Alert.showMessage(
              type: TypeAlert.error,
              title: "ERROR",
              message: "This password is wrong");
        } else if (e.code == 'user-disabled') {
          print('user disabled');

          Alert.showMessage(
              type: TypeAlert.error,
              title: "ERROR",
              message: "This user is disabled.");
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
        Alert.showMessage(
            type: TypeAlert.error, title: "ERROR", message: e.toString());
      }
      // HelperUtility.closeProgressDialog(_keyLoader);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget titleSection = Form(
      key: _formKey,
      child: Container(
        padding:
            const EdgeInsets.only(top: 32, bottom: 12, left: 25, right: 25),
        child: Row(
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
                      autovalidateMode: AutovalidateMode.onUserInteraction,
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
                            borderSide:
                                BorderSide(color: const Color(0xffEEEEEE)),
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
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      'Password',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w200,
                          fontFamily: 'Montserrat-Medium'),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    width: double.infinity,
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.text,
                      obscureText: !_passwordVisible,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Password Required';
                        }
                        if ((value?.length)! < 6) {
                          return 'must contain 6 letters at least';
                        }
                        return null;
                      },
                      onChanged: (text) {
                        setState(() {
                          _password = text!;
                        });
                      }, //This will obscure text dynamically
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 10),
                        hintText: 'password',
                        hintStyle: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Montserrat-Regular',
                            color: Color.fromRGBO(181, 181, 181, 1)),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: ColorConstants.cPrimaryBtnColor,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: const Color(0xffEEEEEE)),
                            borderRadius: BorderRadius.circular(15.0)),
                        // Here is key idea
                        suffixIcon: IconButton(
                          icon: Icon(
                            // Based on passwordVisible state choose the icon
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: ColorConstants.cPrimaryBtnColor,
                          ),
                          onPressed: () {
                            // Update the state i.e. toogle the state of passwordVisible variable
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  // Container(
                  //   margin: const EdgeInsets.only(bottom: 5),
                  //   child: Text(
                  //     '6 characters minimum',
                  //     style: TextStyle(color: Colors.grey),
                  //   ),
                  // ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.only(bottom: 5),
                    child: InkWell(
                      onTap: () {
                        HelperUtility.goPage(
                            context: context,
                            routeName: Routes.FORGET_PASSWORD);
                      },
                      child: Text(
                        'Forget Your Password?',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w200,
                          fontFamily: 'Montserrat-Medium',
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    Widget continueSection = Center(
        child: Align(
      alignment: Alignment.bottomCenter,
      child: Column(children: <Widget>[
        PrimaryButton(
          context: context,
          onTap: () async {
            await loginWithEmail();
          },
          title: "Login Now",
        ),
        Container(
            alignment: Alignment.center,
            // padding: const EdgeInsets.all(20),
            margin: EdgeInsets.only(top: 10, bottom: 40),
            child: GestureDetector(
              onTap: () {
                HelperUtility.goPage(
                    context: context, routeName: Routes.SIGN_UP);
              },
              child: Text(
                'Create New Account',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Montserrat-Medium',
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.01,
                  height: 1.6,
                ),
              ),
            ))
      ]),
    ));
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
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  'Continue with Email',
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
            body: Column(
              children: [
                Expanded(
                    child: ListView(
                  children: [
                    titleSection,
                  ],
                )),
                continueSection
              ],
            )));
  }
}
