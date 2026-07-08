import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'features/settings/presentation/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final bool hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
  final ThemeMode themeMode =
      SettingsProvider.themeModeFromString(prefs.getString(SettingsProvider.themeKey));
  final String defaultCurrency =
      prefs.getString(SettingsProvider.currencyKey) ?? 'PKR';
  // final bool isLockEnabled = prefs.getBool('app_lock_enabled') ?? false;

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(SplitEaseApp(
    showOnboarding: !hasSeenOnboarding,
    startLocked: false, // isLockEnabled,
    initialThemeMode: themeMode,
    initialCurrency: defaultCurrency,
  ));
}
