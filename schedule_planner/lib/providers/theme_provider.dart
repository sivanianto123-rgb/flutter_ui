import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../styles/app_fonts.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = true;
  static const _key = 'theme_is_dark';

  bool get isDark => _isDark;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool(_key) ?? true;
    AppFonts.isDark = _isDark;
    notifyListeners();
  }

  Future<void> toggle() async {
    _isDark = !_isDark;
    AppFonts.isDark = _isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, _isDark);
    notifyListeners();
  }
}
