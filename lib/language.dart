import 'package:KiwiCity/Helpers/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:KiwiCity/locale_provider.dart';

class LanguageSetting extends StatefulWidget {
  const LanguageSetting({super.key});

  @override
  State<LanguageSetting> createState() => _LanguageSetting();
}

class _LanguageSetting extends State<LanguageSetting> {
  bool isLoading = false;
  String localeString = 'en';

  @override
  void initState() {
    super.initState();
    getLocale();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handleLanguageChanged(String value) async {
    setState(() {
      localeString = value;
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('locale', value);
    Locale newLocale = const Locale('en', 'US');
    if (value == 'lv') {
      newLocale = Locale('lv', 'LV');
    } else if (value == 'el') {
      newLocale = Locale('el', 'GR');
    }
    LocaleProvider.of(context).setLocale(newLocale);
  }

  Future<void> getLocale() async {
    setState(() {
      isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      localeString = prefs.getString('locale')!;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              AppLocalizations.of(context).language,
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
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(
                    color: ColorConstants.cPrimaryBtnColor),
              )
            : Container(
                padding: const EdgeInsets.only(top: 22, left: 20, right: 20),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        'English',
                      ),
                      onTap: () {
                        _handleLanguageChanged('en');
                      },
                      leading: Radio(
                        value: 'en',
                        groupValue: localeString,
                        activeColor: ColorConstants.cPrimaryBtnColor,
                        onChanged: (val) =>
                            _handleLanguageChanged(val!.toString()),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Latvian',
                      ),
                      onTap: () {
                        _handleLanguageChanged('lv');
                      },
                      leading: Radio(
                        value: 'lv',
                        groupValue: localeString,
                        activeColor: ColorConstants.cPrimaryBtnColor,
                        onChanged: (val) =>
                            _handleLanguageChanged(val!.toString()),
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        _handleLanguageChanged('el');
                      },
                      title: Text(
                        'Greek',
                      ),
                      leading: Radio(
                        value: 'el',
                        groupValue: localeString,
                        activeColor: ColorConstants.cPrimaryBtnColor,
                        onChanged: (val) =>
                            _handleLanguageChanged(val!.toString()),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
