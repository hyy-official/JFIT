import '../../domain/entities/group_message.dart';

/// 답글 대상 메시지 정보
class ReplyToMessage {
  final String id;
  final String messageText;
  final String senderUsername;

  const ReplyToMessage({
    required this.id,
    required this.messageText,
    required this.senderUsername,
  });
}

/// Data model for GroupMessage entity
class GroupMessageModel {
  final String id;
  final String groupId;
  final String senderId;
  final String senderUsername;
  final String? senderProfileImageUrl;
  final String messageText;
  final String messageType;
  final String? replyToMessageId;
  final Map<String, dynamic>? replyToMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final Map<String, List<String>> reactions;

  const GroupMessageModel({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.senderUsername,
    this.senderProfileImageUrl,
    required this.messageText,
    required this.messageType,
    this.replyToMessageId,
    this.replyToMessage,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    this.reactions = const {},
  });

  factory GroupMessageModel.fromJson(Map<String, dynamic> json) {
    // Parse sender information
    final senderData = json['sender'] as Map<String, dynamic>?;
    final senderUsername = senderData?['username'] as String? ?? 'Unknown User';
    final senderProfileImageUrl = senderData?['profile_image_url'] as String?;

    // Parse reply-to message information
    final replyToData = json['reply_to'] as Map<String, dynamic>?;
    Map<String, dynamic>? replyToMessage;
    if (replyToData != null) {
      final replySenderData = replyToData['sender'] as Map<String, dynamic>?;
      replyToMessage = {
        'id': replyToData['id'],
        'message_text': replyToData['message_text'],
        'sender_username': replySenderData?['username'] ?? 'Unknown User',
      };
    }

    // Parse reactions (this would come from a separate query or join)
    final reactions = <String, List<String>>{};
    // Note: In a real implementation, reactions would be loaded separately
    // or joined in the query

    return GroupMessageModel(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      senderId: json['sender_id'] as String,
      senderUsername: senderUsername,
      senderProfileImageUrl: senderProfileImageUrl,
      messageText: json['message_text'] as String,
      messageType: json['message_type'] as String,
      replyToMessageId: json['reply_to_message_id'] as String?,
      replyToMessage: replyToMessage,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isDeleted: json['is_deleted'] as bool? ?? false,
      reactions: reactions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'sender_id': senderId,
      'message_text': messageText,
      'message_type': messageType,
      'reply_to_message_id': replyToMessageId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_deleted': isDeleted,
    };
  }

  GroupMessage toEntity() {
    return GroupMessage(
      id: id,
      groupId: groupId,
      senderId: senderId,
      senderUsername: senderUsername,
      senderProfileImageUrl: senderProfileImageUrl,
      messageText: messageText,
      messageType: _stringToMessageType(messageType),
      replyToMessageId: replyToMessageId,
      replyToMessage: replyToMessage != null ? GroupMessage(
        id: replyToMessage!['id'] as String,
        groupId: groupId,
        senderId: '',
        senderUsername: replyToMessage!['sender_username'] as String,
        messageText: replyToMessage!['message_text'] as String,
        messageType: MessageType.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDeleted: false,
        reactions: const {},
        status: MessageStatus.sent,
      ) : null,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDeleted: isDeleted,
      reactions: reactions,
      status: MessageStatus.sent, // Default to sent for existing messages
    );
  }

  static GroupMessageModel fromEntity(GroupMessage entity) {
    return GroupMessageModel(
      id: entity.id,
      groupId: entity.groupId,
      senderId: entity.senderId,
      senderUsername: entity.senderUsername,
      senderProfileImageUrl: entity.senderProfileImageUrl,
      messageText: entity.messageText,
      messageType: _messageTypeToString(entity.messageType),
      replyToMessageId: entity.replyToMessageId,
      replyToMessage: entity.replyToMessage != null ? {
        'id': entity.replyToMessage!.id,
        'message_text': entity.replyToMessage!.messageText,
        'sender_username': entity.replyToMessage!.senderUsername,
      } : null,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isDeleted: entity.isDeleted,
      reactions: entity.reactions,
    );
  }

  static MessageType _stringToMessageType(String type) {
    switch (type) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'workout_share':
        return MessageType.workoutShare;
      case 'achievement':
        return MessageType.achievement;
      default:
        return MessageType.text;
    }
  }

  static String _messageTypeToString(MessageType type) {
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
}