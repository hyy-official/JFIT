import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'second_theme.dart';

class AppTheme {
  // 폰트 변경 시 아래 한 줄만 수정하면 전체 앱에 적용됩니다.
  static const String fontFamily = '';
  // 예시: static const String fontFamily = 'NotoSansKR';

  // ------------------------------
  // Dark Modern Fitness 팔레트
  // ------------------------------
  // Base colors
  static const Color primaryBackground = SecondTheme.bgPrimary;
  static const Color secondaryBackground1 = SecondTheme.bgSecondary;
  static const Color secondaryBackground2 = Color(0xFF161616); // 탭 비활성 등

  // Surfaces
  static const Color surface1 = SecondTheme.bgTertiary;
  static const Color surface2 = SecondTheme.border;

  // Accents
  static const Color accent1 = SecondTheme.accentPrimary;
  static const Color accent2 = SecondTheme.accentSecondary;

  // Text
  static const Color textSub = SecondTheme.textSecondary;
  static const Color textMuted = SecondTheme.textMuted;

  // Chart palette (고정 순서)
  static const List<Color> chartColors = SecondThemeChartColors.palette;

  // 기존 위젯 호환용 색상 (대시보드 아이콘 등)
  static const Color workoutIconColor = accent2;
  static const Color nutritionIconColor = Color(0xFF34D399);
  static const Color proteinGraphColor = Color(0xFFF472B6);
  static const Color carbsGraphColor = Color(0xFFFBBF24);
  static const Color fatGraphColor = Color(0xFFF59E42);

  // 공통 그라디언트
  static const LinearGradient accentGradient = SecondTheme.accentGradient;

  // 이전 코드 호환용 alias
  static const Color cardBackgroundColor = surface1;

  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.dark, // 다크 베이스 유지
        colorScheme: const ColorScheme.dark(
          primary: accent1,
          secondary: accent2,
          surface: surface1,
          background: primaryBackground,
          onPrimary: Colors.white,
          onSurface: textSub,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          //headlineLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: textSub),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textSub),
          labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textMuted),
        ),
        fontFamily: fontFamily.isEmpty ? null : fontFamily,
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        cardTheme: CardThemeData(
          color: secondaryBackground1,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        scaffoldBackgroundColor: primaryBackground,
      );

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: accent1,
          secondary: accent2,
          surface: surface1,
          background: primaryBackground,
          onPrimary: Colors.white,
          onSurface: textSub,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: textSub),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textSub),
          labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textMuted),
        ),
        fontFamily: fontFamily.isEmpty ? null : fontFamily,
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        cardTheme: CardThemeData(
          color: secondaryBackground1,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        scaffoldBackgroundColor: primaryBackground, // 더 어두운 배경
      );
} 