import 'package:flutter/material.dart';

/// Tailwind 디자인 토큰 → Flutter Color 및 Radius 매핑
class DesignTokens {
  // Base colors (배경/전경)
  static const Color background = Color(0xFF0A0A0A);
  static const Color foreground = Color(0xFFFFFFFF);

  // Surface colors
  static const Color surface = Color(0xFF161616);
  static const Color surfaceHover = Color(0xFF1F1F1F);

  // Primary / Accent palette
  static const Color primary = Color(0xFF6366F1); // indigo-500
  static const Color primaryForeground = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFF8B5CF6); // violet-500

  // Secondary / muted greys
  static const Color secondary = Color(0xFF1A1A1A);
  static const Color secondaryForeground = Color(0xFFA3A3A3);
  static const Color muted = Color(0xFF737373);

  // Border / ring
  static const Color border = Color(0xFF262626);
  static const Color borderHover = Color(0xFF404040);

  // Chart sample palette (필요 시 업데이트)
  static const Color chart1 = Color(0xFF4ADE80); // green-400
  static const Color chart2 = Color(0xFF60A5FA); // blue-400
  static const Color chart3 = Color(0xFFFBBF24); // yellow-400
  static const Color chart4 = Color(0xFFF87171); // red-400
  static const Color chart5 = Color(0xFF34D399); // emerald-400

  // Border radius tokens
  static const double _baseRadius = 12.0;
  static BorderRadius get radiusLg => BorderRadius.circular(_baseRadius);
  static BorderRadius get radiusMd => BorderRadius.circular(_baseRadius - 2);
  static BorderRadius get radiusSm => BorderRadius.circular(_baseRadius - 4);
} 