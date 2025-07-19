import 'package:equatable/equatable.dart';

abstract class GroupChatEvent extends Equatable {
  const GroupChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatMessages extends GroupChatEvent {
  final String groupId;
  final int limit;
  final int offset;

  const LoadChatMessages({
    required this.groupId,
    this.limit = 50,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [groupId, limit, offset];
}

class SendMessage extends GroupChatEvent {
  final String groupId;
  final String messageText;
  final String messageType;
  final String? replyToMessageId;

  const SendMessage({
    required this.groupId,
    required this.messageText,
    this.messageType = 'text',
    this.replyToMessageId,
  });

  @override
  List<Object?> get props => [groupId, messageText, messageType, replyToMessageId];
}

class SendImageMessage extends GroupChatEvent {
  final String groupId;
  final String imagePath;
  final String? caption;

  const SendImageMessage({
    required this.groupId,
    required this.imagePath,
    this.caption,
  });

  @override
  List<Object?> get props => [groupId, imagePath, caption];
}

class ShareWorkout extends GroupChatEvent {
  final String groupId;
  final String workoutSessionId;
  final String workoutDescription;

  const ShareWorkout({
    required this.groupId,
    required this.workoutSessionId,
    required this.workoutDescription,
  });

  @override
  List<Object?> get props => [groupId, workoutSessionId, workoutDescription];
}

class StartTyping extends GroupChatEvent {
  final String groupId;

  const StartTyping({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

class StopTyping extends GroupChatEvent {
  final String groupId;

  const StopTyping({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

class AddMessageReaction extends GroupChatEvent {
  final String messageId;
  final String reaction;

  const AddMessageReaction({
    required this.messageId,
    required this.reaction,
  });

  @override
  List<Object?> get props => [messageId, reaction];
}

class RemoveMessageReaction extends GroupChatEvent {
  final String messageId;
  final String reaction;

  const RemoveMessageReaction({
    required this.messageId,
    required this.reaction,
  });

  @override
  List<Object?> get props => [messageId, reaction];
}

class DeleteMessage extends GroupChatEvent {
  final String messageId;

  const DeleteMessage({required this.messageId});

  @override
  List<Object?> get props => [messageId];
}

class SubscribeToMessages extends GroupChatEvent {
  final String groupId;

  const SubscribeToMessages({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

class UnsubscribeFromMessages extends GroupChatEvent {
  const UnsubscribeFromMessages();
}

class MessageReceived extends GroupChatEvent {
  final Map<String, dynamic> messageData;

  const MessageReceived({required this.messageData});

  @override
  List<Object?> get props => [messageData];
}

class TypingStatusChanged extends GroupChatEvent {
  final String userId;
  final String username;
  final bool isTyping;

  const TypingStatusChanged({
    required this.userId,
    required this.username,
    required this.isTyping,
  });

  @override
  List<Object?> get props => [userId, username, isTyping];
}