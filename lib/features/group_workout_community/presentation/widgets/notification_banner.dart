import 'package:flutter/material.dart';
import 'package:jfit/features/group_workout_community/data/services/group_notification_service.dart';

/// Widget for displaying in-app notification banners
class NotificationBanner extends StatefulWidget {
  final GroupNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final Duration displayDuration;

  const NotificationBanner({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
    this.displayDuration = const Duration(seconds: 4),
  });

  @override
  State<NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<NotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    // Start animation
    _animationController.forward();

    // Auto-dismiss after duration
    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _animationController.reverse();
    if (mounted) {
      widget.onDismiss?.call();
    }
  }

  Color _getNotificationColor() {
    switch (widget.notification.type) {
      case GroupNotificationType.newMember:
        return Colors.green;
      case GroupNotificationType.routineShared:
        return Colors.blue;
      case GroupNotificationType.workoutCompleted:
        return Colors.orange;
      case GroupNotificationType.encouragementMessage:
        return Colors.purple;
      case GroupNotificationType.newComment:
        return Colors.indigo;
      case GroupNotificationType.postLiked:
        return Colors.red;
      case GroupNotificationType.mentioned:
        return Colors.amber;
      case GroupNotificationType.chatMessage:
        return Colors.teal;
    }
  }

  IconData _getNotificationIcon() {
    switch (widget.notification.type) {
      case GroupNotificationType.newMember:
        return Icons.person_add;
      case GroupNotificationType.routineShared:
        return Icons.share;
      case GroupNotificationType.workoutCompleted:
        return Icons.fitness_center;
      case GroupNotificationType.encouragementMessage:
        return Icons.favorite;
      case GroupNotificationType.newComment:
        return Icons.comment;
      case GroupNotificationType.postLiked:
        return Icons.thumb_up;
      case GroupNotificationType.mentioned:
        return Icons.alternate_email;
      case GroupNotificationType.chatMessage:
        return Icons.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Notification icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getNotificationColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        _getNotificationIcon(),
                        color: _getNotificationColor(),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Notification content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.notification.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.notification.message,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                    // Dismiss button
                    IconButton(
                      onPressed: _dismiss,
                      icon: const Icon(Icons.close),
                      iconSize: 18,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Overlay manager for showing notification banners
class NotificationOverlay {
  static OverlayEntry? _currentOverlay;

  /// Show a notification banner
  static void show(
    BuildContext context,
    GroupNotification notification, {
    VoidCallback? onTap,
    Duration displayDuration = const Duration(seconds: 4),
  }) {
    // Remove existing overlay if present
    hide();

    _currentOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top,
        left: 0,
        right: 0,
        child: NotificationBanner(
          notification: notification,
          onTap: () {
            hide();
            onTap?.call();
          },
          onDismiss: hide,
          displayDuration: displayDuration,
        ),
      ),
    );

    Overlay.of(context).insert(_currentOverlay!);
  }

  /// Hide the current notification banner
  static void hide() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

/// Widget for displaying a list of notifications
class NotificationList extends StatelessWidget {
  final List<GroupNotification> notifications;
  final Function(GroupNotification)? onNotificationTap;
  final Function(GroupNotification)? onNotificationDismiss;
  final bool showUnreadOnly;

  const NotificationList({
    super.key,
    required this.notifications,
    this.onNotificationTap,
    this.onNotificationDismiss,
    this.showUnreadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = showUnreadOnly
        ? notifications.where((n) => !n.isRead).toList()
        : notifications;

    if (filteredNotifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              showUnreadOnly ? '읽지 않은 알림이 없습니다' : '알림이 없습니다',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).disabledColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = filteredNotifications[index];
        return NotificationListItem(
          notification: notification,
          onTap: () => onNotificationTap?.call(notification),
          onDismiss: () => onNotificationDismiss?.call(notification),
        );
      },
    );
  }
}

/// Individual notification list item
class NotificationListItem extends StatelessWidget {
  final GroupNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationListItem({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  });

  Color _getNotificationColor() {
    switch (notification.type) {
      case GroupNotificationType.newMember:
        return Colors.green;
      case GroupNotificationType.routineShared:
        return Colors.blue;
      case GroupNotificationType.workoutCompleted:
        return Colors.orange;
      case GroupNotificationType.encouragementMessage:
        return Colors.purple;
      case GroupNotificationType.newComment:
        return Colors.indigo;
      case GroupNotificationType.postLiked:
        return Colors.red;
      case GroupNotificationType.mentioned:
        return Colors.amber;
      case GroupNotificationType.chatMessage:
        return Colors.teal;
    }
  }

  IconData _getNotificationIcon() {
    switch (notification.type) {
      case GroupNotificationType.newMember:
        return Icons.person_add;
      case GroupNotificationType.routineShared:
        return Icons.share;
      case GroupNotificationType.workoutCompleted:
        return Icons.fitness_center;
      case GroupNotificationType.encouragementMessage:
        return Icons.favorite;
      case GroupNotificationType.newComment:
        return Icons.comment;
      case GroupNotificationType.postLiked:
        return Icons.thumb_up;
      case GroupNotificationType.mentioned:
        return Icons.alternate_email;
      case GroupNotificationType.chatMessage:
        return Icons.message;
    }
  }

  String _getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(notification.createdAt);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${difference.inDays ~/ 7}주 전';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: notification.isRead 
              ? null 
              : Theme.of(context).primaryColor.withOpacity(0.05),
        ),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getNotificationColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _getNotificationIcon(),
              color: _getNotificationColor(),
              size: 20,
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _getTimeAgo(),
                style: Theme.of(context).textTheme.caption?.copyWith(
                  color: Theme.of(context).disabledColor,
                ),
              ),
            ],
          ),
          trailing: notification.isRead 
              ? null 
              : Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
      ),
    );
  }
}