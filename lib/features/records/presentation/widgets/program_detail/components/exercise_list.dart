import 'package:flutter/material.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/core/theme/second_theme.dart';

/// 운동 목록 표시 위젯
class ExerciseList extends StatelessWidget {
  final Future<List<dynamic>?> exercisesFuture;

  const ExerciseList({
    super.key,
    required this.exercisesFuture,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>?>(
      future: exercisesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: AppTheme.accent1,
            ),
          );
        }

        final exercises = snapshot.data;
        if (exercises == null || exercises.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.fitness_center_outlined,
                  size: 48,
                  color: SecondTheme.textMuted,
                ),
                const SizedBox(height: 16),
                Text(
                  '운동 루틴이 없습니다.',
                  style: TextStyle(
                    color: SecondTheme.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        final exerciseList = exercises.cast<Map<String, dynamic>>();
        return ListView.separated(
          shrinkWrap: true,
          itemCount: exerciseList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, idx) {
            final exercise = exerciseList[idx];
            return ExerciseListItem(
              exercise: exercise,
              index: idx,
            );
          },
        );
      },
    );
  }
}

/// 개별 운동 항목 위젯
class ExerciseListItem extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final int index;

  const ExerciseListItem({
    super.key,
    required this.exercise,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final exerciseName = exercise['name'] ?? 
                       exercise['exercise_name'] ?? 
                       exercise['custom_name'] ?? 
                       '운동 ${index + 1}';
    final sets = exercise['sets'] ?? 1;
    final reps = exercise['reps'] ?? '-';
    final order = exercise['order'] ?? index + 1;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: SecondTheme.bgSecondary.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SecondTheme.border.withOpacity(0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Leading - Order number
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$order',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exerciseName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: SecondTheme.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$sets세트 × $reps회',
                    style: TextStyle(
                      color: SecondTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Trailing
            Icon(
              Icons.fitness_center,
              color: AppTheme.accent2,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}