import 'package:flutter/material.dart';
import '../../../../core/utils/breakpoint_utils.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String groupName;
  final VoidCallback? onBackPressed;
  final bool showMemberCount;
  final bool showOnlineStatus;
  final int memberCount;
  final int onlineCount;

  const ChatAppBar({
    super.key,
    required this.groupName,
    this.onBackPressed,
    this.showMemberCount = false,
    this.showOnlineStatus = false,
    this.memberCount = 0,
    this.onlineCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = BreakpointUtils.isDesktop(screenWidth);
    
    return AppBar(
      leading: onBackPressed != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed,
            )
          : null,
      title: _buildTitle(context, isDesktop),
      actions: _buildActions(context, isDesktop),
      elevation: 1,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
    );
  }

  Widget _buildTitle(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          groupName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          overflow: TextOverflow.ellipsis,
        ),
        if (showMemberCount || showOnlineStatus)
          Text(
            _buildSubtitle(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
      ],
    );
  }

  String _buildSubtitle() {
    final parts = <String>[];
    
    if (showMemberCount && memberCount > 0) {
      parts.add('$memberCount members');
    }
    
    if (showOnlineStatus && onlineCount > 0) {
      parts.add('$onlineCount online');
    }
    
    return parts.join(' • ');
  }

  List<Widget> _buildActions(BuildContext context, bool isDesktop) {
    final actions = <Widget>[];

    // Video call button (desktop only)
    if (isDesktop) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.videocam_outlined),
          onPressed: () {
            // TODO: Implement video call
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Video call feature coming soon'),
              ),
            );
          },
          tooltip: 'Start video call',
        ),
      );
    }

    // Search messages
    actions.add(
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          // TODO: Implement message search
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Message search coming soon'),
            ),
          );
        },
        tooltip: 'Search messages',
      ),
    );

    // Group settings
    actions.add(
      PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (value) => _handleMenuAction(context, value),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'group_info',
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Group Info'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const PopupMenuItem(
            value: 'notifications',
            child: ListTile(
              leading: Icon(Icons.notifications_outlined),
              title: Text('Notifications'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const PopupMenuItem(
            value: 'media',
            child: ListTile(
              leading: Icon(Icons.photo_library_outlined),
              title: Text('Shared Media'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: 'leave',
            child: ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.red),
              title: Text('Leave Group', style: TextStyle(color: Colors.red)),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );

    return actions;
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'group_info':
        // TODO: Navigate to group info page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group info coming soon')),
        );
        break;
      case 'notifications':
        // TODO: Open notification settings
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification settings coming soon')),
        );
        break;
      case 'media':
        // TODO: Show shared media
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Shared media coming soon')),
        );
        break;
      case 'leave':
        _showLeaveGroupDialog(context);
        break;
    }
  }

  void _showLeaveGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Group'),
        content: Text('Are you sure you want to leave "$groupName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement leave group functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Leave group functionality coming soon')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}