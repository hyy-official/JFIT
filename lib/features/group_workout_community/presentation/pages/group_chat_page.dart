import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../bloc/group_chat/group_chat_bloc.dart';
import '../bloc/group_chat/group_chat_event.dart';
import '../bloc/group_chat/group_chat_state.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/chat_input_area.dart';
import '../widgets/chat_typing_indicator.dart';
import '../widgets/chat_app_bar.dart';

class GroupChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _subscribeToMessages();
    _setupScrollListener();
  }

  void _loadMessages() {
    context.read<GroupChatBloc>().add(
          LoadChatMessages(groupId: widget.groupId),
        );
  }

  void _subscribeToMessages() {
    context.read<GroupChatBloc>().add(
          SubscribeToMessages(groupId: widget.groupId),
        );
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        // Load more messages when near bottom
        _loadMoreMessages();
      }
    });
  }

  void _loadMoreMessages() {
    final state = context.read<GroupChatBloc>().state;
    if (state is GroupChatLoaded && state.hasMoreMessages && !state.isLoadingMore) {
      context.read<GroupChatBloc>().add(
            LoadChatMessages(
              groupId: widget.groupId,
              offset: state.messages.length,
            ),
          );
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      context.read<GroupChatBloc>().add(
            SendMessage(
              groupId: widget.groupId,
              messageText: text,
            ),
          );
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onTypingChanged(String text) {
    if (text.isNotEmpty) {
      context.read<GroupChatBloc>().add(
            StartTyping(groupId: widget.groupId),
          );
    } else {
      context.read<GroupChatBloc>().add(
            StopTyping(groupId: widget.groupId),
          );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: ChatAppBar(
        groupName: widget.groupName,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: _buildChatBody(),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      appBar: ChatAppBar(
        groupName: widget.groupName,
        onBackPressed: () => Navigator.of(context).pop(),
        showMemberCount: true,
      ),
      body: _buildChatBody(),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      appBar: ChatAppBar(
        groupName: widget.groupName,
        onBackPressed: () => Navigator.of(context).pop(),
        showMemberCount: true,
        showOnlineStatus: true,
      ),
      body: Row(
        children: [
          // Chat area
          Expanded(
            flex: 3,
            child: _buildChatBody(),
          ),
          // Side panel for group info (optional)
          if (MediaQuery.of(context).size.width > 1200)
            Container(
              width: 300,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: _buildGroupInfoPanel(),
            ),
        ],
      ),
    );
  }

  Widget _buildChatBody() {
    return BlocBuilder<GroupChatBloc, GroupChatState>(
      builder: (context, state) {
        if (state is GroupChatLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is GroupChatError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load messages',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadMessages,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is GroupChatLoaded || state is MessageSending) {
          final messages = state is GroupChatLoaded 
              ? state.messages 
              : (state as MessageSending).messages;
          final typingUsers = state is GroupChatLoaded 
              ? state.typingUsers 
              : <TypingUser>[];

          return Column(
            children: [
              // Messages list
              Expanded(
                child: ChatMessageList(
                  messages: messages,
                  scrollController: _scrollController,
                  onReactionTap: (messageId, reaction) {
                    context.read<GroupChatBloc>().add(
                          AddMessageReaction(
                            messageId: messageId,
                            reaction: reaction,
                          ),
                        );
                  },
                  onReactionRemove: (messageId, reaction) {
                    context.read<GroupChatBloc>().add(
                          RemoveMessageReaction(
                            messageId: messageId,
                            reaction: reaction,
                          ),
                        );
                  },
                  pendingMessage: state is MessageSending ? state.pendingMessage : null,
                ),
              ),
              
              // Typing indicator
              if (typingUsers.isNotEmpty)
                ChatTypingIndicator(
                  typingUsers: typingUsers,
                ),
              
              // Input area
              ChatInputArea(
                controller: _messageController,
                focusNode: _messageFocusNode,
                onSendMessage: _sendMessage,
                onTypingChanged: _onTypingChanged,
                onImagePicked: (imagePath) {
                  context.read<GroupChatBloc>().add(
                        SendImageMessage(
                          groupId: widget.groupId,
                          imagePath: imagePath,
                        ),
                      );
                },
                onWorkoutShare: () {
                  // TODO: Implement workout sharing dialog
                  context.read<GroupChatBloc>().add(
                        ShareWorkout(
                          groupId: widget.groupId,
                          workoutSessionId: 'mock_session_id',
                          workoutDescription: 'Today\'s workout',
                        ),
                      );
                },
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildGroupInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Group Info',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          // TODO: Add group member list, shared files, etc.
          const Text('Group members and shared content will be shown here'),
        ],
      ),
    );
  }
}