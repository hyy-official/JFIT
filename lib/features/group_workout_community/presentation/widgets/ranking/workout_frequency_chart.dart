import 'package:flutter/material.dart';

class WorkoutFrequencyChart extends StatelessWidget {
  final Map<String, dynamic> workoutAnalysis;
  final double height;

  const WorkoutFrequencyChart({
    super.key,
    required this.workoutAnalysis,
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
              Icon(Icons.calendar_today, size: 48),
              SizedBox(height: 8),
              Text('운동 빈도 차트'),
              Text('(구현 예정)', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}