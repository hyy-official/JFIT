import 'package:flutter/material.dart';

class GoalAchievementTrends extends StatelessWidget {
  final Map<String, dynamic>? data;
  final DateTime startDate;
  final DateTime endDate;

  const GoalAchievementTrends({
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
        child: Text('목표 달성 트렌드 구현 예정'),
      ),
    );
  }
}