import 'package:equatable/equatable.dart';
import 'workout_group.dart';

/// 그룹 멤버 도메인 엔티티
class GroupMember extends Equatable {
  final String id;
  final String groupId;
  final String userId;
  final String username;
  final String? profileImageUrl;
  final GroupRole role;
  final DateTime joinedAt;
  final bool isActive;
  final DateTime? lastActiveAt;

  const GroupMember({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.username,
    this.profileImageUrl,
    required this.role,
    required this.joinedAt,
    required this.isActive,
    this.lastActiveAt,
  });

  @override
  List<Object?> get props => [
        id,
        groupId,
        userId,
        username,
        profileImageUrl,
        role,
        joinedAt,
        isActive,
        lastActiveAt,
      ];

  GroupMember copyWith({
    String? id,
    String? groupId,
    String? userId,
    String? username,
    String? profileImageUrl,
    GroupRole? role,
    DateTime? joinedAt,
    bool? isActive,
    DateTime? lastActiveAt,
  }) {
    return GroupMember(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      isActive: isActive ?? this.isActive,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  /// 멤버가 관리자인지 확인
  bool get isAdmin => role == GroupRole.admin;

  /// 멤버가 모더레이터인지 확인
  bool get isModerator => role == GroupRole.moderator;

  /// 멤버가 관리 권한을 가지고 있는지 확인 (관리자 또는 모더레이터)
  bool get hasManagementPermissions => isAdmin || isModerator;

  /// 멤버가 최근에 활동했는지 확인 (7일 이내)
  bool get isRecentlyActive {
    if (lastActiveAt == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastActiveAt!);
    return difference.inDays <= 7;
  }
}