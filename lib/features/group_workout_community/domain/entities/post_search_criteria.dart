import 'community_post.dart';

/// 게시글 검색 기준을 정의하는 클래스
class PostSearchCriteria {
  final String? searchQuery;
  final String? categoryId;
  final String? authorId;
  final String? groupId; // null이면 전체 커뮤니티, 값이 있으면 특정 그룹
  final List<String>? tags;
  final PostSortOption sortOption;
  final DateTime? startDate;
  final DateTime? endDate;
  final PostType? postType;
  final bool? isPinned;
  final int? minLikes;
  final int? minComments;
  final List<String>? excludePostIds;

  const PostSearchCriteria({
    this.searchQuery,
    this.categoryId,
    this.authorId,
    this.groupId,
    this.tags,
    this.sortOption = PostSortOption.newest,
    this.startDate,
    this.endDate,
    this.postType,
    this.isPinned,
    this.minLikes,
    this.minComments,
    this.excludePostIds,
  });

  PostSearchCriteria copyWith({
    String? searchQuery,
    String? categoryId,
    String? authorId,
    String? groupId,
    List<String>? tags,
    PostSortOption? sortOption,
    DateTime? startDate,
    DateTime? endDate,
    PostType? postType,
    bool? isPinned,
    int? minLikes,
    int? minComments,
    List<String>? excludePostIds,
  }) {
    return PostSearchCriteria(
      searchQuery: searchQuery ?? this.searchQuery,
      categoryId: categoryId ?? this.categoryId,
      authorId: authorId ?? this.authorId,
      groupId: groupId ?? this.groupId,
      tags: tags ?? this.tags,
      sortOption: sortOption ?? this.sortOption,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      postType: postType ?? this.postType,
      isPinned: isPinned ?? this.isPinned,
      minLikes: minLikes ?? this.minLikes,
      minComments: minComments ?? this.minComments,
      excludePostIds: excludePostIds ?? this.excludePostIds,
    );
  }

  /// 검색 기준이 비어있는지 확인
  bool get isEmpty {
    return searchQuery == null || searchQuery!.trim().isEmpty;
  }

  /// 필터가 적용되어 있는지 확인
  bool get hasFilters {
    return categoryId != null ||
        authorId != null ||
        tags != null && tags!.isNotEmpty ||
        startDate != null ||
        endDate != null ||
        postType != null ||
        isPinned != null ||
        minLikes != null ||
        minComments != null ||
        sortOption != PostSortOption.newest;
  }

  /// 날짜 범위가 설정되어 있는지 확인
  bool get hasDateRange {
    return startDate != null || endDate != null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is PostSearchCriteria &&
        other.searchQuery == searchQuery &&
        other.categoryId == categoryId &&
        other.authorId == authorId &&
        other.groupId == groupId &&
        _listEquals(other.tags, tags) &&
        other.sortOption == sortOption &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.postType == postType &&
        other.isPinned == isPinned &&
        other.minLikes == minLikes &&
        other.minComments == minComments;
  }

  @override
  int get hashCode {
    return Object.hash(
      searchQuery,
      categoryId,
      authorId,
      groupId,
      tags,
      sortOption,
      startDate,
      endDate,
      postType,
      isPinned,
      minLikes,
      minComments,
    );
  }

  @override
  String toString() {
    return 'PostSearchCriteria('
        'searchQuery: $searchQuery, '
        'categoryId: $categoryId, '
        'authorId: $authorId, '
        'groupId: $groupId, '
        'tags: $tags, '
        'sortOption: $sortOption, '
        'startDate: $startDate, '
        'endDate: $endDate, '
        'postType: $postType, '
        'isPinned: $isPinned, '
        'minLikes: $minLikes, '
        'minComments: $minComments'
        ')';
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}

/// 게시글 정렬 옵션
enum PostSortOption {
  newest,       // 최신순
  oldest,       // 오래된순
  popular,      // 인기순 (좋아요 + 댓글)
  mostLiked,    // 좋아요 많은순
  mostCommented, // 댓글 많은순
  mostViewed,   // 조회수 많은순
  trending,     // 트렌딩 (최근 활동량 기준)
}

extension PostSortOptionExtension on PostSortOption {
  String get displayName {
    switch (this) {
      case PostSortOption.newest:
        return '최신순';
      case PostSortOption.oldest:
        return '오래된순';
      case PostSortOption.popular:
        return '인기순';
      case PostSortOption.mostLiked:
        return '좋아요 많은순';
      case PostSortOption.mostCommented:
        return '댓글 많은순';
      case PostSortOption.mostViewed:
        return '조회수 많은순';
      case PostSortOption.trending:
        return '트렌딩';
    }
  }

  String get sqlOrderBy {
    switch (this) {
      case PostSortOption.newest:
        return 'created_at DESC';
      case PostSortOption.oldest:
        return 'created_at ASC';
      case PostSortOption.popular:
        return '(likes_count + comments_count) DESC';
      case PostSortOption.mostLiked:
        return 'likes_count DESC';
      case PostSortOption.mostCommented:
        return 'comments_count DESC';
      case PostSortOption.mostViewed:
        return 'views_count DESC';
      case PostSortOption.trending:
        return 'updated_at DESC';
    }
  }
}

// PostType is imported from community_post.dart

/// 게시글 날짜 필터 옵션
enum PostDateFilter {
  today,        // 오늘
  thisWeek,     // 이번 주
  thisMonth,    // 이번 달
  lastMonth,    // 지난 달
  last3Months,  // 최근 3개월
  custom,       // 사용자 지정
}

extension PostDateFilterExtension on PostDateFilter {
  String get displayName {
    switch (this) {
      case PostDateFilter.today:
        return '오늘';
      case PostDateFilter.thisWeek:
        return '이번 주';
      case PostDateFilter.thisMonth:
        return '이번 달';
      case PostDateFilter.lastMonth:
        return '지난 달';
      case PostDateFilter.last3Months:
        return '최근 3개월';
      case PostDateFilter.custom:
        return '사용자 지정';
    }
  }

  DateTime get startDate {
    final now = DateTime.now();
    switch (this) {
      case PostDateFilter.today:
        return DateTime(now.year, now.month, now.day);
      case PostDateFilter.thisWeek:
        final weekday = now.weekday;
        return now.subtract(Duration(days: weekday - 1));
      case PostDateFilter.thisMonth:
        return DateTime(now.year, now.month, 1);
      case PostDateFilter.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        return lastMonth;
      case PostDateFilter.last3Months:
        return DateTime(now.year, now.month - 3, now.day);
      case PostDateFilter.custom:
        return now.subtract(const Duration(days: 365)); // Default to 1 year ago
    }
  }

  DateTime? get endDate {
    final now = DateTime.now();
    switch (this) {
      case PostDateFilter.today:
        return DateTime(now.year, now.month, now.day, 23, 59, 59);
      case PostDateFilter.thisWeek:
        final weekday = now.weekday;
        return now.add(Duration(days: 7 - weekday));
      case PostDateFilter.thisMonth:
        final nextMonth = DateTime(now.year, now.month + 1, 1);
        return nextMonth.subtract(const Duration(days: 1));
      case PostDateFilter.lastMonth:
        return DateTime(now.year, now.month, 1).subtract(const Duration(days: 1));
      case PostDateFilter.last3Months:
      case PostDateFilter.custom:
        return null; // No end date for these filters
    }
  }
}