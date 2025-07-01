import 'package:flutter/material.dart';
import 'package:jfit/l10n/app_localizations.dart';
import 'package:jfit/core/theme/app_theme.dart';

class WorkoutHistory extends StatelessWidget {
  final List<Map<String, dynamic>> exercises;

  const WorkoutHistory({
    super.key,
    required this.exercises,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // 더미 - 날짜순으로 정렬
    final sortedExercises = List<Map<String, dynamic>>.from(exercises);
    sortedExercises.sort((a, b) {
      final dateA = DateTime.parse(a['exerciseDate'] as String);
      final dateB = DateTime.parse(b['exerciseDate'] as String);
      return dateB.compareTo(dateA);
    });

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey[700]!.withOpacity(0.3),
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
                  color: AppTheme.workoutIconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.history,
                  color: AppTheme.workoutIconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n?.workoutHistory ?? 'Workout History',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
              return _buildWorkoutCard(l10n, exercise);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(AppLocalizations? l10n, Map<String, dynamic> exercise) {
    final exerciseName = _getExerciseName(l10n, exercise['exerciseName'] as String);
    final exerciseType = _getExerciseType(l10n, exercise['exerciseType'] as String);
    final date = DateTime.parse(exercise['exerciseDate'] as String);
    final duration = exercise['duration'] as int;
    final calories = exercise['caloriesBurned'] as int;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[600]!.withOpacity(0.5),
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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTypeColor(exercise['exerciseType'] as String),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  exerciseType,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  '${duration}m',
                  '${calories} cal',
                ),
              ),
              if (exercise['weight'] != null && exercise['sets'] != null && exercise['reps'] != null) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetric(
                    '${exercise['weight']}kg',
                    '${exercise['sets']} sets × ${exercise['reps']} reps',
                  ),
                ),
              ],
              if (exercise['distance'] != null) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetric(
                    '${exercise['distance']}km',
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

  Widget _buildMetric(String primary, String secondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          primary,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        if (secondary.isNotEmpty)
          Text(
            secondary,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
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
        return AppTheme.proteinGraphColor;
      case 'cardio':
        return AppTheme.nutritionIconColor;
      case 'flexibility':
        return AppTheme.carbsGraphColor;
      default:
        return const Color(0xFF6B7280);
    }
  }
} 