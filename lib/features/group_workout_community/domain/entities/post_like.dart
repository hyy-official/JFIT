import 'package:equatable/equatable.dart';
import 'community_post.dart';

/// 게시글/댓글 좋아요 도메인 엔티티
class PostLike extends Equatable {
  final String id;
  final String? postId;
  final String? commentId; // null이면 게시글 좋아요, 값이 있으면 댓글 좋아요
  final String userId;
  final LikeType likeType; // like, dislike
  final DateTime createdAt;

  const PostLike({
    required this.id,
    this.postId,
    this.commentId,
    required this.userId,
    required this.likeType,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        postId,
        commentId,
        userId,
        likeType,
        createdAt,
      ];

  PostLike copyWith({
    String? id,
    String? postId,
    String? commentId,
    String? userId,
    LikeType? likeType,
    DateTime? createdAt,
  }) {
    return PostLike(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      commentId: commentId ?? this.commentId,
      userId: userId ?? this.userId,
      likeType: likeType ?? this.likeType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 게시글에 대한 좋아요인지 확인
  bool get isPostLike => postId != null && commentId == null;

  /// 댓글에 대한 좋아요인지 확인
  bool get isCommentLike => commentId != null && postId == null;

  /// 좋아요인지 확인
  bool get isLike => likeType == LikeType.like;

  /// 싫어요인지 확인
  bool get isDislike => likeType == LikeType.dislike;

  /// 좋아요가 최근에 생성되었는지 확인 (1시간 이내)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours <= 1;
  }
}