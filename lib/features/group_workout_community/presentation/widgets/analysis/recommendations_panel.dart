import 'package:flutter/material.dart';

class RecommendationsPanel extends StatelessWidget {
  final Map<String, dynamic>? recommendations;
  final String? memberId;
  final bool isCompact;

  const RecommendationsPanel({
    super.key,
    this.recommendations,
    this.memberId,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('추천 패널 구현 예정'),
      ),
    );
  }
}