import 'package:flutter/material.dart';
import '../../../domain/entities/body_part_mapping.dart';

class DetailedScoreMetrics extends StatelessWidget {
  final Map<String, dynamic> scoreBreakdown;
  final Map<String, dynamic>? workoutAnalysis;
  final bool isCompact;

  const DetailedScoreMetrics({
    super.key,
    required this.scoreBreakdown,
    this.workoutAnalysis,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetricsGrid(context),
        if (!isCompact && workoutAnalysis != null) ...[
          const SizedBox(height: 16),
          _buildAdditionalMetrics(context),
        ],
      ],
    );
  }

  Widget _buildMetricsGrid(BuildContext context) {
    final metrics = [
      ('볼륨 점수', scoreBreakdown['volumeScore'] as double? ?? 0.0, Icons.fitness_center, Colors.blue),
      ('균형 점수', scoreBreakdown['balanceScore'] as double? ?? 0.0, Icons.balance, Colors.green),
      ('진전 점수', scoreBreakdown['progressScore'] as double? ?? 0.0, Icons.trending_up, Colors.orange),
      ('일관성 점수', scoreBreakdown['consistencyScore'] as double? ?? 0.0, Icons.schedule, Colors.purple),
      ('총 운동량', scoreBreakdown['totalVolume'] as double? ?? 0.0, Icons.straighten, Colors.teal),
      ('운동 빈도', scoreBreakdown['frequency'] as double? ?? 0.0, Icons.repeat, Colors.indigo),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isCompact ? 2 : 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final (label, value, icon, color) = metrics[index];
        return _buildMetricCard(context, label, value, icon, color);
      },
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    double value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value.toStringAsFixed(1),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalMetrics(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '추가 지표',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        _buildMetricsList(context),
      ],
    );
  }

  Widget _buildMetricsList(BuildContext context) {
    final additionalMetrics = [
      ('평균 세션 시간', '${workoutAnalysis!['averageSessionTime'] ?? 0}분'),
      ('최대 볼륨', '${workoutAnalysis!['maxVolume'] ?? 0} kg'),
      ('운동 다양성', '${workoutAnalysis!['exerciseVariety'] ?? 0}종류'),
      ('목표 달성률', '${workoutAnalysis!['goalAchievementRate'] ?? 0}%'),
      ('개선율', '${workoutAnalysis!['improvementRate'] ?? 0}%'),
      ('안정성 지수', '${workoutAnalysis!['stabilityIndex'] ?? 0}'),
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: additionalMetrics.length,
      itemBuilder: (context, index) {
        final (label, value) = additionalMetrics[index];
        return _buildMetricRow(context, label, value);
      },
    );
  }

  Widget _buildMetricRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}