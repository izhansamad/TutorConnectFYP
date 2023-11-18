import 'package:shared_preferences/shared_preferences.dart';

class PrefsManager {
  static PrefsManager? _instance;
  SharedPreferences? _prefs;

  PrefsManager._privateConstructor();

  factory PrefsManager() {
    if (_instance == null) {
      _instance = PrefsManager._privateConstructor();
    }
    return _instance!;
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences? get prefs => _prefs;
  Future<void> clearAll() async {
    await _prefs?.clear();
  }

  // Set a String value
  Future<bool> setString(String key, String value) {
    return _prefs?.setString(key, value) ?? Future.value(false);
  }

  // Get a String value
  String? getString(String key, {String? defaultValue}) {
    return _prefs?.getString(key) ?? defaultValue;
  }

  // Set an integer value
  Future<bool> setInt(String key, int value) {
    return _prefs?.setInt(key, value) ?? Future.value(false);
  }

  // Get an integer value
  int getInt(String key, {int defaultValue = 0}) {
    return _prefs?.getInt(key) ?? defaultValue;
  }

  Future<bool> setBool(String key, bool value) {
    return _prefs?.setBool(key, value) ?? Future.value(false);
  }

  // Get an integer value
  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  String IS_TEACHER_KEY = 'isTeacher';
}
