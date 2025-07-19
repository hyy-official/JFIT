import 'package:equatable/equatable.dart';

/// 게시글 댓글 도메인 엔티티
class PostComment extends Equatable {
  final String id;
  final String postId;
  final String authorId;
  final String? parentCommentId; // 대댓글용
  final String content;
  final int likesCount;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PostComment({
    required this.id,
    required this.postId,
    required this.authorId,
    this.parentCommentId,
    required this.content,
    required this.likesCount,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        postId,
        authorId,
        parentCommentId,
        content,
        likesCount,
        isDeleted,
        createdAt,
        updatedAt,
      ];

  PostComment copyWith({
    String? id,
    String? postId,
    String? authorId,
    String? parentCommentId,
    String? content,
    int? likesCount,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostComment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      content: content ?? this.content,
      likesCount: likesCount ?? this.likesCount,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 댓글이 대댓글인지 확인
  bool get isReply => parentCommentId != null;

  /// 댓글이 최상위 댓글인지 확인
  bool get isTopLevel => parentCommentId == null;

  /// 댓글이 활성화되어 있는지 확인 (삭제되지 않음)
  bool get isActive => !isDeleted;

  /// 댓글이 인기 있는지 확인 (좋아요 5개 이상)
  bool get isPopular => likesCount >= 5;

  /// 댓글이 최근에 작성되었는지 확인 (1시간 이내)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours <= 1;
  }

  /// 댓글이 수정되었는지 확인
  bool get isEdited => updatedAt.isAfter(createdAt);

  /// 댓글 내용이 비어있지 않은지 확인
  bool get hasContent => content.trim().isNotEmpty;
}