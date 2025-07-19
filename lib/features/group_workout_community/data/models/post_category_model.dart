import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/post_category.dart';

part 'post_category_model.g.dart';

@JsonSerializable(explicitToJson: true)
class PostCategoryModel extends PostCategory {
  const PostCategoryModel({
    required super.id,
    required super.name,
    required super.description,
    required super.iconUrl,
    required super.colorCode,
    required super.sortOrder,
    required super.isActive,
    required super.createdAt,
  });

  factory PostCategoryModel.fromJson(Map<String, dynamic> json) {
    return PostCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      iconUrl: json['icon_url'] as String? ?? '',
      colorCode: json['color_code'] as String? ?? '#6366F1',
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'color_code': colorCode,
      'sort_order': sortOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  PostCategory toEntity() {
    return PostCategory(
      id: id,
      name: name,
      description: description,
      iconUrl: iconUrl,
      colorCode: colorCode,
      sortOrder: sortOrder,
      isActive: isActive,
      createdAt: createdAt,
    );
  }

  factory PostCategoryModel.fromEntity(PostCategory entity) {
    return PostCategoryModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      iconUrl: entity.iconUrl,
      colorCode: entity.colorCode,
      sortOrder: entity.sortOrder,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
    );
  }
}