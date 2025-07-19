import 'package:equatable/equatable.dart';

/// 게시글 카테고리 도메인 엔티티
class PostCategory extends Equatable {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String colorCode;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;

  const PostCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.colorCode,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        iconUrl,
        colorCode,
        sortOrder,
        isActive,
        createdAt,
      ];

  PostCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? iconUrl,
    String? colorCode,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return PostCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      colorCode: colorCode ?? this.colorCode,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 카테고리가 활성화되어 있는지 확인
  bool get isEnabled => isActive;

  /// 카테고리 색상을 Color 객체로 변환하기 위한 헬퍼
  String get colorHex => colorCode.startsWith('#') ? colorCode : '#$colorCode';
}