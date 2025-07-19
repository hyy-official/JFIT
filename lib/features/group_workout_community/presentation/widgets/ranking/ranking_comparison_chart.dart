import 'package:flutter/material.dart';
import '../../../domain/entities/group_ranking.dart';

class RankingComparisonChart extends StatelessWidget {
  final List<GroupRanking> groupRankings;
  final List<Map<String, dynamic>> groupTrends;
  final double height;

  const RankingComparisonChart({
    super.key,
    required this.groupRankings,
    required this.groupTrends,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.compare_arrows, size: 48),
              SizedBox(height: 8),
              Text('랭킹 비교 차트'),
              Text('(구현 예정)', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}