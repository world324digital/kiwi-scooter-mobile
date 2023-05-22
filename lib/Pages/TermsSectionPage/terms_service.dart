import 'package:KiwiCity/Helpers/constant.dart';
// import 'package:KiwiCity/Pages/TermsSectionPage/prohibit.dart';
import 'package:KiwiCity/Widgets/primaryButton.dart';
import 'package:KiwiCity/Widgets/terms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TermsService extends StatefulWidget {
  const TermsService({super.key, required this.onNext});
  final Function onNext;

  @override
  State<TermsService> createState() => _TermsService();
}

class _TermsService extends State<TermsService> {
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
      padding: EdgeInsets.only(top: 30, bottom: 20),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 30),
            child: Image.asset('assets/images/terms.png'),
          ),
          TermsTitle(text: AppLocalizations.of(context).termsOfService),
          TermsContent(
              text: AppLocalizations.of(context).termsOfServiceDescription),
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
          title: AppLocalizations.of(context).agree,
        ),
        Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.1,
            left: 50,
            right: 50,
          ),
          child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: AppLocalizations.of(context).agreeMsg,
                    style: TextStyle(
                        color: ColorConstants.cTxtColor2,
                        fontSize: 14,
                        fontFamily: FontStyles.fLight,
                        fontWeight: FontWeight.w400,
                        height: 1.6),
                  ),
                  // TextSpan(text: ' our Terms of Use',style: TextStyle(color:ColorConstants.cPrimaryBtnColor)),
                ],
              )),
        ),
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
                ),
              ),
              Container(
                  padding: EdgeInsets.only(bottom: 30), child: allowSection)
            ],
          ),
        ),
      ),
    );
  }
}
