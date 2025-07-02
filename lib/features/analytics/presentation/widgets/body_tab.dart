import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/theme/analytics_chart_theme.dart';
import 'package:jfit/features/analytics/domain/entities/body_data.dart';
import 'package:jfit/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:jfit/features/analytics/presentation/widgets/body_trend_chart_widget.dart';
import 'package:jfit/features/analytics/presentation/widgets/body_comparison_card.dart';

enum BodyFilter { weight, skeletalMuscleMass, bodyFatPercentage }

class BodyTab extends StatelessWidget {
  const BodyTab({super.key});

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
    final bodyData = loadedState?.bodyData ?? [];
    final period = loadedState?.period ?? '7d';

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
              _BodyTrendCard(data: bodyData, period: period, isDesktop: isDesktop),
              const SizedBox(height: 24),
              BodyComparisonCard(
                previousData: bodyData.length > 1 ? bodyData[bodyData.length - 2] : null,
                currentData: bodyData.isNotEmpty ? bodyData.last : null,
              ),
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

class _BodyTrendCard extends StatefulWidget {
  final List<BodyData> data;
  final String period;
  final bool isDesktop;

  const _BodyTrendCard({
    required this.data,
    required this.period,
    required this.isDesktop,
  });

  @override
  State<_BodyTrendCard> createState() => _BodyTrendCardState();
}

class _BodyTrendCardState extends State<_BodyTrendCard> {
  BodyFilter _selectedFilter = BodyFilter.weight;

  @override
  Widget build(BuildContext context) {
    const filters = ['체중(kg)', '골격근량(kg)', '체지방량(%)'];
    final filterKeys = BodyFilter.values;

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
          const Text('변화 추세', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
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
            child: BodyTrendChartWidget(
              data: widget.data,
              period: widget.period,
              filter: _selectedFilter,
              isDesktop: widget.isDesktop,
            ),
          ),
        ],
      ),
    );
  }
}
