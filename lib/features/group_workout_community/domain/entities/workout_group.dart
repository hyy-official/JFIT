import 'package:equatable/equatable.dart';

/// 그룹 프라이버시 타입
enum GroupPrivacyType {
  public,
  private,
}

/// 그룹 내 사용자 역할
enum GroupRole {
  admin,
  moderator,
  member,
}

/// 그룹 활동 타입
enum GroupActivityType {
  workoutCompleted,
  routineShared,
  memberJoined,
  memberLeft,
  encouragementSent,
  achievementUnlocked,
  programStarted,
  milestoneReached,
}

/// 운동 그룹 도메인 엔티티
class WorkoutGroup extends Equatable {
  final String id;
  final String name;
  final String description;
  final String adminId;
  final GroupPrivacyType privacyType;
  final int maxMembers;
  final int currentMemberCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? inviteCode;
  final bool isActive;
  final String? groupType; // 'personal_training' for PT groups, null for regular groups

  const WorkoutGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.adminId,
    required this.privacyType,
    required this.maxMembers,
    required this.currentMemberCount,
    required this.createdAt,
    required this.updatedAt,
    this.inviteCode,
    required this.isActive,
    this.groupType,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        adminId,
        privacyType,
        maxMembers,
        currentMemberCount,
        createdAt,
        updatedAt,
        inviteCode,
        isActive,
        groupType,
      ];

  WorkoutGroup copyWith({
    String? id,
    String? name,
    String? description,
    String? adminId,
    GroupPrivacyType? privacyType,
    int? maxMembers,
    int? currentMemberCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? inviteCode,
    bool? isActive,
    String? groupType,
  }) {
    return WorkoutGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      adminId: adminId ?? this.adminId,
      privacyType: privacyType ?? this.privacyType,
      maxMembers: maxMembers ?? this.maxMembers,
      currentMemberCount: currentMemberCount ?? this.currentMemberCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      inviteCode: inviteCode ?? this.inviteCode,
      isActive: isActive ?? this.isActive,
      groupType: groupType ?? this.groupType,
    );
  }

  /// 그룹이 PT 그룹인지 확인
  bool get isPTGroup => groupType == 'personal_training';

  /// 그룹이 가득 찼는지 확인
  bool get isFull => currentMemberCount >= maxMembers;

  /// 그룹이 공개 그룹인지 확인
  bool get isPublic => privacyType == GroupPrivacyType.public;
}