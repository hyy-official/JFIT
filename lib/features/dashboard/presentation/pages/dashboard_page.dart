import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/features/dashboard/presentation/widgets/stats_card.dart';
import 'package:jfit/features/dashboard/presentation/widgets/exercise_chart.dart';
import 'package:jfit/features/dashboard/presentation/widgets/nutrition_chart.dart';
import 'package:jfit/features/dashboard/presentation/widgets/recent_workouts.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:jfit/features/daily_summary/bloc/daily_summary_bloc.dart';
import 'package:jfit/features/daily_summary/bloc/daily_summary_event.dart';
import 'package:jfit/features/daily_summary/bloc/daily_summary_state.dart';
import 'package:jfit/l10n/app_localizations.dart';
import 'package:jfit/features/auth/bloc/auth_bloc.dart';
import 'package:jfit/features/auth/bloc/auth_state.dart';
import 'package:jfit/features/records/data/models/user_daily_summary_model.dart';


class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final userId = authState.user.id;
      final today = DateTime.now();
      final weekAgo = today.subtract(const Duration(days: 7));
      
      // Load today's summary and last 7 days for dashboard
      context.read<DailySummaryBloc>().add(LoadDailySummary(
        userId: userId,
        date: today,
      ));
      context.read<DailySummaryBloc>().add(LoadDailySummariesForRange(
        userId: userId,
        startDate: weekAgo,
        endDate: today,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return BlocBuilder<DailySummaryBloc, DailySummaryState>(
      builder: (context, state) {
        return _buildDashboardContent(context, state, l10n);
      },
    );
  }

  Widget _buildDashboardContent(BuildContext context, DailySummaryState state, AppLocalizations? l10n) {
    // Handle loading states
    if (state is DailySummaryLoading || state is DailySummaryRefreshing) {
      return const Center(child: CircularProgressIndicator());
    }

    // Handle error states
    if (state is DailySummaryError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: context.colors.error),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.message}',
              style: TextStyle(color: context.colors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Extract data from different states
    UserDailySummary? todaySummary;
    List<UserDailySummary> weekSummaries = [];

    if (state is DailySummaryLoaded) {
      todaySummary = state.summary;
    } else if (state is DailySummaryUpdated) {
      todaySummary = state.summary;
    } else if (state is DailySummariesLoaded) {
      weekSummaries = state.summaries;
      // Get today's summary from the week summaries
      final today = DateTime.now();
      todaySummary = weekSummaries.firstWhere(
        (summary) => _isSameDay(summary.summaryDate, today),
        orElse: () => UserDailySummary(
          id: '',
          userId: '',
          summaryDate: today,
        ),
      );
    }

    // Build stats from real data
    final stats = _buildStatsFromData(context, l10n, todaySummary, weekSummaries);
    final exerciseChartData = _buildExerciseChartData(weekSummaries);
    final nutritionChartData = _buildNutritionChartData(weekSummaries);
    final recentWorkouts = _buildRecentWorkouts(l10n, weekSummaries);

    final isWide = MediaQuery.of(context).size.width > 700;
    return Container(
      color: context.colors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 섹션
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: context.colors.primary,
                  child: Icon(Icons.fitness_center, color: context.colors.textPrimary),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n?.appTitle ?? 'JFIT', 
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary,
                  ),
                ),
                const Spacer(),
                // Refresh button
                IconButton(
                  onPressed: _loadData,
                  icon: Icon(Icons.refresh, color: context.colors.textSecondary),
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              l10n?.workoutDashboard ?? 'Workout Dashboard', 
              style: context.textTheme.headlineLarge?.copyWith(
                fontSize: 36, 
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _formatCurrentDate(DateTime.now()),
              style: context.textTheme.bodyMedium?.copyWith(
                fontSize: 18, 
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: stats.map((s) => SizedBox(
                            width: 240, 
                            child: StatsCard(
                              title: s['title'] as String, 
                              value: s['value'] as String, 
                              subtitle: s['subtitle'] as String, 
                              icon: s['icon'] as IconData, 
                              gradientColors: s['gradient'] as List<Color>,
                            ),
                          )).toList(),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            ExerciseChart(data: exerciseChartData),
                            const SizedBox(height: 16),
                            NutritionChart(data: nutritionChartData),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      ...stats.map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: StatsCard(
                              title: s['title'] as String, 
                              value: s['value'] as String, 
                              subtitle: s['subtitle'] as String, 
                              icon: s['icon'] as IconData, 
                              gradientColors: s['gradient'] as List<Color>,
                            ),
                          )),
                      ExerciseChart(data: exerciseChartData),
                      const SizedBox(height: 16),
                      NutritionChart(data: nutritionChartData),
                    ],
                  ),
            const SizedBox(height: 24),
            RecentWorkouts(workouts: recentWorkouts),
          ],
        ),
      ),
    );
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// Format current date for display
  String _formatCurrentDate(DateTime date) {
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 
                   'July', 'August', 'September', 'October', 'November', 'December'];
    
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    final day = date.day;
    final year = date.year;
    
    String suffix = 'th';
    if (day % 10 == 1 && day != 11) {
      suffix = 'st';
    } else if (day % 10 == 2 && day != 12) {
      suffix = 'nd';
    } else if (day % 10 == 3 && day != 13) {
      suffix = 'rd';
    }
    
    return '$weekday, $month $day$suffix, $year';
  }

  /// Build stats cards from real data
  List<Map<String, dynamic>> _buildStatsFromData(
    BuildContext context, 
    AppLocalizations? l10n, 
    UserDailySummary? todaySummary,
    List<UserDailySummary> weekSummaries,
  ) {
    // Calculate totals from week summaries
    final totalWorkoutMinutes = weekSummaries.fold<int>(
      0, (sum, summary) => sum + summary.totalWorkoutDurationMinutes,
    );
    final totalCaloriesBurned = weekSummaries.fold<int>(
      0, (sum, summary) => sum + summary.totalCaloriesBurned,
    );


    // Today's data
    final todayWorkoutMinutes = todaySummary?.totalWorkoutDurationMinutes ?? 0;
    final todayCaloriesConsumed = todaySummary?.totalCaloriesConsumed ?? 0.0;

    // Format values
    final todayWorkoutValue = todayWorkoutMinutes > 0 ? '${todayWorkoutMinutes}m' : '0m';
    final totalSessionsValue = weekSummaries.where((s) => s.totalWorkoutDurationMinutes > 0).length.toString();
    final timeInvestedValue = _formatDuration(totalWorkoutMinutes);
    final caloriesBurnedValue = _formatNumber(totalCaloriesBurned.toDouble());
    final todayIntakeValue = _formatNumber(todayCaloriesConsumed);

    return [
      {
        'title': l10n?.todaysWorkout ?? "Today's Workout",
        'value': todayWorkoutValue,
        'subtitle': l10n?.keepMomentum ?? 'Keep the momentum',
        'icon': Icons.show_chart,
        'gradient': [context.colors.primary, context.colors.primary.withAlpha((255 * 0.7).round())],
      },
      {
        'title': l10n?.totalSessions ?? 'Total Sessions',
        'value': totalSessionsValue,
        'subtitle': l10n?.consistencyMatters ?? 'Consistency matters',
        'icon': Icons.bar_chart,
        'gradient': [context.colors.secondary, context.colors.secondary.withAlpha((255 * 0.7).round())],
      },
      {
        'title': l10n?.timeInvested ?? 'Time Invested',
        'value': timeInvestedValue,
        'subtitle': l10n?.yourDedication ?? 'Your dedication',
        'icon': Icons.calendar_month,
        'gradient': [context.colors.primary, context.colors.primary.withAlpha((255 * 0.7).round())],
      },
      {
        'title': l10n?.caloriesBurned ?? 'Calories Burned',
        'value': caloriesBurnedValue,
        'subtitle': l10n?.energyTransformed ?? 'Energy transformed',
        'icon': Icons.local_fire_department,
        'gradient': [context.colors.accent, context.colors.accent.withAlpha((255 * 0.7).round())],
      },
      {
        'title': l10n?.todaysIntake ?? "Today's Intake",
        'value': todayIntakeValue,
        'subtitle': l10n?.caloriesConsumed ?? 'Calories consumed',
        'icon': Icons.flash_on,
        'gradient': [context.colors.secondary, context.colors.secondary.withAlpha((255 * 0.7).round())],
      },
    ];
  }

  /// Build exercise chart data from summaries
  List<Map<String, dynamic>> _buildExerciseChartData(List<UserDailySummary> summaries) {
    // Sort summaries by date
    final sortedSummaries = List<UserDailySummary>.from(summaries)
      ..sort((a, b) => a.summaryDate.compareTo(b.summaryDate));

    // Take last 7 days
    final last7Days = sortedSummaries.length > 7 
        ? sortedSummaries.sublist(sortedSummaries.length - 7)
        : sortedSummaries;

    return last7Days.map((summary) {
      final date = summary.summaryDate;
      final dateStr = '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
      return {
        'date': dateStr,
        'duration': summary.totalWorkoutDurationMinutes,
      };
    }).toList();
  }

  /// Build nutrition chart data from summaries
  List<Map<String, dynamic>> _buildNutritionChartData(List<UserDailySummary> summaries) {
    // Sort summaries by date
    final sortedSummaries = List<UserDailySummary>.from(summaries)
      ..sort((a, b) => a.summaryDate.compareTo(b.summaryDate));

    // Take last 7 days
    final last7Days = sortedSummaries.length > 7 
        ? sortedSummaries.sublist(sortedSummaries.length - 7)
        : sortedSummaries;

    return last7Days.map((summary) {
      final date = summary.summaryDate;
      final dateStr = '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
      return {
        'date': dateStr,
        'protein': summary.totalProteinConsumed.round(),
        'carbs': summary.totalCarbsConsumed.round(),
        'fat': summary.totalFatConsumed.round(),
      };
    }).toList();
  }

  /// Build recent workouts from summaries (placeholder implementation)
  List<Map<String, dynamic>> _buildRecentWorkouts(AppLocalizations? l10n, List<UserDailySummary> summaries) {
    // Since we don't have detailed workout data in summaries, return placeholder data
    // In a real implementation, this would fetch from workout session data
    final workoutDays = summaries.where((s) => s.totalWorkoutDurationMinutes > 0).toList()
      ..sort((a, b) => b.summaryDate.compareTo(a.summaryDate));

    return workoutDays.take(6).map((summary) {
      final date = summary.summaryDate;
      final dateStr = '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
      
      return {
        'name': l10n?.workout ?? 'Workout',
        'duration': summary.totalWorkoutDurationMinutes,
        'calories': summary.totalCaloriesBurned,
        'type': l10n?.strength ?? 'Strength',
        'date': dateStr,
      };
    }).toList();
  }

  /// Format duration in minutes to human readable format
  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}m';
      }
    }
  }

  /// Format number with appropriate suffix (k for thousands)
  String _formatNumber(double number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    } else {
      return number.toStringAsFixed(0);
    }
  }
}