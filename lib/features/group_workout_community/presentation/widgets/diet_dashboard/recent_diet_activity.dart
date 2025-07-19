import 'package:flutter/material.dart';
import 'package:jfit/l10n/app_localizations.dart';

/// 최근 식단 활동 위젯
class RecentDietActivity extends StatelessWidget {
  final String groupId;
  final int maxItems;
  final bool isCompact;

  const RecentDietActivity({
    super.key,
    required this.groupId,
    required this.maxItems,
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
                  Icons.history,
                  color: Theme.of(context).primaryColor,
                  size: isCompact ? 20 : 24,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.recentActivity ?? '최근 활동',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // TODO: Implement actual recent activity list
            Text(
              l10n.activityPlaceholder ?? '최근 활동을 로드 중입니다...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}