import 'package:flutter/material.dart';
import 'package:jfit/l10n/app_localizations.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/core/extensions/context_extensions.dart';

class ExerciseStats extends StatelessWidget {
  final List<Map<String, dynamic>> exercises;

  const ExerciseStats({
    super.key,
    required this.exercises,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    // 더미 - 이번 주 통계 계산
    final thisWeekExercises = exercises.where((exercise) {
      final exerciseDate = DateTime.parse(exercise['exerciseDate'] as String);
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      return exerciseDate.isAfter(weekStart.subtract(const Duration(days: 1)));
    }).toList();

    final sessions = thisWeekExercises.length;
    final totalMinutes = thisWeekExercises.fold<int>(
      0, 
      (sum, exercise) => sum + (exercise['duration'] as int? ?? 0),
    );
    final totalCalories = thisWeekExercises.fold<int>(
      0,
      (sum, exercise) => sum + (exercise['caloriesBurned'] as int? ?? 0),
    );
    final avgDuration = sessions > 0 ? totalMinutes / sessions : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.thisWeekStatistics ?? 'This Week Statistics',
          style: context.texts.titleMedium?.copyWith(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            
            if (isWide) {
              // 데스크톱/태블릿 레이아웃
              return Row(
                children: [
                  Expanded(child: _buildStatCard(
                    context,
                    l10n?.sessions ?? 'Sessions',
                    sessions.toString(),
                    Icons.fitness_center,
                    AppTheme.workoutIconColor,
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard(
                    context,
                    l10n?.totalTime ?? 'Total Time',
                    '${totalMinutes}m',
                    Icons.schedule,
                    AppTheme.nutritionIconColor,
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard(
                    context,
                    l10n?.caloriesBurned ?? 'Calories Burned',
                    totalCalories.toString(),
                    Icons.local_fire_department,
                    AppTheme.fatGraphColor,
                  )),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard(
                    context,
                    l10n?.avgDuration ?? 'Avg Duration',
                    '${avgDuration.round()}m',
                    Icons.trending_up,
                    AppTheme.proteinGraphColor,
                  )),
                ],
              );
            } else {
              // 모바일 레이아웃
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(
                        context,
                        l10n?.sessions ?? 'Sessions',
                        sessions.toString(),
                        Icons.fitness_center,
                        AppTheme.workoutIconColor,
                      )),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard(
                        context,
                        l10n?.totalTime ?? 'Total Time',
                        '${totalMinutes}m',
                        Icons.schedule,
                        AppTheme.nutritionIconColor,
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(
                        context,
                        l10n?.caloriesBurned ?? 'Calories Burned',
                        totalCalories.toString(),
                        Icons.local_fire_department,
                        AppTheme.fatGraphColor,
                      )),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard(
                        context,
                        l10n?.avgDuration ?? 'Avg Duration',
                        '${avgDuration.round()}m',
                        Icons.trending_up,
                        AppTheme.proteinGraphColor,
                      )),
                    ],
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.surface2.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: context.texts.bodySmall?.copyWith(color: AppTheme.textSub),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: context.texts.headlineLarge?.copyWith(fontSize: 28, color: Colors.white),
          ),
        ],
      ),
    );
  }
} 