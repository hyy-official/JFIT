import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/post_like.dart';
import '../../domain/entities/community_post.dart';

part 'post_like_model.g.dart';

@JsonSerializable(explicitToJson: true)
class PostLikeModel extends PostLike {
  const PostLikeModel({
    required super.id,
    super.postId,
    super.commentId,
    required super.userId,
    required super.likeType,
    required super.createdAt,
  });

  factory PostLikeModel.fromJson(Map<String, dynamic> json) {
    return PostLikeModel(
      id: json['id'] as String,
      postId: json['post_id'] as String?,
      commentId: json['comment_id'] as String?,
      userId: json['user_id'] as String,
      likeType: _parseLikeType(json['like_type'] as String?),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  static LikeType _parseLikeType(String? value) {
    switch (value) {
      case 'dislike':
        return LikeType.dislike;
      case 'like':
      default:
        return LikeType.like;
    }
  }

  static String _likeTypeToString(LikeType type) {
    switch (type) {
      case LikeType.like:
        return 'like';
      case LikeType.dislike:
        return 'dislike';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'comment_id': commentId,
      'user_id': userId,
      'like_type': _likeTypeToString(likeType),
      'created_at': createdAt.toIso8601String(),
    };
  }

  PostLike toEntity() {
    return PostLike(
      id: id,
      postId: postId,
      commentId: commentId,
      userId: userId,
      likeType: likeType,
      createdAt: createdAt,
    );
  }

  factory PostLikeModel.fromEntity(PostLike entity) {
    return PostLikeModel(
      id: entity.id,
      postId: entity.postId,
      commentId: entity.commentId,
      userId: entity.userId,
      likeType: entity.likeType,
      createdAt: entity.createdAt,
    );
  }
}