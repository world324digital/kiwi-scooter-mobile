import 'package:KiwiCity/Helpers/constant.dart';
import 'package:KiwiCity/Pages/QRScanPage/allow_camera.dart';
import 'package:KiwiCity/Pages/QRScanPage/qr_scan_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
// import 'package:openstreetmap/qr_scan.dart';
import 'package:passwordfield/passwordfield.dart';
import 'Pages/AuthPages/SignUp.dart';
import 'package:validators/validators.dart';
import 'Services/auth.dart';
import 'services/firebase_service.dart';
import 'tools/functions.dart';

class ContEmail extends StatefulWidget {
  const ContEmail({super.key});

  @override
  State<ContEmail> createState() => _ContEmail();
}

class _ContEmail extends State<ContEmail> {
  final TextEditingController _emailController = TextEditingController();

  String _email = '';
  String _errormessge = '';
  String _password = '';
  FirebaseService service = FirebaseService();
  AuthMethods authMethods = new AuthMethods();

  bool _passwordVisible = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget headerSection = Container(
      padding: const EdgeInsets.only(top: 32, bottom: 12),
      child: const Text(
        'Continue with Email',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat-Bold'),
      ),
    );
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
                          fontWeight: FontWeight.w200,
                          fontFamily: 'Montserrat-Medium'),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 5),
                    child: TextFormField(
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
                          _email = text!;
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
                    margin: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      '6 characters minimum',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  // Container(
                  //     padding:const EdgeInsets.only(top:32),
                  //     child:Row(
                  //         children: const <Widget>[
                  //           Expanded(
                  //               child: Divider(
                  //                 thickness: 1,
                  //                 color:Colors.grey
                  //               )
                  //           ),
                  //
                  //           Text("    or    ", style: TextStyle(fontSize: 20),),
                  //
                  //           Expanded(
                  //               child: Divider(
                  //                 thickness: 1,
                  //                 color:Colors.grey
                  //               )
                  //           ),
                  //         ]
                  //     )
                  // ),
                  // Container(
                  //     width: double.infinity,
                  //     padding: const EdgeInsets.only(top:25),
                  //     child: ElevatedButton.icon(
                  //       icon:Icon(Icons.apple_sharp, color: Colors.black),
                  //       label: Text('Continue with Apple', style: TextStyle(fontSize: 18.0, fontFamily: 'Montserrat', color: Colors.black),),
                  //       style:ElevatedButton.styleFrom(
                  //         backgroundColor: Colors.white,
                  //         padding: const EdgeInsets.all(17),
                  //         textStyle: TextStyle(color: Colors.white),
                  //         shape:  RoundedRectangleBorder(
                  //           borderRadius:  BorderRadius.circular(16.0),
                  //           side: const BorderSide(color: Colors.black),
                  //         ),
                  //       ),
                  //       onPressed: () {},
                  //     )
                  // )
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
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.06,
          padding: const EdgeInsets.only(left: 14, right: 14),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstants.cPrimaryBtnColor,
              textStyle: const TextStyle(
                  color: Colors.white, fontFamily: 'Montserrat'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
                side: const BorderSide(color: ColorConstants.cPrimaryBtnColor),
              ),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // If the form is valid, display a snackbar. In the real world,
                // you'd often call a server or save the information in a database.
                service
                    .signInWithEmail(email: _email, password: _password)
                    .then((result) {
                  print(result);
                  // if(val)
                  // if (result == 'VERIFIED') {
                  //   // ignore: use_build_context_synchronously
                  //   // ignore: use_build_context_synchronously
                  //       print('verified');
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(builder: (context) => QRViewExample()),
                  //       );
                  //   } else if (result == 'NOT_VERIFIED') {
                  //     print('Not verified');
                  //     // ignore: use_build_context_synchronously
                  //     showMessage(context,
                  //         'You are not verified yet. Please check your email.',
                  //         title: 'Info');
                  //   }
                  if (result == 'USER_NOT_FOUND') {
                    print('user_not_found');
                    // ignore: use_build_context_synchronously
                    showMessage(context, 'This user could not be found.',
                        title: 'Info');
                  } else if (result == 'WRONG_PASSWORD') {
                    print('wrong password');
                    // ignore: use_build_context_synchronously
                    showMessage(context, 'This password is wrong.',
                        title: 'Info');
                  } else if (result == 'USER_DISABLED') {
                    print('user disabled');
                    // ignore: use_build_context_synchronously
                    showMessage(context, 'This user is disabled.',
                        title: 'Info');
                  } else if (result == 'INVALID_EMAIL') {
                    print('invalied email');
                    // ignore: use_build_context_synchronously
                    showMessage(context, 'This email is invalid.',
                        title: 'Info');
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AllowCamera()),
                    );
                  }
                });
                // service.signInWithEmail(email: _email, password: _password).then((val){
                //   print(val);
                // });
              }
              ;
            },
            child: const Text('Login Now',
                style: TextStyle(
                    fontSize: 16.0,
                    fontFamily: 'Montserrat-Bold',
                    fontWeight: FontWeight.w700)),
          ),
        ),
        Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              child: Text(
                'Create New Account',
                style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Montserrat-Medium',
                    fontWeight: FontWeight.w500),
              ),
            ))
      ]),
    ));
    return MaterialApp(
        debugShowCheckedModeBanner: false,
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
                    continueSection
                  ],
                ))));
  }
}
