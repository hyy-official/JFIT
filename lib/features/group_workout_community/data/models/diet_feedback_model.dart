import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/diet_feedback.dart';

part 'diet_feedback_model.g.dart';

@JsonSerializable(explicitToJson: true)
class DietFeedbackModel extends DietFeedback {
  const DietFeedbackModel({
    required super.id,
    required super.groupId,
    required super.memberId,
    required super.trainerId,
    required super.mealEntryId,
    required super.feedbackText,
    required super.feedbackType,
    required super.createdAt,
    required super.isRead,
  });

  factory DietFeedbackModel.fromJson(Map<String, dynamic> json) {
    return DietFeedbackModel(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      memberId: json['member_id'] as String,
      trainerId: json['trainer_id'] as String,
      mealEntryId: json['meal_entry_id'] as String,
      feedbackText: json['feedback_text'] as String,
      feedbackType: _parseFeedbackType(json['feedback_type'] as String?),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  static FeedbackType _parseFeedbackType(String? value) {
    switch (value) {
      case 'positive':
        return FeedbackType.positive;
      case 'concern':
        return FeedbackType.concern;
      case 'suggestion':
      default:
        return FeedbackType.suggestion;
    }
  }

  static String _feedbackTypeToString(FeedbackType type) {
    switch (type) {
      case FeedbackType.positive:
        return 'positive';
      case FeedbackType.suggestion:
        return 'suggestion';
      case FeedbackType.concern:
        return 'concern';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'member_id': memberId,
      'trainer_id': trainerId,
      'meal_entry_id': mealEntryId,
      'feedback_text': feedbackText,
      'feedback_type': _feedbackTypeToString(feedbackType),
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }

  DietFeedback toEntity() {
    return DietFeedback(
      id: id,
      groupId: groupId,
      memberId: memberId,
      trainerId: trainerId,
      mealEntryId: mealEntryId,
      feedbackText: feedbackText,
      feedbackType: feedbackType,
      createdAt: createdAt,
      isRead: isRead,
    );
  }

  factory DietFeedbackModel.fromEntity(DietFeedback entity) {
    return DietFeedbackModel(
      id: entity.id,
      groupId: entity.groupId,
      memberId: entity.memberId,
      trainerId: entity.trainerId,
      mealEntryId: entity.mealEntryId,
      feedbackText: entity.feedbackText,
      feedbackType: entity.feedbackType,
      createdAt: entity.createdAt,
      isRead: entity.isRead,
    );
  }
}