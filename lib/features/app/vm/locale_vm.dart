import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleVM extends ChangeNotifier {
  static const _kKey = 'app_locale_code';
  Locale? _locale; // null = theo hệ thống
  Locale? get locale => _locale;

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final code = sp.getString(_kKey);
    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    if (locale == null) {
      await sp.remove(_kKey);
    } else {
      await sp.setString(_kKey, locale.languageCode);
    }
  }

  String displayName() {
    if (_locale == null) return 'System';
    return _locale!.languageCode == 'vi' ? 'Tiếng Việt' : 'English';
  }
}
