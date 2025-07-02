import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:jfit/core/theme/analytics_chart_theme.dart';
import 'package:jfit/features/analytics/domain/entities/diet_score_data.dart';

class DietScoreChartWidget extends StatelessWidget {
  final List<DietScoreData> data;
  final String period;
  final bool isDesktop;

  const DietScoreChartWidget({
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
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return Container();
                // 모바일(작은 화면)에서 1개월 데이터는 라벨 일부만 노출하여 겹침 방지
                if (!isDesktop && period == '1m' && index % 3 != 0) {
                  return const SizedBox.shrink();
                }
                final label = data[index].dateLabel;
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4.0,
                  child: Text(label, style: AnalyticsChartTheme.axisLabelStyle),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
              reservedSize: 35,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value == 0 || value > 5) return Container();
                return Text(
                  '${value.toInt()}',
                  style: AnalyticsChartTheme.axisLabelStyle,
                  textAlign: TextAlign.left,
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item.score,
                gradient: AnalyticsChartTheme.scoreBarGradient,
                width: _getBarWidth(period, isDesktop),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AnalyticsChartTheme.tooltipBackground,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final dateLabel = data[group.x.toInt()].dateLabel;
              return BarTooltipItem(
                '$dateLabel\n${rod.toY?.toStringAsFixed(1)}점',
                AnalyticsChartTheme.tooltipTextStyle,
              );
            },
          ),
        ),
      ),
    );
  }

  double _getBarWidth(String period, bool isDesktop) {
    switch (period) {
      case '7d':
        return isDesktop ? 40.0 : 24.0;
      case '1m':
        return isDesktop ? 28.0 : 12.0;
      case '3m':
        return isDesktop ? 32.0 : 18.0;
      case '1y':
        return isDesktop ? 35.0 : 20.0;
      default:
        return 30.0;
    }
  }
} 