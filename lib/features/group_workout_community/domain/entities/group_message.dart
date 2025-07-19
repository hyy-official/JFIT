import 'package:equatable/equatable.dart';

class GroupMessage extends Equatable {
  final String id;
  final String groupId;
  final String senderId;
  final String senderUsername;
  final String? senderProfileImageUrl;
  final String messageText;
  final MessageType messageType;
  final String? replyToMessageId;
  final GroupMessage? replyToMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final Map<String, List<String>> reactions; // reaction -> list of user IDs
  final MessageStatus status;

  const GroupMessage({
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
    this.isDeleted = false,
    this.reactions = const {},
    this.status = MessageStatus.sent,
  });

  @override
  List<Object?> get props => [
        id,
        groupId,
        senderId,
        senderUsername,
        senderProfileImageUrl,
        messageText,
        messageType,
        replyToMessageId,
        replyToMessage,
        createdAt,
        updatedAt,
        isDeleted,
        reactions,
        status,
      ];

  GroupMessage copyWith({
    String? id,
    String? groupId,
    String? senderId,
    String? senderUsername,
    String? senderProfileImageUrl,
    String? messageText,
    MessageType? messageType,
    String? replyToMessageId,
    GroupMessage? replyToMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    Map<String, List<String>>? reactions,
    MessageStatus? status,
  }) {
    return GroupMessage(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      senderId: senderId ?? this.senderId,
      senderUsername: senderUsername ?? this.senderUsername,
      senderProfileImageUrl: senderProfileImageUrl ?? this.senderProfileImageUrl,
      messageText: messageText ?? this.messageText,
      messageType: messageType ?? this.messageType,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToMessage: replyToMessage ?? this.replyToMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      reactions: reactions ?? this.reactions,
      status: status ?? this.status,
    );
  }

  bool get isFromCurrentUser => false; // This will be determined in the UI layer

  bool get hasReactions => reactions.isNotEmpty;

  int get totalReactions => reactions.values.fold(0, (sum, users) => sum + users.length);

  bool hasReactionFromUser(String userId, String reaction) {
    return reactions[reaction]?.contains(userId) ?? false;
  }

  List<String> get allReactionTypes => reactions.keys.toList();
}

enum MessageType {
  text,
  image,
  workoutShare,
  achievement,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

extension MessageTypeExtension on MessageType {
  String get displayName {
    switch (this) {
      case MessageType.text:
        return 'Text';
      case MessageType.image:
        return 'Image';
      case MessageType.workoutShare:
        return 'Workout Share';
      case MessageType.achievement:
        return 'Achievement';
    }
  }

  bool get isMedia => this == MessageType.image;
  bool get isWorkoutShare => this == MessageType.workoutShare;
  bool get isAchievement => this == MessageType.achievement;
}