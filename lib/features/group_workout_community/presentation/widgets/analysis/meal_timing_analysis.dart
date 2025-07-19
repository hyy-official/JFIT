import 'package:flutter/material.dart';

class MealTimingAnalysis extends StatelessWidget {
  final Map<String, dynamic>? data;
  final DateTime startDate;
  final DateTime endDate;

  const MealTimingAnalysis({
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
        child: Text('식사 타이밍 분석 구현 예정'),
      ),
    );
  }
}