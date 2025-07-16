import 'package:flutter/material.dart';
import 'package:jfit/l10n/app_localizations.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:jfit/features/exercise/data/models/exercise_record.dart';

class WorkoutHistory extends StatelessWidget {
  final List<ExerciseRecord> exercises;

  const WorkoutHistory({
    super.key,
    required this.exercises,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // 날짜순으로 정렬
    final sortedExercises = List<ExerciseRecord>.from(exercises);
    sortedExercises.sort((a, b) {
      return b.exerciseDate.compareTo(a.exerciseDate);
    });

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.colors.border.withAlpha((255 * 0.3).round()),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.primary.withAlpha((255 * 0.15).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.history,
                  color: context.colors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n?.workoutHistory ?? 'Workout History',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 운동 기록 리스트
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedExercises.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final exercise = sortedExercises[index];
              return _buildWorkoutCard(context, l10n, exercise);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, AppLocalizations? l10n, ExerciseRecord exercise) {
    final exerciseName = _getExerciseName(l10n, exercise.exerciseName);
    final exerciseType = _getExerciseType(l10n, exercise.exerciseType);
    final date = exercise.exerciseDate;
    final duration = exercise.durationMinutes;
    final calories = exercise.caloriesBurned;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.border.withAlpha((255 * 0.5).round()),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  exerciseName,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTypeColor(exercise.exerciseType),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  exerciseType,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  context,
                  '${duration}m',
                  '${calories} cal',
                ),
              ),
              if (exercise.weightKg != null && exercise.sets != null && exercise.reps != null) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetric(
                    context,
                    '${exercise.weightKg}kg',
                    '${exercise.sets} sets × ${exercise.reps} reps',
                  ),
                ),
              ],
              if (exercise.distanceKm != null) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetric(
                    context,
                    '${exercise.distanceKm}km',
                    '',
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(BuildContext context, String primary, String secondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          primary,
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
          ),
        ),
        if (secondary.isNotEmpty)
          Text(
            secondary,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
      ],
    );
  }

  String _getExerciseName(AppLocalizations? l10n, String exerciseKey) {
    switch (exerciseKey) {
      case 'benchPress':
        return l10n?.benchPress ?? 'Bench Press';
      case 'squat':
        return l10n?.squat ?? 'Squat';
      case 'deadlift':
        return l10n?.deadlift ?? 'Deadlift';
      case 'pushUp':
        return l10n?.pushUp ?? 'Push Up';
      case 'pullUp':
        return l10n?.pullUp ?? 'Pull Up';
      case 'running':
        return l10n?.running ?? 'Running';
      case 'cycling':
        return l10n?.cycling ?? 'Cycling';
      case 'swimming':
        return l10n?.swimming ?? 'Swimming';
      case 'yoga':
        return l10n?.yoga ?? 'Yoga';
      case 'stretching':
        return l10n?.stretching ?? 'Stretching';
      default:
        return exerciseKey;
    }
  }

  String _getExerciseType(AppLocalizations? l10n, String typeKey) {
    switch (typeKey) {
      case 'strength':
        return l10n?.strength ?? 'Strength';
      case 'cardio':
        return l10n?.cardio ?? 'Cardio';
      case 'flexibility':
        return l10n?.flexibility ?? 'Flexibility';
      default:
        return typeKey;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'strength':
        return JFitChartColors.strengthColor;
      case 'cardio':
        return JFitChartColors.cardioColor;
      case 'flexibility':
        return JFitChartColors.flexibilityColor;
      default:
        return JFitChartColors.defaultExerciseColor;
    }
  }
} 