import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/community_post.dart';

part 'community_post_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CommunityPostModel extends CommunityPost {
  const CommunityPostModel({
    required super.id,
    required super.authorId,
    super.groupId,
    required super.title,
    required super.content,
    required super.postType,
    required super.categoryId,
    required super.mediaUrls,
    required super.tags,
    required super.likesCount,
    required super.commentsCount,
    required super.viewsCount,
    required super.isPinned,
    required super.isDeleted,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CommunityPostModel.fromJson(Map<String, dynamic> json) {
    return CommunityPostModel(
      id: json['id'] as String,
      authorId: json['author_id'] as String,
      groupId: json['group_id'] as String?,
      title: json['title'] as String,
      content: json['content'] as String,
      postType: _parsePostType(json['post_type'] as String?),
      categoryId: json['category_id'] as String,
      mediaUrls: json['media_urls'] != null
          ? List<String>.from(json['media_urls'] as List)
          : <String>[],
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : <String>[],
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      viewsCount: json['views_count'] as int? ?? 0,
      isPinned: json['is_pinned'] as bool? ?? false,
      isDeleted: json['is_deleted'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  static PostType _parsePostType(String? value) {
    switch (value) {
      case 'image':
        return PostType.image;
      case 'video':
        return PostType.video;
      case 'workout_share':
        return PostType.workoutShare;
      case 'text':
      default:
        return PostType.text;
    }
  }

  static String _postTypeToString(PostType type) {
    switch (type) {
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author_id': authorId,
      'group_id': groupId,
      'title': title,
      'content': content,
      'post_type': _postTypeToString(postType),
      'category_id': categoryId,
      'media_urls': mediaUrls,
      'tags': tags,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'views_count': viewsCount,
      'is_pinned': isPinned,
      'is_deleted': isDeleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CommunityPost toEntity() {
    return CommunityPost(
      id: id,
      authorId: authorId,
      groupId: groupId,
      title: title,
      content: content,
      postType: postType,
      categoryId: categoryId,
      mediaUrls: mediaUrls,
      tags: tags,
      likesCount: likesCount,
      commentsCount: commentsCount,
      viewsCount: viewsCount,
      isPinned: isPinned,
      isDeleted: isDeleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory CommunityPostModel.fromEntity(CommunityPost entity) {
    return CommunityPostModel(
      id: entity.id,
      authorId: entity.authorId,
      groupId: entity.groupId,
      title: entity.title,
      content: entity.content,
      postType: entity.postType,
      categoryId: entity.categoryId,
      mediaUrls: entity.mediaUrls,
      tags: entity.tags,
      likesCount: entity.likesCount,
      commentsCount: entity.commentsCount,
      viewsCount: entity.viewsCount,
      isPinned: entity.isPinned,
      isDeleted: entity.isDeleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}