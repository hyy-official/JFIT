import 'package:equatable/equatable.dart';
import 'workout_group.dart';

/// 그룹 활동 도메인 엔티티
class GroupActivity extends Equatable {
  final String id;
  final String groupId;
  final String userId;
  final GroupActivityType activityType;
  final Map<String, dynamic> activityData;
  final DateTime createdAt;
  final List<String> mentionedUserIds;

  const GroupActivity({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.activityType,
    required this.activityData,
    required this.createdAt,
    required this.mentionedUserIds,
  });

  @override
  List<Object?> get props => [
        id,
        groupId,
        userId,
        activityType,
        activityData,
        createdAt,
        mentionedUserIds,
      ];

  GroupActivity copyWith({
    String? id,
    String? groupId,
    String? userId,
    GroupActivityType? activityType,
    Map<String, dynamic>? activityData,
    DateTime? createdAt,
    List<String>? mentionedUserIds,
  }) {
    return GroupActivity(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      activityType: activityType ?? this.activityType,
      activityData: activityData ?? this.activityData,
      createdAt: createdAt ?? this.createdAt,
      mentionedUserIds: mentionedUserIds ?? this.mentionedUserIds,
    );
  }

  /// 활동이 운동 완료 관련인지 확인
  bool get isWorkoutActivity => activityType == GroupActivityType.workoutCompleted;

  /// 활동이 루틴 공유 관련인지 확인
  bool get isRoutineActivity => activityType == GroupActivityType.routineShared;

  /// 활동이 멤버 관련인지 확인
  bool get isMemberActivity => 
      activityType == GroupActivityType.memberJoined || 
      activityType == GroupActivityType.memberLeft;

  /// 활동이 격려 관련인지 확인
  bool get isEncouragementActivity => activityType == GroupActivityType.encouragementSent;

  /// 활동에 멘션된 사용자가 있는지 확인
  bool get hasMentions => mentionedUserIds.isNotEmpty;

  /// 특정 사용자가 멘션되었는지 확인
  bool isUserMentioned(String userId) => mentionedUserIds.contains(userId);

  /// 활동 데이터에서 특정 키의 값을 가져오기
  T? getActivityData<T>(String key) {
    return activityData[key] as T?;
  }

  /// 운동 완료 활동의 운동 시간 가져오기
  int? get workoutDuration => getActivityData<int>('duration_minutes');

  /// 루틴 공유 활동의 루틴 이름 가져오기
  String? get sharedRoutineName => getActivityData<String>('routine_name');

  /// 격려 메시지 내용 가져오기
  String? get encouragementMessage => getActivityData<String>('message');
}