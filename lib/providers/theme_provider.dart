import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme_mode.dart';

class ThemeProvider with ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.system;

  AppThemeMode get themeMode => _themeMode;

  // Mengonversi AppThemeMode kita ke ThemeMode bawaan Flutter
  ThemeMode get flutterThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  // Gunakan colorSchemeSeed untuk tampilan yang lebih profesional (biru karir)
  ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue.shade900,
        brightness: Brightness.light,
      );

  ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue.shade900,
        brightness: Brightness.dark,
      );

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
