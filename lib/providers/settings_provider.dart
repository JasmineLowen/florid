import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _themeModeKey = 'theme_mode';
  static const _autoInstallKey = 'auto_install_apk';
  static const _autoDeleteKey = 'auto_delete_apk';

  ThemeMode _themeMode = ThemeMode.system;
  bool _autoInstallApk = true;
  bool _autoDeleteApk = true;
  bool _loaded = false;

  SettingsProvider() {
    _load();
  }

  bool get isLoaded => _loaded;
  ThemeMode get themeMode => _themeMode;
  bool get autoInstallApk => _autoInstallApk;
  bool get autoDeleteApk => _autoDeleteApk;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeModeKey);
    if (themeIndex != null &&
        themeIndex >= 0 &&
        themeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeIndex];
    }
    _autoInstallApk = prefs.getBool(_autoInstallKey) ?? true;
    _autoDeleteApk = prefs.getBool(_autoDeleteKey) ?? true;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }

  Future<void> setAutoInstallApk(bool value) async {
    _autoInstallApk = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoInstallKey, value);
  }

  Future<void> setAutoDeleteApk(bool value) async {
    _autoDeleteApk = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoDeleteKey, value);
  }
}
