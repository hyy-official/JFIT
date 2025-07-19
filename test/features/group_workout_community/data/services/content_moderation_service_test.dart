import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:jfit/core/services/supabase_service.dart';
import 'package:jfit/features/group_workout_community/data/services/content_moderation_service.dart';
import 'package:jfit/features/group_workout_community/domain/entities/content_filter.dart';

import 'content_moderation_service_test.mocks.dart';

@GenerateMocks([SupabaseService])
void main() {
  late ContentModerationService contentModerationService;
  late MockSupabaseService mockSupabaseService;

  setUp(() {
    mockSupabaseService = MockSupabaseService();
    contentModerationService = ContentModerationService(mockSupabaseService);
  });

  group('ContentModerationService', () {
    test('should block content with high severity violations', () async {
      // Arrange
      const testContent = 'This is spam content with scam links';
      
      when(mockSupabaseService.client).thenReturn(MockSupabaseClient());
      
      // Mock the database response for content filters
      final mockFilters = [
        {
          'id': '1',
          'filter_type': 'keyword',
          'filter_value': 'spam',
          'filter_category': 'spam',
          'severity': 'high',
          'action': 'block',
          'replacement_text': null,
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        {
          'id': '2',
          'filter_type': 'keyword',
          'filter_value': 'scam',
          'filter_category': 'spam',
          'severity': 'high',
          'action': 'block',
          'replacement_text': null,
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      ];

      // Mock the Supabase query chain
      final mockQuery = MockPostgrestFilterBuilder();
      when(mockSupabaseService.client.from('content_filters')).thenReturn(mockQuery);
      when(mockQuery.select()).thenReturn(mockQuery);
      when(mockQuery.eq('is_active', true)).thenReturn(mockQuery);
      when(mockQuery.order('severity', ascending: false)).thenReturn(mockFilters);

      // Act
      final result = await contentModerationService.moderateContent(testContent);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected success but got failure: ${failure.message}'),
        (moderationResult) {
          expect(moderationResult.isBlocked, true);
          expect(moderationResult.triggeredFilters.length, greaterThan(0));
          expect(moderationResult.highestSeverity, ContentFilterSeverity.high);
        },
      );
    });

    test('should flag content with medium severity violations', () async {
      // Arrange
      const testContent = 'Click here for amazing deals!';
      
      when(mockSupabaseService.client).thenReturn(MockSupabaseClient());
      
      // Mock the database response for content filters
      final mockFilters = [
        {
          'id': '1',
          'filter_type': 'phrase',
          'filter_value': 'click here',
          'filter_category': 'spam',
          'severity': 'medium',
          'action': 'flag',
          'replacement_text': null,
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      ];

      // Mock the Supabase query chain
      final mockQuery = MockPostgrestFilterBuilder();
      when(mockSupabaseService.client.from('content_filters')).thenReturn(mockQuery);
      when(mockQuery.select()).thenReturn(mockQuery);
      when(mockQuery.eq('is_active', true)).thenReturn(mockQuery);
      when(mockQuery.order('severity', ascending: false)).thenReturn(mockFilters);

      // Act
      final result = await contentModerationService.moderateContent(testContent);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected success but got failure: ${failure.message}'),
        (moderationResult) {
          expect(moderationResult.isBlocked, false);
          expect(moderationResult.isFlagged, true);
          expect(moderationResult.triggeredFilters, contains('click here'));
          expect(moderationResult.highestSeverity, ContentFilterSeverity.medium);
        },
      );
    });

    test('should replace content with replacement text', () async {
      // Arrange
      const testContent = 'This content has badword in it';
      
      when(mockSupabaseService.client).thenReturn(MockSupabaseClient());
      
      // Mock the database response for content filters
      final mockFilters = [
        {
          'id': '1',
          'filter_type': 'keyword',
          'filter_value': 'badword',
          'filter_category': 'profanity',
          'severity': 'medium',
          'action': 'replace',
          'replacement_text': '***',
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      ];

      // Mock the Supabase query chain
      final mockQuery = MockPostgrestFilterBuilder();
      when(mockSupabaseService.client.from('content_filters')).thenReturn(mockQuery);
      when(mockQuery.select()).thenReturn(mockQuery);
      when(mockQuery.eq('is_active', true)).thenReturn(mockQuery);
      when(mockQuery.order('severity', ascending: false)).thenReturn(mockFilters);

      // Act
      final result = await contentModerationService.moderateContent(testContent);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected success but got failure: ${failure.message}'),
        (moderationResult) {
          expect(moderationResult.isBlocked, false);
          expect(moderationResult.isFlagged, true);
          expect(moderationResult.filteredContent, 'This content has *** in it');
          expect(moderationResult.triggeredFilters, contains('badword'));
        },
      );
    });

    test('should allow clean content without violations', () async {
      // Arrange
      const testContent = 'This is a perfectly normal and clean message about fitness.';
      
      when(mockSupabaseService.client).thenReturn(MockSupabaseClient());
      
      // Mock empty filters response
      final mockFilters = <Map<String, dynamic>>[];

      // Mock the Supabase query chain
      final mockQuery = MockPostgrestFilterBuilder();
      when(mockSupabaseService.client.from('content_filters')).thenReturn(mockQuery);
      when(mockQuery.select()).thenReturn(mockQuery);
      when(mockQuery.eq('is_active', true)).thenReturn(mockQuery);
      when(mockQuery.order('severity', ascending: false)).thenReturn(mockFilters);

      // Act
      final result = await contentModerationService.moderateContent(testContent);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected success but got failure: ${failure.message}'),
        (moderationResult) {
          expect(moderationResult.isBlocked, false);
          expect(moderationResult.isFlagged, false);
          expect(moderationResult.filteredContent, testContent);
          expect(moderationResult.triggeredFilters, isEmpty);
          expect(moderationResult.highestSeverity, isNull);
        },
      );
    });

    test('should handle regex filters correctly', () async {
      // Arrange
      const testContent = 'Contact me at john@example.com for more info';
      
      when(mockSupabaseService.client).thenReturn(MockSupabaseClient());
      
      // Mock the database response for regex filter
      final mockFilters = [
        {
          'id': '1',
          'filter_type': 'regex',
          'filter_value': r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
          'filter_category': 'inappropriate',
          'severity': 'medium',
          'action': 'flag',
          'replacement_text': null,
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
      ];

      // Mock the Supabase query chain
      final mockQuery = MockPostgrestFilterBuilder();
      when(mockSupabaseService.client.from('content_filters')).thenReturn(mockQuery);
      when(mockQuery.select()).thenReturn(mockQuery);
      when(mockQuery.eq('is_active', true)).thenReturn(mockQuery);
      when(mockQuery.order('severity', ascending: false)).thenReturn(mockFilters);

      // Act
      final result = await contentModerationService.moderateContent(testContent);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected success but got failure: ${failure.message}'),
        (moderationResult) {
          expect(moderationResult.isBlocked, false);
          expect(moderationResult.isFlagged, true);
          expect(moderationResult.triggeredFilters.length, 1);
          expect(moderationResult.highestSeverity, ContentFilterSeverity.medium);
        },
      );
    });
  });
}

// Mock classes for testing
class MockSupabaseClient extends Mock {}
class MockPostgrestFilterBuilder extends Mock {}