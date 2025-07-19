import 'package:flutter/material.dart';

class MacroDistributionChart extends StatelessWidget {
  final Map<String, dynamic>? data;
  final String period;

  const MacroDistributionChart({
    super.key,
    this.data,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('매크로 분포 차트 구현 예정'),
      ),
    );
  }
}