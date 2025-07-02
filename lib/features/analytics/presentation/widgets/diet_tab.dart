import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/theme/analytics_chart_theme.dart';
import 'package:jfit/features/analytics/domain/entities/diet_score_data.dart';
import 'package:jfit/features/analytics/domain/entities/nutrition_data.dart';
import 'package:jfit/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:jfit/features/analytics/presentation/widgets/diet_score_chart.dart';
import 'package:jfit/features/analytics/presentation/widgets/nutrition_stats_chart.dart';

class DietTab extends StatelessWidget {
  const DietTab({super.key});

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
    final dietData = loadedState?.dietScoreData ?? [];
    final nutritionData = loadedState?.nutritionData ?? [];
    final period = loadedState?.period ?? '7d';

    final double avgScore = dietData.isNotEmpty
        ? dietData.map((d) => d.score).reduce((a, b) => a + b) / dietData.length
        : 0;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PeriodSelector(selectedPeriod: period),
                const SizedBox(height: 24.0),
                _buildDietScoreCard(context, dietData, avgScore, period),
                const SizedBox(height: 24.0),
                _buildNutritionStatsCard(context, nutritionData, period),
              ],
            ),
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

  Widget _buildDietScoreCard(
      BuildContext context, List<DietScoreData> data, double avgScore, String period) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnalyticsChartTheme.cardBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AnalyticsChartTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('식단 점수', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4.0),
          Text('평균 ${avgScore.toStringAsFixed(1)}점', style: const TextStyle(color: AnalyticsChartTheme.legendText, fontSize: 14)),
          const SizedBox(height: 24.0),
          _buildDietScoreLegend(),
          const SizedBox(height: 16.0),
          SizedBox(
            height: 220,
            child: DietScoreChartWidget(
              data: data,
              period: period,
              isDesktop: MediaQuery.of(context).size.width >= 700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietScoreLegend() {
    final legends = {
      '5점': Colors.green, '4점': Colors.blue, '3점': Colors.yellow, '2점': Colors.orange, '1점': Colors.red,
    };

    return Wrap(
      spacing: 16.0,
      runSpacing: 8.0,
      children: legends.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, color: entry.value, size: 10),
            const SizedBox(width: 6.0),
            Text(entry.key, style: const TextStyle(color: AnalyticsChartTheme.legendText, fontSize: 12)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildNutritionStatsCard(BuildContext context, List<NutritionData> data, String period) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AnalyticsChartTheme.cardBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AnalyticsChartTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('영양성분', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24.0),
          _NutritionFilter(data: data, period: period),
          const SizedBox(height: 16.0),
          _buildNutritionLegend(),
        ],
      ),
    );
  }

  Widget _buildNutritionLegend() {
    final legends = {
      '탄수화물': AnalyticsChartTheme.nutritionDataColors[0],
      '단백질': AnalyticsChartTheme.nutritionDataColors[1],
      '지방': AnalyticsChartTheme.nutritionDataColors[2],
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: legends.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              Icon(Icons.circle, color: entry.value, size: 10),
              const SizedBox(width: 6.0),
              Text(entry.key, style: const TextStyle(color: AnalyticsChartTheme.legendText, fontSize: 12)),
            ],
          ),
        );
      }).toList(),
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

class _NutritionFilter extends StatefulWidget {
  final List<NutritionData> data;
  final String period;

  const _NutritionFilter({required this.data, required this.period});

  @override
  State<_NutritionFilter> createState() => _NutritionFilterState();
}

class _NutritionFilterState extends State<_NutritionFilter> {
  NutritionFilter _selectedFilter = NutritionFilter.all;

  @override
  Widget build(BuildContext context) {
    const filters = ['전체', '탄수화물', '단백질', '지방'];
    final filterKeys = NutritionFilter.values;

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final buttonWidth = (constraints.maxWidth - 2) / filters.length;
            final selectedIndex = filterKeys.indexOf(_selectedFilter);
            final leftPosition = selectedIndex * buttonWidth;

            return Container(
              height: 40,
              decoration: BoxDecoration(
                color: AnalyticsChartTheme.cardBackground.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
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
                        borderRadius: BorderRadius.circular(18),
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
                    children: List.generate(filters.length, (index) {
                      final isSelected = _selectedFilter == filterKeys[index];
                      return Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            setState(() {
                              _selectedFilter = filterKeys[index];
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              filters[index],
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
        ),
        const SizedBox(height: 16.0),
        SizedBox(
          height: 220,
          child: NutritionStatsChartWidget(
            data: widget.data,
            period: widget.period,
            filter: _selectedFilter,
            isDesktop: MediaQuery.of(context).size.width >= 700,
          ),
        ),
      ],
    );
  }
}