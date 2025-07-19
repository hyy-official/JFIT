import 'package:equatable/equatable.dart';

/// 공유된 운동 루틴 도메인 엔티티
class SharedRoutine extends Equatable {
  final String id;
  final String groupId;
  final String sharedByUserId;
  final String userProgramId;
  final String routineName;
  final String? description;
  final List<String> exerciseIds;
  final DateTime sharedAt;
  final int likesCount;
  final int copiesCount;

  const SharedRoutine({
    required this.id,
    required this.groupId,
    required this.sharedByUserId,
    required this.userProgramId,
    required this.routineName,
    this.description,
    required this.exerciseIds,
    required this.sharedAt,
    required this.likesCount,
    required this.copiesCount,
  });

  @override
  List<Object?> get props => [
        id,
        groupId,
        sharedByUserId,
        userProgramId,
        routineName,
        description,
        exerciseIds,
        sharedAt,
        likesCount,
        copiesCount,
      ];

  SharedRoutine copyWith({
    String? id,
    String? groupId,
    String? sharedByUserId,
    String? userProgramId,
    String? routineName,
    String? description,
    List<String>? exerciseIds,
    DateTime? sharedAt,
    int? likesCount,
    int? copiesCount,
  }) {
    return SharedRoutine(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      sharedByUserId: sharedByUserId ?? this.sharedByUserId,
      userProgramId: userProgramId ?? this.userProgramId,
      routineName: routineName ?? this.routineName,
      description: description ?? this.description,
      exerciseIds: exerciseIds ?? this.exerciseIds,
      sharedAt: sharedAt ?? this.sharedAt,
      likesCount: likesCount ?? this.likesCount,
      copiesCount: copiesCount ?? this.copiesCount,
    );
  }

  /// 루틴이 인기 있는지 확인 (좋아요 5개 이상 또는 복사 3회 이상)
  bool get isPopular => likesCount >= 5 || copiesCount >= 3;

  /// 루틴에 운동이 포함되어 있는지 확인
  bool get hasExercises => exerciseIds.isNotEmpty;

  /// 루틴의 운동 개수
  int get exerciseCount => exerciseIds.length;
}