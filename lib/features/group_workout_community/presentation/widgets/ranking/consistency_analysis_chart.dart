import 'package:flutter/material.dart';

class ConsistencyAnalysisChart extends StatelessWidget {
  final Map<String, dynamic> workoutAnalysis;
  final double height;

  const ConsistencyAnalysisChart({
    super.key,
    required this.workoutAnalysis,
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
              Icon(Icons.schedule, size: 48),
              SizedBox(height: 8),
              Text('일관성 분석 차트'),
              Text('(구현 예정)', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}