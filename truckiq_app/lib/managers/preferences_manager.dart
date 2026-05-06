import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  const PreferencesManager._();

  static const PreferencesManager instance = PreferencesManager._();

  static const String userNameKey = 'userName';
  static const String darkModeKey = 'darkMode';

  Future<void> setDarkMode(bool darkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(darkModeKey, darkMode);
  }

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(darkModeKey) ?? false;
  }
}