import 'package:KiwiCity/Widgets/primaryButton.dart';
import 'package:KiwiCity/Widgets/terms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Prohibit extends StatefulWidget {
  const Prohibit({super.key, required this.onNext});
  final Function onNext;

  @override
  State<Prohibit> createState() => _Prohibit();
}

class _Prohibit extends State<Prohibit> {
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
      padding: EdgeInsets.only(top: 60, bottom: 20),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 30),
            child: Image.asset('assets/images/prohibit.png'),
          ),
          TermsTitle(text: "Obey The Law"),
          TermsContent(
              text:
                  'Do not ride on the beach or restricted areas. You maybe fined for doing so.'),
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
              return widget.onNext();
            },
            title: "Okay")
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
          ),
        ),
      ),
    );
  }
}
