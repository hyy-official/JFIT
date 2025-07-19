// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_workout_score_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserWorkoutScoreModel _$UserWorkoutScoreModelFromJson(
        Map<String, dynamic> json) =>
    UserWorkoutScoreModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      groupId: json['groupId'] as String,
      scoreDate: DateTime.parse(json['scoreDate'] as String),
      totalScore: (json['totalScore'] as num).toDouble(),
      bodyBalanceScore: (json['bodyBalanceScore'] as num).toDouble(),
      volumeScore: (json['volumeScore'] as num).toDouble(),
      progressScore: (json['progressScore'] as num).toDouble(),
      consistencyScore: (json['consistencyScore'] as num).toDouble(),
      bodyPartScores: (json['bodyPartScores'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry($enumDecode(_$BodyPartEnumMap, k), (e as num).toDouble()),
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$UserWorkoutScoreModelToJson(
        UserWorkoutScoreModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'groupId': instance.groupId,
      'scoreDate': instance.scoreDate.toIso8601String(),
      'totalScore': instance.totalScore,
      'bodyBalanceScore': instance.bodyBalanceScore,
      'volumeScore': instance.volumeScore,
      'progressScore': instance.progressScore,
      'consistencyScore': instance.consistencyScore,
      'bodyPartScores': instance.bodyPartScores
          .map((k, e) => MapEntry(_$BodyPartEnumMap[k]!, e)),
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$BodyPartEnumMap = {
  BodyPart.chest: 'chest',
  BodyPart.back: 'back',
  BodyPart.legs: 'legs',
  BodyPart.shoulders: 'shoulders',
  BodyPart.arms: 'arms',
  BodyPart.core: 'core',
};
