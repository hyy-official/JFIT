import 'package:flutter/material.dart';

class NutritionTrendsChart extends StatelessWidget {
  final Map<String, dynamic>? data;
  final DateTime startDate;
  final DateTime endDate;

  const NutritionTrendsChart({
    super.key,
    this.data,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('영양소 트렌드 차트 구현 예정'),
      ),
    );
  }
}