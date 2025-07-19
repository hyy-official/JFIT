import 'package:flutter/material.dart';
import 'package:jfit/l10n/app_localizations.dart';
import '../../../domain/entities/diet_feedback.dart';

class FeedbackTextInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final FeedbackType feedbackType;
  final int minLines;
  final int? maxLines;

  const FeedbackTextInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.feedbackType,
    this.minLines = 3,
    this.maxLines = 10,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: l10n.feedbackText ?? '피드백 내용',
        hintText: _getHintText(feedbackType, l10n),
        border: const OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return l10n.feedbackRequired ?? '피드백 내용을 입력해주세요';
        }
        return null;
      },
    );
  }

  String _getHintText(FeedbackType type, AppLocalizations l10n) {
    switch (type) {
      case FeedbackType.positive:
        return l10n.positiveHint ?? '잘하고 있는 점을 구체적으로 칭찬해주세요';
      case FeedbackType.suggestion:
        return l10n.suggestionHint ?? '개선할 수 있는 방법을 제안해주세요';
      case FeedbackType.concern:
        return l10n.concernHint ?? '우려되는 점을 구체적으로 설명해주세요';
    }
  }
}