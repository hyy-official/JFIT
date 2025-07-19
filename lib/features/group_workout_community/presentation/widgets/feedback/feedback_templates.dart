import 'package:flutter/material.dart';
import 'package:jfit/l10n/app_localizations.dart';
import '../../../domain/entities/diet_feedback.dart';

class FeedbackTemplates extends StatelessWidget {
  final FeedbackType feedbackType;
  final ValueChanged<String> onTemplateSelected;
  final bool isCompact;

  const FeedbackTemplates({
    super.key,
    required this.feedbackType,
    required this.onTemplateSelected,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final templates = _getTemplates(feedbackType, l10n);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.feedbackTemplates ?? '템플릿',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...templates.map((template) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: OutlinedButton(
                onPressed: () => onTemplateSelected(template),
                child: Text(template),
              ),
            )),
          ],
        ),
      ),
    );
  }

  List<String> _getTemplates(FeedbackType type, AppLocalizations l10n) {
    switch (type) {
      case FeedbackType.positive:
        return [
          '균형 잡힌 식단을 잘 유지하고 계시네요!',
          '목표 칼로리를 잘 지키고 있습니다.',
          '단백질 섭취량이 적절합니다.',
        ];
      case FeedbackType.suggestion:
        return [
          '야채 섭취량을 늘려보시는 것이 좋겠습니다.',
          '식사 시간을 더 규칙적으로 해보세요.',
          '수분 섭취량을 늘려보시기 바랍니다.',
        ];
      case FeedbackType.concern:
        return [
          '칼로리 섭취량이 목표보다 많이 부족합니다.',
          '단백질 섭취가 부족해 보입니다.',
          '식사를 거르는 경우가 많아 보입니다.',
        ];
    }
  }
}