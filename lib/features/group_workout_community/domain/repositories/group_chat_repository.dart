import 'package:dartz/dartz.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/core/interfaces/base_repository.dart';
import '../entities/group_message.dart';

/// Request models for group chat operations
class SendMessageRequest {
  final String groupId;
  final String senderId;
  final String messageText;
  final MessageType messageType;
  final String? replyToMessageId;
  final Map<String, dynamic>? metadata;

  const SendMessageRequest({
    required this.groupId,
    required this.senderId,
    required this.messageText,
    required this.messageType,
    this.replyToMessageId,
    this.metadata,
  });
}

class UpdateMessageRequest {
  final String messageId;
  final String? messageText;
  final bool? isDeleted;

  const UpdateMessageRequest({
    required this.messageId,
    this.messageText,
    this.isDeleted,
  });
}

class MessageReactionRequest {
  final String messageId;
  final String userId;
  final String reaction;

  const MessageReactionRequest({
    required this.messageId,
    required this.userId,
    required this.reaction,
  });
}

/// Repository interface for group chat operations
/// Handles message sending, receiving, and real-time updates
abstract class GroupChatRepository extends BaseRepository {
  /// Get chat messages for a specific group
  /// Returns messages ordered by creation time (newest first)
  Future<Either<Failure, List<GroupMessage>>> getGroupMessages(
    String groupId, {
    int limit = 50,
    int offset = 0,
    DateTime? before,
    DateTime? after,
  });

  /// Send a new message to a group
  /// Returns the created message with server-generated ID
  Future<Either<Failure, GroupMessage>> sendMessage(SendMessageRequest request);

  /// Update an existing message (edit or delete)
  /// Only the sender can update their own messages
  Future<Either<Failure, GroupMessage>> updateMessage(
    UpdateMessageRequest request,
    String userId,
  );

  /// Delete a message
  /// Soft delete - marks message as deleted but preserves data
  Future<Either<Failure, void>> deleteMessage(String messageId, String userId);

  /// Add a reaction to a message
  /// If user already reacted with same emoji, removes the reaction
  Future<Either<Failure, void>> addMessageReaction(MessageReactionRequest request);

  /// Remove a reaction from a message
  Future<Either<Failure, void>> removeMessageReaction(MessageReactionRequest request);

  /// Get message reactions for a specific message
  /// Returns map of reaction emoji to list of user IDs
  Future<Either<Failure, Map<String, List<String>>>> getMessageReactions(String messageId);

  /// Get a specific message by ID
  /// Used for reply context and message details
  Future<Either<Failure, GroupMessage?>> getMessageById(String messageId);

  /// Search messages in a group
  /// Supports text search and filtering by message type
  Future<Either<Failure, List<GroupMessage>>> searchMessages(
    String groupId,
    String query, {
    MessageType? messageType,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 20,
  });

  /// Get message thread (replies to a specific message)
  /// Returns all messages that reply to the given message ID
  Future<Either<Failure, List<GroupMessage>>> getMessageThread(String messageId);

  /// Mark messages as read for a user
  /// Updates read status for notification purposes
  Future<Either<Failure, void>> markMessagesAsRead(
    String groupId,
    String userId,
    List<String> messageIds,
  );

  /// Get unread message count for a user in a group
  /// Used for notification badges
  Future<Either<Failure, int>> getUnreadMessageCount(String groupId, String userId);

  /// Get recent messages across all user's groups
  /// Used for notification and activity feeds
  Future<Either<Failure, List<GroupMessage>>> getRecentMessages(
    String userId, {
    int limit = 20,
    int hours = 24,
  });

  /// Send typing indicator
  /// Notifies other group members that user is typing
  Future<Either<Failure, void>> sendTypingIndicator(
    String groupId,
    String userId,
    bool isTyping,
  );

  /// Get currently typing users in a group
  /// Returns list of users who are currently typing
  Future<Either<Failure, List<Map<String, dynamic>>>> getTypingUsers(String groupId);

  /// Upload and send image message
  /// Handles image upload and creates message with image URL
  Future<Either<Failure, GroupMessage>> sendImageMessage(
    String groupId,
    String senderId,
    String imagePath,
    String? caption,
  );

  /// Share workout as a message
  /// Creates a special message type for workout sharing
  Future<Either<Failure, GroupMessage>> shareWorkout(
    String groupId,
    String senderId,
    String workoutId,
    String workoutDescription,
  );

  /// Get message statistics for a group
  /// Returns message counts, active users, etc.
  Future<Either<Failure, Map<String, dynamic>>> getGroupChatStats(
    String groupId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Pin a message in the group chat
  /// Only admins/moderators can pin messages
  Future<Either<Failure, void>> pinMessage(
    String messageId,
    String userId,
  );

  /// Unpin a message in the group chat
  Future<Either<Failure, void>> unpinMessage(
    String messageId,
    String userId,
  );

  /// Get pinned messages for a group
  /// Returns list of pinned messages ordered by pin date
  Future<Either<Failure, List<GroupMessage>>> getPinnedMessages(String groupId);

  /// Report a message for inappropriate content
  /// Creates a content report for moderation
  Future<Either<Failure, void>> reportMessage(
    String messageId,
    String reporterId,
    String reason,
    String? description,
  );

  /// Get message history for a specific user
  /// Used for user activity tracking and analytics
  Future<Either<Failure, List<GroupMessage>>> getUserMessageHistory(
    String userId,
    String groupId, {
    int limit = 100,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Bulk delete messages (admin only)
  /// Allows admins to delete multiple messages at once
  Future<Either<Failure, void>> bulkDeleteMessages(
    List<String> messageIds,
    String adminId,
  );

  /// Get message delivery status
  /// Returns delivery and read status for sent messages
  Future<Either<Failure, Map<String, dynamic>>> getMessageStatus(String messageId);

  /// Subscribe to real-time message updates for a group
  /// Returns a stream of new messages and updates
  Stream<GroupMessage> subscribeToMessages(String groupId);

  /// Subscribe to typing indicators for a group
  /// Returns a stream of typing status updates
  Stream<Map<String, dynamic>> subscribeToTypingIndicators(String groupId);

  /// Get message mentions for a user
  /// Returns messages where the user was mentioned
  Future<Either<Failure, List<GroupMessage>>> getUserMentions(
    String userId, {
    String? groupId,
    bool unreadOnly = false,
    int limit = 20,
  });

  /// Export chat history for a group
  /// Generates exportable chat data for backup or analysis
  Future<Either<Failure, Map<String, dynamic>>> exportChatHistory(
    String groupId, {
    DateTime? startDate,
    DateTime? endDate,
    String format = 'json',
  });
}