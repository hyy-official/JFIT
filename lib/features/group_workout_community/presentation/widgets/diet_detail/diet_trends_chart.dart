import 'package:flutter/material.dart';
import 'package:jfit/l10n/app_localizations.dart';

class DietTrendsChart extends StatelessWidget {
  final String memberId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompact;

  const DietTrendsChart({
    super.key,
    required this.memberId,
    required this.startDate,
    required this.endDate,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.dietTrends ?? '식단 트렌드',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('식단 트렌드 차트 구현 예정'),
          ],
        ),
      ),
    );
  }
}