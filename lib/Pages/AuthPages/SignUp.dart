import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Helpers/helperUtility.dart';
import 'package:KiwiCity/Helpers/local_storage.dart';
import 'package:KiwiCity/Models/user_model.dart';
import 'package:KiwiCity/Pages/App/app_provider.dart';
import 'package:KiwiCity/Routes/routes.dart';
import 'package:KiwiCity/Widgets/primaryButton.dart';
import 'package:KiwiCity/Widgets/toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:openstreetmap/verify.dart';
import 'package:validators/validators.dart';
import '../QRScanPage/allow_camera.dart';
import 'package:KiwiCity/services/firebase_service.dart';
import 'package:KiwiCity/tools/functions.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPage();
}

class _SignUpPage extends State<SignUpPage> {
  String _firstName = '';
  String _secondName = '';
  String _dob = '';
  String _errormessge = '';
  bool _passwordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String email = '';

  FirebaseService service = FirebaseService();
  DateTime selectedDate = DateTime.now();
  Future<void> _selectDOBDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1950, 01, 01),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorConstants.cPrimaryBtnColor, // <-- SEE HERE
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dobController.text =
            DateFormat('yyyy-MM-dd').format(selectedDate).toString();
      });
    }
  }

  /*****************************
   * @Auth: world324digital
   * @Date: 2023.04.10
   * @Desc: Launch URL
   */
  _launchURL(String url) async {
    // bool available = await canLaunchUrl(Uri.parse(url));
    await launchUrl(Uri.parse(url));
    // if (available) {
    //   await launchUrl(Uri.parse(url));
    // } else {
    //   // throw 'Could not launch $url';
    //   Alert.showMessage(
    //       type: TypeAlert.error,
    //       title: "ERROR",
    //       message: "Can't launch URL: ${url}");
    // }
  }

  /************************************
   * @Auth: world.digital.dev@gmail.com
   * @Date: 2023.04.11
   * @Desc: Sign Up with Email
   */
  Future<void> _signUp() async {
    await service.initializeFirebase();
    FocusManager.instance.primaryFocus?.unfocus();
    if (_passwordController.text != _confirmController.text) {
      showMessage(context, 'Passwords do not match.', title: 'Info');
    }
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.

      // ========== Show Progress Dialog ===========
      HelperUtility.showProgressDialog(context: context, key: _keyLoader);
      service.registerWithEmail({
        'email': email,
        'password': _passwordController.text
      }).then((result) {
        print("Sign UP::::::::::::::>>>> $result");
        if (result == 'WEAK') {
          HelperUtility.closeProgressDialog(_keyLoader);
          // ignore: use_build_context_synchronously
          Alert.showMessage(
              type: TypeAlert.error,
              title: "ERROR",
              message:
                  "Password strength is too weak. it must be at least 8 in length and contain at least one number.");
        } else if (result == 'DUPLICATED') {
          HelperUtility.closeProgressDialog(_keyLoader);
          Alert.showMessage(
              type: TypeAlert.error,
              title: "ERROR",
              message: "This email address has already been used.");
        } else if (result == 'FAILED') {
          HelperUtility.closeProgressDialog(_keyLoader);
          Alert.showMessage(
              type: TypeAlert.error, title: "ERROR", message: "SignUp Failed.");
        } else {
          // ignore: use_build_context_synchronously
          UserModel userModel = new UserModel(
            id: result,
            firstName: _firstName,
            lastName: _secondName,
            email: email,
            dob: _dobController.text,
            card: null,
            balance: 0.0,
          );

          service.createUser(userModel).then((res) async {
            HelperUtility.closeProgressDialog(_keyLoader);

            print(res);
            if (res) {
              Alert.showMessage(
                  type: TypeAlert.success,
                  title: "SUCCESS",
                  message: "SignUp Success.");

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
              AppProvider.of(context).setLoginType(LoginType.EMAIL);

              HelperUtility.goPageReplace(
                context: context,
                routeName: Routes.ALLOW_CAMERA,
              );
              // Navigator.of(context).pop();
            } else {
              Alert.showMessage(
                type: TypeAlert.error,
                title: "ERROR",
                message: Messages.ERROR_MSG,
              );
            }
          }).onError((error, stackTrace) {
            HelperUtility.closeProgressDialog(_keyLoader);

            print(error);
            Alert.showMessage(
                type: TypeAlert.error,
                title: "ERROR",
                message: error.toString());
          });
        }
      }).onError((error, stackTrace) {
        print(error.toString());
        HelperUtility.closeProgressDialog(_keyLoader);

        Alert.showMessage(
            type: TypeAlert.error, title: "ERROR", message: error.toString());
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dobController.text =
        DateFormat('yyyy-MM-dd').format(selectedDate).toString();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget richTextSection = Container(
        margin: EdgeInsets.only(bottom: 20),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
                fontFamily: 'Montserrat', color: Colors.grey, fontSize: 15.0),
            children: <TextSpan>[
              TextSpan(
                  text: 'By creating an account, you agree to our ',
                  style: TextStyle(
                      fontSize: 12,
                      color: Color.fromRGBO(102, 102, 102, 1),
                      fontFamily: FontStyles.fMedium)),
              TextSpan(
                  text: 'Terms \& Conditions',
                  style: TextStyle(
                    color: ColorConstants.cPrimaryBtnColor,
                    fontSize: 12,
                    fontFamily: FontStyles.fMedium,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      _launchURL(URLS.TERMS_CONDITION_URL);
                    }),
              TextSpan(
                  text: ' and acknowledge our ',
                  style: TextStyle(
                    color: Color.fromRGBO(102, 102, 102, 1),
                    fontSize: 12,
                    fontFamily: FontStyles.fMedium,
                  )),
              TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: ColorConstants.cPrimaryBtnColor,
                    fontSize: 12,
                    fontFamily: FontStyles.fMedium,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _launchURL(URLS.PRIVACY_URL);
                    }),
            ],
          ),
        ));
    Widget continueSection = Center(
        child: Align(
      alignment: Alignment.bottomCenter,
      child: Column(children: <Widget>[
        PrimaryButton(
          horizontalPadding: 0,
          context: context,
          onTap: () async {
            await _signUp();
          },
          title: "Create an Account",
        ),
        Container(
          padding:
              const EdgeInsets.only(top: 15, left: 30, right: 30, bottom: 15),
          child: richTextSection,
        )
      ]),
    ));
    Widget formSection = Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.only(top: 22, left: 25, right: 25),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: ListView(
                children: [
                  //-------First Name------
                  Container(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      'First Name',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: ColorConstants.cPrimaryTitleColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        fontFamily: FontStyles.fMedium,
                        height: 1.6,
                        letterSpacing: -0.01,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 15),
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 10),
                        hintStyle: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Montserrat-Regular',
                            color: Color.fromRGBO(181, 181, 181, 1)),
                        hintText: 'First Name',
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(15.0)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: ColorConstants.cPrimaryBtnColor,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color(0xffEEEEEE),
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        errorStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontFamily: FontStyles.fMedium),
                      ),
                      autocorrect: false,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      inputFormatters: <TextInputFormatter>[
                        UpperCaseTextFormatter()
                      ],
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'First Name Required';
                        }
                        return null;
                      },
                      onChanged: (text) {
                        setState(() {
                          _firstName = text;
                        });
                      },
                    ),
                  ),
                  //------Last Name--------
                  Container(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      'Last Name',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: ColorConstants.cPrimaryTitleColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w200,
                          fontFamily: FontStyles.fMedium),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    width: double.infinity,
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 10),
                        hintStyle: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Montserrat-Regular',
                            color: Color.fromRGBO(181, 181, 181, 1)),
                        hintText: 'Last Name',
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(15.0)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: ColorConstants.cPrimaryBtnColor,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color(0xffEEEEEE),
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        errorStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontFamily: FontStyles.fMedium),
                      ),
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Last Name Required';
                        }
                        return null;
                      },
                      onChanged: (text) {
                        setState(() {
                          _secondName = text;
                        });
                      },
                    ),
                  ),
                  //--------email-----------
                  Container(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      'Email',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: ColorConstants.cPrimaryTitleColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w200,
                          fontFamily: FontStyles.fMedium),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 15),
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        hintStyle: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Montserrat-Regular',
                            color: Color.fromRGBO(181, 181, 181, 1)),
                        contentPadding: const EdgeInsets.only(left: 10),
                        hintText: 'example@email.com',
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(15.0)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: ColorConstants.cPrimaryBtnColor,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color(0xffEEEEEE),
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        errorStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontFamily: FontStyles.fMedium),
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
                          email = text;
                        });
                      },
                    ),
                  ),
                  //------- birdthday-------
                  Container(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      'Date of Birth',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: ColorConstants.cPrimaryTitleColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w200,
                        fontFamily: FontStyles.fMedium,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    width: double.infinity,
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _dobController,
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.only(left: 10, right: 10),
                        hintStyle: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Montserrat-Regular',
                            color: Color.fromRGBO(181, 181, 181, 1)),
                        hintText: 'DD/MM/YYYY',

                        // enabled: false,
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(15.0)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: ColorConstants.cPrimaryBtnColor,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color(0xffEEEEEE),
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        errorStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontFamily: FontStyles.fMedium),
                        suffixIcon: InkWell(
                          onTap: () {
                            _selectDOBDate(context);
                          },
                          child: Icon(
                            Icons.calendar_month,
                            size: 20,
                            color: ColorConstants.cPrimaryBtnColor,
                          ),
                        ),
                      ),
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Birthday Required.';
                        }
                        if (!isDate(value!)) {
                          return 'Invalid Date';
                        } else if (DateTime.now().year -
                                DateTime.parse(value).year <
                            16) {
                          return "Must be at least age 16+";
                        }
                        return null;
                      },
                      onChanged: (text) {
                        setState(() {});
                      },
                    ),
                  ),
                  // Container(
                  //   margin: const EdgeInsets.only(left: 8, bottom: 15),
                  //   child: Text(
                  //     'Must be at least age 16+',
                  //     style: TextStyle(
                  //         fontSize: 12,
                  //         color: ColorConstants.cTxtColor2,
                  //         fontFamily: FontStyles.fMedium),
                  //   ),
                  // ),
                  // --------- password---------
                  Container(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      'Password',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: ColorConstants.cPrimaryTitleColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w200,
                          fontFamily: FontStyles.fMedium),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    width: double.infinity,
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _passwordController,
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
                          borderSide: BorderSide(
                            color: const Color(0xffEEEEEE),
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        errorStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontFamily: FontStyles.fMedium),
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
                  Container(
                    margin: const EdgeInsets.only(left: 8, bottom: 15),
                    child: Text(
                      '6 characters minimum',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color.fromRGBO(102, 102, 102, 1),
                          fontFamily: FontStyles.fMedium),
                    ),
                  ),
                  // --------- confirm password-
                  Container(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      'Confirm Password',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: ColorConstants.cPrimaryTitleColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w100,
                          fontFamily: FontStyles.fMedium),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    width: double.infinity,
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _confirmController,
                      keyboardType: TextInputType.text,
                      obscureText:
                          !_passwordVisible, //This will obscure text dynamically
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
                          borderSide: BorderSide(
                            color: const Color(0xffEEEEEE),
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        errorStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontFamily: FontStyles.fMedium),
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
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'You must confirm Password';
                        }
                        if ((value?.length)! < 6) {
                          return 'must contain 6 letters at least';
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      '6 characters minimum',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            continueSection
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
          body: formSection,
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
                'Create New Account',
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
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: capitalize(newValue.text),
      selection: newValue.selection,
    );
  }
}

String capitalize(String value) {
  if (value.trim().isEmpty) return "";
  return "${value[0].toUpperCase()}${value.substring(1).toLowerCase()}";
}
