import 'package:flutter/material.dart';
import 'package:jfit/l10n/app_localizations.dart';

class DailyNutritionChart extends StatelessWidget {
  final String memberId;
  final DateTime date;
  final bool isCompact;

  const DailyNutritionChart({
    super.key,
    required this.memberId,
    required this.date,
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
              AppLocalizations.of(context)!.dailyNutrition ?? '일일 영양소',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('영양소 차트 구현 예정'),
          ],
        ),
      ),
    );
  }
}