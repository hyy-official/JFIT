import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:jfit/features/analytics/domain/entities/workout_time_data.dart';

class WorkoutTimeChartWidget extends StatelessWidget {
  final List<WorkoutTimeData> data;
  final String period;
  final bool isDesktop;

  const WorkoutTimeChartWidget({
    super.key,
    required this.data,
    required this.period,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('데이터가 없습니다.'));
    }

    return BarChart(
      BarChartData(
        maxY: _getMaxY() * 1.2,
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return Container();
                if (!isDesktop && period == '1m' && index % 3 != 0) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4,
                  child: Text(data[index].dateLabel, style: TextStyle(color: context.colors.textSecondary, fontSize: 12)),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: data.asMap().entries.map((e) {
          final idx = e.key;
          final item = e.value;
          return BarChartGroupData(x: idx, barRods: [
            BarChartRodData(
              toY: item.minutes,
              gradient: LinearGradient(
          colors: [context.colors.primary, context.colors.primary.withOpacity(0.7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
              width: _getBarWidth(period, isDesktop),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ]);
        }).toList(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => context.colors.surface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
              '${rod.toY.toInt()}분',
              TextStyle(color: context.colors.textPrimary, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }

  double _getMaxY() {
    if (data.isEmpty) return 0;
    return data.map((e) => e.minutes).reduce((a,b)=> a>b?a:b);
  }

  double _getBarWidth(String period, bool isDesktop) {
    switch (period) {
      case '7d':
        return isDesktop ? 40 : 24;
      case '1m':
        return isDesktop ? 12 : 8;
      case '3m':
        return isDesktop ? 28 : 16;
      case '1y':
        return isDesktop ? 32 : 18;
      default:
        return 20;
    }
  }
} 