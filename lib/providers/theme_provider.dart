import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme_mode.dart';

class ThemeProvider with ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.system;

  AppThemeMode get themeMode => _themeMode;

  ThemeData get themeData {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeData.light();
      case AppThemeMode.dark:
        return ThemeData.dark();
      case AppThemeMode.system:
        return ThemeData.light(); // For simplicity, default to light
    }
  }

  void setThemeMode(AppThemeMode mode) {
    _themeMode = mode;
    _saveThemeMode();
    notifyListeners();
  }

  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString('themeMode');
    if (savedMode != null) {
      _themeMode = AppThemeMode.values.firstWhere(
        (e) => e.toString() == savedMode,
        orElse: () => AppThemeMode.system,
      );
    }
    notifyListeners();
  }

  Future<void> _saveThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', _themeMode.toString());
  }
}
