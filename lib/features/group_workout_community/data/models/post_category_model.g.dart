// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostCategoryModel _$PostCategoryModelFromJson(Map<String, dynamic> json) =>
    PostCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String,
      colorCode: json['colorCode'] as String,
      sortOrder: (json['sortOrder'] as num).toInt(),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$PostCategoryModelToJson(PostCategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'iconUrl': instance.iconUrl,
      'colorCode': instance.colorCode,
      'sortOrder': instance.sortOrder,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
    };
