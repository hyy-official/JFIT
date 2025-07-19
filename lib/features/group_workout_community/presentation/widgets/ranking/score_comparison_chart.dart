import 'package:flutter/material.dart';

class ScoreComparisonChart extends StatelessWidget {
  final List<Map<String, dynamic>> memberScores;
  final double height;

  const ScoreComparisonChart({
    super.key,
    required this.memberScores,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    if (memberScores.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text('점수 데이터가 없습니다'),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(
            child: _buildBarChart(context),
          ),
          const SizedBox(height: 16),
          _buildChartLegend(context),
        ],
      ),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    // Placeholder for bar chart implementation
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 48),
            SizedBox(height: 8),
            Text('점수 비교 차트'),
            Text('(구현 예정)', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem(context, '총점', Colors.blue),
        _buildLegendItem(context, '균형', Colors.green),
        _buildLegendItem(context, '볼륨', Colors.orange),
        _buildLegendItem(context, '진전', Colors.purple),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}