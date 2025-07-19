import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_workout_score.dart';
import '../../domain/entities/body_part_mapping.dart';

part 'user_workout_score_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserWorkoutScoreModel extends UserWorkoutScore {
  const UserWorkoutScoreModel({
    required super.id,
    required super.userId,
    required super.groupId,
    required super.scoreDate,
    required super.totalScore,
    required super.bodyBalanceScore,
    required super.volumeScore,
    required super.progressScore,
    required super.consistencyScore,
    required super.bodyPartScores,
    required super.createdAt,
  });

  factory UserWorkoutScoreModel.fromJson(Map<String, dynamic> json) {
    return UserWorkoutScoreModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      groupId: json['group_id'] as String,
      scoreDate: json['score_date'] != null
          ? DateTime.parse(json['score_date'] as String)
          : DateTime.now(),
      totalScore: _parseDouble(json['total_score']) ?? 0.0,
      bodyBalanceScore: _parseDouble(json['body_balance_score']) ?? 0.0,
      volumeScore: _parseDouble(json['volume_score']) ?? 0.0,
      progressScore: _parseDouble(json['progress_score']) ?? 0.0,
      consistencyScore: _parseDouble(json['consistency_score']) ?? 0.0,
      bodyPartScores: _parseBodyPartScores(json['body_part_scores']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static Map<BodyPart, double> _parseBodyPartScores(dynamic value) {
    if (value == null) return {};
    if (value is! Map) return {};
    
    final Map<BodyPart, double> result = {};
    final map = value as Map<String, dynamic>;
    
    for (final entry in map.entries) {
      final bodyPart = _parseBodyPart(entry.key);
      if (bodyPart != null) {
        result[bodyPart] = _parseDouble(entry.value);
      }
    }
    
    return result;
  }

  static BodyPart? _parseBodyPart(String value) {
    switch (value) {
      case 'chest':
        return BodyPart.chest;
      case 'back':
        return BodyPart.back;
      case 'legs':
        return BodyPart.legs;
      case 'shoulders':
        return BodyPart.shoulders;
      case 'arms':
        return BodyPart.arms;
      case 'core':
        return BodyPart.core;
      default:
        return null;
    }
  }

  static Map<String, double> _bodyPartScoresToJson(Map<BodyPart, double> scores) {
    return scores.map((bodyPart, score) => MapEntry(_bodyPartToString(bodyPart), score));
  }

  static String _bodyPartToString(BodyPart bodyPart) {
    switch (bodyPart) {
      case BodyPart.chest:
        return 'chest';
      case BodyPart.back:
        return 'back';
      case BodyPart.legs:
        return 'legs';
      case BodyPart.shoulders:
        return 'shoulders';
      case BodyPart.arms:
        return 'arms';
      case BodyPart.core:
        return 'core';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'group_id': groupId,
      'score_date': scoreDate.toIso8601String().split('T')[0], // Date only
      'total_score': totalScore,
      'body_balance_score': bodyBalanceScore,
      'volume_score': volumeScore,
      'progress_score': progressScore,
      'consistency_score': consistencyScore,
      'body_part_scores': _bodyPartScoresToJson(bodyPartScores),
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserWorkoutScore toEntity() {
    return UserWorkoutScore(
      id: id,
      userId: userId,
      groupId: groupId,
      scoreDate: scoreDate,
      totalScore: totalScore,
      bodyBalanceScore: bodyBalanceScore,
      volumeScore: volumeScore,
      progressScore: progressScore,
      consistencyScore: consistencyScore,
      bodyPartScores: bodyPartScores,
      createdAt: createdAt,
    );
  }

  factory UserWorkoutScoreModel.fromEntity(UserWorkoutScore entity) {
    return UserWorkoutScoreModel(
      id: entity.id,
      userId: entity.userId,
      groupId: entity.groupId,
      scoreDate: entity.scoreDate,
      totalScore: entity.totalScore,
      bodyBalanceScore: entity.bodyBalanceScore,
      volumeScore: entity.volumeScore,
      progressScore: entity.progressScore,
      consistencyScore: entity.consistencyScore,
      bodyPartScores: entity.bodyPartScores,
      createdAt: entity.createdAt,
    );
  }
}