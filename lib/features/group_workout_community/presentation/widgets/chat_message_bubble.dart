import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/breakpoint_utils.dart';
import '../../domain/entities/group_message.dart';
import 'message_reactions.dart';

class ChatMessageBubble extends StatefulWidget {
  final GroupMessage message;
  final bool isFromCurrentUser;
  final bool showAvatar;
  final bool showTimestamp;
  final bool isGrouped;
  final double screenWidth;
  final Function(String reaction) onReactionTap;
  final Function(String reaction) onReactionRemove;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isFromCurrentUser,
    required this.showAvatar,
    required this.showTimestamp,
    required this.isGrouped,
    required this.screenWidth,
    required this.onReactionTap,
    required this.onReactionRemove,
  });

  @override
  State<ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

class _ChatMessageBubbleState extends State<ChatMessageBubble> {
  bool _showReactionPicker = false;

  @override
  Widget build(BuildContext context) {
    final maxWidth = _getMaxWidthForBreakpoint();
    
    return Container(
      margin: EdgeInsets.only(
        bottom: widget.isGrouped ? 2 : 8,
        top: widget.isGrouped ? 2 : 8,
      ),
      child: Row(
        mainAxisAlignment: widget.isFromCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar (for other users)
          if (!widget.isFromCurrentUser && widget.showAvatar)
            _buildAvatar(),
          if (!widget.isFromCurrentUser && !widget.showAvatar)
            const SizedBox(width: 40),
          
          // Message content
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: widget.isFromCurrentUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // Username (for other users)
                  if (!widget.isFromCurrentUser && widget.showTimestamp)
                    _buildUsername(),
                  
                  // Message bubble
                  GestureDetector(
                    onLongPress: _showMessageOptions,
                    onTap: () {
                      if (_showReactionPicker) {
                        setState(() {
                          _showReactionPicker = false;
                        });
                      }
                    },
                    child: Container(
                      decoration: _buildBubbleDecoration(),
                      padding: _getBubblePadding(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Reply indicator
                          if (widget.message.replyToMessage != null)
                            _buildReplyIndicator(),
                          
                          // Message content
                          _buildMessageContent(),
                          
                          // Message status and timestamp
                          if (widget.isFromCurrentUser || widget.showTimestamp)
                            _buildMessageFooter(),
                        ],
                      ),
                    ),
                  ),
                  
                  // Reactions
                  if (widget.message.hasReactions)
                    MessageReactions(
                      reactions: widget.message.reactions,
                      onReactionTap: widget.onReactionTap,
                      onReactionRemove: widget.onReactionRemove,
                      currentUserId: 'current_user_id', // TODO: Get from auth
                    ),
                  
                  // Reaction picker
                  if (_showReactionPicker)
                    _buildReactionPicker(),
                ],
              ),
            ),
          ),
          
          // Avatar (for current user)
          if (widget.isFromCurrentUser && widget.showAvatar)
            _buildAvatar(),
          if (widget.isFromCurrentUser && !widget.showAvatar)
            const SizedBox(width: 40),
        ],
      ),
    );
  }

  double _getMaxWidthForBreakpoint() {
    if (BreakpointUtils.isMobile(widget.screenWidth)) {
      return MediaQuery.of(context).size.width * 0.75;
    } else if (BreakpointUtils.isTablet(widget.screenWidth)) {
      return MediaQuery.of(context).size.width * 0.65;
    } else {
      return 500;
    }
  }

  Widget _buildAvatar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: Theme.of(context).colorScheme.primary,
        backgroundImage: widget.message.senderProfileImageUrl != null
            ? NetworkImage(widget.message.senderProfileImageUrl!)
            : null,
        child: widget.message.senderProfileImageUrl == null
            ? Text(
                widget.message.senderUsername.isNotEmpty
                    ? widget.message.senderUsername[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildUsername() {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 4),
      child: Text(
        widget.message.senderUsername,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  BoxDecoration _buildBubbleDecoration() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return BoxDecoration(
      color: widget.isFromCurrentUser
          ? colorScheme.primary
          : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(18).copyWith(
        bottomLeft: widget.isFromCurrentUser || widget.isGrouped
            ? const Radius.circular(18)
            : const Radius.circular(4),
        bottomRight: !widget.isFromCurrentUser || widget.isGrouped
            ? const Radius.circular(18)
            : const Radius.circular(4),
      ),
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withOpacity(0.1),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  EdgeInsets _getBubblePadding() {
    if (BreakpointUtils.isMobile(widget.screenWidth)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
    } else if (BreakpointUtils.isTablet(widget.screenWidth)) {
      return const EdgeInsets.symmetric(horizontal: 18, vertical: 12);
    } else {
      return const EdgeInsets.symmetric(horizontal: 20, vertical: 14);
    }
  }

  Widget _buildReplyIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.isFromCurrentUser
            ? Colors.white.withOpacity(0.2)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Replying to ${widget.message.replyToMessage!.senderUsername}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: widget.isFromCurrentUser
                      ? Colors.white.withOpacity(0.8)
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.message.replyToMessage!.messageText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: widget.isFromCurrentUser
                      ? Colors.white.withOpacity(0.7)
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (widget.message.messageType) {
      case MessageType.text:
        return _buildTextContent();
      case MessageType.image:
        return _buildImageContent();
      case MessageType.workoutShare:
        return _buildWorkoutShareContent();
      case MessageType.achievement:
        return _buildAchievementContent();
    }
  }

  Widget _buildTextContent() {
    return SelectableText(
      widget.message.messageText,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: widget.isFromCurrentUser
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
    );
  }

  Widget _buildImageContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(Icons.image, size: 48),
          ),
        ),
        if (widget.message.messageText.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            widget.message.messageText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: widget.isFromCurrentUser
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildWorkoutShareContent() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isFromCurrentUser
            ? Colors.white.withOpacity(0.2)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.fitness_center,
                size: 20,
                color: widget.isFromCurrentUser
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Workout Shared',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: widget.isFromCurrentUser
                          ? Colors.white.withOpacity(0.9)
                          : Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.message.messageText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: widget.isFromCurrentUser
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementContent() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isFromCurrentUser
            ? Colors.white.withOpacity(0.2)
            : Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                size: 20,
                color: widget.isFromCurrentUser
                    ? Colors.white
                    : Colors.amber[700],
              ),
              const SizedBox(width: 8),
              Text(
                'Achievement Unlocked!',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: widget.isFromCurrentUser
                          ? Colors.white.withOpacity(0.9)
                          : Colors.amber[700],
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.message.messageText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: widget.isFromCurrentUser
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatTime(widget.message.createdAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: widget.isFromCurrentUser
                      ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 11,
                ),
          ),
          if (widget.isFromCurrentUser) ...[
            const SizedBox(width: 4),
            _buildMessageStatusIcon(),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageStatusIcon() {
    IconData icon;
    Color? color;
    
    switch (widget.message.status) {
      case MessageStatus.sending:
        icon = Icons.access_time;
        color = Theme.of(context).colorScheme.onPrimary.withOpacity(0.5);
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        color = Theme.of(context).colorScheme.onPrimary.withOpacity(0.7);
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Theme.of(context).colorScheme.onPrimary.withOpacity(0.7);
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = Colors.blue[300];
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        color = Colors.red[300];
        break;
    }
    
    return Icon(
      icon,
      size: 14,
      color: color,
    );
  }

  Widget _buildReactionPicker() {
    final reactions = ['👍', '❤️', '😂', '😮', '😢', '😡'];
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: reactions.map((reaction) {
          return GestureDetector(
            onTap: () {
              widget.onReactionTap(reaction);
              setState(() {
                _showReactionPicker = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Text(
                reaction,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (messageDate.isAtSameMomentAs(today)) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showMessageOptions() {
    HapticFeedback.mediumImpact();
    
    setState(() {
      _showReactionPicker = !_showReactionPicker;
    });
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement reply functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () {
                Navigator.of(context).pop();
                Clipboard.setData(ClipboardData(text: widget.message.messageText));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message copied')),
                );
              },
            ),
            if (widget.isFromCurrentUser)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.of(context).pop();
                  // TODO: Implement delete functionality
                },
              ),
          ],
        ),
      ),
    );
  }
}