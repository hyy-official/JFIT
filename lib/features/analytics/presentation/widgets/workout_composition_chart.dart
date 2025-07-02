import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:jfit/core/theme/analytics_chart_theme.dart';
import 'package:jfit/features/analytics/domain/entities/workout_composition_data.dart';

class WorkoutCompositionChart extends StatefulWidget {
  final List<WorkoutCompositionData> data;

  static const List<Color> segmentColors = [
    Color(0xFF8A75F5),
    Color(0xFF6A8BFF),
    Color(0xFF4EC3E0),
    Color(0xFFB5E048),
    Color(0xFFFFA94D),
  ];

  const WorkoutCompositionChart({super.key, required this.data});

  @override
  State<WorkoutCompositionChart> createState() => _WorkoutCompositionChartState();
}

class _WorkoutCompositionChartState extends State<WorkoutCompositionChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Center(child: Text('데이터가 없습니다.'));
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 0,
        pieTouchData: PieTouchData(
          touchCallback: (event, response) {
            if (!event.isInterestedForInteractions || response == null || response.touchedSection == null) {
              setState(() => _touchedIndex = null);
              return;
            }
            setState(() => _touchedIndex = response.touchedSection!.touchedSectionIndex);
          },
        ),
        sections: widget.data.asMap().entries.map((e) {
          final idx = e.key;
          final item = e.value;
          final isTouched = idx == _touchedIndex;
          return PieChartSectionData(
            color: WorkoutCompositionChart.segmentColors[idx % WorkoutCompositionChart.segmentColors.length],
            value: item.minutes,
            title: '',
            radius: isTouched ? 70 : 60,
            badgeWidget: isTouched ? _buildTooltip(item) : null,
            badgePositionPercentageOffset: 1.0,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTooltip(WorkoutCompositionData item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AnalyticsChartTheme.tooltipBackground,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${item.category}: ${item.minutes.round()}분',
        style: AnalyticsChartTheme.tooltipTextStyle,
      ),
    );
  }
} 