import 'package:flutter/material.dart';
import '../../../domain/entities/group_ranking.dart';

class RankingStatsSummary extends StatelessWidget {
  final List<GroupRanking> rankings;
  final RankingPeriod period;
  final bool isCompact;
  final bool showDetailedStats;

  const RankingStatsSummary({
    super.key,
    required this.rankings,
    required this.period,
    this.isCompact = false,
    this.showDetailedStats = false,
  });

  @override
  Widget build(BuildContext context) {
    if (rankings.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalGroups = rankings.length;
    final topGroups = rankings.where((r) => r.isTopRanking).length;
    final averageScore = rankings.map((r) => r.averageScore).reduce((a, b) => a + b) / totalGroups;
    final highestScore = rankings.map((r) => r.totalScore).reduce((a, b) => a > b ? a : b);

    if (isCompact) {
      return _buildCompactView(context, totalGroups, topGroups, averageScore, highestScore);
    }

    if (showDetailedStats) {
      return _buildDetailedView(context, totalGroups, topGroups, averageScore, highestScore);
    }

    return _buildStandardView(context, totalGroups, topGroups, averageScore, highestScore);
  }

  Widget _buildCompactView(BuildContext context, int totalGroups, int topGroups, double averageScore, int highestScore) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(context, '전체', '$totalGroups', Icons.groups),
            _buildStatItem(context, '상위', '$topGroups', Icons.star),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(context, '평균', averageScore.toStringAsFixed(1), Icons.analytics),
            _buildStatItem(context, '최고', '$highestScore', Icons.emoji_events),
          ],
        ),
      ],
    );
  }

  Widget _buildStandardView(BuildContext context, int totalGroups, int topGroups, double averageScore, int highestScore) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_getPeriodText(period)} 랭킹 통계',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard(context, '전체 그룹', '$totalGroups개', Icons.groups, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(context, '상위 그룹', '$topGroups개', Icons.star, Colors.amber)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCard(context, '평균 점수', averageScore.toStringAsFixed(1), Icons.analytics, Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(context, '최고 점수', '$highestScore', Icons.emoji_events, Colors.purple)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedView(BuildContext context, int totalGroups, int topGroups, double averageScore, int highestScore) {
    final improvingGroups = rankings.where((r) => r.rankImproved).length;
    final decliningGroups = rankings.where((r) => r.rankDeclined).length;
    final newGroups = rankings.where((r) => r.isNewRanking).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_getPeriodText(period)} 상세 통계',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildDetailedStatGrid(context, [
          ('전체 그룹', '$totalGroups개', Icons.groups, Colors.blue),
          ('상위 그룹', '$topGroups개', Icons.star, Colors.amber),
          ('평균 점수', averageScore.toStringAsFixed(1), Icons.analytics, Colors.green),
          ('최고 점수', '$highestScore', Icons.emoji_events, Colors.purple),
          ('상승 그룹', '$improvingGroups개', Icons.trending_up, Colors.green),
          ('하락 그룹', '$decliningGroups개', Icons.trending_down, Colors.red),
          ('신규 그룹', '$newGroups개', Icons.new_releases, Colors.orange),
          ('안정 그룹', '${totalGroups - improvingGroups - decliningGroups - newGroups}개', Icons.trending_flat, Colors.grey),
        ]),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStatGrid(BuildContext context, List<(String, String, IconData, Color)> stats) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final (title, value, icon, color) = stats[index];
        return _buildStatCard(context, title, value, icon, color);
      },
    );
  }

  String _getPeriodText(RankingPeriod period) {
    switch (period) {
      case RankingPeriod.daily:
        return '일간';
      case RankingPeriod.weekly:
        return '주간';
      case RankingPeriod.monthly:
        return '월간';
    }
  }
}