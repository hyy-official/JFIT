import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AppTheme {
  // 폰트 변경 시 아래 한 줄만 수정하면 전체 앱에 적용됩니다.
  static const String fontFamily = '';
  // 예시: static const String fontFamily = 'NotoSansKR';

  // 색상 팔레트 정의
  static const Color cardBackgroundColor = Color(0xFF161616); // 거의 검정에 가까운 다크 그레이
  static const Color workoutIconColor = Color(0xFFA78BFA); // 연보라색
  static const Color nutritionIconColor = Color(0xFF34D399); // 민트/에메랄드 계열
  static const Color proteinGraphColor = Color(0xFFF472B6); // 밝은 핑크
  static const Color carbsGraphColor = Color(0xFFFBBF24); // 선명한 노랑
  static const Color fatGraphColor = Color(0xFFF59E42); // 오렌지/주황

  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: fontFamily.isEmpty ? null : fontFamily,
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            // 데스크톱 플랫폼은 페이드 업 애니메이션으로 전환해 스와이프 제스처를 제거
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
            // 모바일(iOS)은 기본 Cupertino(스와이프 지원)
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            // Android 는 기본(Material) 유지 – 지정하지 않으면 기본값 사용
          },
        ),
        cardTheme: CardThemeData(
          color: cardBackgroundColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple, 
          brightness: Brightness.dark,
          secondary: workoutIconColor,
          tertiary: nutritionIconColor,
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
          color: cardBackgroundColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F0F), // 더 어두운 배경
      );
} 