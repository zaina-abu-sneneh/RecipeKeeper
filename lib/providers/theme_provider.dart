import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  String _themeString = 'light'; // Default

  String get themeString => _themeString;

  ThemeMode get themeMode {
    if (_themeString == 'dark') return ThemeMode.dark;
    return ThemeMode.light;
  }

  // Constructor runs when the app starts
  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  // Change and Save
  void setTheme(String theme) async {
    _themeString = theme;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_key', theme);
  }

  // Load from phone memory
  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _themeString = prefs.getString('theme_key') ?? 'light';
    notifyListeners();
  }
}
