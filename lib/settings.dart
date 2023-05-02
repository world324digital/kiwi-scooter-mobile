import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Helpers/helperUtility.dart';
import 'package:KiwiCity/Models/user_model.dart';
import 'package:KiwiCity/Pages/App/app_provider.dart';
import 'package:KiwiCity/Routes/routes.dart';
import 'package:KiwiCity/Widgets/primaryButton.dart';
import 'package:KiwiCity/Widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:openstreetmap/verify.dart';
import 'package:validators/validators.dart';
import '../../services/firebase_service.dart';
import '../../tools/functions.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _Settings();
}

class _Settings extends State<Settings> {
  String _firstName = '';
  String _secondName = '';
  String _dob = '';
  String _errormessge = '';
  bool _passwordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  String email = '';

  FirebaseService service = FirebaseService();
  DateTime selectedDate = DateTime.now();
  Future<void> _selectDOBDate(BuildContext context) async {
    List dob = AppProvider.of(context).currentUser.dob.split('-');
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime(int.parse(dob[0]), int.parse(dob[1]), int.parse(dob[2])),
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

  /************************************
   * @Auth: world324digital.
   * @Date: 2023.04.02
   * @Desc: Update Account
   */
  Future<void> _updateAccount() async {
    if (_passwordController.text != _confirmController.text) {
      showMessage(context, AppLocalizations.of(context).passwordNotMatch,
          title: AppLocalizations.of(context).info);
    }
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.

      // ========== Show Progress Dialog ===========
      // HelperUtility.showProgressDialog(context: context, key: _keyLoader);
      UserModel currentUser = AppProvider.of(context).currentUser;
      if (_passwordController.text == "") {
        if (_firstNameController.text != "" || _lastNameController.text != "") {
          currentUser.firstName = _firstNameController.text;
          currentUser.lastName = _lastNameController.text;
        }
        service.updateUser(currentUser).then((res) async {
          print(res);
          if (res) {
            Alert.showMessage(
              type: TypeAlert.success,
              title: AppLocalizations.of(context).success,
              message: AppLocalizations.of(context).updateSuccess,
            );
            AppProvider.of(context).setCurrentUser(currentUser);
            AppProvider.of(context).setIndex(3);
            HelperUtility.goPage(
              context: context,
              routeName: Routes.HOME,
            );
          } else {
            Alert.showMessage(
              type: TypeAlert.error,
              title: AppLocalizations.of(context).error,
              message: AppLocalizations.of(context).errorMsg,
            );
          }
        });
      } else {
        await service
            .updatePassword(newPassword: _passwordController.text)
            .then((result) {
          currentUser.firstName = _firstNameController.text;
          currentUser.lastName = _lastNameController.text;
          currentUser.dob = _dobController.text;

          service.updateUser(currentUser).then((res) async {
            print(res);
            if (res) {
              Alert.showMessage(
                type: TypeAlert.success,
                title: AppLocalizations.of(context).success,
                message: AppLocalizations.of(context).updateSuccess,
              );
              AppProvider.of(context).setCurrentUser(currentUser);
              AppProvider.of(context).setIndex(3);
              HelperUtility.goPage(
                context: context,
                routeName: Routes.HOME,
              );
            } else {
              Alert.showMessage(
                type: TypeAlert.error,
                title: AppLocalizations.of(context).error,
                message: AppLocalizations.of(context).errorMsg,
              );
            }
          });
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _firstNameController.addListener(() {});
    initialValve();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _confirmController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void initialValve() {
    // _dobController.text =
    //     DateFormat('yyyy-MM-dd').format(selectedDate).toString();
    UserModel currentUser = AppProvider.of(context).currentUser;
    _firstNameController.text = currentUser.firstName;
    _lastNameController.text = currentUser.lastName;
    _dobController.text = currentUser.dob;
  }

  @override
  Widget build(BuildContext context) {
    // Widget headerSection = Container(
    //   padding: const EdgeInsets.only(bottom: 22),
    //   child: const Text(
    //     'Settings',
    //     textAlign: TextAlign.center,
    //     style: TextStyle(
    //         fontSize: 20,
    //         fontWeight: FontWeight.w700,
    //         fontFamily: 'Montserrat-Bold',
    //         height: 1.2,
    //         color: ColorConstants.cPrimaryTitleColor),
    //   ),
    // );

    Widget continueSection = Center(
        child: Align(
      alignment: Alignment.bottomCenter,
      child: Column(children: <Widget>[
        PrimaryButton(
          horizontalPadding: 0,
          context: context,
          txtColor: Colors.white,
          color: ColorConstants.cPrimaryBtnColor,
          borderColor: ColorConstants.cPrimaryBtnColor,
          onTap: () async {
            await _updateAccount();
          },
          title: AppLocalizations.of(context).updateAccount,
        ),
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
                      AppLocalizations.of(context).firstName,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black,
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
                      controller: _firstNameController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 10),
                        hintStyle: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Montserrat-Regular',
                            color: Color.fromRGBO(181, 181, 181, 1)),
                        hintText: AppLocalizations.of(context).firstName,
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
                      ),
                      autocorrect: false,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return AppLocalizations.of(context).firstNameRequired;
                        }
                        return null;
                      },
                    ),
                  ),
                  //------Last Name--------
                  Container(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      AppLocalizations.of(context).lastName,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w200,
                          fontFamily: FontStyles.fMedium),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    width: double.infinity,
                    child: TextFormField(
                      controller: _lastNameController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 10),
                        hintStyle: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Montserrat-Regular',
                            color: Color.fromRGBO(181, 181, 181, 1)),
                        hintText: AppLocalizations.of(context).lastName,
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
                      ),
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return AppLocalizations.of(context).lastNameRequired;
                        }
                        return null;
                      },
                      // onChanged: (text) {
                      //   setState(() {
                      //     _secondName = text;
                      //   });
                      // },
                    ),
                  ),
                  //--------email-----------
                  Container(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      AppLocalizations.of(context).email,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w200,
                          fontFamily: FontStyles.fMedium),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 15),
                    child: TextFormField(
                      initialValue: AppProvider.of(context).currentUser.email,
                      readOnly: true,
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
                      ),
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return AppLocalizations.of(context).emailRequired;
                        }
                        if (!isEmail(value!)) {
                          return AppLocalizations.of(context).invalidEmail;
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
                      AppLocalizations.of(context).dob,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black,
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
                          return AppLocalizations.of(context).dobRequired;
                        }
                        if (!isDate(value!)) {
                          return AppLocalizations.of(context).invalidDate;
                        } else if (DateTime.now().year -
                                DateTime.parse(value).year <
                            16) {
                          return AppLocalizations.of(context).ageError;
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 8, bottom: 15),
                    child: Text(
                      AppLocalizations.of(context).ageError,
                      style: TextStyle(
                          fontSize: 12,
                          color: Color.fromRGBO(102, 102, 102, 1),
                          fontFamily: FontStyles.fMedium),
                    ),
                  ),
                  // --------- password---------
                  Container(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      AppLocalizations.of(context).password,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Colors.black,
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
                      // validator: (value) {
                      //   if (value?.isEmpty ?? true) {
                      //     return 'Password Required';
                      //   }
                      //   if ((value?.length)! < 6) {
                      //     return 'must contain 6 letters at least';
                      //   }
                      //   return null;
                      // }, //This will obscure text dynamically
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 10),
                        hintText: AppLocalizations.of(context).password,
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
                      AppLocalizations.of(context).passwordLength,
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
                      AppLocalizations.of(context).confirmPassword,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: Colors.black,
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
                        hintText: AppLocalizations.of(context).password,
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
                      // validator: (value) {
                      //   if (value?.isEmpty ?? true) {
                      //     return 'You must confirm Password';
                      //   }
                      //   if ((value?.length)! < 6) {
                      //     return 'must contain 6 letters at least';
                      //   }
                      //   return null;
                      // },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      AppLocalizations.of(context).passwordLength,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            continueSection,
            SizedBox(
              height: 20,
            )
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
            title: Text(
              AppLocalizations.of(context).settings,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Montserrat-SemiBold',
                fontWeight: FontWeight.w600,
                color: ColorConstants.cPrimaryTitleColor,
                height: 1.4,
              ),
            ),
          ),
          body: formSection,
        ),
      ),
    );
  }
}
