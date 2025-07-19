import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Enum for different types of group notifications
enum GroupNotificationType {
  newMember,
  routineShared,
  workoutCompleted,
  encouragementMessage,
  newComment,
  postLiked,
  mentioned,
  chatMessage,
}

/// Data class for group notifications
class GroupNotification {
  final String id;
  final String userId;
  final String groupId;
  final GroupNotificationType type;
  final String title;
  final String message;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final bool isRead;

  const GroupNotification({
    required this.id,
    required this.userId,
    required this.groupId,
    required this.type,
    required this.title,
    required this.message,
    required this.data,
    required this.createdAt,
    this.isRead = false,
  });

  GroupNotification copyWith({
    String? id,
    String? userId,
    String? groupId,
    GroupNotificationType? type,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return GroupNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      groupId: groupId ?? this.groupId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'group_id': groupId,
      'notification_type': type.name,
      'title': title,
      'message': message,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }

  factory GroupNotification.fromJson(Map<String, dynamic> json) {
    return GroupNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      groupId: json['group_id'] as String,
      type: GroupNotificationType.values.firstWhere(
        (e) => e.name == json['notification_type'],
        orElse: () => GroupNotificationType.chatMessage,
      ),
      title: json['title'] as String,
      message: json['message'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map? ?? {}),
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
    );
  }
}

/// Service for handling group workout community notifications
class GroupNotificationService {
  final SupabaseClient _supabase;
  final StreamController<GroupNotification> _notificationController = 
      StreamController<GroupNotification>.broadcast();

  GroupNotificationService(this._supabase) {
    _initializeNotificationListener();
  }

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Stream of incoming notifications
  Stream<GroupNotification> get notificationStream => _notificationController.stream;

  /// Initialize real-time notification listener
  void _initializeNotificationListener() {
    if (_currentUserId == null) return;

    final channel = _supabase.channel('user_notifications_${_currentUserId}');
    
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'group_notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: _currentUserId!,
          ),
          callback: (payload) {
            try {
              final notification = GroupNotification.fromJson(payload.newRecord);
              _notificationController.add(notification);
              
              // Show local notification if app is in foreground
              _showLocalNotification(notification);
            } catch (e) {
              print('Error processing notification: $e');
            }
          },
        )
        .subscribe((status, [error]) {
          if (status == RealtimeSubscribeStatus.subscribed) {
            print('Successfully subscribed to user notifications');
          } else if (error != null) {
            print('Error subscribing to notifications: $error');
          }
        });
  }

  /// Send notification for new group member
  Future<void> sendNewMemberNotification({
    required String groupId,
    required String newMemberName,
    required List<String> memberIds,
  }) async {
    final title = '새 멤버 가입';
    final message = '$newMemberName님이 그룹에 가입했습니다';
    
    await _sendNotificationToUsers(
      userIds: memberIds,
      groupId: groupId,
      type: GroupNotificationType.newMember,
      title: title,
      message: message,
      data: {
        'new_member_name': newMemberName,
        'action': 'view_group',
      },
    );
  }

  /// Send notification for shared routine
  Future<void> sendRoutineSharedNotification({
    required String groupId,
    required String sharerName,
    required String routineName,
    required List<String> memberIds,
  }) async {
    final title = '새 루틴 공유';
    final message = '$sharerName님이 "$routineName" 루틴을 공유했습니다';
    
    await _sendNotificationToUsers(
      userIds: memberIds,
      groupId: groupId,
      type: GroupNotificationType.routineShared,
      title: title,
      message: message,
      data: {
        'sharer_name': sharerName,
        'routine_name': routineName,
        'action': 'view_routine',
      },
    );
  }

  /// Send notification for workout completion
  Future<void> sendWorkoutCompletedNotification({
    required String groupId,
    required String userName,
    required String workoutName,
    required List<String> memberIds,
  }) async {
    final title = '운동 완료';
    final message = '$userName님이 "$workoutName" 운동을 완료했습니다';
    
    await _sendNotificationToUsers(
      userIds: memberIds,
      groupId: groupId,
      type: GroupNotificationType.workoutCompleted,
      title: title,
      message: message,
      data: {
        'user_name': userName,
        'workout_name': workoutName,
        'action': 'view_activity',
      },
    );
  }

  /// Send notification for encouragement message
  Future<void> sendEncouragementNotification({
    required String groupId,
    required String senderName,
    required String targetUserId,
    required String message,
  }) async {
    final title = '격려 메시지';
    final notificationMessage = '$senderName님이 격려 메시지를 보냈습니다: $message';
    
    await _sendNotificationToUsers(
      userIds: [targetUserId],
      groupId: groupId,
      type: GroupNotificationType.encouragementMessage,
      title: title,
      message: notificationMessage,
      data: {
        'sender_name': senderName,
        'encouragement_message': message,
        'action': 'view_group',
      },
    );
  }

  /// Send notification for new comment
  Future<void> sendNewCommentNotification({
    required String groupId,
    required String postId,
    required String commenterName,
    required String postTitle,
    required String postAuthorId,
  }) async {
    final title = '새 댓글';
    final message = '$commenterName님이 "$postTitle" 게시글에 댓글을 달았습니다';
    
    await _sendNotificationToUsers(
      userIds: [postAuthorId],
      groupId: groupId,
      type: GroupNotificationType.newComment,
      title: title,
      message: message,
      data: {
        'post_id': postId,
        'commenter_name': commenterName,
        'post_title': postTitle,
        'action': 'view_post',
      },
    );
  }

  /// Send notification for post like
  Future<void> sendPostLikedNotification({
    required String groupId,
    required String postId,
    required String likerName,
    required String postTitle,
    required String postAuthorId,
  }) async {
    final title = '게시글 좋아요';
    final message = '$likerName님이 "$postTitle" 게시글을 좋아합니다';
    
    await _sendNotificationToUsers(
      userIds: [postAuthorId],
      groupId: groupId,
      type: GroupNotificationType.postLiked,
      title: title,
      message: message,
      data: {
        'post_id': postId,
        'liker_name': likerName,
        'post_title': postTitle,
        'action': 'view_post',
      },
    );
  }

  /// Send notification for mention
  Future<void> sendMentionNotification({
    required String groupId,
    required String mentionerName,
    required String mentionedUserId,
    required String content,
    String? postId,
    String? commentId,
  }) async {
    final title = '멘션';
    final message = '$mentionerName님이 회원님을 언급했습니다';
    
    await _sendNotificationToUsers(
      userIds: [mentionedUserId],
      groupId: groupId,
      type: GroupNotificationType.mentioned,
      title: title,
      message: message,
      data: {
        'mentioner_name': mentionerName,
        'content': content,
        'post_id': postId,
        'comment_id': commentId,
        'action': postId != null ? 'view_post' : 'view_group',
      },
    );
  }

  /// Send notification for chat message
  Future<void> sendChatMessageNotification({
    required String groupId,
    required String senderName,
    required String message,
    required List<String> memberIds,
  }) async {
    final title = '새 메시지';
    final notificationMessage = '$senderName: $message';
    
    await _sendNotificationToUsers(
      userIds: memberIds,
      groupId: groupId,
      type: GroupNotificationType.chatMessage,
      title: title,
      message: notificationMessage,
      data: {
        'sender_name': senderName,
        'chat_message': message,
        'action': 'view_chat',
      },
    );
  }

  /// Get user's notifications
  Future<List<GroupNotification>> getUserNotifications({
    int limit = 50,
    int offset = 0,
    bool unreadOnly = false,
  }) async {
    if (_currentUserId == null) return [];

    try {
      var query = _supabase
          .from('group_notifications')
          .select('*')
          .eq('user_id', _currentUserId!);

      if (unreadOnly) {
        query = query.eq('is_read', false);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      return (response as List)
          .map((json) => GroupNotification.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching user notifications: $e');
      return [];
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    if (_currentUserId == null) return;

    try {
      await _supabase
          .from('group_notifications')
          .update({'is_read': true})
          .eq('id', notificationId)
          .eq('user_id', _currentUserId!);
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    if (_currentUserId == null) return;

    try {
      await _supabase
          .from('group_notifications')
          .update({'is_read': true})
          .eq('user_id', _currentUserId!)
          .eq('is_read', false);
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  /// Get unread notification count
  Future<int> getUnreadNotificationCount() async {
    if (_currentUserId == null) return 0;

    try {
      final response = await _supabase
          .from('group_notifications')
          .select('id')
          .eq('user_id', _currentUserId!)
          .eq('is_read', false);

      return (response as List).length;
    } catch (e) {
      print('Error getting unread notification count: $e');
      return 0;
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    if (_currentUserId == null) return;

    try {
      await _supabase
          .from('group_notifications')
          .delete()
          .eq('id', notificationId)
          .eq('user_id', _currentUserId!);
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  /// Send notification to multiple users
  Future<void> _sendNotificationToUsers({
    required List<String> userIds,
    required String groupId,
    required GroupNotificationType type,
    required String title,
    required String message,
    required Map<String, dynamic> data,
  }) async {
    if (userIds.isEmpty) return;

    try {
      final notifications = userIds.map((userId) => {
        'user_id': userId,
        'group_id': groupId,
        'notification_type': type.name,
        'title': title,
        'message': message,
        'data': data,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'is_read': false,
      }).toList();

      await _supabase
          .from('group_notifications')
          .insert(notifications);
    } catch (e) {
      print('Error sending notifications: $e');
    }
  }

  /// Show local notification (for foreground notifications)
  void _showLocalNotification(GroupNotification notification) {
    // This would integrate with flutter_local_notifications or similar
    // For now, just print to console
    if (kDebugMode) {
      print('Local Notification: ${notification.title} - ${notification.message}');
    }
    
    // TODO: Implement actual local notification display
    // This could show a banner, dialog, or system notification
    // depending on the platform and app state
  }

  /// Dispose of the service
  void dispose() {
    _notificationController.close();
  }
}