import 'package:flutter/material.dart';
import '../../../../core/utils/breakpoint_utils.dart';
import '../../domain/entities/group_message.dart';
import 'chat_message_bubble.dart';

class ChatMessageList extends StatelessWidget {
  final List<GroupMessage> messages;
  final ScrollController scrollController;
  final Function(String messageId, String reaction) onReactionTap;
  final Function(String messageId, String reaction) onReactionRemove;
  final GroupMessage? pendingMessage;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.scrollController,
    required this.onReactionTap,
    required this.onReactionRemove,
    this.pendingMessage,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = _getPaddingForScreenWidth(screenWidth);
    
    // Combine messages with pending message
    final allMessages = <GroupMessage>[
      if (pendingMessage != null) pendingMessage!,
      ...messages,
    ];

    if (allMessages.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      controller: scrollController,
      reverse: true, // Show newest messages at bottom
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: 16,
      ),
      itemCount: allMessages.length,
      itemBuilder: (context, index) {
        final message = allMessages[index];
        final previousMessage = index < allMessages.length - 1 
            ? allMessages[index + 1] 
            : null;
        final nextMessage = index > 0 
            ? allMessages[index - 1] 
            : null;

        return _buildMessageItem(
          context,
          message,
          previousMessage,
          nextMessage,
          screenWidth,
        );
      },
    );
  }

  double _getPaddingForScreenWidth(double screenWidth) {
    if (BreakpointUtils.isMobile(screenWidth)) {
      return 16.0;
    } else if (BreakpointUtils.isTablet(screenWidth)) {
      return 24.0;
    } else {
      return 32.0;
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start the conversation by sending a message',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(
    BuildContext context,
    GroupMessage message,
    GroupMessage? previousMessage,
    GroupMessage? nextMessage,
    double screenWidth,
  ) {
    final isFromCurrentUser = message.senderId == 'current_user_id'; // TODO: Get from auth
    final showAvatar = _shouldShowAvatar(message, nextMessage);
    final showTimestamp = _shouldShowTimestamp(message, previousMessage);
    final isGrouped = _isMessageGrouped(message, previousMessage);

    return Column(
      children: [
        // Date separator
        if (_shouldShowDateSeparator(message, previousMessage))
          _buildDateSeparator(context, message.createdAt),
        
        // Message bubble
        ChatMessageBubble(
          message: message,
          isFromCurrentUser: isFromCurrentUser,
          showAvatar: showAvatar,
          showTimestamp: showTimestamp,
          isGrouped: isGrouped,
          screenWidth: screenWidth,
          onReactionTap: (reaction) => onReactionTap(message.id, reaction),
          onReactionRemove: (reaction) => onReactionRemove(message.id, reaction),
        ),
      ],
    );
  }

  bool _shouldShowAvatar(GroupMessage message, GroupMessage? nextMessage) {
    if (nextMessage == null) return true;
    if (message.senderId != nextMessage.senderId) return true;
    
    final timeDiff = nextMessage.createdAt.difference(message.createdAt);
    return timeDiff.inMinutes > 5;
  }

  bool _shouldShowTimestamp(GroupMessage message, GroupMessage? previousMessage) {
    if (previousMessage == null) return true;
    if (message.senderId != previousMessage.senderId) return true;
    
    final timeDiff = message.createdAt.difference(previousMessage.createdAt);
    return timeDiff.inMinutes > 5;
  }

  bool _isMessageGrouped(GroupMessage message, GroupMessage? previousMessage) {
    if (previousMessage == null) return false;
    if (message.senderId != previousMessage.senderId) return false;
    
    final timeDiff = message.createdAt.difference(previousMessage.createdAt);
    return timeDiff.inMinutes <= 5;
  }

  bool _shouldShowDateSeparator(GroupMessage message, GroupMessage? previousMessage) {
    if (previousMessage == null) return true;
    
    final messageDate = DateTime(
      message.createdAt.year,
      message.createdAt.month,
      message.createdAt.day,
    );
    final previousDate = DateTime(
      previousMessage.createdAt.year,
      previousMessage.createdAt.month,
      previousMessage.createdAt.day,
    );
    
    return !messageDate.isAtSameMomentAs(previousDate);
  }

  Widget _buildDateSeparator(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    String dateText;
    if (messageDate.isAtSameMomentAs(today)) {
      dateText = 'Today';
    } else if (messageDate.isAtSameMomentAs(yesterday)) {
      dateText = 'Yesterday';
    } else {
      dateText = '${date.day}/${date.month}/${date.year}';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              dateText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Divider(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}