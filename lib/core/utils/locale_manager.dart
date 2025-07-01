import 'package:flutter/material.dart';

class LocaleManager extends ChangeNotifier {
  static final LocaleManager _instance = LocaleManager._internal();
  factory LocaleManager() => _instance;
  LocaleManager._internal();

  Locale _currentLocale = const Locale('ko'); // 기본값은 한국어

  Locale get currentLocale => _currentLocale;

  void setLocale(Locale locale) {
    if (_currentLocale != locale) {
      _currentLocale = locale;
      notifyListeners();
    }
  }

  void toggleLocale() {
    setLocale(_currentLocale.languageCode == 'ko' 
        ? const Locale('en') 
        : const Locale('ko'));
  }
} 