import 'package:flutter/material.dart';

class DietSheetTheme {
  // Colors
  static const Color sheetBackground = Color(0xFF232329);
  static const Color handlebarColor = Color(0xFF444444);
  static const Color buttonGridBackground = Color(0xFF3A3A40);

  static const Color primaryTextColor = Colors.white;
  static const Color secondaryTextColor = Color(0xFFAAAAAA);

  static const Color activeTabColor = Colors.white;
  static const Color inactiveTabColor = Color(0xFF757575);
  static const Color activeTabBackground = sheetBackground;
  static const Color inactiveTabBackground = Colors.transparent;
  static const Color tabContainerBackground = Color(0xFF3A3A40);

  // Text Styles
  static const TextStyle dateHeaderStyle = TextStyle(
    color: primaryTextColor,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle emptyMessageStyle = TextStyle(
    color: primaryTextColor,
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle subMessageStyle = TextStyle(
    color: secondaryTextColor,
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    color: primaryTextColor,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle tabTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
} 