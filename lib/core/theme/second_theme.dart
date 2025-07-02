import 'package:flutter/material.dart';


/// docs/color_theme.md 를 코드로 옮긴 파일
class SecondTheme {
  // ---------- 배경 계층 ----------
  static const Color bgPrimary   = Color(0xFF0A0A0A); // 앱 전체 기본 배경
  static const Color bgSecondary = Color(0xFF111111); // 사이드바/패널 등 보조 배경
  static const Color bgTertiary  = Color(0xFF1A1A1A); // 카드, 차트 Surface
  static const Color surfaceHover = Color(0xFF1F1F1F); // 카드 hover/pressed

  // ---------- 텍스트 ----------
  static const Color textPrimary   = Colors.white;       // 제목/주요 텍스트
  static const Color textSecondary = Color(0xFFA3A3A3); // 본문/설명
  static const Color textMuted     = Color(0xFF737373); // placeholder/비활성

  // ---------- 강조(Accent) ----------
  static const Color accentPrimary   = Color(0xFF6366F1); // 인디고 (Gradient 시작)
  static const Color accentSecondary = Color(0xFF8B5CF6); // 퍼플 (Gradient 끝)

  // ---------- Border ----------
  static const Color border      = Color(0xFF262626);
  static const Color borderHover = Color(0xFF404040);

  // Glass Morphism 카드 배경 (opacity 는 사용할 때 지정)
  static Color glassCardBG = bgTertiary.withOpacity(0.70);

  // Accent Gradient (좌→우)
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentPrimary, accentSecondary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

/// 차트 컬러 팔레트 – 데이터 시각화용 (순서대로 사용)
class SecondThemeChartColors {
  static const List<Color> palette = [
    SecondTheme.accentSecondary, // 퍼플
    SecondTheme.accentPrimary,   // 인디고
    Color(0xFF22D3EE),              // 청록
    Color(0xFFA3E635),              // 라임
    Color(0xFFF59E42),              // 오렌지
  ];
} 