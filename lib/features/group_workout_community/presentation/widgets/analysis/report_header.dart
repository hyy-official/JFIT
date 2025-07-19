import 'package:flutter/material.dart';
import 'package:jfit/l10n/app_localizations.dart';

class ReportHeader extends StatelessWidget {
  final String groupId;
  final String? memberId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompact;

  const ReportHeader({
    super.key,
    required this.groupId,
    this.memberId,
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
              AppLocalizations.of(context)!.analysisReport ?? '분석 리포트',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('리포트 헤더 구현 예정'),
          ],
        ),
      ),
    );
  }
}