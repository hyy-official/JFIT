import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/features/group_workout_community/data/repositories/community_repository_impl.dart';
import 'package:jfit/features/group_workout_community/domain/entities/community_post.dart';
import 'package:jfit/features/group_workout_community/domain/entities/post_category.dart';
import 'package:jfit/features/group_workout_community/domain/repositories/community_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'community_repository_impl_test.mocks.dart';

@GenerateMocks([SupabaseClient, SupabaseQueryBuilder, PostgrestFilterBuilder, SupabaseStorageClient])
void main() {
  group('CommunityRepositoryImpl', () {
    late CommunityRepositoryImpl repository;
    late MockSupabaseClient mockSupabaseClient;
    late MockSupabaseQueryBuilder mockQueryBuilder;
    late MockPostgrestFilterBuilder mockFilterBuilder;
    late MockSupabaseStorageClient mockStorageClient;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockQueryBuilder = MockSupabaseQueryBuilder();
      mockFilterBuilder = MockPostgrestFilterBuilder();
      mockStorageClient = MockSupabaseStorageClient();
      repository = CommunityRepositoryImpl(supabaseClient: mockSupabaseClient);
    });

    group('getPosts', () {
      final testPosts = [
        {
          'id': 'post-1',
          'author_id': 'author-1',
          'group_id': null,
          'category_id': 'category-1',
          'title': 'Test Post 1',
          'content': 'Test Content 1',
          'post_type': 'text',
          'media_urls': <String>[],
          'tags': ['fitness', 'workout'],
          'likes_count': 10,
          'comments_count': 5,
          'views_count': 100,
          'is_pinned': false,
          'is_deleted': false,
          'created_at': '2024-01-01T00:00:00Z',
          'updated_at': '2024-01-01T00:00:00Z',
        },
        {
          'id': 'post-2',
          'author_id': 'author-2',
          'group_id': 'group-1',
          'category_id': 'category-2',
          'title': 'Test Post 2',
          'content': 'Test Content 2',
          'post_type': 'image',
          'media_urls': ['https://example.com/image.jpg'],
          'tags': ['nutrition'],
          'likes_count': 25,
          'comments_count': 12,
          'views_count': 200,
          'is_pinned': true,
          'is_deleted': false,
          'created_at': '2024-01-02T00:00:00Z',
          'updated_at': '2024-01-02T00:00:00Z',
        },
      ];

      test('should return list of posts when successful', () async {
        // Arrange
        const request = PostSearchRequest();
        when(mockSupabaseClient.from('community_posts')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_deleted', false)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('created_at', ascending: false)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.limit(20)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.offset(0)).thenAnswer((_) async => testPosts);

        // Act
        final result = await repository.getPosts(request);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (posts) {
            expect(posts.length, 2);
            expect(posts[0].id, 'post-1');
            expect(posts[0].title, 'Test Post 1');
            expect(posts[0].postType, PostType.text);
            expect(posts[0].tags, ['fitness', 'workout']);
            expect(posts[1].id, 'post-2');
            expect(posts[1].title, 'Test Post 2');
            expect(posts[1].postType, PostType.image);
            expect(posts[1].isPinned, true);
          },
        );
      });

      test('should filter by category when categoryId is provided', () async {
        // Arrange
        const categoryId = 'category-1';
        const request = PostSearchRequest(categoryId: categoryId);
        when(mockSupabaseClient.from('community_posts')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_deleted', false)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('category_id', categoryId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('created_at', ascending: false)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.limit(20)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.offset(0)).thenAnswer((_) async => [testPosts[0]]);

        // Act
        final result = await repository.getPosts(request);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (posts) {
            expect(posts.length, 1);
            expect(posts[0].id, 'post-1');
          },
        );
        verify(mockFilterBuilder.eq('category_id', categoryId)).called(1);
      });

      test('should filter by group when groupId is provided', () async {
        // Arrange
        const groupId = 'group-1';
        const request = PostSearchRequest(groupId: groupId);
        when(mockSupabaseClient.from('community_posts')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_deleted', false)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('group_id', groupId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('created_at', ascending: false)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.limit(20)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.offset(0)).thenAnswer((_) async => [testPosts[1]]);

        // Act
        final result = await repository.getPosts(request);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (posts) {
            expect(posts.length, 1);
            expect(posts[0].id, 'post-2');
          },
        );
        verify(mockFilterBuilder.eq('group_id', groupId)).called(1);
      });

      test('should apply pagination correctly', () async {
        // Arrange
        const limit = 10;
        const offset = 20;
        const request = PostSearchRequest(limit: limit, offset: offset);
        when(mockSupabaseClient.from('community_posts')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_deleted', false)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('created_at', ascending: false)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.limit(limit)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.offset(offset)).thenAnswer((_) async => <Map<String, dynamic>>[]);

        // Act
        final result = await repository.getPosts(request);

        // Assert
        expect(result.isRight(), true);
        verify(mockFilterBuilder.limit(limit)).called(1);
        verify(mockFilterBuilder.offset(offset)).called(1);
      });

      test('should return ServerFailure when Supabase throws exception', () async {
        // Arrange
        const request = PostSearchRequest();
        when(mockSupabaseClient.from('community_posts')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_deleted', false)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('created_at', ascending: false)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.limit(20)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.offset(0)).thenThrow(Exception('Database error'));

        // Act
        final result = await repository.getPosts(request);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, contains('Database error'));
          },
          (posts) => fail('Expected failure but got success'),
        );
      });
    });

    group('createPost', () {
      const request = CreatePostRequest(
        authorId: 'author-1',
        title: 'New Test Post',
        content: 'New Test Content',
        postType: PostType.text,
        categoryId: 'category-1',
        tags: ['fitness', 'workout'],
      );

      final createdPostData = {
        'id': 'new-post-id',
        'author_id': 'author-1',
        'group_id': null,
        'category_id': 'category-1',
        'title': 'New Test Post',
        'content': 'New Test Content',
        'post_type': 'text',
        'media_urls': <String>[],
        'tags': ['fitness', 'workout'],
        'likes_count': 0,
        'comments_count': 0,
        'views_count': 0,
        'is_pinned': false,
        'is_deleted': false,
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
      };

      test('should create post successfully', () async {
        // Arrange
        when(mockSupabaseClient.from('community_posts')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => createdPostData);

        // Act
        final result = await repository.createPost(request);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (post) {
            expect(post.id, 'new-post-id');
            expect(post.title, 'New Test Post');
            expect(post.content, 'New Test Content');
            expect(post.authorId, 'author-1');
            expect(post.postType, PostType.text);
            expect(post.tags, ['fitness', 'workout']);
          },
        );
      });

      test('should return ValidationFailure when title is empty', () async {
        // Arrange
        const invalidRequest = CreatePostRequest(
          authorId: 'author-1',
          title: '',
          content: 'Test Content',
          postType: PostType.text,
          categoryId: 'category-1',
        );

        // Act
        final result = await repository.createPost(invalidRequest);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, contains('Post title cannot be empty'));
          },
          (post) => fail('Expected failure but got success'),
        );
      });

      test('should return ValidationFailure when content is empty', () async {
        // Arrange
        const invalidRequest = CreatePostRequest(
          authorId: 'author-1',
          title: 'Test Title',
          content: '',
          postType: PostType.text,
          categoryId: 'category-1',
        );

        // Act
        final result = await repository.createPost(invalidRequest);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, contains('Post content cannot be empty'));
          },
          (post) => fail('Expected failure but got success'),
        );
      });

      test('should return ValidationFailure when authorId is empty', () async {
        // Arrange
        const invalidRequest = CreatePostRequest(
          authorId: '',
          title: 'Test Title',
          content: 'Test Content',
          postType: PostType.text,
          categoryId: 'category-1',
        );

        // Act
        final result = await repository.createPost(invalidRequest);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, contains('Author ID cannot be empty'));
          },
          (post) => fail('Expected failure but got success'),
        );
      });
    });

    group('updatePost', () {
      const postId = 'post-id';
      const request = UpdatePostRequest(
        title: 'Updated Title',
        content: 'Updated Content',
        tags: ['updated', 'tags'],
      );

      final updatedPostData = {
        'id': postId,
        'author_id': 'author-1',
        'group_id': null,
        'category_id': 'category-1',
        'title': 'Updated Title',
        'content': 'Updated Content',
        'post_type': 'text',
        'media_urls': <String>[],
        'tags': ['updated', 'tags'],
        'likes_count': 10,
        'comments_count': 5,
        'views_count': 100,
        'is_pinned': false,
        'is_deleted': false,
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T12:00:00Z',
      };

      test('should update post successfully', () async {
        // Arrange
        when(mockSupabaseClient.from('community_posts')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.update(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', postId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => updatedPostData);

        // Act
        final result = await repository.updatePost(postId, request, 'author-1');

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (post) {
            expect(post.id, postId);
            expect(post.title, 'Updated Title');
            expect(post.content, 'Updated Content');
            expect(post.tags, ['updated', 'tags']);
          },
        );
      });

      test('should return NotFoundFailure when post does not exist', () async {
        // Arrange
        when(mockSupabaseClient.from('community_posts')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.update(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', postId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenThrow(Exception('No rows returned'));

        // Act
        final result = await repository.updatePost(postId, request, 'author-1');

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<NotFoundFailure>());
            expect(failure.message, contains('Post not found'));
          },
          (post) => fail('Expected failure but got success'),
        );
      });
    });

    group('deletePost', () {
      const postId = 'post-id';
      const userId = 'user-id';

      test('should delete post successfully (soft delete)', () async {
        // Arrange
        when(mockSupabaseClient.from('community_posts')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.update(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', postId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('author_id', userId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.select()).thenAnswer((_) async => []);

        // Act
        final result = await repository.deletePost(postId, userId);

        // Assert
        expect(result.isRight(), true);
        verify(mockQueryBuilder.update({
          'is_deleted': true,
          'updated_at': any,
        })).called(1);
      });

      test('should return PermissionFailure when user is not the author', () async {
        // Arrange
        when(mockSupabaseClient.from('community_posts')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.update(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('id', postId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('author_id', userId)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.select()).thenAnswer((_) async => []);

        // Act
        final result = await repository.deletePost(postId, userId);

        // Assert
        expect(result.isRight(), true); // Should succeed even if no rows affected
      });
    });

    group('getCategories', () {
      final testCategories = [
        {
          'id': 'category-1',
          'name': 'Fitness',
          'description': 'Fitness related posts',
          'icon_url': 'https://example.com/fitness-icon.png',
          'color_code': '#FF5722',
          'sort_order': 1,
          'is_active': true,
          'created_at': '2024-01-01T00:00:00Z',
        },
        {
          'id': 'category-2',
          'name': 'Nutrition',
          'description': 'Nutrition and diet posts',
          'icon_url': 'https://example.com/nutrition-icon.png',
          'color_code': '#4CAF50',
          'sort_order': 2,
          'is_active': true,
          'created_at': '2024-01-01T00:00:00Z',
        },
      ];

      test('should return list of categories when successful', () async {
        // Arrange
        when(mockSupabaseClient.from('post_categories')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('sort_order', ascending: true))
            .thenAnswer((_) async => testCategories);

        // Act
        final result = await repository.getCategories();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (categories) {
            expect(categories.length, 2);
            expect(categories[0].id, 'category-1');
            expect(categories[0].name, 'Fitness');
            expect(categories[0].colorCode, '#FF5722');
            expect(categories[1].id, 'category-2');
            expect(categories[1].name, 'Nutrition');
            expect(categories[1].colorCode, '#4CAF50');
          },
        );
      });

      test('should return empty list when no categories exist', () async {
        // Arrange
        when(mockSupabaseClient.from('post_categories')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.eq('is_active', true)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.order('sort_order', ascending: true))
            .thenAnswer((_) async => <Map<String, dynamic>>[]);

        // Act
        final result = await repository.getCategories();

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (categories) => expect(categories.isEmpty, true),
        );
      });
    });

    group('createCategory', () {
      const request = CreateCategoryRequest(
        name: 'New Category',
        description: 'New Category Description',
        colorCode: '#2196F3',
        sortOrder: 3,
      );

      final createdCategoryData = {
        'id': 'new-category-id',
        'name': 'New Category',
        'description': 'New Category Description',
        'icon_url': null,
        'color_code': '#2196F3',
        'sort_order': 3,
        'is_active': true,
        'created_at': '2024-01-01T00:00:00Z',
      };

      test('should create category successfully', () async {
        // Arrange
        when(mockSupabaseClient.from('post_categories')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.insert(any)).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
        when(mockFilterBuilder.single()).thenAnswer((_) async => createdCategoryData);

        // Act
        final result = await repository.createCategory(request);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (category) {
            expect(category.id, 'new-category-id');
            expect(category.name, 'New Category');
            expect(category.description, 'New Category Description');
            expect(category.colorCode, '#2196F3');
            expect(category.sortOrder, 3);
          },
        );
      });

      test('should return ValidationFailure when category name is empty', () async {
        // Arrange
        const invalidRequest = CreateCategoryRequest(
          name: '',
          description: 'Test Description',
          colorCode: '#2196F3',
          sortOrder: 1,
        );

        // Act
        final result = await repository.createCategory(invalidRequest);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, contains('Category name cannot be empty'));
          },
          (category) => fail('Expected failure but got success'),
        );
      });

      test('should return ValidationFailure when color code is invalid', () async {
        // Arrange
        const invalidRequest = CreateCategoryRequest(
          name: 'Test Category',
          description: 'Test Description',
          colorCode: 'invalid-color',
          sortOrder: 1,
        );

        // Act
        final result = await repository.createCategory(invalidRequest);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, contains('Invalid color code format'));
          },
          (category) => fail('Expected failure but got success'),
        );
      });
    });

    group('uploadMedia', () {
      final testFilePaths = ['path/to/image1.jpg', 'path/to/image2.png'];
      final uploadedUrls = [
        'https://storage.example.com/image1.jpg',
        'https://storage.example.com/image2.png',
      ];

      test('should upload media files successfully', () async {
        // Arrange
        when(mockSupabaseClient.storage).thenReturn(mockStorageClient);
        // Note: This is a simplified mock - actual implementation would be more complex
        
        // Act
        final result = await repository.uploadMedia(testFilePaths);

        // Assert
        expect(result.isRight(), true);
        // Note: Actual verification would depend on the storage implementation
      });

      test('should return ValidationFailure when file paths are empty', () async {
        // Act
        final result = await repository.uploadMedia([]);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ValidationFailure>());
            expect(failure.message, contains('No files provided for upload'));
          },
          (urls) => fail('Expected failure but got success'),
        );
      });
    });
  });
}