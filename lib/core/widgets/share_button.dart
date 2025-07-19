import 'package:flutter/material.dart';
import 'package:jfit/core/utils/deep_link_handler.dart';

/// A reusable share button widget for group workout community features
class ShareButton extends StatelessWidget {
  final String title;
  final String path;
  final VoidCallback? onShare;
  final VoidCallback? onCopyLink;
  final IconData icon;
  final String? tooltip;
  final bool showLabel;
  final Color? color;

  const ShareButton({
    super.key,
    required this.title,
    required this.path,
    this.onShare,
    this.onCopyLink,
    this.icon = Icons.share,
    this.tooltip,
    this.showLabel = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final button = showLabel
        ? TextButton.icon(
            onPressed: () => _showShareDialog(context),
            icon: Icon(icon, color: color),
            label: Text(
              '공유',
              style: TextStyle(color: color),
            ),
          )
        : IconButton(
            onPressed: () => _showShareDialog(context),
            icon: Icon(icon, color: color),
            tooltip: tooltip ?? '공유하기',
          );

    return button;
  }

  void _showShareDialog(BuildContext context) {
    DeepLinkHandler.showShareDialog(
      context: context,
      title: title,
      path: path,
      onShare: onShare,
      onCopyLink: onCopyLink,
    );
  }
}

/// Specialized share button for group invites
class GroupInviteShareButton extends StatelessWidget {
  final String inviteCode;
  final String groupName;
  final bool showLabel;
  final Color? color;

  const GroupInviteShareButton({
    super.key,
    required this.inviteCode,
    required this.groupName,
    this.showLabel = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ShareButton(
      title: '그룹 초대 공유',
      path: '/invite/$inviteCode',
      icon: Icons.group_add,
      showLabel: showLabel,
      color: color,
      onShare: () => DeepLinkHandler.shareGroupInvite(
        inviteCode: inviteCode,
        groupName: groupName,
      ),
    );
  }
}

/// Specialized share button for posts
class PostShareButton extends StatelessWidget {
  final String postId;
  final String postTitle;
  final bool showLabel;
  final Color? color;

  const PostShareButton({
    super.key,
    required this.postId,
    required this.postTitle,
    this.showLabel = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ShareButton(
      title: '게시글 공유',
      path: '/share/post/$postId',
      icon: Icons.share,
      showLabel: showLabel,
      color: color,
      onShare: () => DeepLinkHandler.sharePost(
        postId: postId,
        postTitle: postTitle,
      ),
    );
  }
}

/// Specialized share button for groups
class GroupShareButton extends StatelessWidget {
  final String groupId;
  final String groupName;
  final bool showLabel;
  final Color? color;

  const GroupShareButton({
    super.key,
    required this.groupId,
    required this.groupName,
    this.showLabel = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ShareButton(
      title: '그룹 공유',
      path: '/share/group/$groupId',
      icon: Icons.group,
      showLabel: showLabel,
      color: color,
      onShare: () => DeepLinkHandler.shareGroup(
        groupId: groupId,
        groupName: groupName,
      ),
    );
  }
}

/// Specialized share button for routines
class RoutineShareButton extends StatelessWidget {
  final String routineId;
  final String routineName;
  final String? groupId;
  final bool showLabel;
  final Color? color;

  const RoutineShareButton({
    super.key,
    required this.routineId,
    required this.routineName,
    this.groupId,
    this.showLabel = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final query = groupId != null ? '?groupId=$groupId' : '';
    return ShareButton(
      title: '루틴 공유',
      path: '/share/routine/$routineId$query',
      icon: Icons.fitness_center,
      showLabel: showLabel,
      color: color,
      onShare: () => DeepLinkHandler.shareRoutine(
        routineId: routineId,
        routineName: routineName,
        groupId: groupId,
      ),
    );
  }
}