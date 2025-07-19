import 'package:flutter/material.dart';
import 'package:jfit/features/group_workout_community/domain/entities/group_search_criteria.dart';
import 'package:jfit/features/group_workout_community/domain/entities/workout_group.dart';
import 'dart:async';

/// 향상된 그룹 검색바 위젯 - 고급 검색 및 필터링 지원
class EnhancedGroupSearchBar extends StatefulWidget {
  final ValueChanged<GroupSearchCriteria> onSearchChanged;
  final GroupSearchCriteria initialCriteria;
  final String hintText;
  final Duration debounceTime;
  final bool showAdvancedFilters;

  const EnhancedGroupSearchBar({
    super.key,
    required this.onSearchChanged,
    this.initialCriteria = const GroupSearchCriteria(),
    this.hintText = '그룹 이름이나 설명으로 검색',
    this.debounceTime = const Duration(milliseconds: 500),
    this.showAdvancedFilters = true,
  });

  @override
  State<EnhancedGroupSearchBar> createState() => _EnhancedGroupSearchBarState();
}

class _EnhancedGroupSearchBarState extends State<EnhancedGroupSearchBar> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;
  GroupSearchCriteria _currentCriteria = const GroupSearchCriteria();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _currentCriteria = widget.initialCriteria;
    _controller.text = _currentCriteria.searchQuery ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceTime, () {
      final newCriteria = _currentCriteria.copyWith(
        searchQuery: value.isEmpty ? null : value,
      );
      setState(() {
        _currentCriteria = newCriteria;
      });
      widget.onSearchChanged(newCriteria);
    });
  }

  void _onCriteriaChanged(GroupSearchCriteria newCriteria) {
    setState(() {
      _currentCriteria = newCriteria;
    });
    widget.onSearchChanged(newCriteria);
  }

  void _clearSearch() {
    _controller.clear();
    final clearedCriteria = const GroupSearchCriteria();
    setState(() {
      _currentCriteria = clearedCriteria;
      _showFilters = false;
    });
    widget.onSearchChanged(clearedCriteria);
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main search bar
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: TextField(
            controller: _controller,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: colorScheme.onSurfaceVariant,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_currentCriteria.hasFilters)
                    Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '필터',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (widget.showAdvancedFilters)
                    IconButton(
                      onPressed: _toggleFilters,
                      icon: Icon(
                        _showFilters ? Icons.filter_list : Icons.tune,
                        color: _showFilters 
                            ? colorScheme.primary 
                            : colorScheme.onSurfaceVariant,
                      ),
                      tooltip: '고급 필터',
                    ),
                  if (_controller.text.isNotEmpty || _currentCriteria.hasFilters)
                    IconButton(
                      onPressed: _clearSearch,
                      icon: Icon(
                        Icons.clear,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      tooltip: '검색 초기화',
                    ),
                ],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            style: TextStyle(
              color: colorScheme.onSurface,
            ),
          ),
        ),
        
        // Advanced filters
        if (_showFilters && widget.showAdvancedFilters) ...[
          const SizedBox(height: 12),
          _buildAdvancedFilters(context),
        ],
      ],
    );
  }

  Widget _buildAdvancedFilters(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '고급 필터',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Privacy type filter
          _buildFilterSection(
            context,
            '공개 설정',
            _buildPrivacyFilter(context),
          ),
          
          const SizedBox(height: 16),
          
          // Size filter
          _buildFilterSection(
            context,
            '그룹 크기',
            _buildSizeFilter(context),
          ),
          
          const SizedBox(height: 16),
          
          // Sort options
          _buildFilterSection(
            context,
            '정렬 방식',
            _buildSortFilter(context),
          ),
          
          const SizedBox(height: 16),
          
          // PT group filter
          _buildFilterSection(
            context,
            '그룹 유형',
            _buildGroupTypeFilter(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildPrivacyFilter(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        _buildFilterChip(
          context,
          '전체',
          _currentCriteria.privacyType == null,
          () => _onCriteriaChanged(_currentCriteria.copyWith(privacyType: null)),
        ),
        _buildFilterChip(
          context,
          '공개',
          _currentCriteria.privacyType == GroupPrivacyType.public,
          () => _onCriteriaChanged(_currentCriteria.copyWith(privacyType: GroupPrivacyType.public)),
        ),
        _buildFilterChip(
          context,
          '비공개',
          _currentCriteria.privacyType == GroupPrivacyType.private,
          () => _onCriteriaChanged(_currentCriteria.copyWith(privacyType: GroupPrivacyType.private)),
        ),
      ],
    );
  }

  Widget _buildSizeFilter(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        _buildFilterChip(
          context,
          '전체',
          _currentCriteria.sizeFilter == null,
          () => _onCriteriaChanged(_currentCriteria.copyWith(sizeFilter: null)),
        ),
        ...GroupSizeFilter.values.map((filter) => _buildFilterChip(
          context,
          filter.displayName,
          _currentCriteria.sizeFilter == filter,
          () => _onCriteriaChanged(_currentCriteria.copyWith(sizeFilter: filter)),
        )),
      ],
    );
  }

  Widget _buildSortFilter(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: GroupSortOption.values.map((option) => _buildFilterChip(
        context,
        option.displayName,
        _currentCriteria.sortOption == option,
        () => _onCriteriaChanged(_currentCriteria.copyWith(sortOption: option)),
      )).toList(),
    );
  }

  Widget _buildGroupTypeFilter(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        _buildFilterChip(
          context,
          '전체',
          _currentCriteria.isPTGroup == null,
          () => _onCriteriaChanged(_currentCriteria.copyWith(isPTGroup: null)),
        ),
        _buildFilterChip(
          context,
          '일반 그룹',
          _currentCriteria.isPTGroup == false,
          () => _onCriteriaChanged(_currentCriteria.copyWith(isPTGroup: false)),
        ),
        _buildFilterChip(
          context,
          'PT 그룹',
          _currentCriteria.isPTGroup == true,
          () => _onCriteriaChanged(_currentCriteria.copyWith(isPTGroup: true)),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FilterChip(
      selected: isSelected,
      onSelected: (_) => onTap(),
      label: Text(label),
      backgroundColor: colorScheme.surface,
      selectedColor: colorScheme.secondaryContainer,
      checkmarkColor: colorScheme.onSecondaryContainer,
      labelStyle: TextStyle(
        color: isSelected 
            ? colorScheme.onSecondaryContainer 
            : colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected 
            ? colorScheme.secondary 
            : colorScheme.outline.withOpacity(0.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}