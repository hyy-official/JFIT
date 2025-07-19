import 'package:flutter/material.dart';
import 'package:jfit/core/utils/breakpoint_utils.dart';
import 'package:jfit/features/group_workout_community/domain/entities/group_activity.dart';
import 'package:jfit/features/group_workout_community/domain/entities/workout_group.dart';

/// 활동 타임라인 아이템 위젯
class ActivityTimelineItem extends StatelessWidget {
  final GroupActivity activity;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;

  const ActivityTimelineItem({
    super.key,
    required this.activity,
    this.onLike,
    this.onComment,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = BreakpointUtils.getDeviceType(constraints.maxWidth);
        return _buildTimelineCard(context, deviceType);
      },
    );
  }

  Widget _buildTimelineCard(BuildContext context, DeviceType deviceType) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(deviceType.isMobile ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info and timestamp
            Row(
              children: [
                CircleAvatar(
                  radius: deviceType.isMobile ? 16 : 20,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    _getActivityIcon(),
                    size: deviceType.isMobile ? 16 : 20,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getUserName(),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatTimestamp(activity.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildActivityBadge(context),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Activity content
            _buildActivityContent(context, deviceType),
            
            const SizedBox(height: 12),
            
            // Action buttons
            _buildActionButtons(context, deviceType),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityBadge(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final (text, color) = _getActivityBadgeInfo();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActivityContent(BuildContext context, DeviceType deviceType) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main activity description
        Text(
          _getActivityDescription(),
          style: theme.textTheme.bodyMedium,
        ),
        
        // Additional content based on activity type
        if (_hasAdditionalContent()) ...[
          const SizedBox(height: 8),
          _buildAdditionalContent(context, deviceType),
        ],
      ],
    );
  }

  Widget _buildAdditionalContent(BuildContext context, DeviceType deviceType) {
    switch (activity.activityType) {
      case GroupActivityType.workoutCompleted:
        return _buildWorkoutCompletedContent(context);
      case GroupActivityType.routineShared:
        return _buildRoutineSharedContent(context);
      case GroupActivityType.memberJoined:
      case GroupActivityType.memberLeft:
      case GroupActivityType.encouragementSent:
        return const SizedBox.shrink();
      case GroupActivityType.achievementUnlocked:
        return _buildAchievementContent(context);
      case GroupActivityType.programStarted:
      case GroupActivityType.milestoneReached:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWorkoutCompletedContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Extract workout data from activity data
    final workoutData = activity.activityData;
    final duration = workoutData['duration'] as int? ?? 0;
    final exerciseCount = workoutData['exercise_count'] as int? ?? 0;
    final totalSets = workoutData['total_sets'] as int? ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildWorkoutStat('시간', '${duration}분', Icons.timer, context),
          ),
          Expanded(
            child: _buildWorkoutStat('운동', '$exerciseCount개', Icons.fitness_center, context),
          ),
          Expanded(
            child: _buildWorkoutStat('세트', '$totalSets세트', Icons.repeat, context),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutStat(String label, String value, IconData icon, BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }

  Widget _buildRoutineSharedContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final routineData = activity.activityData;
    final routineName = routineData['routine_name'] as String? ?? '운동 루틴';
    final exerciseCount = routineData['exercise_count'] as int? ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.secondary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.share,
            color: colorScheme.secondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routineName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$exerciseCount개 운동',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _viewSharedRoutine(),
            child: const Text('보기'),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final achievementData = activity.activityData;
    final achievementName = achievementData['achievement_name'] as String? ?? '성취';
    final achievementDescription = achievementData['description'] as String? ?? '';
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.amber.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.emoji_events,
            color: Colors.amber,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievementName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade700,
                  ),
                ),
                if (achievementDescription.isNotEmpty)
                  Text(
                    achievementDescription,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, DeviceType deviceType) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        TextButton.icon(
          onPressed: onLike,
          icon: const Icon(Icons.favorite_outline, size: 16),
          label: const Text('좋아요'),
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.symmetric(
              horizontal: deviceType.isMobile ? 8 : 12,
              vertical: 4,
            ),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        
        TextButton.icon(
          onPressed: onComment,
          icon: const Icon(Icons.comment_outlined, size: 16),
          label: const Text('댓글'),
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.symmetric(
              horizontal: deviceType.isMobile ? 8 : 12,
              vertical: 4,
            ),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        
        TextButton.icon(
          onPressed: onShare,
          icon: const Icon(Icons.share_outlined, size: 16),
          label: const Text('공유'),
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.symmetric(
              horizontal: deviceType.isMobile ? 8 : 12,
              vertical: 4,
            ),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        
        const Spacer(),
        
        // Reaction count (placeholder)
        Text(
          '👍 5',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }

  IconData _getActivityIcon() {
    switch (activity.activityType) {
      case GroupActivityType.workoutCompleted:
        return Icons.check_circle;
      case GroupActivityType.routineShared:
        return Icons.share;
      case GroupActivityType.memberJoined:
        return Icons.person_add;
      case GroupActivityType.memberLeft:
        return Icons.person_remove;
      case GroupActivityType.encouragementSent:
        return Icons.favorite;
      case GroupActivityType.achievementUnlocked:
        return Icons.emoji_events;
      case GroupActivityType.programStarted:
        return Icons.play_arrow;
      case GroupActivityType.milestoneReached:
        return Icons.flag;
    }
  }

  (String, Color) _getActivityBadgeInfo() {
    switch (activity.activityType) {
      case GroupActivityType.workoutCompleted:
        return ('운동 완료', Colors.green);
      case GroupActivityType.routineShared:
        return ('루틴 공유', Colors.blue);
      case GroupActivityType.memberJoined:
        return ('새 멤버', Colors.purple);
      case GroupActivityType.memberLeft:
        return ('멤버 탈퇴', Colors.grey);
      case GroupActivityType.encouragementSent:
        return ('격려', Colors.pink);
      case GroupActivityType.achievementUnlocked:
        return ('성취', Colors.amber);
      case GroupActivityType.programStarted:
        return ('프로그램 시작', Colors.orange);
      case GroupActivityType.milestoneReached:
        return ('마일스톤', Colors.teal);
    }
  }

  String _getUserName() {
    // TODO: Get actual user name from activity data
    return activity.activityData['user_name'] as String? ?? '사용자';
  }

  String _getActivityDescription() {
    final userName = _getUserName();
    
    switch (activity.activityType) {
      case GroupActivityType.workoutCompleted:
        return '$userName님이 운동을 완료했습니다';
      case GroupActivityType.routineShared:
        return '$userName님이 운동 루틴을 공유했습니다';
      case GroupActivityType.memberJoined:
        return '$userName님이 그룹에 가입했습니다';
      case GroupActivityType.memberLeft:
        return '$userName님이 그룹을 떠났습니다';
      case GroupActivityType.encouragementSent:
        final targetUser = activity.activityData['target_user'] as String? ?? '멤버';
        return '$userName님이 $targetUser님에게 격려 메시지를 보냈습니다';
      case GroupActivityType.achievementUnlocked:
        return '$userName님이 새로운 성취를 달성했습니다';
      case GroupActivityType.programStarted:
        return '$userName님이 새로운 프로그램을 시작했습니다';
      case GroupActivityType.milestoneReached:
        return '$userName님이 마일스톤을 달성했습니다';
    }
  }

  bool _hasAdditionalContent() {
    switch (activity.activityType) {
      case GroupActivityType.workoutCompleted:
      case GroupActivityType.routineShared:
      case GroupActivityType.achievementUnlocked:
        return true;
      default:
        return false;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${timestamp.month}/${timestamp.day}';
    }
  }

  void _viewSharedRoutine() {
    // TODO: Implement view shared routine
  }
}