import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/group_message.dart';
import '../../../domain/repositories/group_chat_repository.dart';
import '../../../data/models/group_message_model.dart';
import 'group_chat_event.dart';
import 'group_chat_state.dart';

@injectable
class GroupChatBloc extends Bloc<GroupChatEvent, GroupChatState> {
  final GroupChatRepository _repository;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _typingSubscription;
  Timer? _typingTimer;
  final List<GroupMessage> _messages = [];

  GroupChatBloc(this._repository) : super(GroupChatInitial()) {
    on<LoadChatMessages>(_onLoadChatMessages);
    on<SendMessage>(_onSendMessage);
    on<SendImageMessage>(_onSendImageMessage);
    on<ShareWorkout>(_onShareWorkout);
    on<StartTyping>(_onStartTyping);
    on<StopTyping>(_onStopTyping);
    on<AddMessageReaction>(_onAddMessageReaction);
    on<RemoveMessageReaction>(_onRemoveMessageReaction);
    on<DeleteMessage>(_onDeleteMessage);
    on<SubscribeToMessages>(_onSubscribeToMessages);
    on<UnsubscribeFromMessages>(_onUnsubscribeFromMessages);
    on<MessageReceived>(_onMessageReceived);
    on<TypingStatusChanged>(_onTypingStatusChanged);
  }

  Future<void> _onLoadChatMessages(
    LoadChatMessages event,
    Emitter<GroupChatState> emit,
  ) async {
    try {
      if (state is! GroupChatLoaded) {
        emit(GroupChatLoading());
      }

      final result = await _repository.getGroupMessages(
        event.groupId,
        limit: event.limit,
        offset: event.offset,
      );

      result.fold(
        (failure) => emit(GroupChatError(message: failure.message)),
        (messages) {
          _messages.clear();
          _messages.addAll(messages);

          emit(GroupChatLoaded(
            messages: List.from(_messages),
            hasMoreMessages: messages.length == event.limit,
            typingUsers: const [],
          ));
        },
      );
    } catch (e) {
      emit(GroupChatError(message: e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<GroupChatState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is! GroupChatLoaded) return;

      // Create pending message
      final pendingMessage = GroupMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        groupId: event.groupId,
        senderId: 'current_user_id', // TODO: Get from auth service
        senderUsername: 'Current User', // TODO: Get from auth service
        messageText: event.messageText,
        messageType: _stringToMessageType(event.messageType ?? 'text'),
        replyToMessageId: event.replyToMessageId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: MessageStatus.sending,
      );

      emit(MessageSending(
        messages: currentState.messages,
        pendingMessage: pendingMessage,
      ));

      // Send message via repository
      final result = await _repository.sendMessage(SendMessageRequest(
        groupId: event.groupId,
        senderId: 'current_user_id', // TODO: Get from auth service
        messageText: event.messageText,
        messageType: _stringToMessageType(event.messageType ?? 'text'),
        replyToMessageId: event.replyToMessageId,
      ));

      result.fold(
        (failure) {
          emit(MessageSendError(
            error: failure.message,
            messages: currentState.messages,
          ));
        },
        (sentMessage) {
          // Update local messages list
          _messages.insert(0, sentMessage);

          emit(GroupChatLoaded(
            messages: List.from(_messages),
            hasMoreMessages: currentState.hasMoreMessages,
            typingUsers: currentState.typingUsers,
          ));
        },
      );
    } catch (e) {
      final currentState = state;
      if (currentState is GroupChatLoaded) {
        emit(MessageSendError(
          error: e.toString(),
          messages: currentState.messages,
        ));
      }
    }
  }

  Future<void> _onSendImageMessage(
    SendImageMessage event,
    Emitter<GroupChatState> emit,
  ) async {
    // TODO: Implement image message sending
    add(SendMessage(
      groupId: event.groupId,
      messageText: '📷 Image: ${event.caption ?? 'Photo'}',
      messageType: 'image',
    ));
  }

  Future<void> _onShareWorkout(
    ShareWorkout event,
    Emitter<GroupChatState> emit,
  ) async {
    // TODO: Implement workout sharing
    add(SendMessage(
      groupId: event.groupId,
      messageText: '💪 Shared workout: ${event.workoutDescription}',
      messageType: 'workout_share',
    ));
  }

  Future<void> _onStartTyping(
    StartTyping event,
    Emitter<GroupChatState> emit,
  ) async {
    // TODO: Implement typing indicator
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), () {
      add(StopTyping(groupId: event.groupId));
    });
  }

  Future<void> _onStopTyping(
    StopTyping event,
    Emitter<GroupChatState> emit,
  ) async {
    // TODO: Implement stop typing
    _typingTimer?.cancel();
  }

  Future<void> _onAddMessageReaction(
    AddMessageReaction event,
    Emitter<GroupChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! GroupChatLoaded) return;

    // Find and update message with reaction
    final updatedMessages = currentState.messages.map((message) {
      if (message.id == event.messageId) {
        final reactions = Map<String, List<String>>.from(message.reactions);
        final currentUsers = reactions[event.reaction] ?? [];
        if (!currentUsers.contains('current_user_id')) {
          reactions[event.reaction] = [...currentUsers, 'current_user_id'];
        }
        return message.copyWith(reactions: reactions);
      }
      return message;
    }).toList();

    emit(currentState.copyWith(messages: updatedMessages));
  }

  Future<void> _onRemoveMessageReaction(
    RemoveMessageReaction event,
    Emitter<GroupChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! GroupChatLoaded) return;

    // Find and update message by removing reaction
    final updatedMessages = currentState.messages.map((message) {
      if (message.id == event.messageId) {
        final reactions = Map<String, List<String>>.from(message.reactions);
        final currentUsers = reactions[event.reaction] ?? [];
        currentUsers.remove('current_user_id');
        if (currentUsers.isEmpty) {
          reactions.remove(event.reaction);
        } else {
          reactions[event.reaction] = currentUsers;
        }
        return message.copyWith(reactions: reactions);
      }
      return message;
    }).toList();

    emit(currentState.copyWith(messages: updatedMessages));
  }

  Future<void> _onDeleteMessage(
    DeleteMessage event,
    Emitter<GroupChatState> emit,
  ) async {
    // TODO: Implement message deletion
  }

  Future<void> _onSubscribeToMessages(
    SubscribeToMessages event,
    Emitter<GroupChatState> emit,
  ) async {
    // Cancel existing subscription
    await _messageSubscription?.cancel();
    
    // Subscribe to real-time messages
    _messageSubscription = _repository.subscribeToMessages(event.groupId).listen(
      (message) {
        add(MessageReceived(messageData: {'message': message.messageText}));
      },
      onError: (error) {
        emit(GroupChatError(message: error.toString()));
      },
    );

    // Subscribe to typing indicators
    await _typingSubscription?.cancel();
    _typingSubscription = _repository.subscribeToTypingIndicators(event.groupId).listen(
      (typingData) {
        add(TypingStatusChanged(
          userId: typingData['user_id'] as String,
          username: typingData['username'] as String? ?? 'Unknown',
          isTyping: typingData['is_typing'] as bool? ?? false,
        ));
      },
    );
  }

  Future<void> _onUnsubscribeFromMessages(
    UnsubscribeFromMessages event,
    Emitter<GroupChatState> emit,
  ) async {
    await _messageSubscription?.cancel();
    _messageSubscription = null;
  }

  Future<void> _onMessageReceived(
    MessageReceived event,
    Emitter<GroupChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! GroupChatLoaded) return;

    // Convert messageData to GroupMessage
    final messageModel = GroupMessageModel.fromJson(event.messageData);
    final message = messageModel.toEntity();
    
    // Add new message to the beginning of the list
    _messages.insert(0, message);

    emit(currentState.copyWith(
      messages: List.from(_messages),
    ));
  }

  Future<void> _onTypingStatusChanged(
    TypingStatusChanged event,
    Emitter<GroupChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is! GroupChatLoaded) return;

    List<TypingUser> updatedTypingUsers = List.from(currentState.typingUsers);
    
    if (event.isTyping) {
      // Add or update typing user
      updatedTypingUsers.removeWhere((user) => user.userId == event.userId);
      updatedTypingUsers.add(TypingUser(
        userId: event.userId,
        username: event.username,
        lastTypingAt: DateTime.now(),
      ));
    } else {
      // Remove typing user
      updatedTypingUsers.removeWhere((user) => user.userId == event.userId);
    }

    emit(currentState.copyWith(typingUsers: updatedTypingUsers));
  }

  // Helper method to convert string to MessageType
  MessageType _stringToMessageType(String type) {
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

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _typingTimer?.cancel();
    return super.close();
  }
}