import 'package:flutter/material.dart';

class ComparisonChart extends StatelessWidget {
  final Map<String, dynamic>? data;
  final String groupId;
  final bool isCompact;

  const ComparisonChart({
    super.key,
    this.data,
    required this.groupId,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('비교 차트 구현 예정'),
      ),
    );
  }
}