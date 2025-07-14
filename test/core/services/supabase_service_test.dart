import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/core/services/supabase_service.dart';
import 'package:jfit/features/analytics/domain/entities/diet_score_data.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service_test.mocks.dart';

// We only need to mock the top-level classes we interact with.
@GenerateMocks([SupabaseClient, GoTrueClient, PostgrestFilterBuilder])
void main() {
  late SupabaseService supabaseService;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late MockPostgrestFilterBuilder<List<Map<String, dynamic>>> mockPostgrestFilterBuilder;

  setUp(() {
    // Create fresh mocks for each test
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    mockPostgrestFilterBuilder = MockPostgrestFilterBuilder<List<Map<String, dynamic>>>();

    // Instantiate the service with the mock client
    supabaseService = SupabaseService(mockSupabaseClient);

    // Mock the authentication part
    when(mockSupabaseClient.auth).thenReturn(mockGoTrueClient);

    // Mock the entire chain of Supabase calls to return the final filter builder
    // This is a simplified way to handle the fluent API
    when(mockSupabaseClient.from(any)
      .select(any)
      .eq(any, any)
      .gte(any, any)
      .lte(any, any)
      .order(any, ascending: anyNamed('ascending')))
    .thenReturn(mockPostgrestFilterBuilder);
  });

  group('getDietScoreData', () {
    final user = User(
      id: 'test-user-id',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
    );

    test('returns empty list when not authenticated', () async {
      // Arrange
      when(mockGoTrueClient.currentUser).thenReturn(null);

      // Act
      final result = await supabaseService.getDietScoreData('7d');

      // Assert
      expect(result, isEmpty);
    });

    test('returns diet score data when authenticated and data is available', () async {
      // Arrange
      when(mockGoTrueClient.currentUser).thenReturn(user);
      final responseData = <Map<String, dynamic>>[
        {'entry_date': '2024-07-10', 'calories': 1500.0},
        {'entry_date': '2024-07-11', 'calories': 2500.0},
      ];
      
      // The PostgrestFilterBuilder is a Future, so we can use thenAnswer to return the data.
      when(mockPostgrestFilterBuilder.then(any)).thenAnswer((realInvocation) async {
        final onValue = realInvocation.positionalArguments.first as Function(List<Map<String, dynamic>>);
        return onValue(responseData);
      });

      // Act
      final result = await supabaseService.getDietScoreData('7d');

      // Assert
      expect(result, isA<List<DietScoreData>>());
      expect(result.length, 2);
      expect(result[0].score, 4.0);
      expect(result[1].score, 3.0);
    });

    test('returns empty list on exception', () async {
      // Arrange
      when(mockGoTrueClient.currentUser).thenReturn(user);
      
      // Mock the chain to throw an exception
      when(mockPostgrestFilterBuilder.then(any, onError: anyNamed('onError')))
          .thenAnswer((realInvocation) async {
        final onError = realInvocation.namedArguments[#onError] as Function;
        onError(Exception('DB Error'), StackTrace.empty);
      });

      // Act
      final result = await supabaseService.getDietScoreData('7d');

      // Assert
      expect(result, isEmpty);
    });
  });
}