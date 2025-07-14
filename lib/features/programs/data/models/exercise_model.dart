import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'exercise_model.g.dart';

@JsonSerializable()
class ExerciseModel extends Equatable {
  final String id;
  final String titleKo;
  final String? titleEn;
  final String? descKo;
  final String? descEn;
  final String? difficulty;
  final String? type;
  final String? equipment;
  final double? caloriesPerMinute;
  final String? categoryKo;
  final String? categoryEn;
  final String? recommendedSets;
  final String? recommendedReps;
  final String? imageUrl;

  const ExerciseModel({
    required this.id,
    required this.titleKo,
    this.titleEn,
    this.descKo,
    this.descEn,
    this.difficulty,
    this.type,
    this.equipment,
    this.caloriesPerMinute,
    this.categoryKo,
    this.categoryEn,
    this.recommendedSets,
    this.recommendedReps,
    this.imageUrl,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) => _$ExerciseModelFromJson(json);
  Map<String, dynamic> toJson() => _$ExerciseModelToJson(this);

  @override
  List<Object?> get props => [id, titleKo, titleEn, descKo, descEn, difficulty, type, equipment, caloriesPerMinute, categoryKo, categoryEn, recommendedSets, recommendedReps, imageUrl];
} 