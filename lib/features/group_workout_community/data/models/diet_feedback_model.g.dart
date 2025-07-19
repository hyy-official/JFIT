// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diet_feedback_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DietFeedbackModel _$DietFeedbackModelFromJson(Map<String, dynamic> json) =>
    DietFeedbackModel(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      memberId: json['memberId'] as String,
      trainerId: json['trainerId'] as String,
      mealEntryId: json['mealEntryId'] as String,
      feedbackText: json['feedbackText'] as String,
      feedbackType: $enumDecode(_$FeedbackTypeEnumMap, json['feedbackType']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool,
    );

Map<String, dynamic> _$DietFeedbackModelToJson(DietFeedbackModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'memberId': instance.memberId,
      'trainerId': instance.trainerId,
      'mealEntryId': instance.mealEntryId,
      'feedbackText': instance.feedbackText,
      'feedbackType': _$FeedbackTypeEnumMap[instance.feedbackType]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'isRead': instance.isRead,
    };

const _$FeedbackTypeEnumMap = {
  FeedbackType.positive: 'positive',
  FeedbackType.suggestion: 'suggestion',
  FeedbackType.concern: 'concern',
};
