import 'package:flutter/material.dart';

class ScoreTrendChart extends StatelessWidget {
  final List<Map<String, dynamic>> scoreTrends;
  final double height;

  const ScoreTrendChart({
    super.key,
    required this.scoreTrends,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (scoreTrends.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text('트렌드 데이터가 없습니다'),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(
            child: _buildLineChart(context),
          ),
          const SizedBox(height: 16),
          _buildTrendSummary(context),
        ],
      ),
    );
  }

  Widget _buildLineChart(BuildContext context) {
    // Placeholder for line chart implementation
    // This would typically use a charting library like fl_chart
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart, size: 48),
            SizedBox(height: 8),
            Text('점수 변화 추이 차트'),
            Text('(구현 예정)', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendSummary(BuildContext context) {
    final latestScore = scoreTrends.first['totalScore'] as double? ?? 0.0;
    final previousScore = scoreTrends.length > 1 
        ? scoreTrends[1]['totalScore'] as double? ?? 0.0 
        : latestScore;
    
    final change = latestScore - previousScore;
    final isImproving = change > 0;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildTrendItem(
          context,
          '최근 점수',
          latestScore.toStringAsFixed(1),
          Icons.score,
          Colors.blue,
        ),
        _buildTrendItem(
          context,
          '변화량',
          '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}',
          isImproving ? Icons.trending_up : Icons.trending_down,
          isImproving ? Colors.green : Colors.red,
        ),
        _buildTrendItem(
          context,
          '기간',
          '${scoreTrends.length}회',
          Icons.timeline,
          Colors.grey,
        ),
      ],
    );
  }

  Widget _buildTrendItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}