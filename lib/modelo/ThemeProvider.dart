import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  final String _themeBox = 'themeBox';

  ThemeProvider() {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    var box = await Hive.openBox(_themeBox);
    await box.put('themeMode', mode == ThemeMode.dark ? 'dark' : 'light');
  }

  void _loadThemeMode() async {
    var box = await Hive.openBox(_themeBox);
    String? themeString = box.get('themeMode');

    if (themeString == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (themeString == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }
}
