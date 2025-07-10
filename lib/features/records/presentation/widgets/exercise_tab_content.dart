import 'package:flutter/material.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'exercise_routine_list.dart';
import 'exercise_empty_state.dart';

class ExerciseTabContent extends StatelessWidget {
  final bool hasRoutine;
  const ExerciseTabContent({super.key, required this.hasRoutine});

  @override
  Widget build(BuildContext context) {
    // 실제 구현 시 BLoC 상태로 대체
    if (hasRoutine) {
      return const ExerciseRoutineList();
    } else {
      return const ExerciseEmptyState();
    }
  }
} 