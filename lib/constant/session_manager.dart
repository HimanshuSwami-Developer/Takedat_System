import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {

  static SharedPreferences? _preferences;

  /// INIT
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  /// SAVE STRING
  static Future<void> saveString(
    String key,
    String value,
  ) async {
    await _preferences?.setString(key, value);
  }

  /// GET STRING
  static String getString(String key) {
    return _preferences?.getString(key) ?? '';
  }

  /// SAVE BOOL
  static Future<void> saveBool(
    String key,
    bool value,
  ) async {
    await _preferences?.setBool(key, value);
  }

  /// GET BOOL
  static bool getBool(String key) {
    return _preferences?.getBool(key) ?? false;
  }

  /// REMOVE
  static Future<void> remove(String key) async {
    await _preferences?.remove(key);
  }

  /// CLEAR ALL
  static Future<void> clear() async {
    await _preferences?.clear();
  }

  /// CHECK LOGIN
  static bool isLoggedIn() {
    return getBool("isLoggedIn");
  }
}