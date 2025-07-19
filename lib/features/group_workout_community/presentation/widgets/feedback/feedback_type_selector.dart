import 'package:flutter/material.dart';
import 'package:jfit/l10n/app_localizations.dart';
import '../../../domain/entities/diet_feedback.dart';

class FeedbackTypeSelector extends StatelessWidget {
  final FeedbackType selectedType;
  final ValueChanged<FeedbackType> onTypeChanged;

  const FeedbackTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.feedbackType ?? '피드백 유형',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: FeedbackType.values.map((type) {
                final isSelected = selectedType == type;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(_getTypeLabel(type, l10n)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) onTypeChanged(type);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(FeedbackType type, AppLocalizations l10n) {
    switch (type) {
      case FeedbackType.positive:
        return l10n.positive ?? '칭찬';
      case FeedbackType.suggestion:
        return l10n.suggestion ?? '제안';
      case FeedbackType.concern:
        return l10n.concern ?? '우려';
    }
  }
}