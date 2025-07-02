import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:jfit/l10n/app_localizations.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/core/extensions/context_extensions.dart';

class NutritionChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const NutritionChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: context.colors.surface,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppTheme.nutritionIconColor.withOpacity(0.8), AppTheme.nutritionIconColor]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.restaurant, color: Colors.white, size: 20),
                ),
                SizedBox(width: 10),
                Text(l10n?.weeklyNutritionIntake ?? 'Weekly Nutrition Intake', style: context.texts.titleMedium?.copyWith(color: Colors.white)),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: AppTheme.surface2, strokeWidth: 1)),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, meta) => Text(v.toInt().toString(), style: context.texts.bodySmall?.copyWith(color: AppTheme.textSub)),
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, meta) {
                          if (v.toInt() >= 0 && v.toInt() < data.length) {
                            return Text(data[v.toInt()]['date'], style: context.texts.bodySmall?.copyWith(color: AppTheme.textSub));
                          }
                          return SizedBox.shrink();
                        },
                        reservedSize: 40,
                        interval: 2, // 2칸씩 건너뛰어서 표시
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['protein'] as num).toDouble())).toList(),
                      isCurved: true,
                      color: AppTheme.proteinGraphColor,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['carbs'] as num).toDouble())).toList(),
                      isCurved: true,
                      color: AppTheme.carbsGraphColor,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['fat'] as num).toDouble())).toList(),
                      isCurved: true,
                      color: AppTheme.fatGraphColor,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(color: AppTheme.proteinGraphColor, label: l10n?.protein ?? 'Protein (g)'),
                SizedBox(width: 12),
                _LegendDot(color: AppTheme.carbsGraphColor, label: l10n?.carbs ?? 'Carbs (g)'),
                SizedBox(width: 12),
                _LegendDot(color: AppTheme.fatGraphColor, label: l10n?.fat ?? 'Fat (g)'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 4),
        Text(label, style: context.texts.bodySmall?.copyWith(color: AppTheme.textSub)),
      ],
    );
  }
} 