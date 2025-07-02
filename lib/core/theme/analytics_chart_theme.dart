import 'package:flutter/material.dart';

class AnalyticsChartTheme {
  AnalyticsChartTheme._();

  static const Color primaryAccent = Color(0xFF8A75F5);
  static const Color tooltipBackground = Color(0xFF333333);
  static const Color cardBackground = Color(0xFF1A1A1A);
  static const Color cardBorder = Color(0xFF262626);
  static const Color unselectedToggleText = Color(0xFFA3A3A3);
  static const Color legendText = Color(0xFFA3A3A3);
  static const Color gridLineColor = Color(0xFF262626);
  static const Color borderColor = Color(0xFF262626);

  static const TextStyle axisLabelStyle = TextStyle(
    color: unselectedToggleText,
    fontSize: 12,
  );

  static const TextStyle tooltipTextStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  static const LinearGradient scoreBarGradient = LinearGradient(
    colors: [
      Color(0xFF8A75F5),
      Color(0xFF6A5BE2),
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  static const List<Color> scoreLegendColors = [
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.red,
    Colors.purple, // Example for 5 score
  ];

  static const List<Color> nutritionDataColors = [
    Color(0xFF8A75F5), // Carbs
    Color(0xFF6AD2A1), // Protein
    Color(0xFF4EC3E0), // Fat
  ];
} 