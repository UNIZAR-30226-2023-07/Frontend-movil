import 'package:flutter/material.dart';
import '../services/local_storage.dart';

class ThemeManager extends ChangeNotifier {
  static bool _darkMode = true;
  ThemeMode _themeMode = ThemeMode.light;

  get darkMode => _darkMode;
  get thememode => _themeMode;

  ThemeManager() {
    if(LocalStorage.prefs.getBool('darkMode') != null) {
      _darkMode = LocalStorage.prefs.getBool('darkMode') as bool;
      _themeMode = darkMode? ThemeMode.dark : ThemeMode.light;
    } else {
      LocalStorage.prefs.setBool('darkMode', darkMode);
    }
  }

  toggleTheme () {
    _darkMode = !_darkMode;
    _themeMode = _darkMode? ThemeMode.dark : ThemeMode.light;
    LocalStorage.prefs.setBool('darkMode', _darkMode);
    notifyListeners();
  }

}

ThemeManager themeManager = ThemeManager();