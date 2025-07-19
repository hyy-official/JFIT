import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/group_activity/group_activity_bloc.dart';
import '../bloc/group_activity/group_activity_event.dart';
import '../bloc/group_activity/group_activity_state.dart';
import '../../domain/entities/group_activity.dart';
import 'infinite_scroll_list.dart';
import 'activity_timeline_item.dart';

/// Widget for displaying paginated group activity feed with infinite scroll
class PaginatedActivityFeed extends StatefulWidget {
  final String groupId;
  final List<String>? activityTypeFilter;
  final EdgeInsetsGeometry? padding;
  final bool enablePullToRefresh;
  final Function(GroupActivity)? onActivityTap;
  final Widget? header;
  final Widget? footer;

  const PaginatedActivityFeed({
    Key? key,
    required this.groupId,
    this.activityTypeFilter,
    this.padding,
    this.enablePullToRefresh = true,
    this.onActivityTap,
    this.header,
    this.footer,
  }) : super(key: key);

  @override
  State<PaginatedActivityFeed> createState() => _PaginatedActivityFeedState();
}

class _PaginatedActivityFeedState extends State<PaginatedActivityFeed> {
  @override
  void initState() {
    super.initState();
    _loadInitialActivities();
  }

  void _loadInitialActivities() {
    context.read<GroupActivityBloc>().add(
      LoadGroupActivities(
        groupId: widget.groupId,
        activityTypes: widget.activityTypeFilter,
      ),
    );
  }

  void _loadMoreActivities() {
    context.read<GroupActivityBloc>().add(
      LoadMoreActivities(
        groupId: widget.groupId,
        activityTypes: widget.activityTypeFilter,
      ),
    );
  }

  void _refreshActivities() {
    context.read<GroupActivityBloc>().add(
      LoadGroupActivities(
        groupId: widget.groupId,
        activityTypes: widget.activityTypeFilter,
        forceRefresh: true,
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, GroupActivity activity, int index) {
    return ActivityTimelineItem(
      activity: activity,
      onTap: widget.onActivityTap != null 
          ? () => widget.onActivityTap!(activity)
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timeline_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '아직 활동이 없습니다',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '그룹 멤버들의 운동 활동이 여기에 표시됩니다',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshActivities,
              icon: const Icon(Icons.refresh),
              label: const Text('새로고침'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              '활동을 불러올 수 없습니다',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshActivities,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('활동을 불러오는 중...'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupActivityBloc, GroupActivityState>(
      builder: (context, state) {
        if (state is GroupActivitiesLoaded && state.groupId == widget.groupId) {
          Widget content = InfiniteScrollList<GroupActivity>(
            items: state.activities,
            hasMore: state.hasMore,
            isLoading: false,
            itemBuilder: _buildActivityItem,
            onLoadMore: _loadMoreActivities,
            onRefresh: _refreshActivities,
            padding: widget.padding,
            enablePullToRefresh: widget.enablePullToRefresh,
            emptyWidget: _buildEmptyState(),
            separator: const SizedBox(height: 8),
          );

          // Add header and footer if provided
          if (widget.header != null || widget.footer != null) {
            content = Column(
              children: [
                if (widget.header != null) widget.header!,
                Expanded(child: content),
                if (widget.footer != null) widget.footer!,
              ],
            );
          }

          return content;
        }

        if (state is GroupActivityLoading) {
          return _buildLoadingState();
        }

        if (state is GroupActivityErrorState) {
          return _buildErrorState(state.message);
        }

        // Initial state - load activities
        if (state is GroupActivityInitial) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadInitialActivities();
          });
          return _buildLoadingState();
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// Compact version of activity feed for smaller spaces
class CompactActivityFeed extends StatelessWidget {
  final String groupId;
  final int maxItems;
  final Function(GroupActivity)? onActivityTap;
  final VoidCallback? onViewAll;

  const CompactActivityFeed({
    Key? key,
    required this.groupId,
    this.maxItems = 5,
    this.onActivityTap,
    this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupActivityBloc, GroupActivityState>(
      builder: (context, state) {
        if (state is GroupActivitiesLoaded && state.groupId == groupId) {
          final limitedActivities = state.activities.take(maxItems).toList();
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '최근 활동',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (onViewAll != null)
                    TextButton(
                      onPressed: onViewAll,
                      child: const Text('전체 보기'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (limitedActivities.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      '최근 활동이 없습니다',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...limitedActivities.map((activity) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ActivityTimelineItem(
                    activity: activity,
                    isCompact: true,
                    onTap: onActivityTap != null 
                        ? () => onActivityTap!(activity)
                        : null,
                  ),
                )),
            ],
          );
        }

        if (state is GroupActivityLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// Activity feed with filtering options
class FilterableActivityFeed extends StatefulWidget {
  final String groupId;
  final EdgeInsetsGeometry? padding;

  const FilterableActivityFeed({
    Key? key,
    required this.groupId,
    this.padding,
  }) : super(key: key);

  @override
  State<FilterableActivityFeed> createState() => _FilterableActivityFeedState();
}

class _FilterableActivityFeedState extends State<FilterableActivityFeed> {
  List<String>? _selectedFilters;
  
  final Map<String, String> _filterOptions = {
    'workout_completed': '운동 완료',
    'routine_shared': '루틴 공유',
    'encouragement': '격려 메시지',
    'member_joined': '멤버 가입',
    'achievement': '성취 달성',
    'program_started': '프로그램 시작',
    'milestone_reached': '마일스톤 달성',
  };

  void _updateFilters(List<String>? filters) {
    setState(() {
      _selectedFilters = filters;
    });
    
    context.read<GroupActivityBloc>().add(
      FilterActivitiesByType(
        groupId: widget.groupId,
        activityTypes: filters,
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          FilterChip(
            label: const Text('전체'),
            selected: _selectedFilters == null,
            onSelected: (selected) {
              if (selected) _updateFilters(null);
            },
          ),
          const SizedBox(width: 8),
          ..._filterOptions.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(entry.value),
              selected: _selectedFilters?.contains(entry.key) ?? false,
              onSelected: (selected) {
                final currentFilters = List<String>.from(_selectedFilters ?? []);
                if (selected) {
                  currentFilters.add(entry.key);
                } else {
                  currentFilters.remove(entry.key);
                }
                _updateFilters(currentFilters.isEmpty ? null : currentFilters);
              },
            ),
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterChips(),
        const Divider(height: 1),
        Expanded(
          child: PaginatedActivityFeed(
            groupId: widget.groupId,
            activityTypeFilter: _selectedFilters,
            padding: widget.padding,
          ),
        ),
      ],
    );
  }
}