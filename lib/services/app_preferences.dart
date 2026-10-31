import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences extends ChangeNotifier {
  AppPreferences._();

  static final AppPreferences instance = AppPreferences._();

  static const _themeKey = 'app_dark_mode';
  static const _languageKey = 'app_language';

  bool _darkMode = false;
  String _language = 'en';

  bool get darkMode => _darkMode;
  String get language => _language;
  bool get isKhmer => _language == 'km';

  ThemeMode get themeMode =>
      _darkMode ? ThemeMode.dark : ThemeMode.light;

  Locale get locale => Locale(_language);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    _darkMode = prefs.getBool(_themeKey) ?? false;

    final savedLanguage = prefs.getString(_languageKey);
    _language = savedLanguage == 'km' ? 'km' : 'en';

    notifyListeners();
  }

  Future<void> setDarkMode(bool enabled) async {
    _darkMode = enabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, enabled);
  }

  Future<void> setLanguage(String value) async {
    if (value != 'en' && value != 'km') return;

    _language = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, value);
  }

  String translate(String english, String khmer) {
    return isKhmer ? khmer : english;
  }
}