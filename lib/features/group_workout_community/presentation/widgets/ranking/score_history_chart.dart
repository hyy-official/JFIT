import 'package:flutter/material.dart';

class ScoreHistoryChart extends StatelessWidget {
  final List<Map<String, dynamic>> scoreTrends;
  final String selectedMetric;
  final double height;

  const ScoreHistoryChart({
    super.key,
    required this.scoreTrends,
    required this.selectedMetric,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 48),
              SizedBox(height: 8),
              Text('점수 히스토리 차트'),
              Text('(구현 예정)', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}