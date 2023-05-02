import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  static LocaleProvider of(BuildContext context, {bool listen = false}) =>
      Provider.of<LocaleProvider>(context, listen: listen);

  LocaleProvider() {
    init();
  }

  Locale _locale = const Locale('en', 'US');

  Locale get locale => _locale;

  void setLocale(Locale newLocale) {
    _locale = newLocale;
    notifyListeners();
  }

  Future<void> initialize() async {
    // simulate some asynchronous initialization process
    final prefs = await SharedPreferences.getInstance();
    String localeString = prefs.getString('locale')!;
    _locale = Locale('en', 'US');
    if (localeString == 'lv') {
      _locale = Locale('lv', 'LV');
    } else if (localeString == 'el') {
      _locale = Locale('el', 'GR');
    }
    print("locale string");
    print(localeString);
  }

  @override
  void dispose() {
    // clean up resources here
    super.dispose();
  }

  Future<void> init() async {
    await initialize();
    notifyListeners();
  }
}
