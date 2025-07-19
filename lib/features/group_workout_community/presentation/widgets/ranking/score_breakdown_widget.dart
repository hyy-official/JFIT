import 'package:flutter/material.dart';

class ScoreBreakdownWidget extends StatelessWidget {
  final Map<String, dynamic> scoreBreakdown;
  final bool isCompact;

  const ScoreBreakdownWidget({
    super.key,
    required this.scoreBreakdown,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (scoreBreakdown.isEmpty) {
      return const Center(
        child: Text('점수 분석 데이터가 없습니다'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildScoreMetrics(context),
        if (!isCompact) ...[
          const SizedBox(height: 16),
          _buildDetailedAnalysis(context),
        ],
      ],
    );
  }

  Widget _buildScoreMetrics(BuildContext context) {
    final metrics = [
      ('볼륨 점수', scoreBreakdown['volumeScore'] as double? ?? 0.0, Icons.fitness_center, Colors.blue),
      ('균형 점수', scoreBreakdown['balanceScore'] as double? ?? 0.0, Icons.balance, Colors.green),
      ('진전 점수', scoreBreakdown['progressScore'] as double? ?? 0.0, Icons.trending_up, Colors.orange),
      ('일관성 점수', scoreBreakdown['consistencyScore'] as double? ?? 0.0, Icons.schedule, Colors.purple),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isCompact ? 2 : 4,
        childAspectRatio: isCompact ? 1.5 : 1.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final (label, score, icon, color) = metrics[index];
        return _buildMetricCard(context, label, score, icon, color);
      },
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    double score,
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
            score.toStringAsFixed(1),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
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

  Widget _buildDetailedAnalysis(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '상세 분석',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        _buildAnalysisItem(
          context,
          '강점 영역',
          _getStrongestArea(),
          Icons.star,
          Colors.green,
        ),
        _buildAnalysisItem(
          context,
          '개선 영역',
          _getWeakestArea(),
          Icons.trending_up,
          Colors.orange,
        ),
        _buildAnalysisItem(
          context,
          '전체 평가',
          _getOverallAssessment(),
          Icons.assessment,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildAnalysisItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStrongestArea() {
    final scores = {
      '볼륨': scoreBreakdown['volumeScore'] as double? ?? 0.0,
      '균형': scoreBreakdown['balanceScore'] as double? ?? 0.0,
      '진전': scoreBreakdown['progressScore'] as double? ?? 0.0,
      '일관성': scoreBreakdown['consistencyScore'] as double? ?? 0.0,
    };
    
    final strongest = scores.entries.reduce((a, b) => a.value > b.value ? a : b);
    return '${strongest.key} (${strongest.value.toStringAsFixed(1)}점)';
  }

  String _getWeakestArea() {
    final scores = {
      '볼륨': scoreBreakdown['volumeScore'] as double? ?? 0.0,
      '균형': scoreBreakdown['balanceScore'] as double? ?? 0.0,
      '진전': scoreBreakdown['progressScore'] as double? ?? 0.0,
      '일관성': scoreBreakdown['consistencyScore'] as double? ?? 0.0,
    };
    
    final weakest = scores.entries.reduce((a, b) => a.value < b.value ? a : b);
    return '${weakest.key} (${weakest.value.toStringAsFixed(1)}점)';
  }

  String _getOverallAssessment() {
    final totalScore = scoreBreakdown['totalScore'] as double? ?? 0.0;
    
    if (totalScore >= 90) return '우수한 성과를 보이고 있습니다';
    if (totalScore >= 80) return '양호한 수준입니다';
    if (totalScore >= 70) return '보통 수준입니다';
    if (totalScore >= 60) return '개선이 필요합니다';
    return '많은 개선이 필요합니다';
  }
}