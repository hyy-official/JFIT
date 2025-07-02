import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/theme/analytics_chart_theme.dart';
import 'package:jfit/features/analytics/domain/entities/workout_composition_data.dart';
import 'package:jfit/features/analytics/domain/entities/workout_time_data.dart';
import 'package:jfit/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:jfit/features/analytics/presentation/widgets/workout_composition_chart.dart';
import 'package:jfit/features/analytics/presentation/widgets/workout_time_chart.dart';

class ExerciseTab extends StatelessWidget {
  const ExerciseTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) {
        if (state is AnalyticsError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        if (state is AnalyticsLoaded) {
          return _buildContent(context, state, false);
        }
        // AnalyticsLoading or AnalyticsInitial
        return _buildContent(context, null, true);
      },
    );
  }

  Widget _buildContent(BuildContext context, AnalyticsLoaded? loadedState, bool isLoading) {
    final timeData = loadedState?.workoutTimeData ?? [];
    final compData = loadedState?.workoutCompositionData ?? [];
    final period = loadedState?.period ?? '7d';

    final totalMinutes = timeData.fold<double>(0, (sum, item) => sum + item.minutes);
    final avgMinutes = timeData.isNotEmpty ? totalMinutes / timeData.length : 0.0;
    final isDesktop = MediaQuery.of(context).size.width >= 700;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PeriodSelector(selectedPeriod: period),
              const SizedBox(height: 24),
              _buildWorkoutTimeCard(context, timeData, totalMinutes, avgMinutes, isDesktop, period),
              const SizedBox(height: 24),
              _buildCompositionCard(context, compData),
            ],
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildWorkoutTimeCard(BuildContext context, List<WorkoutTimeData> data, double total, double avg, bool isDesktop, String period) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnalyticsChartTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AnalyticsChartTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('운동 시간', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('누적 ${total.round()}분 / 평균 ${avg.round()}분', style: const TextStyle(color: AnalyticsChartTheme.legendText, fontSize: 14)),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: WorkoutTimeChartWidget(data: data, period: period, isDesktop: isDesktop),
          ),
        ],
      ),
    );
  }

  Widget _buildCompositionCard(BuildContext context, List<WorkoutCompositionData> data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnalyticsChartTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AnalyticsChartTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('운동 구성', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: data.asMap().entries.map((e) {
              final idx = e.key;
              final label = e.value.category;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.square, color: WorkoutCompositionChart.segmentColors[idx % WorkoutCompositionChart.segmentColors.length], size: 10),
                  const SizedBox(width: 4),
                  Text(label, style: const TextStyle(color: AnalyticsChartTheme.legendText, fontSize: 12)),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: WorkoutCompositionChart(data: data),
          ),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  final String selectedPeriod;

  const _PeriodSelector({required this.selectedPeriod});

  @override
  Widget build(BuildContext context) {
    const periodsText = ['7일', '1개월', '3개월', '1년'];
    const periodKeys = ['7d', '1m', '3m', '1y'];

    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonWidth = (constraints.maxWidth - 2) / periodsText.length;
        final selectedIndex = periodKeys.indexOf(selectedPeriod);
        final leftPosition = selectedIndex * buttonWidth;

        return Container(
          height: 48,
          decoration: BoxDecoration(
            color: AnalyticsChartTheme.cardBackground.withOpacity(0.3),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AnalyticsChartTheme.cardBorder.withOpacity(0.5), width: 1),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                left: leftPosition,
                top: 2,
                bottom: 2,
                width: buttonWidth,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AnalyticsChartTheme.scoreBarGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AnalyticsChartTheme.primaryAccent.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: List.generate(periodsText.length, (index) {
                  final isSelected = selectedPeriod == periodKeys[index];
                  return Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        context.read<AnalyticsBloc>().add(FetchAnalyticsData(period: periodKeys[index]));
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          periodsText[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : AnalyticsChartTheme.unselectedToggleText,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}