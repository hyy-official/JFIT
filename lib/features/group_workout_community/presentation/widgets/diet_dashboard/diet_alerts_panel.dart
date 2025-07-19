import 'package:flutter/material.dart';
import 'package:jfit/l10n/app_localizations.dart';

/// 식단 알림 패널 위젯
class DietAlertsPanel extends StatelessWidget {
  final String groupId;
  final DateTime date;
  final bool isCompact;

  const DietAlertsPanel({
    super.key,
    required this.groupId,
    required this.date,
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
            Row(
              children: [
                Icon(
                  Icons.notifications,
                  color: Theme.of(context).primaryColor,
                  size: isCompact ? 20 : 24,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.alerts ?? '알림',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // TODO: Implement actual alerts
            Text(
              l10n.alertsPlaceholder ?? '알림을 로드 중입니다...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}