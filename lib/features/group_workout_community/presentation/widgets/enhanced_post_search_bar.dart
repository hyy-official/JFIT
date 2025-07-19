import 'package:flutter/material.dart';
import 'package:jfit/features/group_workout_community/domain/entities/post_search_criteria.dart';
import 'package:jfit/features/group_workout_community/domain/entities/post_category.dart';
import 'dart:async';

/// 향상된 게시글 검색바 위젯 - 고급 검색 및 필터링 지원
class EnhancedPostSearchBar extends StatefulWidget {
  final ValueChanged<PostSearchCriteria> onSearchChanged;
  final PostSearchCriteria initialCriteria;
  final String hintText;
  final Duration debounceTime;
  final bool showAdvancedFilters;
  final List<PostCategory>? categories;
  final String? groupId; // null for public community, groupId for group posts

  const EnhancedPostSearchBar({
    super.key,
    required this.onSearchChanged,
    this.initialCriteria = const PostSearchCriteria(),
    this.hintText = '게시글 제목이나 내용으로 검색',
    this.debounceTime = const Duration(milliseconds: 500),
    this.showAdvancedFilters = true,
    this.categories,
    this.groupId,
  });

  @override
  State<EnhancedPostSearchBar> createState() => _EnhancedPostSearchBarState();
}

class _EnhancedPostSearchBarState extends State<EnhancedPostSearchBar> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;
  PostSearchCriteria _currentCriteria = const PostSearchCriteria();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _currentCriteria = widget.initialCriteria.copyWith(groupId: widget.groupId);
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

  void _onCriteriaChanged(PostSearchCriteria newCriteria) {
    setState(() {
      _currentCriteria = newCriteria;
    });
    widget.onSearchChanged(newCriteria);
  }

  void _clearSearch() {
    _controller.clear();
    final clearedCriteria = PostSearchCriteria(groupId: widget.groupId);
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
          
          // Category filter
          if (widget.categories != null && widget.categories!.isNotEmpty) ...[
            _buildFilterSection(
              context,
              '카테고리',
              _buildCategoryFilter(context),
            ),
            const SizedBox(height: 16),
          ],
          
          // Post type filter
          _buildFilterSection(
            context,
            '게시글 유형',
            _buildPostTypeFilter(context),
          ),
          
          const SizedBox(height: 16),
          
          // Sort options
          _buildFilterSection(
            context,
            '정렬 방식',
            _buildSortFilter(context),
          ),
          
          const SizedBox(height: 16),
          
          // Date filter
          _buildFilterSection(
            context,
            '날짜 범위',
            _buildDateFilter(context),
          ),
          
          const SizedBox(height: 16),
          
          // Engagement filter
          _buildFilterSection(
            context,
            '인기도',
            _buildEngagementFilter(context),
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

  Widget _buildCategoryFilter(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        _buildFilterChip(
          context,
          '전체',
          _currentCriteria.categoryId == null,
          () => _onCriteriaChanged(_currentCriteria.copyWith(categoryId: null)),
        ),
        ...widget.categories!.map((category) => _buildFilterChip(
          context,
          category.name,
          _currentCriteria.categoryId == category.id,
          () => _onCriteriaChanged(_currentCriteria.copyWith(categoryId: category.id)),
        )),
      ],
    );
  }

  Widget _buildPostTypeFilter(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        _buildFilterChip(
          context,
          '전체',
          _currentCriteria.postType == null,
          () => _onCriteriaChanged(_currentCriteria.copyWith(postType: null)),
        ),
        ...PostType.values.map((type) => _buildFilterChip(
          context,
          type.displayName,
          _currentCriteria.postType == type,
          () => _onCriteriaChanged(_currentCriteria.copyWith(postType: type)),
        )),
      ],
    );
  }

  Widget _buildSortFilter(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: PostSortOption.values.map((option) => _buildFilterChip(
        context,
        option.displayName,
        _currentCriteria.sortOption == option,
        () => _onCriteriaChanged(_currentCriteria.copyWith(sortOption: option)),
      )).toList(),
    );
  }

  Widget _buildDateFilter(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        _buildFilterChip(
          context,
          '전체',
          !_currentCriteria.hasDateRange,
          () => _onCriteriaChanged(_currentCriteria.copyWith(
            startDate: null,
            endDate: null,
          )),
        ),
        ...PostDateFilter.values.where((filter) => filter != PostDateFilter.custom).map((filter) => _buildFilterChip(
          context,
          filter.displayName,
          _isDateFilterSelected(filter),
          () => _onCriteriaChanged(_currentCriteria.copyWith(
            startDate: filter.startDate,
            endDate: filter.endDate,
          )),
        )),
      ],
    );
  }

  Widget _buildEngagementFilter(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        _buildFilterChip(
          context,
          '전체',
          _currentCriteria.minLikes == null && _currentCriteria.minComments == null,
          () => _onCriteriaChanged(_currentCriteria.copyWith(
            minLikes: null,
            minComments: null,
          )),
        ),
        _buildFilterChip(
          context,
          '좋아요 5개 이상',
          _currentCriteria.minLikes == 5,
          () => _onCriteriaChanged(_currentCriteria.copyWith(minLikes: 5)),
        ),
        _buildFilterChip(
          context,
          '댓글 3개 이상',
          _currentCriteria.minComments == 3,
          () => _onCriteriaChanged(_currentCriteria.copyWith(minComments: 3)),
        ),
        _buildFilterChip(
          context,
          '인기 게시글',
          _currentCriteria.minLikes == 10 && _currentCriteria.minComments == 5,
          () => _onCriteriaChanged(_currentCriteria.copyWith(
            minLikes: 10,
            minComments: 5,
          )),
        ),
      ],
    );
  }

  bool _isDateFilterSelected(PostDateFilter filter) {
    if (!_currentCriteria.hasDateRange) return false;
    
    final filterStart = filter.startDate;
    final filterEnd = filter.endDate;
    
    final criteriaStart = _currentCriteria.startDate;
    final criteriaEnd = _currentCriteria.endDate;
    
    // Check if dates match (allowing for some tolerance)
    final startMatches = criteriaStart != null && 
        (criteriaStart.difference(filterStart).inHours.abs() < 24);
    
    final endMatches = (criteriaEnd == null && filterEnd == null) ||
        (criteriaEnd != null && filterEnd != null && 
         criteriaEnd.difference(filterEnd).inHours.abs() < 24);
    
    return startMatches && endMatches;
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