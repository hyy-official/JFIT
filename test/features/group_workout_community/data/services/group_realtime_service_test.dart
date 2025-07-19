import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jfit/features/group_workout_community/data/services/group_realtime_service.dart';
import 'package:jfit/features/group_workout_community/domain/entities/group_activity.dart';

// Generate mocks
@GenerateMocks([SupabaseClient, RealtimeChannel, User])
import 'group_realtime_service_test.mocks.dart';

void main() {
  group('GroupRealtimeService', () {
    late GroupRealtimeService service;
    late MockSupabaseClient mockSupabaseClient;
    late MockRealtimeChannel mockChannel;
    late MockUser mockUser;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockChannel = MockRealtimeChannel();
      mockUser = MockUser();
      service = GroupRealtimeService(mockSupabaseClient);

      // Setup auth mock
      when(mockSupabaseClient.auth).thenReturn(
        MockGoTrueClient()..currentUser = mockUser,
      );
      when(mockUser.id).thenReturn('test-user-id');
    });

    group('subscribeToGroupActivities', () {
      test('should create channel and set up subscription', () async {
        // Arrange
        const groupId = 'test-group-id';
        when(mockSupabaseClient.channel(any)).thenReturn(mockChannel);
        when(mockChannel.onPostgresChanges(
          event: anyNamed('event'),
          schema: anyNamed('schema'),
          table: anyNamed('table'),
          filter: anyNamed('filter'),
        )).thenReturn(mockChannel);
        when(mockChannel.subscribe(any)).thenReturn(mockChannel);

        // Mock the database query for initial data
        when(mockSupabaseClient.from('group_activities')).thenReturn(
          MockPostgrestQueryBuilder(),
        );

        // Act
        final stream = service.subscribeToGroupActivities(groupId);

        // Assert
        expect(stream, isA<Stream<List<GroupActivity>>>());
        verify(mockSupabaseClient.channel('group_activities_$groupId')).called(1);
        verify(mockChannel.onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'group_activities',
          filter: any,
        )).called(1);
      });

      test('should handle subscription errors gracefully', () async {
        // Arrange
        const groupId = 'test-group-id';
        when(mockSupabaseClient.channel(any)).thenReturn(mockChannel);
        when(mockChannel.onPostgresChanges(
          event: anyNamed('event'),
          schema: anyNamed('schema'),
          table: anyNamed('table'),
          filter: anyNamed('filter'),
        )).thenReturn(mockChannel);
        
        // Simulate subscription error
        when(mockChannel.subscribe(any)).thenAnswer((invocation) {
          final callback = invocation.positionalArguments[0] as Function;
          callback(RealtimeSubscribeStatus.channelError, 'Test error');
          return mockChannel;
        });

        // Mock the database query for initial data
        when(mockSupabaseClient.from('group_activities')).thenReturn(
          MockPostgrestQueryBuilder(),
        );

        // Act
        final stream = service.subscribeToGroupActivities(groupId);

        // Assert
        expect(stream, isA<Stream<List<GroupActivity>>>());
        // The stream should handle errors without throwing
      });
    });

    group('subscribeToGroupMessages', () {
      test('should create channel for group messages', () async {
        // Arrange
        const groupId = 'test-group-id';
        when(mockSupabaseClient.channel(any)).thenReturn(mockChannel);
        when(mockChannel.onPostgresChanges(
          event: anyNamed('event'),
          schema: anyNamed('schema'),
          table: anyNamed('table'),
          filter: anyNamed('filter'),
        )).thenReturn(mockChannel);
        when(mockChannel.subscribe(any)).thenReturn(mockChannel);

        // Mock the database query for initial data
        when(mockSupabaseClient.from('group_messages')).thenReturn(
          MockPostgrestQueryBuilder(),
        );

        // Act
        final stream = service.subscribeToGroupMessages(groupId);

        // Assert
        expect(stream, isA<Stream<List<Map<String, dynamic>>>>());
        verify(mockSupabaseClient.channel('group_messages_$groupId')).called(1);
      });
    });

    group('subscribeToPostInteractions', () {
      test('should create channels for both comments and likes', () async {
        // Arrange
        const postId = 'test-post-id';
        when(mockSupabaseClient.channel(any)).thenReturn(mockChannel);
        when(mockChannel.onPostgresChanges(
          event: anyNamed('event'),
          schema: anyNamed('schema'),
          table: anyNamed('table'),
          filter: anyNamed('filter'),
        )).thenReturn(mockChannel);
        when(mockChannel.subscribe(any)).thenReturn(mockChannel);

        // Mock the database queries for initial data
        when(mockSupabaseClient.from('post_comments')).thenReturn(
          MockPostgrestQueryBuilder(),
        );
        when(mockSupabaseClient.from('post_likes')).thenReturn(
          MockPostgrestQueryBuilder(),
        );

        // Act
        final stream = service.subscribeToPostInteractions(postId);

        // Assert
        expect(stream, isA<Stream<Map<String, dynamic>>>());
        verify(mockSupabaseClient.channel('post_comments_$postId')).called(1);
        verify(mockSupabaseClient.channel('post_likes_$postId')).called(1);
      });
    });

    group('sendTypingIndicator', () {
      test('should send broadcast message for typing indicator', () async {
        // Arrange
        const groupId = 'test-group-id';
        when(mockSupabaseClient.channel(any)).thenReturn(mockChannel);
        when(mockChannel.sendBroadcastMessage(
          event: anyNamed('event'),
          payload: anyNamed('payload'),
        )).thenAnswer((_) async {});

        // First subscribe to create the channel
        when(mockChannel.onPostgresChanges(
          event: anyNamed('event'),
          schema: anyNamed('schema'),
          table: anyNamed('table'),
          filter: anyNamed('filter'),
        )).thenReturn(mockChannel);
        when(mockChannel.subscribe(any)).thenReturn(mockChannel);
        when(mockSupabaseClient.from('group_messages')).thenReturn(
          MockPostgrestQueryBuilder(),
        );

        service.subscribeToGroupMessages(groupId);

        // Act
        await service.sendTypingIndicator(groupId, true);

        // Assert
        verify(mockChannel.sendBroadcastMessage(
          event: 'typing',
          payload: argThat(
            isA<Map<String, dynamic>>()
                .having((m) => m['user_id'], 'user_id', 'test-user-id')
                .having((m) => m['group_id'], 'group_id', groupId)
                .having((m) => m['is_typing'], 'is_typing', true),
          ),
        )).called(1);
      });
    });

    group('dispose', () {
      test('should unsubscribe from all channels', () {
        // Arrange
        when(mockSupabaseClient.removeChannel(any)).thenReturn(null);

        // Act
        service.dispose();

        // Assert - should not throw any errors
        expect(() => service.dispose(), returnsNormally);
      });
    });
  });
}

// Mock classes for testing
class MockGoTrueClient extends Mock implements GoTrueClient {
  @override
  User? currentUser;
}

class MockPostgrestQueryBuilder extends Mock implements PostgrestQueryBuilder {
  @override
  PostgrestQueryBuilder select([String columns = '*']) => this;
  
  @override
  PostgrestQueryBuilder eq(String column, Object value) => this;
  
  @override
  PostgrestQueryBuilder order(String column, {bool ascending = false}) => this;
  
  @override
  PostgrestQueryBuilder limit(int count) => this;
  
  @override
  PostgrestQueryBuilder maybeSingle() => this;
  
  @override
  Future<List<Map<String, dynamic>>> then<R>(
    FutureOr<R> Function(List<Map<String, dynamic>>) onValue, {
    Function? onError,
  }) async {
    return [];
  }
}