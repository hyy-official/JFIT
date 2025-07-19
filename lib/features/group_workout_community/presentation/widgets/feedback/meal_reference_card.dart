import 'package:flutter/material.dart';
import 'package:jfit/l10n/app_localizations.dart';

class MealReferenceCard extends StatelessWidget {
  final Map<String, dynamic> mealData;

  const MealReferenceCard({
    super.key,
    required this.mealData,
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
              AppLocalizations.of(context)!.mealReference ?? '참조 식사',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('식사 참조 카드 구현 예정'),
          ],
        ),
      ),
    );
  }
}