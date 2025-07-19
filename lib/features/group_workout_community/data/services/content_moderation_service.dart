import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/content_filter.dart';

class ContentModerationResult {
  final bool isBlocked;
  final bool isFlagged;
  final String? filteredContent;
  final List<String> triggeredFilters;
  final ContentFilterSeverity? highestSeverity;

  const ContentModerationResult({
    required this.isBlocked,
    required this.isFlagged,
    this.filteredContent,
    this.triggeredFilters = const [],
    this.highestSeverity,
  });

  bool get hasViolations => isBlocked || isFlagged;
}

class ContentModerationService {
  final SupabaseClient _supabaseClient;
  List<ContentFilter>? _cachedFilters;
  DateTime? _lastFilterUpdate;
  static const Duration _cacheExpiry = Duration(minutes: 30);

  ContentModerationService(this._supabaseClient);

  /// Moderate content and return moderation result
  Future<Either<Failure, ContentModerationResult>> moderateContent(
    String content,
  ) async {
    try {
      final filtersResult = await _getActiveFilters();
      if (filtersResult.isLeft()) {
        return Left(filtersResult.fold((l) => l, (r) => throw Exception()));
      }

      final filters = filtersResult.fold((l) => <ContentFilter>[], (r) => r);
      
      bool isBlocked = false;
      bool isFlagged = false;
      String? filteredContent = content;
      final List<String> triggeredFilters = [];
      ContentFilterSeverity? highestSeverity;

      for (final filter in filters) {
        final matchResult = _checkContentAgainstFilter(content, filter);
        
        if (matchResult.hasMatch) {
          triggeredFilters.add(filter.filterValue);
          
          // Update highest severity
          if (highestSeverity == null || 
              _getSeverityLevel(filter.severity) > _getSeverityLevel(highestSeverity)) {
            highestSeverity = filter.severity;
          }

          switch (filter.action) {
            case ContentFilterAction.block:
              isBlocked = true;
              break;
            case ContentFilterAction.flag:
              isFlagged = true;
              break;
            case ContentFilterAction.replace:
              if (filter.replacementText != null) {
                filteredContent = matchResult.replacedContent ?? filteredContent;
              }
              isFlagged = true;
              break;
          }
        }
      }

      return Right(ContentModerationResult(
        isBlocked: isBlocked,
        isFlagged: isFlagged,
        filteredContent: filteredContent,
        triggeredFilters: triggeredFilters,
        highestSeverity: highestSeverity,
      ));
    } catch (e) {
      return Left(ServerFailure('Content moderation failed: ${e.toString()}'));
    }
  }

  /// Get active content filters with caching
  Future<Either<Failure, List<ContentFilter>>> _getActiveFilters() async {
    try {
      // Check cache validity
      if (_cachedFilters != null && 
          _lastFilterUpdate != null &&
          DateTime.now().difference(_lastFilterUpdate!) < _cacheExpiry) {
        return Right(_cachedFilters!);
      }

      final response = await _supabaseClient
          .from('content_filters')
          .select()
          .eq('is_active', true)
          .order('severity', ascending: false);

      final filters = (response as List<dynamic>)
          .map((json) => _contentFilterFromJson(json))
          .toList();

      // Update cache
      _cachedFilters = filters;
      _lastFilterUpdate = DateTime.now();

      return Right(filters);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch content filters: ${e.toString()}'));
    }
  }

  /// Check content against a specific filter
  _FilterMatchResult _checkContentAgainstFilter(String content, ContentFilter filter) {
    final lowerContent = content.toLowerCase();
    
    switch (filter.filterType) {
      case ContentFilterType.keyword:
        final keyword = filter.filterValue.toLowerCase();
        if (lowerContent.contains(keyword)) {
          String? replacedContent;
          if (filter.action == ContentFilterAction.replace && filter.replacementText != null) {
            replacedContent = content.replaceAll(
              RegExp(RegExp.escape(filter.filterValue), caseSensitive: false),
              filter.replacementText!,
            );
          }
          return _FilterMatchResult(hasMatch: true, replacedContent: replacedContent);
        }
        break;
        
      case ContentFilterType.phrase:
        final phrase = filter.filterValue.toLowerCase();
        if (lowerContent.contains(phrase)) {
          String? replacedContent;
          if (filter.action == ContentFilterAction.replace && filter.replacementText != null) {
            replacedContent = content.replaceAll(
              RegExp(RegExp.escape(filter.filterValue), caseSensitive: false),
              filter.replacementText!,
            );
          }
          return _FilterMatchResult(hasMatch: true, replacedContent: replacedContent);
        }
        break;
        
      case ContentFilterType.regex:
        try {
          final regex = RegExp(filter.filterValue, caseSensitive: false);
          if (regex.hasMatch(content)) {
            String? replacedContent;
            if (filter.action == ContentFilterAction.replace && filter.replacementText != null) {
              replacedContent = content.replaceAll(regex, filter.replacementText!);
            }
            return _FilterMatchResult(hasMatch: true, replacedContent: replacedContent);
          }
        } catch (e) {
          // Invalid regex, skip this filter
          return const _FilterMatchResult(hasMatch: false);
        }
        break;
    }
    
    return const _FilterMatchResult(hasMatch: false);
  }

  /// Get numeric severity level for comparison
  int _getSeverityLevel(ContentFilterSeverity severity) {
    switch (severity) {
      case ContentFilterSeverity.low:
        return 1;
      case ContentFilterSeverity.medium:
        return 2;
      case ContentFilterSeverity.high:
        return 3;
    }
  }

  /// Convert JSON to ContentFilter entity
  ContentFilter _contentFilterFromJson(Map<String, dynamic> json) {
    return ContentFilter(
      id: json['id'] as String,
      filterType: ContentFilterTypeExtension.fromString(json['filter_type'] as String),
      filterValue: json['filter_value'] as String,
      filterCategory: ContentFilterCategoryExtension.fromString(json['filter_category'] as String),
      severity: ContentFilterSeverityExtension.fromString(json['severity'] as String),
      action: ContentFilterActionExtension.fromString(json['action'] as String),
      replacementText: json['replacement_text'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Clear filter cache (useful for testing or manual refresh)
  void clearFilterCache() {
    _cachedFilters = null;
    _lastFilterUpdate = null;
  }

  /// Add a new content filter
  Future<Either<Failure, ContentFilter>> addContentFilter({
    required ContentFilterType filterType,
    required String filterValue,
    required ContentFilterCategory filterCategory,
    required ContentFilterSeverity severity,
    required ContentFilterAction action,
    String? replacementText,
  }) async {
    try {
      final response = await _supabaseClient
          .from('content_filters')
          .insert({
            'filter_type': filterType.value,
            'filter_value': filterValue,
            'filter_category': filterCategory.value,
            'severity': severity.value,
            'action': action.value,
            'replacement_text': replacementText,
            'is_active': true,
          })
          .select()
          .single();

      final filter = _contentFilterFromJson(response);
      
      // Clear cache to force refresh
      clearFilterCache();
      
      return Right(filter);
    } catch (e) {
      return Left(ServerFailure('Failed to add content filter: ${e.toString()}'));
    }
  }

  /// Update content filter
  Future<Either<Failure, ContentFilter>> updateContentFilter({
    required String filterId,
    ContentFilterType? filterType,
    String? filterValue,
    ContentFilterCategory? filterCategory,
    ContentFilterSeverity? severity,
    ContentFilterAction? action,
    String? replacementText,
    bool? isActive,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (filterType != null) updateData['filter_type'] = filterType.value;
      if (filterValue != null) updateData['filter_value'] = filterValue;
      if (filterCategory != null) updateData['filter_category'] = filterCategory.value;
      if (severity != null) updateData['severity'] = severity.value;
      if (action != null) updateData['action'] = action.value;
      if (replacementText != null) updateData['replacement_text'] = replacementText;
      if (isActive != null) updateData['is_active'] = isActive;

      final response = await _supabaseClient
          .from('content_filters')
          .update(updateData)
          .eq('id', filterId)
          .select()
          .single();

      final filter = _contentFilterFromJson(response);
      
      // Clear cache to force refresh
      clearFilterCache();
      
      return Right(filter);
    } catch (e) {
      return Left(ServerFailure('Failed to update content filter: ${e.toString()}'));
    }
  }

  /// Delete content filter
  Future<Either<Failure, void>> deleteContentFilter(String filterId) async {
    try {
      await _supabaseClient
          .from('content_filters')
          .delete()
          .eq('id', filterId);

      // Clear cache to force refresh
      clearFilterCache();
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete content filter: ${e.toString()}'));
    }
  }

  /// Get all content filters (for admin management)
  Future<Either<Failure, List<ContentFilter>>> getAllContentFilters() async {
    try {
      final response = await _supabaseClient
          .from('content_filters')
          .select()
          .order('created_at', ascending: false);

      final filters = (response as List<dynamic>)
          .map((json) => _contentFilterFromJson(json))
          .toList();

      return Right(filters);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch all content filters: ${e.toString()}'));
    }
  }
}

class _FilterMatchResult {
  final bool hasMatch;
  final String? replacedContent;

  const _FilterMatchResult({
    required this.hasMatch,
    this.replacedContent,
  });
}