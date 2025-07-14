import 'package:flutter/material.dart';
import 'package:jfit/core/theme/app_theme.dart';

class ExerciseTodayList extends StatelessWidget {
  final List<Map<String, dynamic>> exercises;
  const ExerciseTodayList({super.key, required this.exercises});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: exercises.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final exercise = exercises[idx];
        final name = exercise['name'] ?? exercise['exercise_name'] ?? '운동';
        final sets = exercise['sets'] ?? exercise['recommended_sets'] ?? 3;
        final reps = exercise['reps'] ?? exercise['recommended_reps'] ?? '10회';
        final imageUrl = exercise['image_url'] ?? exercise['img'] ?? '';
        
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.programCardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              _buildExerciseImage(imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'x ${sets}세트   ${reps}',
                      style: TextStyle(
                        color: AppTheme.textSub,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.play_arrow,
                color: AppTheme.textMuted,
                size: 24,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExerciseImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.programBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.fitness_center,
          color: AppTheme.textMuted,
          size: 24,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.programBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.image_not_supported,
              color: AppTheme.textMuted,
              size: 20,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.programBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: AppTheme.textMuted,
              ),
            ),
          );
        },
      ),
    );
  }
} 