import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jfit/features/group_workout_community/data/services/group_realtime_service.dart';
import 'package:jfit/features/group_workout_community/data/services/group_notification_service.dart';
import 'package:jfit/features/group_workout_community/domain/entities/group_activity.dart';
import 'package:jfit/features/group_workout_community/domain/entities/community_post.dart';
import 'package:jfit/features/group_workout_community/domain/entities/workout_group.dart';

/// Centralized manager for all real-time functionality in group workout community
class GroupRealtimeManager {
  final GroupRealtimeService _realtimeService;
  final GroupNotificationService _notificationService;
  
  // Active subscriptions tracking
  final Map<String, StreamSubscription> _activeSubscriptions = {};
  final Map<String, Stream> _activeStreams = {};

  GroupRealtimeManager(SupabaseClient supabase)
      : _realtimeService = GroupRealtimeService(supabase),
        _notificationService = GroupNotificationService(supabase);

  /// Get the notification service
  GroupNotificationService get notificationService => _notificationService;

  /// Get the realtime service
  GroupRealtimeService get realtimeService => _realtimeService;

  /// Subscribe to group activities with automatic notification handling
  Stream<List<GroupActivity>> subscribeToGroupActivities(String groupId) {
    final streamKey = 'group_activities_$groupId';
    
    if (_activeStreams.containsKey(streamKey)) {
      return _activeStreams[streamKey] as Stream<List<GroupActivity>>;
    }

    final stream = _realtimeService.subscribeToGroupActivities(groupId);
    _activeStreams[streamKey] = stream;

    // Listen to activities and trigger notifications when appropriate
    final subscription = stream.listen((activities) {
      _handleGroupActivityUpdates(groupId, activities);
    });

    _activeSubscriptions[streamKey] = subscription;
    return stream;
  }

  /// Subscribe to group messages with typing indicators
  Stream<List<Map<String, dynamic>>> subscribeToGroupMessages(String groupId) {
    final streamKey = 'group_messages_$groupId';
    
    if (_activeStreams.containsKey(streamKey)) {
      return _activeStreams[streamKey] as Stream<List<Map<String, dynamic>>>;
    }

    final stream = _realtimeService.subscribeToGroupMessages(groupId);
    _activeStreams[streamKey] = stream;

    // Listen to messages and trigger notifications
    final subscription = stream.listen((messages) {
      _handleGroupMessageUpdates(groupId, messages);
    });

    _activeSubscriptions[streamKey] = subscription;
    return stream;
  }

  /// Subscribe to post interactions with notification handling
  Stream<Map<String, dynamic>> subscribeToPostInteractions(String postId) {
    final streamKey = 'post_interactions_$postId';
    
    if (_activeStreams.containsKey(streamKey)) {
      return _activeStreams[streamKey] as Stream<Map<String, dynamic>>;
    }

    final stream = _realtimeService.subscribeToPostInteractions(postId);
    _activeStreams[streamKey] = stream;

    // Listen to interactions and trigger notifications
    final subscription = stream.listen((interactions) {
      _handlePostInteractionUpdates(postId, interactions);
    });

    _activeSubscriptions[streamKey] = subscription;
    return stream;
  }

  /// Subscribe to community posts
  Stream<List<CommunityPost>> subscribeToCommunityPosts({
    String? categoryId,
    String? groupId,
  }) {
    final streamKey = 'community_posts_${categoryId ?? 'all'}_${groupId ?? 'all'}';
    
    if (_activeStreams.containsKey(streamKey)) {
      return _activeStreams[streamKey] as Stream<List<CommunityPost>>;
    }

    final stream = _realtimeService.subscribeToCommunityPosts(
      categoryId: categoryId,
      groupId: groupId,
    );
    _activeStreams[streamKey] = stream;

    return stream;
  }

  /// Subscribe to typing indicators for group chat
  Stream<Map<String, dynamic>> subscribeToTypingIndicators(String groupId) {
    return _realtimeService.subscribeToTypingIndicators(groupId);
  }

  /// Send typing indicator
  Future<void> sendTypingIndicator(String groupId, bool isTyping) async {
    await _realtimeService.sendTypingIndicator(groupId, isTyping);
  }

  /// Get notification stream
  Stream<GroupNotification> get notificationStream => 
      _notificationService.notificationStream;

  /// Handle group activity updates and trigger notifications
  void _handleGroupActivityUpdates(String groupId, List<GroupActivity> activities) {
    // This could analyze new activities and trigger appropriate notifications
    // For example, if a new workout completion activity is detected
    
    if (activities.isNotEmpty) {
      final latestActivity = activities.first;
      
      switch (latestActivity.activityType) {
        case GroupActivityType.workoutCompleted:
          // Could trigger workout completion notification
          break;
        case GroupActivityType.routineShared:
          // Could trigger routine shared notification
          break;
        case GroupActivityType.memberJoined:
          // Could trigger new member notification
          break;
        case GroupActivityType.memberLeft:
          // Could trigger member left notification
          break;
        case GroupActivityType.encouragementSent:
          // Could trigger encouragement notification
          break;
        case GroupActivityType.achievementUnlocked:
          // Could trigger achievement notification
          break;
        case GroupActivityType.programStarted:
          // Could trigger program started notification
          break;
        case GroupActivityType.milestoneReached:
          // Could trigger milestone notification
          break;
      }
    }
  }

  /// Handle group message updates and trigger notifications
  void _handleGroupMessageUpdates(String groupId, List<Map<String, dynamic>> messages) {
    // This could analyze new messages and trigger chat notifications
    // Implementation would depend on specific notification requirements
  }

  /// Handle post interaction updates and trigger notifications
  void _handlePostInteractionUpdates(String postId, Map<String, dynamic> interactions) {
    // This could analyze new interactions and trigger appropriate notifications
    // For example, new comments or likes
  }

  /// Unsubscribe from specific stream
  void unsubscribeFromStream(String streamKey) {
    final subscription = _activeSubscriptions[streamKey];
    if (subscription != null) {
      subscription.cancel();
      _activeSubscriptions.remove(streamKey);
      _activeStreams.remove(streamKey);
    }
  }

  /// Unsubscribe from group activities
  void unsubscribeFromGroupActivities(String groupId) {
    unsubscribeFromStream('group_activities_$groupId');
  }

  /// Unsubscribe from group messages
  void unsubscribeFromGroupMessages(String groupId) {
    unsubscribeFromStream('group_messages_$groupId');
  }

  /// Unsubscribe from post interactions
  void unsubscribeFromPostInteractions(String postId) {
    unsubscribeFromStream('post_interactions_$postId');
  }

  /// Unsubscribe from community posts
  void unsubscribeFromCommunityPosts({String? categoryId, String? groupId}) {
    final streamKey = 'community_posts_${categoryId ?? 'all'}_${groupId ?? 'all'}';
    unsubscribeFromStream(streamKey);
  }

  /// Get connection status for real-time features
  bool get isConnected {
    // This would check the Supabase connection status
    // For now, return true as a placeholder
    return true;
  }

  /// Reconnect all active subscriptions
  Future<void> reconnectAll() async {
    // Store current active streams
    final activeStreamKeys = _activeStreams.keys.toList();
    
    // Dispose current connections
    await dispose();
    
    // Recreate subscriptions based on stored keys
    for (final streamKey in activeStreamKeys) {
      if (streamKey.startsWith('group_activities_')) {
        final groupId = streamKey.replaceFirst('group_activities_', '');
        subscribeToGroupActivities(groupId);
      } else if (streamKey.startsWith('group_messages_')) {
        final groupId = streamKey.replaceFirst('group_messages_', '');
        subscribeToGroupMessages(groupId);
      } else if (streamKey.startsWith('post_interactions_')) {
        final postId = streamKey.replaceFirst('post_interactions_', '');
        subscribeToPostInteractions(postId);
      } else if (streamKey.startsWith('community_posts_')) {
        // Parse category and group IDs from stream key
        final parts = streamKey.replaceFirst('community_posts_', '').split('_');
        final categoryId = parts[0] != 'all' ? parts[0] : null;
        final groupId = parts.length > 1 && parts[1] != 'all' ? parts[1] : null;
        subscribeToCommunityPosts(categoryId: categoryId, groupId: groupId);
      }
    }
  }

  /// Get active subscription count
  int get activeSubscriptionCount => _activeSubscriptions.length;

  /// Get list of active stream keys
  List<String> get activeStreamKeys => _activeStreams.keys.toList();

  /// Dispose of all subscriptions and services
  Future<void> dispose() async {
    // Cancel all active subscriptions
    for (final subscription in _activeSubscriptions.values) {
      await subscription.cancel();
    }
    _activeSubscriptions.clear();
    _activeStreams.clear();

    // Dispose services
    _realtimeService.dispose();
    _notificationService.dispose();
  }
}