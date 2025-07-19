import 'package:flutter/material.dart';
import 'package:jfit/l10n/app_localizations.dart';
import '../../../domain/entities/diet_feedback.dart';

class FeedbackPreview extends StatelessWidget {
  final String feedbackText;
  final FeedbackType feedbackType;

  const FeedbackPreview({
    super.key,
    required this.feedbackText,
    required this.feedbackType,
  });

  @override
  Widget build(BuildContext context) {
    if (feedbackText.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.preview,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.preview ?? '미리보기',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getTypeColor(feedbackType).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _getTypeColor(feedbackType).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(_getTypeEmoji(feedbackType)),
                      const SizedBox(width: 8),
                      Text(
                        _getTypeLabel(feedbackType),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getTypeColor(feedbackType),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(feedbackText),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(FeedbackType type) {
    switch (type) {
      case FeedbackType.positive:
        return Colors.green;
      case FeedbackType.suggestion:
        return Colors.blue;
      case FeedbackType.concern:
        return Colors.orange;
    }
  }

  String _getTypeEmoji(FeedbackType type) {
    switch (type) {
      case FeedbackType.positive:
        return '👍';
      case FeedbackType.suggestion:
        return '💡';
      case FeedbackType.concern:
        return '⚠️';
    }
  }

  String _getTypeLabel(FeedbackType type) {
    switch (type) {
      case FeedbackType.positive:
        return '칭찬';
      case FeedbackType.suggestion:
        return '제안';
      case FeedbackType.concern:
        return '우려';
    }
  }
}