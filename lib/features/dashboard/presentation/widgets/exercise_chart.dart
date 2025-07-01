import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:jfit/l10n/app_localizations.dart';
import 'package:jfit/core/theme/app_theme.dart';

class ExerciseChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const ExerciseChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: AppTheme.cardBackgroundColor,
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
                    gradient: LinearGradient(colors: [AppTheme.workoutIconColor, AppTheme.workoutIconColor.withOpacity(0.7)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(Icons.show_chart, color: Colors.white, size: 20),
                ),
                SizedBox(width: 10),
                Text(l10n?.weeklyWorkoutDuration ?? 'Weekly Workout Duration', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey[800], strokeWidth: 1)),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, meta) => Text(v.toInt().toString(), style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, meta) {
                          if (v.toInt() >= 0 && v.toInt() < data.length) {
                            return Text(data[v.toInt()]['date'], style: TextStyle(color: Colors.grey[400], fontSize: 12));
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
                  barGroups: data.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value['duration'].toDouble(), color: AppTheme.workoutIconColor, width: 18, borderRadius: BorderRadius.circular(6), gradient: LinearGradient(colors: [AppTheme.workoutIconColor, AppTheme.workoutIconColor.withOpacity(0.7)]))])).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 