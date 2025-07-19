import 'package:flutter/material.dart';
import 'package:jfit/l10n/app_localizations.dart';
import '../../../domain/entities/pt_group_diet_summary.dart';

class NutritionBreakdownCard extends StatelessWidget {
  final PTGroupDietSummary dietSummary;
  final bool isCompact;

  const NutritionBreakdownCard({
    super.key,
    required this.dietSummary,
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
              AppLocalizations.of(context)!.nutritionBreakdown ?? '영양소 분석',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('영양소 분석 구현 예정'),
          ],
        ),
      ),
    );
  }
}