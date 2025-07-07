import 'package:flutter/material.dart';
import 'design_tokens.dart';

class DietDetailTheme {
  // Colors
  static const Color sheetBackground = Color(0xFF232329);
  static const Color handlebarColor = Color(0xFF444444);
  static const Color inputBackground = DesignTokens.surfaceHover; // #1F1F1F-like
  static const Color buttonActiveBackground = DesignTokens.primary;
  static const Color buttonInactiveBackground = DesignTokens.surfaceHover;
  static const Color buttonActiveText = Colors.white;
  static const Color buttonInactiveText = DesignTokens.secondaryForeground;

  static const Color primaryTextColor = Colors.white;
  static const Color secondaryTextColor = DesignTokens.secondaryForeground;
  static const Color placeholderTextColor = DesignTokens.muted;

  // Text Styles
  static const TextStyle headerStyle = TextStyle(
    color: primaryTextColor,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle sectionTitleStyle = TextStyle(
    color: primaryTextColor,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle inputTextStyle = TextStyle(
    color: primaryTextColor,
    fontSize: 16,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle timeDisplayStyle = TextStyle(
    color: primaryTextColor,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle saveButtonStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  // 선택 그룹(분류/포만감/점수) 제목용 (회색, 14)
  static const TextStyle selectionGroupTitleStyle = TextStyle(
    color: secondaryTextColor,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
} 