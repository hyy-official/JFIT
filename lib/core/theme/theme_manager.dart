import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 테마 전환을 관리하는 클래스
class ThemeManager extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.dark; // 기본값: 다크 모드
  
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  /// 싱글톤 인스턴스
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  /// 초기화 - 저장된 테마 모드 로드
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeIndex = prefs.getInt(_themeKey) ?? ThemeMode.dark.index;
    _themeMode = ThemeMode.values[savedThemeIndex];
    notifyListeners();
  }

  /// 테마 모드 변경
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    
    // SharedPreferences에 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  /// 다크 모드로 전환
  Future<void> setDarkMode() async {
    await setThemeMode(ThemeMode.dark);
  }

  /// 라이트 모드로 전환
  Future<void> setLightMode() async {
    await setThemeMode(ThemeMode.light);
  }

  /// 시스템 모드로 전환
  Future<void> setSystemMode() async {
    await setThemeMode(ThemeMode.system);
  }

  /// 테마 토글 (다크 ↔ 라이트)
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setLightMode();
    } else {
      await setDarkMode();
    }
  }

  /// 현재 테마 모드의 이름 반환
  String get themeName {
    switch (_themeMode) {
      case ThemeMode.light:
        return '라이트 모드';
      case ThemeMode.dark:
        return '다크 모드';
      case ThemeMode.system:
        return '시스템 설정';
    }
  }

  /// 현재 테마 모드의 아이콘 반환
  IconData get themeIcon {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}