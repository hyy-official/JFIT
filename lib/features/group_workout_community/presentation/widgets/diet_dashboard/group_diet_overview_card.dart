import 'package:flutter/material.dart';
import 'package:jfit/core/widgets/responsive_layout.dart';
import 'package:jfit/core/utils/breakpoint_utils.dart';
import 'package:jfit/l10n/app_localizations.dart';

/// 그룹 식단 개요 카드 위젯
/// 전체 그룹의 식단 요약 정보를 표시
class GroupDietOverviewCard extends StatelessWidget {
  final String groupId;
  final DateTime date;
  final bool isCompact;

  const GroupDietOverviewCard({
    super.key,
    required this.groupId,
    required this.date,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // TODO: Get actual data from BLoC
    final mockData = {
      'totalMembers': 12,
      'activeMembers': 9,
      'avgCalorieAchievement': 87.5,
      'avgProteinAchievement': 92.3,
      'membersOnTrack': 7,
      'membersNeedAttention': 2,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.group,
                  color: Theme.of(context).primaryColor,
                  size: isCompact ? 20 : 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.groupOverview ?? '그룹 개요',
                    style: isCompact 
                        ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                        : Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            BreakpointUtils.isMobile(MediaQuery.of(context).size.width) || isCompact
                ? _buildCompactLayout(context, l10n, mockData)
                : _buildExpandedLayout(context, l10n, mockData),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactLayout(BuildContext context, AppLocalizations l10n, Map<String, dynamic> data) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                context,
                l10n.activeMembers ?? '활성 멤버',
                '${data['activeMembers']}/${data['totalMembers']}',
                Icons.people,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatItem(
                context,
                l10n.onTrack ?? '목표 달성',
                '${data['membersOnTrack']}명',
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildProgressItem(
                context,
                l10n.avgCalories ?? '평균 칼로리',
                data['avgCalorieAchievement'].toDouble(),
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildProgressItem(
                context,
                l10n.avgProtein ?? '평균 단백질',
                data['avgProteinAchievement'].toDouble(),
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpandedLayout(BuildContext context, AppLocalizations l10n, Map<String, dynamic> data) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                context,
                l10n.totalMembers ?? '전체 멤버',
                '${data['totalMembers']}명',
                Icons.group,
                Colors.blue,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                context,
                l10n.activeMembers ?? '활성 멤버',
                '${data['activeMembers']}명',
                Icons.people,
                Colors.green,
              ),
            ),
            Expanded(
              child: _buildStatItem(
                context,
                l10n.needAttention ?? '주의 필요',
                '${data['membersNeedAttention']}명',
                Icons.warning,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildProgressItem(
                context,
                l10n.avgCalorieAchievement ?? '평균 칼로리 달성률',
                data['avgCalorieAchievement'].toDouble(),
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildProgressItem(
                context,
                l10n.avgProteinAchievement ?? '평균 단백질 달성률',
                data['avgProteinAchievement'].toDouble(),
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(BuildContext context, String label, double percentage, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }
}