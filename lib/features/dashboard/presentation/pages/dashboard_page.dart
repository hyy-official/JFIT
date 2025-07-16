import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/features/dashboard/presentation/widgets/stats_card.dart';
import 'package:jfit/features/dashboard/presentation/widgets/exercise_chart.dart';
import 'package:jfit/features/dashboard/presentation/widgets/nutrition_chart.dart';
import 'package:jfit/features/dashboard/presentation/widgets/recent_workouts.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:jfit/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:jfit/features/dashboard/bloc/dashboard_event.dart';
import 'package:jfit/features/dashboard/bloc/dashboard_state.dart';
import 'package:jfit/l10n/app_localizations.dart';
import 'package:jfit/features/auth/bloc/auth_bloc.dart';
import 'package:jfit/features/auth/bloc/auth_state.dart';


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
      context.read<DashboardBloc>().add(LoadDashboardSummary(userId: userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DashboardLoaded) {
          final dailySummaries = state.dailySummaries;
          // TODO: dailySummaries를 사용하여 stats, exerciseChartData, nutritionChartData, recentWorkouts를 구성해야 합니다.
          // 현재는 더미 데이터를 그대로 사용합니다.
          final stats = [
            {
              'title': l10n?.todaysWorkout ?? "Today's Workout",
              'value': '0m',
              'subtitle': l10n?.keepMomentum ?? 'Keep the momentum',
              'icon': Icons.show_chart,
              'gradient': [context.colors.primary, context.colors.primary.withAlpha((255 * 0.7).round())],
            },
            {
              'title': l10n?.totalSessions ?? 'Total Sessions',
              'value': '10',
              'subtitle': l10n?.consistencyMatters ?? 'Consistency matters',
              'icon': Icons.bar_chart,
              'gradient': [context.colors.secondary, context.colors.secondary.withAlpha((255 * 0.7).round())],
            },
            {
              'title': l10n?.timeInvested ?? 'Time Invested',
              'value': '7h 10m',
              'subtitle': l10n?.yourDedication ?? 'Your dedication',
              'icon': Icons.calendar_month,
              'gradient': [context.colors.primary, context.colors.primary.withAlpha((255 * 0.7).round())],
            },
            {
              'title': l10n?.caloriesBurned ?? 'Calories Burned',
              'value': '2.5k',
              'subtitle': l10n?.energyTransformed ?? 'Energy transformed',
              'icon': Icons.local_fire_department,
              'gradient': [context.colors.accent, context.colors.accent.withAlpha((255 * 0.7).round())],
            },
            {
              'title': l10n?.todaysIntake ?? "Today's Intake",
              'value': '0.0k',
              'subtitle': l10n?.caloriesConsumed ?? 'Calories consumed',
              'icon': Icons.flash_on,
              'gradient': [context.colors.secondary, context.colors.secondary.withAlpha((255 * 0.7).round())],
            },
          ];
          final exerciseChartData = [
            {'date': '06/18', 'duration': 0},
            {'date': '06/19', 'duration': 0},
            {'date': '06/20', 'duration': 0},
            {'date': '06/21', 'duration': 0},
            {'date': '06/22', 'duration': 0},
            {'date': '06/23', 'duration': 0},
            {'date': '06/24', 'duration': 0},
          ];
          final nutritionChartData = [
            {'date': '06/18', 'protein': 0, 'carbs': 0, 'fat': 0},
            {'date': '06/19', 'protein': 0, 'carbs': 0, 'fat': 0},
            {'date': '06/20', 'protein': 0, 'carbs': 0, 'fat': 0},
            {'date': '06/21', 'protein': 0, 'carbs': 0, 'fat': 0},
            {'date': '06/22', 'protein': 0, 'carbs': 0, 'fat': 0},
            {'date': '06/23', 'protein': 200, 'carbs': 50, 'fat': 20},
            {'date': '06/24', 'protein': 0, 'carbs': 0, 'fat': 0},
          ];
          final recentWorkouts = [
            {'name': l10n?.squat ?? '스쿼트', 'duration': 40, 'calories': 270, 'type': l10n?.strength ?? 'Strength', 'date': '12/06'},
            {'name': l10n?.benchPress ?? '벤치프레스', 'duration': 45, 'calories': 220, 'type': l10n?.strength ?? 'Strength', 'date': '12/05'},
            {'name': l10n?.squat ?? '스쿼트', 'duration': 40, 'calories': 260, 'type': l10n?.strength ?? 'Strength', 'date': '12/04'},
            {'name': l10n?.deadlift ?? '데드리프트', 'duration': 50, 'calories': 310, 'type': l10n?.strength ?? 'Strength', 'date': '12/04'},
            {'name': l10n?.benchPress ?? '벤치프레스', 'duration': 45, 'calories': 210, 'type': l10n?.strength ?? 'Strength', 'date': '12/03'},
            {'name': l10n?.squat ?? '스쿼트', 'duration': 40, 'calories': 250, 'type': l10n?.strength ?? 'Strength', 'date': '12/02'},
          ];

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
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(l10n?.workoutDashboard ?? 'Workout Dashboard', style: context.textTheme.headlineLarge?.copyWith(fontSize: 36, color: context.colors.textPrimary)),
                  SizedBox(height: 6),
                  Text(l10n?.currentDate ?? 'Tuesday, June 24th, 2025', style: context.textTheme.bodyMedium?.copyWith(fontSize: 18, color: context.colors.textSecondary)),
                  SizedBox(height: 24),
                  isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: stats.map((s) => SizedBox(width: 240, child: StatsCard(title: s['title'] as String, value: s['value'] as String, subtitle: s['subtitle'] as String, icon: s['icon'] as IconData, gradientColors: s['gradient'] as List<Color>))).toList(),
                              ),
                            ),
                            SizedBox(width: 24),
                            Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  ExerciseChart(data: exerciseChartData),
                                  SizedBox(height: 16),
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
                                  child: StatsCard(title: s['title'] as String, value: s['value'] as String, subtitle: s['subtitle'] as String, icon: s['icon'] as IconData, gradientColors: s['gradient'] as List<Color>),
                                )),
                            ExerciseChart(data: exerciseChartData),
                            SizedBox(height: 16),
                            NutritionChart(data: nutritionChartData),
                          ],
                        ),
                  SizedBox(height: 24),
                  RecentWorkouts(workouts: recentWorkouts),
                ],
              ),
            ),
          );
        } else if (state is DashboardError) {
          return Center(child: Text('Error: ${state.message}', style: TextStyle(color: context.colors.error)));
        }
        return Center(child: Text('Unknown state', style: TextStyle(color: context.colors.textPrimary)));
      },
    );
  }
}