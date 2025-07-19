import 'package:flutter/material.dart';

class RankingTrendChart extends StatelessWidget {
  final List<Map<String, dynamic>> groupTrends;
  final List<Map<String, dynamic>> userTrends;
  final String selectedMetric;
  final double height;

  const RankingTrendChart({
    super.key,
    required this.groupTrends,
    required this.userTrends,
    required this.selectedMetric,
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
              Icon(Icons.trending_up, size: 48),
              SizedBox(height: 8),
              Text('랭킹 트렌드 차트'),
              Text('(구현 예정)', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}