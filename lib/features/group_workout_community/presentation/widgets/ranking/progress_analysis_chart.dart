import 'package:flutter/material.dart';

class ProgressAnalysisChart extends StatelessWidget {
  final List<Map<String, dynamic>> scoreTrends;
  final double height;

  const ProgressAnalysisChart({
    super.key,
    required this.scoreTrends,
    this.height = 250,
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
              Icon(Icons.trending_up, size: 48),
              SizedBox(height: 8),
              Text('진전도 분석 차트'),
              Text('(구현 예정)', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}