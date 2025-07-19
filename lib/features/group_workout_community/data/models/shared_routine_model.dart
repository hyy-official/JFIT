import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/shared_routine.dart';

part 'shared_routine_model.g.dart';

@JsonSerializable(explicitToJson: true)
class SharedRoutineModel extends SharedRoutine {
  const SharedRoutineModel({
    required super.id,
    required super.groupId,
    required super.sharedByUserId,
    required super.userProgramId,
    required super.routineName,
    super.description,
    required super.exerciseIds,
    required super.sharedAt,
    required super.likesCount,
    required super.copiesCount,
  });

  factory SharedRoutineModel.fromJson(Map<String, dynamic> json) {
    return SharedRoutineModel(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      sharedByUserId: json['shared_by_user_id'] as String,
      userProgramId: json['user_program_id'] as String,
      routineName: json['routine_name'] as String,
      description: json['description'] as String?,
      exerciseIds: json['exercise_ids'] != null
          ? List<String>.from(json['exercise_ids'] as List)
          : <String>[],
      sharedAt: json['shared_at'] != null
          ? DateTime.parse(json['shared_at'] as String)
          : DateTime.now(),
      likesCount: json['likes_count'] as int? ?? 0,
      copiesCount: json['copies_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'shared_by_user_id': sharedByUserId,
      'user_program_id': userProgramId,
      'routine_name': routineName,
      'description': description,
      'exercise_ids': exerciseIds,
      'shared_at': sharedAt.toIso8601String(),
      'likes_count': likesCount,
      'copies_count': copiesCount,
    };
  }

  SharedRoutine toEntity() {
    return SharedRoutine(
      id: id,
      groupId: groupId,
      sharedByUserId: sharedByUserId,
      userProgramId: userProgramId,
      routineName: routineName,
      description: description,
      exerciseIds: exerciseIds,
      sharedAt: sharedAt,
      likesCount: likesCount,
      copiesCount: copiesCount,
    );
  }

  factory SharedRoutineModel.fromEntity(SharedRoutine entity) {
    return SharedRoutineModel(
      id: entity.id,
      groupId: entity.groupId,
      sharedByUserId: entity.sharedByUserId,
      userProgramId: entity.userProgramId,
      routineName: entity.routineName,
      description: entity.description,
      exerciseIds: entity.exerciseIds,
      sharedAt: entity.sharedAt,
      likesCount: entity.likesCount,
      copiesCount: entity.copiesCount,
    );
  }
}