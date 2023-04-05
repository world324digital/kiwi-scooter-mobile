import 'package:KiwiCity/Widgets/primaryButton.dart';
import 'package:KiwiCity/Widgets/terms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Helmet extends StatefulWidget {
  const Helmet({super.key, required this.onNext});
  final Function onNext;

  @override
  State<Helmet> createState() => _Helmet();
}

class _Helmet extends State<Helmet> {
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
            margin: const EdgeInsets.only(bottom: 30),
            child: Image.asset('assets/images/helmet.png'),
          ),
          TermsTitle(text: 'Please Wear Helmet'),
          TermsContent(
              text: 'KiwiCity safely by using the helmet attached to this scooter'),
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
            title: "I Agree")
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
