// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommunityPostModel _$CommunityPostModelFromJson(Map<String, dynamic> json) =>
    CommunityPostModel(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      groupId: json['groupId'] as String?,
      title: json['title'] as String,
      content: json['content'] as String,
      postType: $enumDecode(_$PostTypeEnumMap, json['postType']),
      categoryId: json['categoryId'] as String,
      mediaUrls:
          (json['mediaUrls'] as List<dynamic>).map((e) => e as String).toList(),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      likesCount: (json['likesCount'] as num).toInt(),
      commentsCount: (json['commentsCount'] as num).toInt(),
      viewsCount: (json['viewsCount'] as num).toInt(),
      isPinned: json['isPinned'] as bool,
      isDeleted: json['isDeleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CommunityPostModelToJson(CommunityPostModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'authorId': instance.authorId,
      'groupId': instance.groupId,
      'title': instance.title,
      'content': instance.content,
      'postType': _$PostTypeEnumMap[instance.postType]!,
      'categoryId': instance.categoryId,
      'mediaUrls': instance.mediaUrls,
      'tags': instance.tags,
      'likesCount': instance.likesCount,
      'commentsCount': instance.commentsCount,
      'viewsCount': instance.viewsCount,
      'isPinned': instance.isPinned,
      'isDeleted': instance.isDeleted,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$PostTypeEnumMap = {
  PostType.text: 'text',
  PostType.image: 'image',
  PostType.video: 'video',
  PostType.workoutShare: 'workoutShare',
};
