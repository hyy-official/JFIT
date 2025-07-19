import 'package:flutter/material.dart';
import '../../../domain/entities/group_ranking.dart';

class RankingLeaderboardWidget extends StatelessWidget {
  final List<GroupRanking> rankings;
  final RankingPeriod period;
  final ValueChanged<String>? onGroupTap;

  const RankingLeaderboardWidget({
    super.key,
    required this.rankings,
    required this.period,
    this.onGroupTap,
  });

  @override
  Widget build(BuildContext context) {
    if (rankings.isEmpty) {
      return const Center(
        child: Text('랭킹 데이터가 없습니다'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_getPeriodText(period)} 그룹 랭킹',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        // Top 3 podium
        if (rankings.length >= 3) _buildPodium(context),
        const SizedBox(height: 24),
        // Full ranking list
        _buildRankingList(context),
      ],
    );
  }

  Widget _buildPodium(BuildContext context) {
    final top3 = rankings.take(3).toList();
    
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            Theme.of(context).colorScheme.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          if (top3.length > 1) _buildPodiumItem(context, top3[1], 2, 120),
          // 1st place
          _buildPodiumItem(context, top3[0], 1, 160),
          // 3rd place
          if (top3.length > 2) _buildPodiumItem(context, top3[2], 3, 100),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(BuildContext context, GroupRanking ranking, int position, double height) {
    final colors = [Colors.amber, Colors.grey[400]!, Colors.brown[400]!];
    final color = colors[position - 1];

    return GestureDetector(
      onTap: () => onGroupTap?.call(ranking.groupId),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Crown/Medal
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              position == 1 ? Icons.emoji_events : Icons.military_tech,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          // Group name
          SizedBox(
            width: 80,
            child: Text(
              ranking.groupName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          // Score
          Text(
            '${ranking.totalScore}점',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Podium base
          Container(
            width: 60,
            height: height,
            decoration: BoxDecoration(
              color: color.withOpacity(0.7),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Center(
              child: Text(
                '$position',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rankings.length,
      itemBuilder: (context, index) {
        final ranking = rankings[index];
        return _buildRankingItem(context, ranking, index + 1);
      },
    );
  }

  Widget _buildRankingItem(BuildContext context, GroupRanking ranking, int displayRank) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: () => onGroupTap?.call(ranking.groupId),
        leading: _buildRankBadge(context, ranking.rankPosition),
        title: Text(
          ranking.groupName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${ranking.memberCount}명 • 평균 ${ranking.averageScore.toStringAsFixed(1)}점'),
            const SizedBox(height: 4),
            _buildScoreBreakdown(context, ranking),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${ranking.totalScore}점',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            _buildRankChange(context, ranking),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildRankBadge(BuildContext context, int rank) {
    Color color;
    if (rank <= 3) {
      color = [Colors.amber, Colors.grey[400]!, Colors.brown[400]!][rank - 1];
    } else if (rank <= 10) {
      color = Colors.blue;
    } else {
      color = Colors.grey;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$rank',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBreakdown(BuildContext context, GroupRanking ranking) {
    return Row(
      children: [
        _buildScoreChip('볼륨', ranking.volumeScore, Colors.blue),
        const SizedBox(width: 4),
        _buildScoreChip('균형', ranking.balanceScore, Colors.green),
        const SizedBox(width: 4),
        _buildScoreChip('진전', ranking.progressScore, Colors.orange),
      ],
    );
  }

  Widget _buildScoreChip(String label, double score, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
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

  Widget _buildRankChange(BuildContext context, GroupRanking ranking) {
    if (ranking.isNewRanking) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'NEW',
          style: TextStyle(
            fontSize: 10,
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (ranking.rankMaintained) {
      return const Icon(
        Icons.remove,
        color: Colors.grey,
        size: 16,
      );
    }

    final isImproved = ranking.rankImproved;
    final change = ranking.rankChange.abs();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isImproved ? Icons.arrow_upward : Icons.arrow_downward,
          color: isImproved ? Colors.green : Colors.red,
          size: 16,
        ),
        Text(
          '$change',
          style: TextStyle(
            fontSize: 12,
            color: isImproved ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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