import 'package:flutter/material.dart';
import 'package:jfit/l10n/app_localizations.dart';

class MealTimeline extends StatelessWidget {
  final String memberId;
  final DateTime date;
  final bool isCompact;

  const MealTimeline({
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
              AppLocalizations.of(context)!.mealTimeline ?? '식사 타임라인',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('식사 타임라인 구현 예정'),
          ],
        ),
      ),
    );
  }
}