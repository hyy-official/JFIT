import 'package:flutter/material.dart';
import '../bloc/group_chat/group_chat_state.dart';

class ChatTypingIndicator extends StatefulWidget {
  final List<TypingUser> typingUsers;

  const ChatTypingIndicator({
    super.key,
    required this.typingUsers,
  });

  @override
  State<ChatTypingIndicator> createState() => _ChatTypingIndicatorState();
}

class _ChatTypingIndicatorState extends State<ChatTypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter out users who haven't typed recently
    final activeTypingUsers = widget.typingUsers
        .where((user) => user.isRecentlyTyping)
        .toList();

    if (activeTypingUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Avatar for single user, or multiple avatars for multiple users
          _buildAvatars(activeTypingUsers),
          
          const SizedBox(width: 12),
          
          // Typing text and animation
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _buildTypingText(activeTypingUsers),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                ),
                const SizedBox(height: 4),
                _buildTypingAnimation(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatars(List<TypingUser> users) {
    if (users.length == 1) {
      return _buildSingleAvatar(users.first);
    } else {
      return _buildMultipleAvatars(users);
    }
  }

  Widget _buildSingleAvatar(TypingUser user) {
    return CircleAvatar(
      radius: 12,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Text(
        user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMultipleAvatars(List<TypingUser> users) {
    return SizedBox(
      width: 32,
      height: 24,
      child: Stack(
        children: users.take(3).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final user = entry.value;
          
          return Positioned(
            left: index * 8.0,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _buildTypingText(List<TypingUser> users) {
    if (users.length == 1) {
      return '${users.first.username} is typing...';
    } else if (users.length == 2) {
      return '${users.first.username} and ${users.last.username} are typing...';
    } else {
      return '${users.first.username} and ${users.length - 1} others are typing...';
    }
  }

  Widget _buildTypingAnimation() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animationValue = (_animation.value - delay).clamp(0.0, 1.0);
            final opacity = (Curves.easeInOut.transform(animationValue) * 2 - 1).abs();
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              child: AnimatedOpacity(
                opacity: 0.3 + (opacity * 0.7),
                duration: const Duration(milliseconds: 100),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}