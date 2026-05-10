import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLockService {
  final LocalAuthentication _auth = LocalAuthentication();
  static const String _lockKey = 'app_lock_enabled';

  static bool isAuthenticating = false;
  static bool isLockScreenVisible = false;

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_lockKey) ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lockKey, enabled);
  }

  Future<bool> authenticate() async {
    isAuthenticating = true;
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) {
        isAuthenticating = false;
        return true;
      } // Fallback if device doesn't support any auth

      final result = await _auth.authenticate(
        localizedReason: 'Verify your identity to access SplitEase',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      isAuthenticating = false;
      return result;
    } catch (e) {
      isAuthenticating = false;
      return false;
    }
  }
}
