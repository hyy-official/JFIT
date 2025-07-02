import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:jfit/l10n/app_localizations.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/core/extensions/context_extensions.dart';

class ExerciseChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const ExerciseChart({super.key, required this.data});

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
                    gradient: LinearGradient(colors: [AppTheme.workoutIconColor.withOpacity(0.8), AppTheme.workoutIconColor]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.show_chart, color: Colors.white, size: 20),
                ),
                SizedBox(width: 10),
                Text(l10n?.weeklyWorkoutDuration ?? 'Weekly Workout Duration', style: context.texts.titleMedium?.copyWith(color: Colors.white)),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
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
                  barGroups: data.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value['duration'].toDouble(), gradient: LinearGradient(colors: [AppTheme.workoutIconColor.withOpacity(0.8), AppTheme.workoutIconColor]), width: 18, borderRadius: BorderRadius.circular(6))])).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 