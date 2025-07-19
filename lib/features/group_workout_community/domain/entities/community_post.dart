import 'package:equatable/equatable.dart';

/// 게시글 타입
enum PostType {
  text,
  image,
  video,
  workoutShare,
}

extension PostTypeExtension on PostType {
  String get value {
    switch (this) {
      case PostType.text:
        return 'text';
      case PostType.image:
        return 'image';
      case PostType.video:
        return 'video';
      case PostType.workoutShare:
        return 'workout_share';
    }
  }
}

/// 좋아요 타입
enum LikeType {
  like,
  dislike,
}

/// 커뮤니티 게시글 도메인 엔티티
class CommunityPost extends Equatable {
  final String id;
  final String authorId;
  final String? groupId; // null이면 전체 커뮤니티 게시글
  final String title;
  final String content;
  final PostType postType;
  final String categoryId;
  final List<String> mediaUrls;
  final List<String> tags;
  final int likesCount;
  final int commentsCount;
  final int viewsCount;
  final bool isPinned;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CommunityPost({
    required this.id,
    required this.authorId,
    this.groupId,
    required this.title,
    required this.content,
    required this.postType,
    required this.categoryId,
    required this.mediaUrls,
    required this.tags,
    required this.likesCount,
    required this.commentsCount,
    required this.viewsCount,
    required this.isPinned,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        authorId,
        groupId,
        title,
        content,
        postType,
        categoryId,
        mediaUrls,
        tags,
        likesCount,
        commentsCount,
        viewsCount,
        isPinned,
        isDeleted,
        createdAt,
        updatedAt,
      ];

  CommunityPost copyWith({
    String? id,
    String? authorId,
    String? groupId,
    String? title,
    String? content,
    PostType? postType,
    String? categoryId,
    List<String>? mediaUrls,
    List<String>? tags,
    int? likesCount,
    int? commentsCount,
    int? viewsCount,
    bool? isPinned,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      groupId: groupId ?? this.groupId,
      title: title ?? this.title,
      content: content ?? this.content,
      postType: postType ?? this.postType,
      categoryId: categoryId ?? this.categoryId,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      tags: tags ?? this.tags,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      viewsCount: viewsCount ?? this.viewsCount,
      isPinned: isPinned ?? this.isPinned,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 게시글이 그룹 전용인지 확인
  bool get isGroupPost => groupId != null;

  /// 게시글이 전체 커뮤니티용인지 확인
  bool get isPublicPost => groupId == null;

  /// 게시글이 미디어를 포함하는지 확인
  bool get hasMedia => mediaUrls.isNotEmpty;

  /// 게시글이 이미지를 포함하는지 확인
  bool get hasImages => postType == PostType.image && hasMedia;

  /// 게시글이 비디오를 포함하는지 확인
  bool get hasVideos => postType == PostType.video && hasMedia;

  /// 게시글이 운동 공유인지 확인
  bool get isWorkoutShare => postType == PostType.workoutShare;

  /// 게시글이 인기 있는지 확인 (좋아요 10개 이상 또는 댓글 5개 이상)
  bool get isPopular => likesCount >= 10 || commentsCount >= 5;

  /// 게시글이 활성화되어 있는지 확인 (삭제되지 않음)
  bool get isActive => !isDeleted;

  /// 게시글에 태그가 있는지 확인
  bool get hasTags => tags.isNotEmpty;

  /// 특정 태그가 포함되어 있는지 확인
  bool hasTag(String tag) => tags.contains(tag);

  /// 게시글이 최근에 작성되었는지 확인 (24시간 이내)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours <= 24;
  }

  /// 게시글이 수정되었는지 확인
  bool get isEdited => updatedAt.isAfter(createdAt);
}