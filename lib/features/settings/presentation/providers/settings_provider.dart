import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String themeKey = 'theme_mode';
  static const String currencyKey = 'default_currency';

  ThemeMode _themeMode;
  String _defaultCurrency;

  SettingsProvider({
    ThemeMode themeMode = ThemeMode.system,
    String defaultCurrency = 'PKR',
  })  : _themeMode = themeMode,
        _defaultCurrency = defaultCurrency;

  ThemeMode get themeMode => _themeMode;
  String get defaultCurrency => _defaultCurrency;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(themeKey, mode.name);
  }

  Future<void> setDefaultCurrency(String currency) async {
    if (currency == _defaultCurrency) return;
    _defaultCurrency = currency;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(currencyKey, currency);
  }

  static ThemeMode themeModeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
