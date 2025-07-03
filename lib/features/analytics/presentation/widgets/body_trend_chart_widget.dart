import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:jfit/core/theme/analytics_chart_theme.dart';
import 'package:jfit/features/analytics/domain/entities/body_data.dart';
import 'package:jfit/features/analytics/presentation/widgets/body_tab.dart';
import 'package:intl/intl.dart';

class BodyTrendChartWidget extends StatelessWidget {
  final List<BodyData> data;
  final String period;
  final BodyFilter filter;
  final bool isDesktop;

  const BodyTrendChartWidget({
    super.key,
    required this.data,
    required this.period,
    this.filter = BodyFilter.weight,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('데이터가 없습니다.'));
    }

    final double maxY = _getMaxY();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: data.length - 1,
        minY: 0,
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

                // 포인트가 있는 위치(정수 index)일 때만 라벨을 보여줌
                if (value == index.toDouble()) {
                  final label = period == '1y'
                      ? DateFormat('yy/MM').format(DateTime.parse(data[index].dateLabel))
                      : DateFormat('M/d').format(DateTime.parse(data[index].dateLabel));
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 4.0,
                    child: Text(label, style: AnalyticsChartTheme.axisLabelStyle),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
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
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: maxY / 3,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AnalyticsChartTheme.gridLineColor,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: AnalyticsChartTheme.gridLineColor,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AnalyticsChartTheme.borderColor, width: 1),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              double yValue;
              switch (filter) {
                case BodyFilter.weight:
                  yValue = item.weight;
                  break;
                case BodyFilter.skeletalMuscleMass:
                  yValue = item.skeletalMuscleMass;
                  break;
                case BodyFilter.bodyFatPercentage:
                  yValue = item.bodyFatPercentage;
                  break;
              }
              return FlSpot(index.toDouble(), yValue);
            }).toList(),
            isCurved: true,
            gradient: AnalyticsChartTheme.scoreBarGradient, // Use a gradient for the line
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 4,
                color: AnalyticsChartTheme.primaryAccent,
                strokeColor: Colors.white,
                strokeWidth: 1,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: AnalyticsChartTheme.scoreBarGradient.colors
                    .map((color) => color.withOpacity(0.3))
                    .toList(),
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final index = touchedSpot.spotIndex;
                final item = data[index];
                String valueText;
                String unit;

                switch (filter) {
                  case BodyFilter.weight:
                    valueText = item.weight.toStringAsFixed(1);
                    unit = 'kg';
                    break;
                  case BodyFilter.skeletalMuscleMass:
                    valueText = item.skeletalMuscleMass.toStringAsFixed(1);
                    unit = 'kg';
                    break;
                  case BodyFilter.bodyFatPercentage:
                    valueText = item.bodyFatPercentage.toStringAsFixed(1);
                    unit = '%';
                    break;
                }

                return LineTooltipItem(
                  '${item.dateLabel}\n$valueText$unit',
                  AnalyticsChartTheme.tooltipTextStyle,
                );
              }).toList();
            },
            getTooltipColor: (_) => AnalyticsChartTheme.tooltipBackground,
          ),
        ),
      ),
    );
  }

  double _getMaxY() {
    if (data.isEmpty) return 0;

    double maxVal = 0;
    switch (filter) {
      case BodyFilter.weight:
        maxVal = data.map((d) => d.weight).reduce((a, b) => a > b ? a : b);
        break;
      case BodyFilter.skeletalMuscleMass:
        maxVal = data.map((d) => d.skeletalMuscleMass).reduce((a, b) => a > b ? a : b);
        break;
      case BodyFilter.bodyFatPercentage:
        maxVal = data.map((d) => d.bodyFatPercentage).reduce((a, b) => a > b ? a : b);
        break;
    }
    return (maxVal * 1.1).ceilToDouble();
  }
}
