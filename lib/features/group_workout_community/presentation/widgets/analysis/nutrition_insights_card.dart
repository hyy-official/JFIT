import 'package:flutter/material.dart';

class NutritionInsightsCard extends StatelessWidget {
  final Map<String, dynamic>? insights;
  final bool isCompact;

  const NutritionInsightsCard({
    super.key,
    this.insights,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('영양 인사이트 카드 구현 예정'),
      ),
    );
  }
}