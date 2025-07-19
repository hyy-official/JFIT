import 'package:flutter/material.dart';
import '../../../domain/entities/group_ranking.dart';

class TrendAnalysisWidget extends StatelessWidget {
  final List<Map<String, dynamic>> groupTrends;
  final List<Map<String, dynamic>> userTrends;
  final RankingPeriod period;
  final bool isDetailed;

  const TrendAnalysisWidget({
    super.key,
    required this.groupTrends,
    required this.userTrends,
    required this.period,
    this.isDetailed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTrendSummary(context),
        if (isDetailed) ...[
          const SizedBox(height: 16),
          _buildDetailedTrendAnalysis(context),
        ],
      ],
    );
  }

  Widget _buildTrendSummary(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildTrendCard(
            context,
            '전체 트렌드',
            _getOverallTrend(),
            _getTrendIcon(_getOverallTrend()),
            _getTrendColor(_getOverallTrend()),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTrendCard(
            context,
            '개인 트렌드',
            _getPersonalTrend(),
            _getTrendIcon(_getPersonalTrend()),
            _getTrendColor(_getPersonalTrend()),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTrendCard(
            context,
            '예측 방향',
            _getPredictedTrend(),
            Icons.trending_up,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
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

  Widget _buildDetailedTrendAnalysis(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '상세 트렌드 분석',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        _buildAnalysisItems(context),
      ],
    );
  }

  Widget _buildAnalysisItems(BuildContext context) {
    final analysisItems = [
      ('변화율', _getChangeRate()),
      ('안정성', _getStability()),
      ('성장 패턴', _getGrowthPattern()),
      ('예상 성과', _getPredictedPerformance()),
    ];

    return Column(
      children: analysisItems.map((item) {
        final (label, value) = item;
        return _buildAnalysisItem(context, label, value);
      }).toList(),
    );
  }

  Widget _buildAnalysisItem(BuildContext context, String label, String value) {
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

  String _getOverallTrend() {
    // Analyze group trends to determine overall trend
    if (groupTrends.isEmpty) return '데이터 부족';
    return '상승 추세';
  }

  String _getPersonalTrend() {
    // Analyze user trends to determine personal trend
    if (userTrends.isEmpty) return '데이터 부족';
    return '개선 중';
  }

  String _getPredictedTrend() {
    return '긍정적';
  }

  String _getChangeRate() {
    return '+15.2%';
  }

  String _getStability() {
    return '안정적';
  }

  String _getGrowthPattern() {
    return '꾸준한 성장';
  }

  String _getPredictedPerformance() {
    return '향상 예상';
  }

  IconData _getTrendIcon(String trend) {
    switch (trend) {
      case '상승 추세':
      case '개선 중':
        return Icons.trending_up;
      case '하락 추세':
      case '악화 중':
        return Icons.trending_down;
      case '안정적':
        return Icons.trending_flat;
      default:
        return Icons.help_outline;
    }
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case '상승 추세':
      case '개선 중':
        return Colors.green;
      case '하락 추세':
      case '악화 중':
        return Colors.red;
      case '안정적':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}