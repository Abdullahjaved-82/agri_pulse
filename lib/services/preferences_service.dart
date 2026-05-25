import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyEmail = 'saved_email';
  static const String _keyPassword = 'saved_password';
  static const String _keyRememberMe = 'remember_me';

  Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPassword, password);
    await prefs.setBool(_keyRememberMe, true);
  }

  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyPassword);
    await prefs.setBool(_keyRememberMe, false);
  }

  Future<Map<String, String?>> getCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final bool rememberMe = prefs.getBool(_keyRememberMe) ?? false;
    
    if (rememberMe) {
      return {
        'email': prefs.getString(_keyEmail),
        'password': prefs.getString(_keyPassword),
      };
    }
    return {'email': null, 'password': null};
  }
}
