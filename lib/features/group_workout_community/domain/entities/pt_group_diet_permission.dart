import 'package:equatable/equatable.dart';

/// PT 그룹 식단 권한 도메인 엔티티
class PTGroupDietPermission extends Equatable {
  final String id;
  final String groupId;
  final String memberId;
  final String trainerId;
  final bool canViewMeals;
  final bool canViewPhotos;
  final bool canViewNutrition;
  final DateTime permissionGrantedAt;

  const PTGroupDietPermission({
    required this.id,
    required this.groupId,
    required this.memberId,
    required this.trainerId,
    required this.canViewMeals,
    required this.canViewPhotos,
    required this.canViewNutrition,
    required this.permissionGrantedAt,
  });

  @override
  List<Object?> get props => [
        id,
        groupId,
        memberId,
        trainerId,
        canViewMeals,
        canViewPhotos,
        canViewNutrition,
        permissionGrantedAt,
      ];

  PTGroupDietPermission copyWith({
    String? id,
    String? groupId,
    String? memberId,
    String? trainerId,
    bool? canViewMeals,
    bool? canViewPhotos,
    bool? canViewNutrition,
    DateTime? permissionGrantedAt,
  }) {
    return PTGroupDietPermission(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      memberId: memberId ?? this.memberId,
      trainerId: trainerId ?? this.trainerId,
      canViewMeals: canViewMeals ?? this.canViewMeals,
      canViewPhotos: canViewPhotos ?? this.canViewPhotos,
      canViewNutrition: canViewNutrition ?? this.canViewNutrition,
      permissionGrantedAt: permissionGrantedAt ?? this.permissionGrantedAt,
    );
  }

  /// 모든 권한이 허용되었는지 확인
  bool get hasFullAccess => canViewMeals && canViewPhotos && canViewNutrition;

  /// 기본 권한만 있는지 확인 (식사 기록만)
  bool get hasBasicAccess => canViewMeals && !canViewPhotos && !canViewNutrition;

  /// 어떤 권한도 없는지 확인
  bool get hasNoAccess => !canViewMeals && !canViewPhotos && !canViewNutrition;

  /// 사진 권한이 있는지 확인
  bool get hasPhotoAccess => canViewPhotos;

  /// 영양 정보 권한이 있는지 확인
  bool get hasNutritionAccess => canViewNutrition;

  /// 권한이 최근에 부여되었는지 확인 (7일 이내)
  bool get isRecentlyGranted {
    final now = DateTime.now();
    final difference = now.difference(permissionGrantedAt);
    return difference.inDays <= 7;
  }

  /// 허용된 권한 개수
  int get permissionCount {
    int count = 0;
    if (canViewMeals) count++;
    if (canViewPhotos) count++;
    if (canViewNutrition) count++;
    return count;
  }

  /// 권한 레벨 (0-3)
  int get permissionLevel => permissionCount;

  /// 권한 레벨 문자열
  String get permissionLevelString {
    switch (permissionLevel) {
      case 0:
        return '권한 없음';
      case 1:
        return '기본';
      case 2:
        return '중급';
      case 3:
        return '전체';
      default:
        return '알 수 없음';
    }
  }

  /// 특정 권한을 토글한 새 인스턴스 반환
  PTGroupDietPermission toggleMealPermission() => 
      copyWith(canViewMeals: !canViewMeals);

  PTGroupDietPermission togglePhotoPermission() => 
      copyWith(canViewPhotos: !canViewPhotos);

  PTGroupDietPermission toggleNutritionPermission() => 
      copyWith(canViewNutrition: !canViewNutrition);

  /// 모든 권한을 허용하는 새 인스턴스 반환
  PTGroupDietPermission grantAllPermissions() => copyWith(
        canViewMeals: true,
        canViewPhotos: true,
        canViewNutrition: true,
      );

  /// 모든 권한을 거부하는 새 인스턴스 반환
  PTGroupDietPermission revokeAllPermissions() => copyWith(
        canViewMeals: false,
        canViewPhotos: false,
        canViewNutrition: false,
      );

  /// 권한 요약 정보
  Map<String, dynamic> get permissionSummary => {
    'permissionLevel': permissionLevel,
    'permissionLevelString': permissionLevelString,
    'hasFullAccess': hasFullAccess,
    'hasBasicAccess': hasBasicAccess,
    'hasNoAccess': hasNoAccess,
    'permissions': {
      'meals': canViewMeals,
      'photos': canViewPhotos,
      'nutrition': canViewNutrition,
    },
    'grantedAt': permissionGrantedAt.toIso8601String(),
    'isRecentlyGranted': isRecentlyGranted,
  };
}