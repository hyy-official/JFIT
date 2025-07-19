// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_like_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostLikeModel _$PostLikeModelFromJson(Map<String, dynamic> json) =>
    PostLikeModel(
      id: json['id'] as String,
      postId: json['postId'] as String?,
      commentId: json['commentId'] as String?,
      userId: json['userId'] as String,
      likeType: $enumDecode(_$LikeTypeEnumMap, json['likeType']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$PostLikeModelToJson(PostLikeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'postId': instance.postId,
      'commentId': instance.commentId,
      'userId': instance.userId,
      'likeType': _$LikeTypeEnumMap[instance.likeType]!,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$LikeTypeEnumMap = {
  LikeType.like: 'like',
  LikeType.dislike: 'dislike',
};
