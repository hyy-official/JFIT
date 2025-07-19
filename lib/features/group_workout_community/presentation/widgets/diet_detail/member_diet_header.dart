import 'package:flutter/material.dart';
import 'package:jfit/l10n/app_localizations.dart';

/// 멤버 식단 헤더 위젯
class MemberDietHeader extends StatelessWidget {
  final String groupId;
  final String memberId;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final bool isCompact;

  const MemberDietHeader({
    super.key,
    required this.groupId,
    required this.memberId,
    required this.selectedDate,
    required this.onDateChanged,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.memberDietHeader ?? '멤버 식단 정보',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // TODO: Implement actual member header with date selector
            Text(
              l10n.memberHeaderPlaceholder ?? '멤버 정보를 로드 중입니다...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}