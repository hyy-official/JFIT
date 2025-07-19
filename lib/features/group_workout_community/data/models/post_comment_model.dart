import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/post_comment.dart';

part 'post_comment_model.g.dart';

@JsonSerializable(explicitToJson: true)
class PostCommentModel extends PostComment {
  const PostCommentModel({
    required super.id,
    required super.postId,
    required super.authorId,
    super.parentCommentId,
    required super.content,
    required super.likesCount,
    required super.isDeleted,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PostCommentModel.fromJson(Map<String, dynamic> json) {
    return PostCommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      authorId: json['author_id'] as String,
      parentCommentId: json['parent_comment_id'] as String?,
      content: json['content'] as String,
      likesCount: json['likes_count'] as int? ?? 0,
      isDeleted: json['is_deleted'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'author_id': authorId,
      'parent_comment_id': parentCommentId,
      'content': content,
      'likes_count': likesCount,
      'is_deleted': isDeleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PostComment toEntity() {
    return PostComment(
      id: id,
      postId: postId,
      authorId: authorId,
      parentCommentId: parentCommentId,
      content: content,
      likesCount: likesCount,
      isDeleted: isDeleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory PostCommentModel.fromEntity(PostComment entity) {
    return PostCommentModel(
      id: entity.id,
      postId: entity.postId,
      authorId: entity.authorId,
      parentCommentId: entity.parentCommentId,
      content: entity.content,
      likesCount: entity.likesCount,
      isDeleted: entity.isDeleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}