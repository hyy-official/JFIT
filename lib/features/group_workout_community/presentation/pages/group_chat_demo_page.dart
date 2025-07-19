import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/group_chat/group_chat_bloc.dart';
import 'group_chat_page.dart';

class GroupChatDemoPage extends StatelessWidget {
  const GroupChatDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Chat Demo'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Group Chat Feature',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Experience responsive group chat with real-time messaging,\nreactions, and media sharing.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _openGroupChat(context),
              icon: const Icon(Icons.chat),
              label: const Text('Open Demo Chat'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _showFeatureInfo(context),
              icon: const Icon(Icons.info_outline),
              label: const Text('Feature Info'),
            ),
          ],
        ),
      ),
    );
  }

  void _openGroupChat(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => GroupChatBloc(),
          child: const GroupChatPage(
            groupId: 'demo_group_id',
            groupName: 'Fitness Enthusiasts',
          ),
        ),
      ),
    );
  }

  void _showFeatureInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Group Chat Features'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _FeatureItem(
                icon: Icons.chat_bubble,
                title: 'Real-time Messaging',
                description: 'Send and receive messages instantly with live updates',
              ),
              _FeatureItem(
                icon: Icons.emoji_emotions,
                title: 'Message Reactions',
                description: 'React to messages with emojis and see others\' reactions',
              ),
              _FeatureItem(
                icon: Icons.reply,
                title: 'Reply to Messages',
                description: 'Reply to specific messages to maintain context',
              ),
              _FeatureItem(
                icon: Icons.photo_camera,
                title: 'Media Sharing',
                description: 'Share photos and workout achievements',
              ),
              _FeatureItem(
                icon: Icons.fitness_center,
                title: 'Workout Sharing',
                description: 'Share your workout routines with the group',
              ),
              _FeatureItem(
                icon: Icons.devices,
                title: 'Responsive Design',
                description: 'Optimized for mobile, tablet, and desktop',
              ),
              _FeatureItem(
                icon: Icons.edit,
                title: 'Typing Indicators',
                description: 'See when others are typing messages',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}