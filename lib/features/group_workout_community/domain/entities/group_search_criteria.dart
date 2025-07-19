import 'package:jfit/features/group_workout_community/domain/entities/workout_group.dart';

/// 그룹 검색 기준을 정의하는 클래스
class GroupSearchCriteria {
  final String? searchQuery;
  final GroupPrivacyType? privacyType;
  final GroupSizeFilter? sizeFilter;
  final GroupSortOption sortOption;
  final int? minMembers;
  final int? maxMembers;
  final bool? isPTGroup;
  final List<String>? excludeGroupIds;

  const GroupSearchCriteria({
    this.searchQuery,
    this.privacyType,
    this.sizeFilter,
    this.sortOption = GroupSortOption.newest,
    this.minMembers,
    this.maxMembers,
    this.isPTGroup,
    this.excludeGroupIds,
  });

  GroupSearchCriteria copyWith({
    String? searchQuery,
    GroupPrivacyType? privacyType,
    GroupSizeFilter? sizeFilter,
    GroupSortOption? sortOption,
    int? minMembers,
    int? maxMembers,
    bool? isPTGroup,
    List<String>? excludeGroupIds,
  }) {
    return GroupSearchCriteria(
      searchQuery: searchQuery ?? this.searchQuery,
      privacyType: privacyType ?? this.privacyType,
      sizeFilter: sizeFilter ?? this.sizeFilter,
      sortOption: sortOption ?? this.sortOption,
      minMembers: minMembers ?? this.minMembers,
      maxMembers: maxMembers ?? this.maxMembers,
      isPTGroup: isPTGroup ?? this.isPTGroup,
      excludeGroupIds: excludeGroupIds ?? this.excludeGroupIds,
    );
  }

  /// 검색 기준이 비어있는지 확인
  bool get isEmpty {
    return searchQuery == null || searchQuery!.trim().isEmpty;
  }

  /// 필터가 적용되어 있는지 확인
  bool get hasFilters {
    return privacyType != null ||
        sizeFilter != null ||
        minMembers != null ||
        maxMembers != null ||
        isPTGroup != null ||
        sortOption != GroupSortOption.newest;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is GroupSearchCriteria &&
        other.searchQuery == searchQuery &&
        other.privacyType == privacyType &&
        other.sizeFilter == sizeFilter &&
        other.sortOption == sortOption &&
        other.minMembers == minMembers &&
        other.maxMembers == maxMembers &&
        other.isPTGroup == isPTGroup;
  }

  @override
  int get hashCode {
    return Object.hash(
      searchQuery,
      privacyType,
      sizeFilter,
      sortOption,
      minMembers,
      maxMembers,
      isPTGroup,
    );
  }

  @override
  String toString() {
    return 'GroupSearchCriteria('
        'searchQuery: $searchQuery, '
        'privacyType: $privacyType, '
        'sizeFilter: $sizeFilter, '
        'sortOption: $sortOption, '
        'minMembers: $minMembers, '
        'maxMembers: $maxMembers, '
        'isPTGroup: $isPTGroup'
        ')';
  }
}

/// 그룹 크기 필터 옵션
enum GroupSizeFilter {
  small,    // 1-10명
  medium,   // 11-30명
  large,    // 31명 이상
}

extension GroupSizeFilterExtension on GroupSizeFilter {
  String get displayName {
    switch (this) {
      case GroupSizeFilter.small:
        return '소규모 (1-10명)';
      case GroupSizeFilter.medium:
        return '중규모 (11-30명)';
      case GroupSizeFilter.large:
        return '대규모 (31명 이상)';
    }
  }

  int get minMembers {
    switch (this) {
      case GroupSizeFilter.small:
        return 1;
      case GroupSizeFilter.medium:
        return 11;
      case GroupSizeFilter.large:
        return 31;
    }
  }

  int? get maxMembers {
    switch (this) {
      case GroupSizeFilter.small:
        return 10;
      case GroupSizeFilter.medium:
        return 30;
      case GroupSizeFilter.large:
        return null; // 무제한
    }
  }
}

/// 그룹 정렬 옵션
enum GroupSortOption {
  newest,       // 최신순
  oldest,       // 오래된순
  nameAsc,      // 이름 오름차순
  nameDesc,     // 이름 내림차순
  memberCount,  // 멤버 수 많은순
  activity,     // 활동량 많은순
}

extension GroupSortOptionExtension on GroupSortOption {
  String get displayName {
    switch (this) {
      case GroupSortOption.newest:
        return '최신순';
      case GroupSortOption.oldest:
        return '오래된순';
      case GroupSortOption.nameAsc:
        return '이름순 (가-하)';
      case GroupSortOption.nameDesc:
        return '이름순 (하-가)';
      case GroupSortOption.memberCount:
        return '멤버 수 많은순';
      case GroupSortOption.activity:
        return '활동량 많은순';
    }
  }

  String get sqlOrderBy {
    switch (this) {
      case GroupSortOption.newest:
        return 'created_at DESC';
      case GroupSortOption.oldest:
        return 'created_at ASC';
      case GroupSortOption.nameAsc:
        return 'name ASC';
      case GroupSortOption.nameDesc:
        return 'name DESC';
      case GroupSortOption.memberCount:
        return 'current_member_count DESC';
      case GroupSortOption.activity:
        return 'last_activity_at DESC NULLS LAST';
    }
  }
}