import 'package:flutter/material.dart';

class WorkoutSummary extends StatelessWidget {
  final Map<String, dynamic> session;
  final List<Map<String, dynamic>> exercises;
  final int workoutTime;
  // 콜백: Finish/Rest 등

  const WorkoutSummary({
    super.key,
    required this.session,
    required this.exercises,
    required this.workoutTime,
    // 콜백 파라미터 추가 예정
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF161616),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 타이머, 진행률, Finish/Rest 버튼 등
            Text('Workout Time: $workoutTime'),
            // ...
          ],
        ),
      ),
    );
  }
} 