import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:jfit/core/theme/analytics_chart_theme.dart';
import 'package:jfit/features/analytics/domain/entities/nutrition_data.dart';
import 'dart:math';

enum NutritionFilter { all, carbs, protein, fat }

class NutritionStatsChartWidget extends StatelessWidget {
  final List<NutritionData> data;
  final String period;
  final NutritionFilter filter;
  final bool isDesktop;

  const NutritionStatsChartWidget({
    super.key,
    required this.data,
    required this.period,
    this.filter = NutritionFilter.all,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('데이터가 없습니다.'));
    }

    final double maxY = _getMaxY();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
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
                // 모바일에서 1개월 라벨 축소
                if (!isDesktop && period == '1m' && index % 3 != 0) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4.0,
                  child: Text(data[index].dateLabel, style: AnalyticsChartTheme.axisLabelStyle),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == 0 || value > maxY) return Container();
                // Show labels at intervals of maxY / 3
                if (value % (maxY / 3).round() == 0 || value == maxY) {
                     return Text('${value.toInt()}', style: AnalyticsChartTheme.axisLabelStyle);
                }
                return Container();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: _getBarGroups(),
        barTouchData: _getBarTouchData(),
      ),
    );
  }

  double _getMaxY() {
    if (data.isEmpty) return 0;

    double maxVal = 0;
    switch (filter) {
      case NutritionFilter.carbs:
        maxVal = data.map((d) => d.carbs).reduce(max);
        break;
      case NutritionFilter.protein:
        maxVal = data.map((d) => d.protein).reduce(max);
        break;
      case NutritionFilter.fat:
        maxVal = data.map((d) => d.fat).reduce(max);
        break;
      case NutritionFilter.all:
      default:
        maxVal = data.map((d) => d.carbs + d.protein + d.fat).reduce(max);
        break;
    }
    return (maxVal * 1.2).ceilToDouble();
  }

  List<BarChartGroupData> _getBarGroups() {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      
      final totalY = item.carbs + item.protein + item.fat;
      
      final rodStackItems = <BarChartRodStackItem>[
        if (filter == NutritionFilter.all || filter == NutritionFilter.carbs)
          BarChartRodStackItem(0, item.carbs, AnalyticsChartTheme.nutritionDataColors[0]),
        if (filter == NutritionFilter.all || filter == NutritionFilter.protein)
          BarChartRodStackItem(item.carbs, item.carbs + item.protein, AnalyticsChartTheme.nutritionDataColors[1]),
        if (filter == NutritionFilter.all || filter == NutritionFilter.fat)
          BarChartRodStackItem(item.carbs + item.protein, totalY, AnalyticsChartTheme.nutritionDataColors[2]),
      ];
      
      // Adjust stack for filtered view
      double rodY = 0;
      List<BarChartRodStackItem> displayStack = [];
      if (filter != NutritionFilter.all) {
          double currentY = 0;
          if (filter == NutritionFilter.carbs) {
              rodY = item.carbs;
              displayStack.add(BarChartRodStackItem(0, rodY, AnalyticsChartTheme.nutritionDataColors[0]));
          } else if (filter == NutritionFilter.protein) {
              rodY = item.protein;
              displayStack.add(BarChartRodStackItem(0, rodY, AnalyticsChartTheme.nutritionDataColors[1]));
          } else if (filter == NutritionFilter.fat) {
              rodY = item.fat;
              displayStack.add(BarChartRodStackItem(0, rodY, AnalyticsChartTheme.nutritionDataColors[2]));
          }
      } else {
        rodY = totalY;
        displayStack = rodStackItems;
      }


      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: rodY,
            width: _getBarWidth(period, isDesktop),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            rodStackItems: displayStack,
          ),
        ],
      );
    }).toList();
  }

  BarTouchData _getBarTouchData() {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (_) => AnalyticsChartTheme.tooltipBackground,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final item = data[group.x.toInt()];
          final total = item.carbs + item.protein + item.fat;
          
          String tooltipText;
          final dateLabel = item.dateLabel;
          switch (filter) {
            case NutritionFilter.carbs:
              tooltipText = '탄수화물: ${item.carbs.round()}g';
              break;
            case NutritionFilter.protein:
              tooltipText = '단백질: ${item.protein.round()}g';
              break;
            case NutritionFilter.fat:
              tooltipText = '지방: ${item.fat.round()}g';
              break;
            case NutritionFilter.all:
            default:
              tooltipText = '총: ${total.round()}g\n'
                            '탄: ${item.carbs.round()}g\n'
                            '단: ${item.protein.round()}g\n'
                            '지: ${item.fat.round()}g';
              break;
          }

          return BarTooltipItem(
            '$dateLabel\n$tooltipText',
            AnalyticsChartTheme.tooltipTextStyle.copyWith(
              fontSize: 12, 
              height: 1.5,
              // Use a single color for filtered tooltip
              color: filter == NutritionFilter.all 
                ? Colors.white 
                : AnalyticsChartTheme.nutritionDataColors[filter.index -1],
            ),
          );
        },
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