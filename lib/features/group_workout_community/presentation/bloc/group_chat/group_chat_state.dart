import 'package:equatable/equatable.dart';
import '../../../domain/entities/group_message.dart';

abstract class GroupChatState extends Equatable {
  const GroupChatState();

  @override
  List<Object?> get props => [];
}

class GroupChatInitial extends GroupChatState {}

class GroupChatLoading extends GroupChatState {}

class GroupChatLoaded extends GroupChatState {
  final List<GroupMessage> messages;
  final bool hasMoreMessages;
  final List<TypingUser> typingUsers;
  final bool isLoadingMore;

  const GroupChatLoaded({
    required this.messages,
    this.hasMoreMessages = true,
    this.typingUsers = const [],
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [messages, hasMoreMessages, typingUsers, isLoadingMore];

  GroupChatLoaded copyWith({
    List<GroupMessage>? messages,
    bool? hasMoreMessages,
    List<TypingUser>? typingUsers,
    bool? isLoadingMore,
  }) {
    return GroupChatLoaded(
      messages: messages ?? this.messages,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      typingUsers: typingUsers ?? this.typingUsers,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class GroupChatError extends GroupChatState {
  final String message;

  const GroupChatError({required this.message});

  @override
  List<Object?> get props => [message];
}

class MessageSending extends GroupChatState {
  final List<GroupMessage> messages;
  final GroupMessage pendingMessage;

  const MessageSending({
    required this.messages,
    required this.pendingMessage,
  });

  @override
  List<Object?> get props => [messages, pendingMessage];
}

class MessageSent extends GroupChatState {
  final List<GroupMessage> messages;

  const MessageSent({required this.messages});

  @override
  List<Object?> get props => [messages];
}

class MessageSendError extends GroupChatState {
  final String error;
  final List<GroupMessage> messages;

  const MessageSendError({
    required this.error,
    required this.messages,
  });

  @override
  List<Object?> get props => [error, messages];
}

class TypingUser extends Equatable {
  final String userId;
  final String username;
  final DateTime lastTypingAt;

  const TypingUser({
    required this.userId,
    required this.username,
    required this.lastTypingAt,
  });

  @override
  List<Object?> get props => [userId, username, lastTypingAt];

  bool get isRecentlyTyping {
    return DateTime.now().difference(lastTypingAt).inSeconds < 5;
  }
}