import 'package:Move/Helpers/helperUtility.dart';
import 'package:Move/Routes/routes.dart';
import 'package:Move/Widgets/primaryButton.dart';
import 'package:Move/Widgets/terms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../RideNowPage/ride_now.dart';

class Drink extends StatefulWidget {
  const Drink({super.key, required this.onNext});
  final Function onNext;

  @override
  State<Drink> createState() => _Drink();
}

class _Drink extends State<Drink> {
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
      padding: const EdgeInsets.only(top: 60, bottom: 12),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 30),
            child: Image.asset('assets/images/drink.png'),
          ),
          TermsTitle(text: 'Finally! Don\'t Drink \& Ride'),
          TermsContent(
              text:
                  'Please don\'t operate this scooter if you are under the influence. See terms of service.'),
        ],
      ),
    );
    Widget allowSection = Center(
        child: Align(
      alignment: Alignment.bottomCenter,
      child: Column(children: <Widget>[
        PrimaryButton(
            context: context,
            onTap: () {
              //
              HelperUtility.goPage(
                  context: context, routeName: Routes.RIDE_HOME);
            },
            title: "I'm Ready")
      ]),
    ));
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Container(
          color: Colors.white,
          child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Column(
                children: [
                  Expanded(
                      child: ListView(
                    children: [
                      headerSection,
                    ],
                  )),
                  allowSection,
                  SizedBox(
                    height: 30,
                  )
                ],
              ))),
    );
  }
}
