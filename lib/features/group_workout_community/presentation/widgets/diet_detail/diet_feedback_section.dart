import 'package:flutter/material.dart';
import 'package:jfit/l10n/app_localizations.dart';

class DietFeedbackSection extends StatelessWidget {
  final String groupId;
  final String memberId;
  final String trainerId;
  final bool isCompact;

  const DietFeedbackSection({
    super.key,
    required this.groupId,
    required this.memberId,
    required this.trainerId,
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
              AppLocalizations.of(context)!.dietFeedback ?? '식단 피드백',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('식단 피드백 섹션 구현 예정'),
          ],
        ),
      ),
    );
  }
}