import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:jfit/core/error/failures.dart';
import 'package:jfit/core/interfaces/base_repository.dart';
import '../../domain/repositories/group_chat_repository.dart';
import '../../domain/entities/group_message.dart';
import '../models/group_message_model.dart';

/// Implementation of GroupChatRepository using Supabase as the data source
class GroupChatRepositoryImpl extends GroupChatRepository with BaseRepositoryMixin {
  final SupabaseClient _supabaseClient;
  final Uuid _uuid = const Uuid();

  GroupChatRepositoryImpl({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  Future<Either<Failure, List<GroupMessage>>> getGroupMessages(
    String groupId, {
    int limit = 50,
    int offset = 0,
    DateTime? before,
    DateTime? after,
  }) async {
    return safeCall(() async {
      var query = _supabaseClient
          .from('group_messages')
          .select('''
            *,
            sender:user_profiles!sender_id(username, profile_image_url),
            reply_to:group_messages!reply_to_message_id(
              id,
              message_text,
              sender:user_profiles!sender_id(username)
            )
          ''')
          .eq('group_id', groupId)
          .eq('is_deleted', false);

      if (before != null) {
        query = query.lt('created_at', before.toIso8601String());
      }
      if (after != null) {
        query = query.gt('created_at', after.toIso8601String());
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List).map((json) {
        return GroupMessageModel.fromJson(json).toEntity();
      }).toList();
    });
  }

  @override
  Future<Either<Failure, GroupMessage>> sendMessage(SendMessageRequest request) async {
    return safeCall(() async {
      final messageId = _uuid.v4();
      final now = DateTime.now();

      final messageData = {
        'id': messageId,
        'group_id': request.groupId,
        'sender_id': request.senderId,
        'message_text': request.messageText,
        'message_type': _messageTypeToString(request.messageType),
        'reply_to_message_id': request.replyToMessageId,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'is_deleted': false,
      };

      await _supabaseClient
          .from('group_messages')
          .insert(messageData);

      // Get the created message with sender info
      final response = await _supabaseClient
          .from('group_messages')
          .select('''
            *,
            sender:user_profiles!sender_id(username, profile_image_url),
            reply_to:group_messages!reply_to_message_id(
              id,
              message_text,
              sender:user_profiles!sender_id(username)
            )
          ''')
          .eq('id', messageId)
          .single();

      return GroupMessageModel.fromJson(response).toEntity();
    });
  }

  @override
  Future<Either<Failure, GroupMessage>> updateMessage(
    UpdateMessageRequest request,
    String userId,
  ) async {
    return safeCall(() async {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (request.messageText != null) {
        updateData['message_text'] = request.messageText;
      }
      if (request.isDeleted != null) {
        updateData['is_deleted'] = request.isDeleted;
      }

      await _supabaseClient
          .from('group_messages')
          .update(updateData)
          .eq('id', request.messageId)
          .eq('sender_id', userId); // Only sender can update

      // Get the updated message
      final response = await _supabaseClient
          .from('group_messages')
          .select('''
            *,
            sender:user_profiles!sender_id(username, profile_image_url),
            reply_to:group_messages!reply_to_message_id(
              id,
              message_text,
              sender:user_profiles!sender_id(username)
            )
          ''')
          .eq('id', request.messageId)
          .single();

      return GroupMessageModel.fromJson(response).toEntity();
    });
  }

  @override
  Future<Either<Failure, void>> deleteMessage(String messageId, String userId) async {
    return safeCall(() async {
      await _supabaseClient
          .from('group_messages')
          .update({
            'is_deleted': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', messageId)
          .eq('sender_id', userId); // Only sender can delete
    });
  }

  @override
  Future<Either<Failure, void>> addMessageReaction(MessageReactionRequest request) async {
    return safeCall(() async {
      // Check if reaction already exists
      final existingReaction = await _supabaseClient
          .from('message_reactions')
          .select('id')
          .eq('message_id', request.messageId)
          .eq('user_id', request.userId)
          .eq('reaction', request.reaction)
          .maybeSingle();

      if (existingReaction == null) {
        // Add new reaction
        await _supabaseClient
            .from('message_reactions')
            .insert({
              'id': _uuid.v4(),
              'message_id': request.messageId,
              'user_id': request.userId,
              'reaction': request.reaction,
              'created_at': DateTime.now().toIso8601String(),
            });
      }
    });
  }

  @override
  Future<Either<Failure, void>> removeMessageReaction(MessageReactionRequest request) async {
    return safeCall(() async {
      await _supabaseClient
          .from('message_reactions')
          .delete()
          .eq('message_id', request.messageId)
          .eq('user_id', request.userId)
          .eq('reaction', request.reaction);
    });
  }

  @override
  Future<Either<Failure, Map<String, List<String>>>> getMessageReactions(String messageId) async {
    return safeCall(() async {
      final response = await _supabaseClient
          .from('message_reactions')
          .select('reaction, user_id')
          .eq('message_id', messageId);

      final reactions = <String, List<String>>{};
      for (final reaction in response as List) {
        final emoji = reaction['reaction'] as String;
        final userId = reaction['user_id'] as String;
        
        if (reactions[emoji] == null) {
          reactions[emoji] = [];
        }
        reactions[emoji]!.add(userId);
      }

      return reactions;
    });
  }

  @override
  Future<Either<Failure, GroupMessage?>> getMessageById(String messageId) async {
    return safeCall(() async {
      try {
        final response = await _supabaseClient
            .from('group_messages')
            .select('''
              *,
              sender:user_profiles!sender_id(username, profile_image_url),
              reply_to:group_messages!reply_to_message_id(
                id,
                message_text,
                sender:user_profiles!sender_id(username)
              )
            ''')
            .eq('id', messageId)
            .single();

        return GroupMessageModel.fromJson(response).toEntity();
      } catch (e) {
        if (e is PostgrestException && (e.code == 'PGRST116' || e.message.contains('0 rows'))) {
          return null;
        }
        rethrow;
      }
    });
  }

  @override
  Future<Either<Failure, List<GroupMessage>>> searchMessages(
    String groupId,
    String query, {
    MessageType? messageType,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
  }) async {
    return safeCall(() async {
      var supabaseQuery = _supabaseClient
          .from('group_messages')
          .select('''
            *,
            sender:user_profiles!sender_id(username, profile_image_url),
            reply_to:group_messages!reply_to_message_id(
              id,
              message_text,
              sender:user_profiles!sender_id(username)
            )
          ''')
          .eq('group_id', groupId)
          .eq('is_deleted', false)
          .ilike('message_text', '%$query%');

      if (messageType != null) {
        supabaseQuery = supabaseQuery.eq('message_type', _messageTypeToString(messageType));
      }
      if (startDate != null) {
        supabaseQuery = supabaseQuery.gte('created_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        supabaseQuery = supabaseQuery.lte('created_at', endDate.toIso8601String());
      }

      final response = await supabaseQuery
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List).map((json) {
        return GroupMessageModel.fromJson(json).toEntity();
      }).toList();
    });
  }

  @override
  Future<Either<Failure, List<GroupMessage>>> getMessageThread(String messageId) async {
    return safeCall(() async {
      final response = await _supabaseClient
          .from('group_messages')
          .select('''
            *,
            sender:user_profiles!sender_id(username, profile_image_url),
            reply_to:group_messages!reply_to_message_id(
              id,
              message_text,
              sender:user_profiles!sender_id(username)
            )
          ''')
          .eq('reply_to_message_id', messageId)
          .eq('is_deleted', false)
          .order('created_at', ascending: true);

      return (response as List).map((json) {
        return GroupMessageModel.fromJson(json).toEntity();
      }).toList();
    });
  }

  @override
  Future<Either<Failure, void>> markMessagesAsRead(
    String groupId,
    String userId,
    List<String> messageIds,
  ) async {
    return safeCall(() async {
      // This would typically be implemented with a separate read_receipts table
      // For now, we'll implement a simple version
      for (final messageId in messageIds) {
        await _supabaseClient
            .from('message_read_receipts')
            .upsert({
              'id': _uuid.v4(),
              'message_id': messageId,
              'user_id': userId,
              'read_at': DateTime.now().toIso8601String(),
            }, onConflict: 'message_id,user_id');
      }
    });
  }

  @override
  Future<Either<Failure, int>> getUnreadMessageCount(String groupId, String userId) async {
    return safeCall(() async {
      // Get all messages in the group
      final allMessages = await _supabaseClient
          .from('group_messages')
          .select('id')
          .eq('group_id', groupId)
          .eq('is_deleted', false);

      // Get read messages for this user
      final readMessages = await _supabaseClient
          .from('message_read_receipts')
          .select('message_id')
          .eq('user_id', userId);

      final readMessageIds = (readMessages as List)
          .map((r) => r['message_id'] as String)
          .toSet();

      final totalMessages = (allMessages as List).length;
      final readCount = readMessageIds.length;

      return totalMessages - readCount;
    });
  }

  @override
  Future<Either<Failure, void>> sendTypingIndicator(
    String groupId,
    String userId,
    bool isTyping,
  ) async {
    return safeCall(() async {
      if (isTyping) {
        await _supabaseClient
            .from('typing_indicators')
            .upsert({
              'group_id': groupId,
              'user_id': userId,
              'is_typing': true,
              'last_typing_at': DateTime.now().toIso8601String(),
            }, onConflict: 'group_id,user_id');
      } else {
        await _supabaseClient
            .from('typing_indicators')
            .delete()
            .eq('group_id', groupId)
            .eq('user_id', userId);
      }
    });
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getTypingUsers(String groupId) async {
    return safeCall(() async {
      final response = await _supabaseClient
          .from('typing_indicators')
          .select('''
            user_id,
            last_typing_at,
            user_profiles!user_id(username)
          ''')
          .eq('group_id', groupId)
          .eq('is_typing', true)
          .gte('last_typing_at', DateTime.now().subtract(const Duration(seconds: 5)).toIso8601String());

      return (response as List).map((item) => {
        'user_id': item['user_id'],
        'username': item['user_profiles']['username'],
        'last_typing_at': item['last_typing_at'],
      }).toList();
    });
  }

  @override
  Stream<GroupMessage> subscribeToMessages(String groupId) {
    final controller = StreamController<GroupMessage>();

    final subscription = _supabaseClient
        .from('group_messages')
        .stream(primaryKey: ['id'])
        .listen((data) {
          for (final item in data) {
            try {
              final message = GroupMessageModel.fromJson(item).toEntity();
              controller.add(message);
            } catch (e) {
              // Log error but continue processing other messages
              print('Error parsing message: $e');
            }
          }
        });

    controller.onCancel = () {
      subscription.cancel();
    };

    return controller.stream;
  }

  @override
  Stream<Map<String, dynamic>> subscribeToTypingIndicators(String groupId) {
    final controller = StreamController<Map<String, dynamic>>();

    final subscription = _supabaseClient
        .from('typing_indicators')
        .stream(primaryKey: ['group_id', 'user_id'])
        .eq('group_id', groupId)
        .listen((data) {
          for (final item in data) {
            controller.add({
              'user_id': item['user_id'],
              'is_typing': item['is_typing'],
              'last_typing_at': item['last_typing_at'],
            });
          }
        });

    controller.onCancel = () {
      subscription.cancel();
    };

    return controller.stream;
  }

  // Helper method to convert MessageType to string
  String _messageTypeToString(MessageType type) {
    switch (type) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      case MessageType.workoutShare:
        return 'workout_share';
      case MessageType.achievement:
        return 'achievement';
    }
  }

  // Stub implementations for remaining abstract methods
  @override
  Future<Either<Failure, List<GroupMessage>>> getRecentMessages(String userId, {int limit = 20, int hours = 24}) async {
    return safeCall(() async => <GroupMessage>[]);
  }

  @override
  Future<Either<Failure, GroupMessage>> sendImageMessage(String groupId, String senderId, String imagePath, String? caption) async {
    return safeCall(() async {
      // This would involve uploading the image first, then creating a message
      throw UnimplementedError('Image upload not implemented');
    });
  }

  @override
  Future<Either<Failure, GroupMessage>> shareWorkout(String groupId, String senderId, String workoutId, String workoutDescription) async {
    return safeCall(() async {
      return sendMessage(SendMessageRequest(
        groupId: groupId,
        senderId: senderId,
        messageText: workoutDescription,
        messageType: MessageType.workoutShare,
        metadata: {'workout_id': workoutId},
      )).then((result) => result.fold((l) => throw Exception(l.message), (r) => r));
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getGroupChatStats(String groupId, {DateTime? startDate, DateTime? endDate}) async {
    return safeCall(() async => <String, dynamic>{});
  }

  @override
  Future<Either<Failure, void>> pinMessage(String messageId, String userId) async {
    return safeCall(() async {});
  }

  @override
  Future<Either<Failure, void>> unpinMessage(String messageId, String userId) async {
    return safeCall(() async {});
  }

  @override
  Future<Either<Failure, List<GroupMessage>>> getPinnedMessages(String groupId) async {
    return safeCall(() async => <GroupMessage>[]);
  }

  @override
  Future<Either<Failure, void>> reportMessage(String messageId, String reporterId, String reason, String? description) async {
    return safeCall(() async {});
  }

  @override
  Future<Either<Failure, List<GroupMessage>>> getUserMessageHistory(String userId, String groupId, {int limit = 100, DateTime? startDate, DateTime? endDate}) async {
    return safeCall(() async => <GroupMessage>[]);
  }

  @override
  Future<Either<Failure, void>> bulkDeleteMessages(List<String> messageIds, String adminId) async {
    return safeCall(() async {});
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMessageStatus(String messageId) async {
    return safeCall(() async => <String, dynamic>{});
  }

  @override
  Future<Either<Failure, List<GroupMessage>>> getUserMentions(String userId, {String? groupId, bool unreadOnly = false, int limit = 20}) async {
    return safeCall(() async => <GroupMessage>[]);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportChatHistory(String groupId, {DateTime? startDate, DateTime? endDate, String format = 'json'}) async {
    return safeCall(() async => <String, dynamic>{});
  }
}