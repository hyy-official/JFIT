import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:jfit/l10n/app_localizations.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:jfit/features/exercise/data/models/exercise_record.dart';

class ExerciseProgressChart extends StatefulWidget {
  final List<ExerciseRecord> exercises;

  const ExerciseProgressChart({
    super.key,
    required this.exercises,
  });

  @override
  State<ExerciseProgressChart> createState() => _ExerciseProgressChartState();
}

class _ExerciseProgressChartState extends State<ExerciseProgressChart> {
  String selectedExercise = 'benchPress';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // 더미 - 선택 가능한 운동 목록
    final exerciseOptions = [
      'benchPress',
      'squat',
      'deadlift',
      'pushUp',
      'pullUp',
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.colors.border.withAlpha((255 * 0.3).round()),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.primary.withAlpha((255 * 0.15).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: context.colors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n?.exerciseProgress ?? 'Exercise Progress',
                style: context.textTheme.titleMedium?.copyWith(color: context.colors.textPrimary),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 운동 선택 드롭다운
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.colors.border.withAlpha((255 * 0.5).round()),
                width: 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedExercise,
                dropdownColor: context.colors.surface,
                style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textPrimary),
                icon: Icon(Icons.keyboard_arrow_down, color: context.colors.textPrimary),
                isExpanded: true,
                items: exerciseOptions.map((exercise) {
                  return DropdownMenuItem<String>(
                    value: exercise,
                    child: Text(
                      _getExerciseName(l10n, exercise),
                      style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textPrimary),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedExercise = value;
                    });
                  }
                },
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 차트 제목
          Text(
            l10n?.totalVolume ?? 'Total Volume (kg × sets × reps)',
            style: context.textTheme.bodyMedium?.copyWith(fontSize: 16, color: context.colors.textSecondary),
          ),
          
          const SizedBox(height: 20),
          
          // 차트
          SizedBox(
            height: 200,
            child: _buildChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    // 선택된 운동의 데이터 필터링 및 볼륨 계산
    final selectedExerciseData = widget.exercises
        .where((exercise) => exercise.exerciseName == selectedExercise)
        .toList();

    if (selectedExerciseData.isEmpty) {
      final l10n = AppLocalizations.of(context);
      return Center(
        child: Text(
          l10n?.selectExerciseToViewProgress ?? 'Please select an exercise to view progress',
          style: context.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary, fontSize: 16),
        ),
      );
    }

    // 볼륨 계산 (무게 × 세트 × 회수)
    final List<FlSpot> spots = [];
    for (int i = 0; i < selectedExerciseData.length; i++) {
      final exercise = selectedExerciseData[i];
      final weight = exercise.weightKg ?? 0;
      final sets = exercise.sets ?? 0;
      final reps = exercise.reps ?? 0;
      final volume = weight * sets * reps;
      spots.add(FlSpot(i.toDouble(), volume.toDouble()));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 500,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: context.colors.border,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: context.colors.border,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= selectedExerciseData.length) {
                  return const Text('');
                }
                final date = selectedExerciseData[value.toInt()].exerciseDate;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '${date.month}/${date.day}',
                    style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary, fontSize: 12),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: context.textTheme.bodySmall?.copyWith(color: context.colors.textSecondary, fontSize: 12),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: context.colors.border, width: 1),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: context.colors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(
              show: true,
            ),
            belowBarData: BarAreaData(
              show: true,
              color: context.colors.primary.withAlpha((255 * 0.1).round()),
            ),
          ),
        ],
      ),
    );
  }

  String _getExerciseName(AppLocalizations? l10n, String exerciseKey) {
    switch (exerciseKey) {
      case 'benchPress':
        return l10n?.benchPress ?? 'Bench Press';
      case 'squat':
        return l10n?.squat ?? 'Squat';
      case 'deadlift':
        return l10n?.deadlift ?? 'Deadlift';
      case 'pushUp':
        return l10n?.pushUp ?? 'Push Up';
      case 'pullUp':
        return l10n?.pullUp ?? 'Pull Up';
      default:
        return exerciseKey;
    }
  }
} 