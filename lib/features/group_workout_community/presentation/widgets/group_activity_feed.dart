import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/widgets/responsive_layout.dart';
import 'package:jfit/core/utils/breakpoint_utils.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group_activity/group_activity_bloc.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group_activity/group_activity_event.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group_activity/group_activity_state.dart';
import 'package:jfit/features/group_workout_community/presentation/widgets/activity_timeline_item.dart';
import 'package:jfit/features/group_workout_community/domain/entities/group_activity.dart';
import 'package:jfit/features/group_workout_community/domain/entities/workout_group.dart';

/// 그룹 활동 피드를 표시하는 위젯 - 무한 스크롤, 풀 투 리프레시 지원
class GroupActivityFeed extends StatefulWidget {
  final String groupId;

  const GroupActivityFeed({
    super.key,
    required this.groupId,
  });

  @override
  State<GroupActivityFeed> createState() => _GroupActivityFeedState();
}

class _GroupActivityFeedState extends State<GroupActivityFeed> {
  final ScrollController _scrollController = ScrollController();
  List<GroupActivity> _activities = [];
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialActivities();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialActivities() {
    context.read<GroupActivityBloc>().add(LoadGroupActivities(
      groupId: widget.groupId,
      forceRefresh: true,
    ));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreActivities();
    }
  }

  void _loadMoreActivities() {
    if (!_isLoadingMore && _hasMore) {
      setState(() {
        _isLoadingMore = true;
      });
      
      context.read<GroupActivityBloc>().add(LoadGroupActivities(
        groupId: widget.groupId,
        limit: 20,
        offset: _activities.length,
      ));
    }
  }

  Future<void> _onRefresh() async {
    context.read<GroupActivityBloc>().add(LoadGroupActivities(
      groupId: widget.groupId,
      forceRefresh: true,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupActivityBloc, GroupActivityState>(
      listener: (context, state) {
        if (state is GroupActivitiesLoaded) {
          setState(() {
            if (_activities.isEmpty || state.activities.length < 20) {
              _activities = state.activities;
            } else {
              _activities.addAll(state.activities);
            }
            _hasMore = state.hasMore;
            _isLoadingMore = false;
          });
        } else if (state is GroupActivityErrorState) {
          setState(() {
            _isLoadingMore = false;
          });
          _showErrorSnackBar(state.userMessage);
        }
      },
      child: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return _buildActivityList(isMobile: true);
  }

  Widget _buildTabletLayout() {
    return _buildActivityList(isMobile: false);
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Main activity feed
        Expanded(
          flex: 2,
          child: _buildActivityList(isMobile: false),
        ),
        // Side panel for quick actions
        SizedBox(
          width: 280,
          child: Card(
            margin: const EdgeInsets.all(16),
            child: _buildQuickActionsPanel(),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityList({required bool isMobile}) {
    return BlocBuilder<GroupActivityBloc, GroupActivityState>(
      builder: (context, state) {
        if (state is GroupActivityLoading && _activities.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is GroupActivityErrorState && _activities.isEmpty) {
          return _buildErrorWidget(state.userMessage);
        }

        if (_activities.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            itemCount: _activities.length + (_hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _activities.length) {
                return _buildLoadingIndicator();
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ActivityTimelineItem(
                  activity: _activities[index],
                  onLike: () => _likeActivity(_activities[index]),
                  onComment: () => _commentOnActivity(_activities[index]),
                  onShare: () => _shareActivity(_activities[index]),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildQuickActionsPanel() {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '빠른 작업',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          ElevatedButton.icon(
            onPressed: () => _showShareRoutineDialog(),
            icon: const Icon(Icons.share),
            label: const Text('루틴 공유'),
          ),
          
          const SizedBox(height: 8),
          
          OutlinedButton.icon(
            onPressed: () => _showWorkoutCompletionDialog(),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('운동 완료'),
          ),
          
          const SizedBox(height: 8),
          
          OutlinedButton.icon(
            onPressed: () => _showEncouragementDialog(),
            icon: const Icon(Icons.favorite_outline),
            label: const Text('격려 메시지'),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            '최근 활동',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Expanded(
            child: _buildRecentActivitySummary(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySummary() {
    final recentActivities = _activities.take(3).toList();
    
    if (recentActivities.isEmpty) {
      return const Center(
        child: Text(
          '최근 활동이 없습니다',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: recentActivities.length,
      itemBuilder: (context, index) {
        final activity = recentActivities[index];
        return ListTile(
          dense: true,
          leading: CircleAvatar(
            radius: 16,
            child: Icon(
              _getActivityIcon(activity.activityType.toString()),
              size: 16,
            ),
          ),
          title: Text(
            _getActivityTitle(activity),
            style: const TextStyle(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            _formatTime(activity.createdAt),
            style: const TextStyle(fontSize: 10),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            '아직 활동이 없습니다',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '첫 번째 운동을 완료하거나\n루틴을 공유해보세요!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showShareRoutineDialog(),
            icon: const Icon(Icons.share),
            label: const Text('루틴 공유하기'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            '활동을 불러올 수 없습니다',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadInitialActivities,
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  void _likeActivity(GroupActivity activity) {
    // TODO: Implement like functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('좋아요 기능 구현 예정')),
    );
  }

  void _commentOnActivity(GroupActivity activity) {
    // TODO: Implement comment functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('댓글 기능 구현 예정')),
    );
  }

  void _shareActivity(GroupActivity activity) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('공유 기능 구현 예정')),
    );
  }

  void _showShareRoutineDialog() {
    // TODO: Implement share routine dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('루틴 공유 기능 구현 예정')),
    );
  }

  void _showWorkoutCompletionDialog() {
    // TODO: Implement workout completion dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('운동 완료 기능 구현 예정')),
    );
  }

  void _showEncouragementDialog() {
    // TODO: Implement encouragement dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('격려 메시지 기능 구현 예정')),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'workout_completed':
        return Icons.check_circle;
      case 'routine_shared':
        return Icons.share;
      case 'member_joined':
        return Icons.person_add;
      case 'encouragement_sent':
        return Icons.favorite;
      case 'achievement_unlocked':
        return Icons.emoji_events;
      default:
        return Icons.notifications;
    }
  }

  String _getActivityTitle(GroupActivity activity) {
    switch (activity.activityType) {
      case GroupActivityType.workoutCompleted:
        return '운동을 완료했습니다';
      case GroupActivityType.routineShared:
        return '루틴을 공유했습니다';
      case GroupActivityType.memberJoined:
        return '그룹에 가입했습니다';
      case GroupActivityType.memberLeft:
        return '그룹을 떠났습니다';
      case GroupActivityType.encouragementSent:
        return '격려 메시지를 보냈습니다';
      case GroupActivityType.achievementUnlocked:
        return '성취를 달성했습니다';
      case GroupActivityType.programStarted:
        return '프로그램을 시작했습니다';
      case GroupActivityType.milestoneReached:
        return '마일스톤을 달성했습니다';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }
}