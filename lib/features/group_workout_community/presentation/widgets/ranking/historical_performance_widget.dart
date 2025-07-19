import 'package:flutter/material.dart';

class HistoricalPerformanceWidget extends StatelessWidget {
  final List<Map<String, dynamic>> scoreTrends;
  final bool isCompact;

  const HistoricalPerformanceWidget({
    super.key,
    required this.scoreTrends,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (scoreTrends.isEmpty) {
      return const Center(
        child: Text('성과 기록이 없습니다'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPerformanceSummary(context),
        const SizedBox(height: 16),
        _buildPerformanceList(context),
      ],
    );
  }

  Widget _buildPerformanceSummary(BuildContext context) {
    final bestScore = scoreTrends.map((s) => s['totalScore'] as double? ?? 0.0).reduce((a, b) => a > b ? a : b);
    final averageScore = scoreTrends.map((s) => s['totalScore'] as double? ?? 0.0).reduce((a, b) => a + b) / scoreTrends.length;
    final latestScore = scoreTrends.first['totalScore'] as double? ?? 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            '최고 점수',
            bestScore.toStringAsFixed(1),
            Icons.star,
            Colors.amber,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context,
            '평균 점수',
            averageScore.toStringAsFixed(1),
            Icons.analytics,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context,
            '최근 점수',
            latestScore.toStringAsFixed(1),
            Icons.schedule,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String label,
    String value,
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
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
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

  Widget _buildPerformanceList(BuildContext context) {
    final displayCount = isCompact ? 5 : 10;
    final displayTrends = scoreTrends.take(displayCount).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayTrends.length,
      itemBuilder: (context, index) {
        final trend = displayTrends[index];
        return _buildPerformanceItem(context, trend, index);
      },
    );
  }

  Widget _buildPerformanceItem(BuildContext context, Map<String, dynamic> trend, int index) {
    final date = trend['date'] as String? ?? '';
    final totalScore = trend['totalScore'] as double? ?? 0.0;
    final balanceScore = trend['balanceScore'] as double? ?? 0.0;
    final volumeScore = trend['volumeScore'] as double? ?? 0.0;
    final progressScore = trend['progressScore'] as double? ?? 0.0;
    final consistencyScore = trend['consistencyScore'] as double? ?? 0.0;

    final grade = _calculateGrade(totalScore);
    final isImprovement = index < scoreTrends.length - 1 
        ? totalScore > (scoreTrends[index + 1]['totalScore'] as double? ?? 0.0)
        : false;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getGradeColor(grade),
          child: Text(
            grade,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          '${totalScore.toStringAsFixed(1)}점',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date),
            const SizedBox(height: 4),
            if (!isCompact) _buildScoreBreakdown(context, balanceScore, volumeScore, progressScore, consistencyScore),
          ],
        ),
        trailing: isImprovement
            ? const Icon(Icons.trending_up, color: Colors.green)
            : const Icon(Icons.trending_down, color: Colors.red),
        isThreeLine: !isCompact,
      ),
    );
  }

  Widget _buildScoreBreakdown(
    BuildContext context,
    double balanceScore,
    double volumeScore,
    double progressScore,
    double consistencyScore,
  ) {
    return Row(
      children: [
        _buildScoreChip('균형', balanceScore, Colors.green),
        const SizedBox(width: 4),
        _buildScoreChip('볼륨', volumeScore, Colors.blue),
        const SizedBox(width: 4),
        _buildScoreChip('진전', progressScore, Colors.orange),
        const SizedBox(width: 4),
        _buildScoreChip('일관성', consistencyScore, Colors.purple),
      ],
    );
  }

  Widget _buildScoreChip(String label, double score, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label ${score.toStringAsFixed(0)}',
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _calculateGrade(double score) {
    if (score >= 90) return 'S';
    if (score >= 80) return 'A';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    if (score >= 50) return 'D';
    return 'F';
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'S':
        return Colors.purple;
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}