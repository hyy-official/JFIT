import 'package:flutter/material.dart';
import 'package:jfit/features/group_workout_community/presentation/pages/group_list_page.dart';

/// 그룹 필터링을 위한 칩 위젯들
class GroupFilterChips extends StatelessWidget {
  final GroupFilter currentFilter;
  final ValueChanged<GroupFilter> onFilterChanged;

  const GroupFilterChips({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(
            context,
            GroupFilter.all,
            '전체',
            Icons.apps,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            GroupFilter.public,
            '공개',
            Icons.public,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            GroupFilter.private,
            '비공개',
            Icons.lock,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            GroupFilter.small,
            '소규모',
            Icons.group,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            context,
            GroupFilter.large,
            '대규모',
            Icons.groups,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    GroupFilter filter,
    String label,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = currentFilter == filter;

    return FilterChip(
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onFilterChanged(filter);
        }
      },
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected 
                ? colorScheme.onSecondaryContainer 
                : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      backgroundColor: colorScheme.surface,
      selectedColor: colorScheme.secondaryContainer,
      checkmarkColor: colorScheme.onSecondaryContainer,
      labelStyle: TextStyle(
        color: isSelected 
            ? colorScheme.onSecondaryContainer 
            : colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected 
            ? colorScheme.secondary 
            : colorScheme.outline.withOpacity(0.2),
      ),
    );
  }
}