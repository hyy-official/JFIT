import 'package:flutter/material.dart';
import 'package:jfit/core/theme/theme_system.dart';

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
              color: context.colors.primary,
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
                  color: context.colors.textMuted,
                ),
                const SizedBox(height: 16),
                Text(
                  '운동 루틴이 없습니다.',
                  style: TextStyle(
                    color: context.colors.textSecondary,
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
        color: context.colors.surfaceVariant.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colors.border.withOpacity(0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withOpacity(0.1),
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
                gradient: context.colors.gradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$order',
                  style: TextStyle(
                    color: context.colors.textPrimary,
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
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$sets세트 × $reps회',
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Trailing
            Icon(
              Icons.fitness_center,
              color: context.colors.secondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}