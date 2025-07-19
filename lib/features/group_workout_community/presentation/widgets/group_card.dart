import 'package:flutter/material.dart';
import 'package:jfit/core/utils/breakpoint_utils.dart';
import 'package:jfit/core/utils/accessibility_utils.dart';
import 'package:jfit/core/utils/ux_optimization_utils.dart';
import 'package:jfit/features/group_workout_community/domain/entities/workout_group.dart';
import 'package:jfit/l10n/app_localizations.dart';

/// 그룹 정보를 표시하는 카드 위젯
class GroupCard extends StatelessWidget {
  final WorkoutGroup group;
  final VoidCallback? onTap;
  final bool showJoinButton;
  final VoidCallback? onJoinPressed;
  final bool isGridView;

  const GroupCard({
    super.key,
    required this.group,
    this.onTap,
    this.showJoinButton = false,
    this.onJoinPressed,
    this.isGridView = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Create comprehensive semantic label for the entire card
    final semanticLabel = AccessibilityUtils.groupCardSemanticLabel(
      context,
      groupName: group.name,
      memberCount: group.currentMemberCount,
      isPublic: group.privacyType == GroupPrivacyType.public,
      isAdmin: false, // This would need to be passed as parameter in real implementation
    );

    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final deviceType = BreakpointUtils.getDeviceType(constraints.maxWidth);
          
          if (isGridView) {
            return _buildGridCard(context, deviceType);
          } else {
            return _buildListCard(context, deviceType);
          }
        },
      ),
    );
  }

  Widget _buildListCard(BuildContext context, DeviceType deviceType) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(deviceType.isMobile ? 12.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Group avatar
                  CircleAvatar(
                    radius: deviceType.isMobile ? 20 : 24,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.group,
                      color: colorScheme.onPrimaryContainer,
                      size: deviceType.isMobile ? 20 : 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Group info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                group.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildPrivacyBadge(context),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.people,
                              size: 16,
                              color: colorScheme.outline,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${group.currentMemberCount}/${group.maxMembers}명',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.outline,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: colorScheme.outline,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatCreatedDate(group.createdAt),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Join button
                  if (showJoinButton) ...[
                    const SizedBox(width: 8),
                    _buildJoinButton(context, deviceType),
                  ],
                ],
              ),
              if (group.description?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Text(
                  group.description!,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              _buildProgressIndicator(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, DeviceType deviceType) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with avatar and privacy badge
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.group,
                      color: colorScheme.onPrimaryContainer,
                      size: 16,
                    ),
                  ),
                  const Spacer(),
                  _buildPrivacyBadge(context),
                ],
              ),
              const SizedBox(height: 12),
              // Group name
              Text(
                group.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Description
              if (group.description?.isNotEmpty == true)
                Expanded(
                  child: Text(
                    group.description!,
                    style: theme.textTheme.bodySmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const Spacer(),
              // Member count and join button
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 14,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${group.currentMemberCount}/${group.maxMembers}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  const Spacer(),
                  if (showJoinButton)
                    _buildJoinButton(context, deviceType, isCompact: true),
                ],
              ),
              const SizedBox(height: 8),
              _buildProgressIndicator(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyBadge(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    
    final isPublic = group.privacyType == GroupPrivacyType.public;
    final privacyText = isPublic ? '공개' : '비공개';
    
    return Semantics(
      label: 'Group privacy: $privacyText',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isPublic 
              ? colorScheme.secondaryContainer 
              : colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPublic ? Icons.public : Icons.lock,
              size: 12,
              color: isPublic 
                  ? colorScheme.onSecondaryContainer 
                  : colorScheme.onTertiaryContainer,
            ),
            const SizedBox(width: 4),
            Text(
              privacyText,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isPublic 
                    ? colorScheme.onSecondaryContainer 
                    : colorScheme.onTertiaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinButton(BuildContext context, DeviceType deviceType, {bool isCompact = false}) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isFull = group.currentMemberCount >= group.maxMembers;
    
    final semanticLabel = isFull 
        ? 'Group is full'
        : 'Join ${group.name}';
    
    final semanticHint = isFull 
        ? null
        : 'Double tap to join group';
    
    if (isCompact) {
      return AccessibilityUtils.createAccessibleTapTarget(
        onTap: isFull ? null : () {
          onJoinPressed?.call();
          AccessibilityUtils.provideHapticFeedback();
          AccessibilityUtils.announceToScreenReader(context, semanticLabel);
        },
        semanticLabel: semanticLabel,
        semanticHint: semanticHint,
        child: IconButton(
          onPressed: null, // Handled by AccessibleTapTarget
          icon: Icon(
            isFull ? Icons.group : Icons.group_add,
            size: 20,
          ),
          tooltip: isFull ? '그룹 가득참' : '그룹 가입',
        ),
      );
    }
    
    return AccessibilityUtils.createAccessibleTapTarget(
      onTap: isFull ? null : () {
        onJoinPressed?.call();
        AccessibilityUtils.provideHapticFeedback();
        AccessibilityUtils.announceToScreenReader(context, semanticLabel);
      },
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
      child: ElevatedButton(
        onPressed: null, // Handled by AccessibleTapTarget
        style: ElevatedButton.styleFrom(
          minimumSize: Size(
            deviceType.isMobile ? 60 : 80,
            deviceType.isMobile ? 32 : 36,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: deviceType.isMobile ? 12 : 16,
            vertical: 0,
          ),
        ),
        child: Text(
          isFull ? '가득참' : '가입',
          style: theme.textTheme.labelSmall,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = group.currentMemberCount / group.maxMembers;
    
    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(
            progress >= 0.8 
                ? colorScheme.error 
                : progress >= 0.6 
                    ? Colors.orange 
                    : colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '멤버 ${group.currentMemberCount}명',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
            Text(
              '최대 ${group.maxMembers}명',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatCreatedDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}개월 전';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else {
      return '방금 전';
    }
  }
}