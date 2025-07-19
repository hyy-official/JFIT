import 'package:flutter/material.dart';
import 'package:jfit/core/widgets/responsive_layout.dart';
import 'package:jfit/core/utils/breakpoint_utils.dart';
import 'package:jfit/l10n/app_localizations.dart';

/// PT 식단 대시보드 헤더 위젯
/// 날짜 선택 및 기본 정보를 표시
class DietDashboardHeader extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final bool isCompact;

  const DietDashboardHeader({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return ResponsiveBuilder(
      builder: (context, deviceType, screenSize) {
        if (deviceType.isMobile) {
          return _buildMobileHeader(context, l10n);
        } else {
          return _buildDesktopHeader(context, l10n);
        }
      },
    );
  }

  Widget _buildMobileHeader(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dashboard,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.ptDietDashboard ?? 'PT 식단 대시보드',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDateSelector(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopHeader(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(
              Icons.dashboard,
              color: Theme.of(context).primaryColor,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.ptDietDashboard ?? 'PT 식단 대시보드',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.dietDashboardSubtitle ?? '그룹 멤버들의 식단 현황을 한눈에 확인하세요',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            _buildDateSelector(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _changeDate(context, -1),
            icon: const Icon(Icons.chevron_left),
            tooltip: l10n.previousDay ?? '이전 날',
          ),
          InkWell(
            onTap: () => _showDatePicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatDate(selectedDate),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _formatWeekday(selectedDate, l10n),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () => _changeDate(context, 1),
            icon: const Icon(Icons.chevron_right),
            tooltip: l10n.nextDay ?? '다음 날',
          ),
        ],
      ),
    );
  }

  void _changeDate(BuildContext context, int days) {
    final newDate = selectedDate.add(Duration(days: days));
    onDateChanged(newDate);
  }

  void _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    if (picked != null && picked != selectedDate) {
      onDateChanged(picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  String _formatWeekday(DateTime date, AppLocalizations l10n) {
    final weekdays = [
      l10n.monday ?? '월요일',
      l10n.tuesday ?? '화요일',
      l10n.wednesday ?? '수요일',
      l10n.thursday ?? '목요일',
      l10n.friday ?? '금요일',
      l10n.saturday ?? '토요일',
      l10n.sunday ?? '일요일',
    ];
    return weekdays[date.weekday - 1];
  }
}