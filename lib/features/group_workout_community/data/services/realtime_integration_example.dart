import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jfit/features/group_workout_community/data/services/group_realtime_manager.dart';
import 'package:jfit/features/group_workout_community/data/services/push_notification_manager.dart';
import 'package:jfit/features/group_workout_community/data/services/group_notification_service.dart';
import 'package:jfit/features/group_workout_community/presentation/widgets/notification_banner.dart';

/// Example integration showing how to use the real-time features
/// This demonstrates the complete workflow from real-time events to user notifications
class RealtimeIntegrationExample {
  final GroupRealtimeManager _realtimeManager;
  final PushNotificationManager _pushManager;
  
  // Active subscriptions
  final Map<String, StreamSubscription> _subscriptions = {};

  RealtimeIntegrationExample(
    this._realtimeManager,
    this._pushManager,
  );

  /// Initialize real-time features for a group
  Future<void> initializeGroupFeatures(String groupId, BuildContext context) async {
    // Subscribe to group activities
    final activitySubscription = _realtimeManager
        .subscribeToGroupActivities(groupId)
        .listen((activities) {
      _handleGroupActivities(activities, context);
    });
    _subscriptions['activities_$groupId'] = activitySubscription;

    // Subscribe to group messages
    final messageSubscription = _realtimeManager
        .subscribeToGroupMessages(groupId)
        .listen((messages) {
      _handleGroupMessages(messages, context);
    });
    _subscriptions['messages_$groupId'] = messageSubscription;

    // Subscribe to typing indicators
    final typingSubscription = _realtimeManager
        .subscribeToTypingIndicators(groupId)
        .listen((typingData) {
      _handleTypingIndicators(typingData, context);
    });
    _subscriptions['typing_$groupId'] = typingSubscription;

    // Subscribe to push notifications
    final notificationSubscription = _pushManager
        .groupActivityNotifications
        .listen((notification) {
      _handlePushNotification(notification, context);
    });
    _subscriptions['notifications_$groupId'] = notificationSubscription;

    print('Real-time features initialized for group: $groupId');
  }

  /// Handle group activity updates
  void _handleGroupActivities(List<dynamic> activities, BuildContext context) {
    if (activities.isEmpty) return;

    // Process the latest activity
    final latestActivity = activities.first;
    print('New group activity: ${latestActivity}');

    // Show in-app notification for significant activities
    // This would be based on the actual activity type and data
  }

  /// Handle group message updates
  void _handleGroupMessages(List<Map<String, dynamic>> messages, BuildContext context) {
    if (messages.isEmpty) return;

    final latestMessage = messages.last;
    print('New group message: ${latestMessage['message_text']}');

    // Show notification banner for new messages
    // (only if the user is not currently in the chat screen)
    if (_shouldShowMessageNotification(context)) {
      _showMessageNotificationBanner(latestMessage, context);
    }
  }

  /// Handle typing indicators
  void _handleTypingIndicators(Map<String, dynamic> typingData, BuildContext context) {
    final isTyping = typingData['is_typing'] as bool;
    final userId = typingData['user_id'] as String;
    
    print('User $userId is ${isTyping ? 'typing' : 'stopped typing'}');
    
    // Update UI to show typing indicator
    // This would typically update a state management solution
  }

  /// Handle push notifications
  void _handlePushNotification(GroupNotification notification, BuildContext context) {
    print('Received push notification: ${notification.title}');

    // Show notification banner
    NotificationOverlay.show(
      context,
      notification,
      onTap: () {
        _handleNotificationTap(notification, context);
      },
    );
  }

  /// Handle notification tap
  void _handleNotificationTap(GroupNotification notification, BuildContext context) {
    final action = notification.data['action'] as String?;
    
    switch (action) {
      case 'view_group':
        _navigateToGroup(notification.groupId, context);
        break;
      case 'view_routine':
        _navigateToRoutine(notification.data['routine_id'] as String?, context);
        break;
      case 'view_activity':
        _navigateToActivity(notification.groupId, context);
        break;
      case 'view_post':
        _navigateToPost(notification.data['post_id'] as String?, context);
        break;
      case 'view_chat':
        _navigateToChat(notification.groupId, context);
        break;
      default:
        _navigateToGroup(notification.groupId, context);
        break;
    }
  }

  /// Check if message notification should be shown
  bool _shouldShowMessageNotification(BuildContext context) {
    // This would check if the user is currently viewing the chat screen
    // For now, always show notifications
    return true;
  }

  /// Show message notification banner
  void _showMessageNotificationBanner(Map<String, dynamic> message, BuildContext context) {
    final senderName = message['user_profiles']?['username'] as String? ?? 'Someone';
    final messageText = message['message_text'] as String;
    
    final notification = GroupNotification(
      id: message['id'] as String,
      userId: message['sender_id'] as String,
      groupId: message['group_id'] as String,
      type: GroupNotificationType.chatMessage,
      title: '새 메시지',
      message: '$senderName: $messageText',
      data: {
        'action': 'view_chat',
        'message_id': message['id'],
      },
      createdAt: DateTime.parse(message['created_at'] as String),
    );

    NotificationOverlay.show(
      context,
      notification,
      onTap: () {
        _navigateToChat(message['group_id'] as String, context);
      },
      displayDuration: const Duration(seconds: 3),
    );
  }

  /// Send typing indicator
  Future<void> sendTypingIndicator(String groupId, bool isTyping) async {
    await _realtimeManager.sendTypingIndicator(groupId, isTyping);
  }

  /// Send group activity notification
  Future<void> sendGroupActivityNotification({
    required String groupId,
    required List<String> memberIds,
    required GroupNotificationType type,
    required Map<String, dynamic> data,
  }) async {
    await _pushManager.sendGroupActivityNotifications(
      groupId: groupId,
      memberIds: memberIds,
      type: type,
      data: data,
    );
  }

  /// Send community notification
  Future<void> sendCommunityNotification({
    required String groupId,
    required GroupNotificationType type,
    required Map<String, dynamic> data,
  }) async {
    await _pushManager.sendCommunityNotifications(
      groupId: groupId,
      type: type,
      data: data,
    );
  }

  /// Send chat notification
  Future<void> sendChatNotification({
    required String groupId,
    required String senderName,
    required String message,
    required List<String> memberIds,
  }) async {
    await _pushManager.sendChatNotifications(
      groupId: groupId,
      senderName: senderName,
      message: message,
      memberIds: memberIds,
    );
  }

  /// Navigation methods (these would integrate with your app's navigation system)
  void _navigateToGroup(String groupId, BuildContext context) {
    print('Navigating to group: $groupId');
    // Navigator.pushNamed(context, '/group/$groupId');
  }

  void _navigateToRoutine(String? routineId, BuildContext context) {
    print('Navigating to routine: $routineId');
    // Navigator.pushNamed(context, '/routine/$routineId');
  }

  void _navigateToActivity(String groupId, BuildContext context) {
    print('Navigating to activity feed for group: $groupId');
    // Navigator.pushNamed(context, '/group/$groupId/activity');
  }

  void _navigateToPost(String? postId, BuildContext context) {
    print('Navigating to post: $postId');
    // Navigator.pushNamed(context, '/post/$postId');
  }

  void _navigateToChat(String groupId, BuildContext context) {
    print('Navigating to chat for group: $groupId');
    // Navigator.pushNamed(context, '/group/$groupId/chat');
  }

  /// Get connection status
  bool get isConnected => _realtimeManager.isConnected;

  /// Get active subscription count
  int get activeSubscriptionCount => _subscriptions.length;

  /// Reconnect all subscriptions
  Future<void> reconnectAll() async {
    await _realtimeManager.reconnectAll();
  }

  /// Clean up subscriptions for a specific group
  void cleanupGroupSubscriptions(String groupId) {
    final keysToRemove = _subscriptions.keys
        .where((key) => key.contains(groupId))
        .toList();

    for (final key in keysToRemove) {
      _subscriptions[key]?.cancel();
      _subscriptions.remove(key);
    }

    _realtimeManager.unsubscribeFromGroupActivities(groupId);
    _realtimeManager.unsubscribeFromGroupMessages(groupId);

    print('Cleaned up subscriptions for group: $groupId');
  }

  /// Dispose of all subscriptions
  void dispose() {
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();

    _realtimeManager.dispose();
    _pushManager.dispose();

    print('Real-time integration disposed');
  }
}

/// Example usage widget
class RealtimeExampleWidget extends StatefulWidget {
  final String groupId;
  final RealtimeIntegrationExample integration;

  const RealtimeExampleWidget({
    super.key,
    required this.groupId,
    required this.integration,
  });

  @override
  State<RealtimeExampleWidget> createState() => _RealtimeExampleWidgetState();
}

class _RealtimeExampleWidgetState extends State<RealtimeExampleWidget> {
  @override
  void initState() {
    super.initState();
    // Initialize real-time features when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.integration.initializeGroupFeatures(widget.groupId, context);
    });
  }

  @override
  void dispose() {
    // Clean up subscriptions when widget is disposed
    widget.integration.cleanupGroupSubscriptions(widget.groupId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-time Features Demo'),
        actions: [
          // Connection status indicator
          IconButton(
            icon: Icon(
              widget.integration.isConnected 
                  ? Icons.wifi 
                  : Icons.wifi_off,
              color: widget.integration.isConnected 
                  ? Colors.green 
                  : Colors.red,
            ),
            onPressed: () {
              if (!widget.integration.isConnected) {
                widget.integration.reconnectAll();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Status information
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Group ID: ${widget.groupId}'),
                Text('Active Subscriptions: ${widget.integration.activeSubscriptionCount}'),
                Text('Connected: ${widget.integration.isConnected}'),
              ],
            ),
          ),
          
          // Action buttons for testing
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ElevatedButton(
                  onPressed: () => _sendTestNotification(),
                  child: const Text('Send Test Notification'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _sendTypingIndicator(),
                  child: const Text('Send Typing Indicator'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _reconnectAll(),
                  child: const Text('Reconnect All'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendTestNotification() {
    widget.integration.sendGroupActivityNotification(
      groupId: widget.groupId,
      memberIds: ['test-user-1', 'test-user-2'],
      type: GroupNotificationType.workoutCompleted,
      data: {
        'userName': 'Test User',
        'workoutName': 'Morning Workout',
      },
    );
  }

  void _sendTypingIndicator() {
    widget.integration.sendTypingIndicator(widget.groupId, true);
    
    // Stop typing after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      widget.integration.sendTypingIndicator(widget.groupId, false);
    });
  }

  void _reconnectAll() {
    widget.integration.reconnectAll();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reconnecting all subscriptions...')),
    );
  }
}