import 'package:flutter/material.dart';

class MessageReactions extends StatelessWidget {
  final Map<String, List<String>> reactions;
  final Function(String reaction) onReactionTap;
  final Function(String reaction) onReactionRemove;
  final String currentUserId;

  const MessageReactions({
    super.key,
    required this.reactions,
    required this.onReactionTap,
    required this.onReactionRemove,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: reactions.entries.map((entry) {
          final reaction = entry.key;
          final userIds = entry.value;
          final hasCurrentUserReacted = userIds.contains(currentUserId);
          
          return _buildReactionChip(
            context,
            reaction,
            userIds.length,
            hasCurrentUserReacted,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReactionChip(
    BuildContext context,
    String reaction,
    int count,
    bool hasCurrentUserReacted,
  ) {
    return GestureDetector(
      onTap: () {
        if (hasCurrentUserReacted) {
          onReactionRemove(reaction);
        } else {
          onReactionTap(reaction);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: hasCurrentUserReacted
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasCurrentUserReacted
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: hasCurrentUserReacted ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              reaction,
              style: const TextStyle(fontSize: 14),
            ),
            if (count > 1) ...[
              const SizedBox(width: 4),
              Text(
                count.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: hasCurrentUserReacted
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}