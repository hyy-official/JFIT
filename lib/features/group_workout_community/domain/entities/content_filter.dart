import 'package:equatable/equatable.dart';

enum ContentFilterType {
  keyword,
  regex,
  phrase,
}

enum ContentFilterCategory {
  profanity,
  spam,
  harassment,
  hateSpeech,
  inappropriate,
  promotional,
}

enum ContentFilterSeverity {
  low,
  medium,
  high,
}

enum ContentFilterAction {
  flag,
  block,
  replace,
}

class ContentFilter extends Equatable {
  final String id;
  final ContentFilterType filterType;
  final String filterValue;
  final ContentFilterCategory filterCategory;
  final ContentFilterSeverity severity;
  final ContentFilterAction action;
  final String? replacementText;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ContentFilter({
    required this.id,
    required this.filterType,
    required this.filterValue,
    required this.filterCategory,
    required this.severity,
    required this.action,
    this.replacementText,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  ContentFilter copyWith({
    String? id,
    ContentFilterType? filterType,
    String? filterValue,
    ContentFilterCategory? filterCategory,
    ContentFilterSeverity? severity,
    ContentFilterAction? action,
    String? replacementText,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContentFilter(
      id: id ?? this.id,
      filterType: filterType ?? this.filterType,
      filterValue: filterValue ?? this.filterValue,
      filterCategory: filterCategory ?? this.filterCategory,
      severity: severity ?? this.severity,
      action: action ?? this.action,
      replacementText: replacementText ?? this.replacementText,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        filterType,
        filterValue,
        filterCategory,
        severity,
        action,
        replacementText,
        isActive,
        createdAt,
        updatedAt,
      ];
}

extension ContentFilterTypeExtension on ContentFilterType {
  String get value {
    switch (this) {
      case ContentFilterType.keyword:
        return 'keyword';
      case ContentFilterType.regex:
        return 'regex';
      case ContentFilterType.phrase:
        return 'phrase';
    }
  }

  static ContentFilterType fromString(String value) {
    switch (value) {
      case 'keyword':
        return ContentFilterType.keyword;
      case 'regex':
        return ContentFilterType.regex;
      case 'phrase':
        return ContentFilterType.phrase;
      default:
        return ContentFilterType.keyword;
    }
  }
}

extension ContentFilterCategoryExtension on ContentFilterCategory {
  String get displayName {
    switch (this) {
      case ContentFilterCategory.profanity:
        return 'Profanity';
      case ContentFilterCategory.spam:
        return 'Spam';
      case ContentFilterCategory.harassment:
        return 'Harassment';
      case ContentFilterCategory.hateSpeech:
        return 'Hate Speech';
      case ContentFilterCategory.inappropriate:
        return 'Inappropriate';
      case ContentFilterCategory.promotional:
        return 'Promotional';
    }
  }

  String get value {
    switch (this) {
      case ContentFilterCategory.profanity:
        return 'profanity';
      case ContentFilterCategory.spam:
        return 'spam';
      case ContentFilterCategory.harassment:
        return 'harassment';
      case ContentFilterCategory.hateSpeech:
        return 'hate_speech';
      case ContentFilterCategory.inappropriate:
        return 'inappropriate';
      case ContentFilterCategory.promotional:
        return 'promotional';
    }
  }

  static ContentFilterCategory fromString(String value) {
    switch (value) {
      case 'profanity':
        return ContentFilterCategory.profanity;
      case 'spam':
        return ContentFilterCategory.spam;
      case 'harassment':
        return ContentFilterCategory.harassment;
      case 'hate_speech':
        return ContentFilterCategory.hateSpeech;
      case 'inappropriate':
        return ContentFilterCategory.inappropriate;
      case 'promotional':
        return ContentFilterCategory.promotional;
      default:
        return ContentFilterCategory.inappropriate;
    }
  }
}

extension ContentFilterSeverityExtension on ContentFilterSeverity {
  String get value {
    switch (this) {
      case ContentFilterSeverity.low:
        return 'low';
      case ContentFilterSeverity.medium:
        return 'medium';
      case ContentFilterSeverity.high:
        return 'high';
    }
  }

  static ContentFilterSeverity fromString(String value) {
    switch (value) {
      case 'low':
        return ContentFilterSeverity.low;
      case 'medium':
        return ContentFilterSeverity.medium;
      case 'high':
        return ContentFilterSeverity.high;
      default:
        return ContentFilterSeverity.medium;
    }
  }
}

extension ContentFilterActionExtension on ContentFilterAction {
  String get displayName {
    switch (this) {
      case ContentFilterAction.flag:
        return 'Flag for Review';
      case ContentFilterAction.block:
        return 'Block Content';
      case ContentFilterAction.replace:
        return 'Replace Content';
    }
  }

  String get value {
    switch (this) {
      case ContentFilterAction.flag:
        return 'flag';
      case ContentFilterAction.block:
        return 'block';
      case ContentFilterAction.replace:
        return 'replace';
    }
  }

  static ContentFilterAction fromString(String value) {
    switch (value) {
      case 'flag':
        return ContentFilterAction.flag;
      case 'block':
        return ContentFilterAction.block;
      case 'replace':
        return ContentFilterAction.replace;
      default:
        return ContentFilterAction.flag;
    }
  }
}