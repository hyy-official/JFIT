import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/features/group_workout_community/domain/entities/community_post.dart';

void main() {
  group('CommunityPost', () {
    final testPost = CommunityPost(
      id: 'post-id',
      authorId: 'author-id',
      title: 'Test Post',
      content: 'Test Content',
      postType: PostType.text,
      categoryId: 'category-id',
      mediaUrls: [],
      tags: ['fitness', 'workout'],
      likesCount: 10,
      commentsCount: 5,
      viewsCount: 100,
      isPinned: false,
      isDeleted: false,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    group('Entity Creation', () {
      test('should create CommunityPost with required fields', () {
        expect(testPost.id, 'post-id');
        expect(testPost.authorId, 'author-id');
        expect(testPost.title, 'Test Post');
        expect(testPost.content, 'Test Content');
        expect(testPost.postType, PostType.text);
        expect(testPost.categoryId, 'category-id');
        expect(testPost.mediaUrls, []);
        expect(testPost.tags, ['fitness', 'workout']);
        expect(testPost.likesCount, 10);
        expect(testPost.commentsCount, 5);
        expect(testPost.viewsCount, 100);
        expect(testPost.isPinned, false);
        expect(testPost.isDeleted, false);
        expect(testPost.groupId, null);
      });

      test('should create CommunityPost with optional fields', () {
        final postWithOptionals = CommunityPost(
          id: 'post-id-2',
          authorId: 'author-id-2',
          groupId: 'group-id',
          title: 'Group Post',
          content: 'Group Content',
          postType: PostType.image,
          categoryId: 'category-id-2',
          mediaUrls: ['https://example.com/image.jpg'],
          tags: ['nutrition', 'diet'],
          likesCount: 25,
          commentsCount: 12,
          viewsCount: 200,
          isPinned: true,
          isDeleted: false,
          createdAt: DateTime(2024, 1, 2),
          updatedAt: DateTime(2024, 1, 2),
        );

        expect(postWithOptionals.groupId, 'group-id');
        expect(postWithOptionals.postType, PostType.image);
        expect(postWithOptionals.mediaUrls, ['https://example.com/image.jpg']);
        expect(postWithOptionals.isPinned, true);
      });
    });

    group('Equality', () {
      test('should be equal when all properties are the same', () {
        final post1 = CommunityPost(
          id: 'post-id',
          authorId: 'author-id',
          title: 'Test Post',
          content: 'Test Content',
          postType: PostType.text,
          categoryId: 'category-id',
          mediaUrls: [],
          tags: ['fitness', 'workout'],
          likesCount: 10,
          commentsCount: 5,
          viewsCount: 100,
          isPinned: false,
          isDeleted: false,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final post2 = CommunityPost(
          id: 'post-id',
          authorId: 'author-id',
          title: 'Test Post',
          content: 'Test Content',
          postType: PostType.text,
          categoryId: 'category-id',
          mediaUrls: [],
          tags: ['fitness', 'workout'],
          likesCount: 10,
          commentsCount: 5,
          viewsCount: 100,
          isPinned: false,
          isDeleted: false,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        expect(post1, equals(post2));
        expect(post1.hashCode, equals(post2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final post1 = testPost;
        final post2 = testPost.copyWith(title: 'Different Title');

        expect(post1, isNot(equals(post2)));
        expect(post1.hashCode, isNot(equals(post2.hashCode)));
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final updatedPost = testPost.copyWith(
          title: 'Updated Title',
          content: 'Updated Content',
          likesCount: 20,
          isPinned: true,
        );

        expect(updatedPost.id, testPost.id);
        expect(updatedPost.authorId, testPost.authorId);
        expect(updatedPost.title, 'Updated Title');
        expect(updatedPost.content, 'Updated Content');
        expect(updatedPost.likesCount, 20);
        expect(updatedPost.isPinned, true);
        expect(updatedPost.postType, testPost.postType);
        expect(updatedPost.categoryId, testPost.categoryId);
      });

      test('should create copy with same values when no changes', () {
        final copiedPost = testPost.copyWith();

        expect(copiedPost, equals(testPost));
        expect(copiedPost.hashCode, equals(testPost.hashCode));
      });

      test('should handle null values correctly', () {
        final postWithGroup = testPost.copyWith(groupId: 'group-id');
        expect(postWithGroup.groupId, 'group-id');

        // Note: copyWith doesn't support explicit null assignment in this implementation
        // This test verifies the current behavior
        final postWithoutGroup = postWithGroup.copyWith();
        expect(postWithoutGroup.groupId, 'group-id'); // Keeps existing value
      });
    });

    group('Business Logic Properties', () {
      test('isGroupPost should return true for group posts', () {
        final groupPost = testPost.copyWith(groupId: 'group-id');
        expect(groupPost.isGroupPost, true);

        final communityPost = testPost.copyWith();
        expect(communityPost.isGroupPost, false);
      });

      test('isPublicPost should return true for public posts', () {
        final publicPost = testPost.copyWith();
        expect(publicPost.isPublicPost, true);

        final groupPost = testPost.copyWith(groupId: 'group-id');
        expect(groupPost.isPublicPost, false);
      });

      test('hasMedia should return true when media URLs exist', () {
        final postWithMedia = testPost.copyWith(
          mediaUrls: ['https://example.com/image.jpg'],
        );
        expect(postWithMedia.hasMedia, true);

        final postWithoutMedia = testPost.copyWith(mediaUrls: []);
        expect(postWithoutMedia.hasMedia, false);
      });

      test('hasImages should return true for image posts with media', () {
        final imagePost = testPost.copyWith(
          postType: PostType.image,
          mediaUrls: ['https://example.com/image.jpg'],
        );
        expect(imagePost.hasImages, true);

        final imagePostWithoutMedia = testPost.copyWith(
          postType: PostType.image,
          mediaUrls: [],
        );
        expect(imagePostWithoutMedia.hasImages, false);

        final textPostWithMedia = testPost.copyWith(
          postType: PostType.text,
          mediaUrls: ['https://example.com/image.jpg'],
        );
        expect(textPostWithMedia.hasImages, false);
      });

      test('hasVideos should return true for video posts with media', () {
        final videoPost = testPost.copyWith(
          postType: PostType.video,
          mediaUrls: ['https://example.com/video.mp4'],
        );
        expect(videoPost.hasVideos, true);

        final videoPostWithoutMedia = testPost.copyWith(
          postType: PostType.video,
          mediaUrls: [],
        );
        expect(videoPostWithoutMedia.hasVideos, false);

        final textPostWithMedia = testPost.copyWith(
          postType: PostType.text,
          mediaUrls: ['https://example.com/video.mp4'],
        );
        expect(textPostWithMedia.hasVideos, false);
      });

      test('isWorkoutShare should return true for workout share posts', () {
        final workoutPost = testPost.copyWith(postType: PostType.workoutShare);
        expect(workoutPost.isWorkoutShare, true);

        final textPost = testPost.copyWith(postType: PostType.text);
        expect(textPost.isWorkoutShare, false);
      });

      test('hasTags should return true when tags exist', () {
        final postWithTags = testPost.copyWith(tags: ['fitness', 'workout']);
        expect(postWithTags.hasTags, true);

        final postWithoutTags = testPost.copyWith(tags: []);
        expect(postWithoutTags.hasTags, false);
      });

      test('hasTag should return true when specific tag exists', () {
        final postWithTags = testPost.copyWith(tags: ['fitness', 'workout']);
        expect(postWithTags.hasTag('fitness'), true);
        expect(postWithTags.hasTag('workout'), true);
        expect(postWithTags.hasTag('nutrition'), false);

        final postWithoutTags = testPost.copyWith(tags: []);
        expect(postWithoutTags.hasTag('fitness'), false);
      });

      test('isPopular should return true for posts with high engagement', () {
        // High likes (>= 10)
        final popularPost1 = testPost.copyWith(likesCount: 15, commentsCount: 2);
        expect(popularPost1.isPopular, true);

        // High comments (>= 5)
        final popularPost2 = testPost.copyWith(likesCount: 5, commentsCount: 8);
        expect(popularPost2.isPopular, true);

        // Both high
        final popularPost3 = testPost.copyWith(likesCount: 20, commentsCount: 10);
        expect(popularPost3.isPopular, true);

        // Low engagement
        final unpopularPost = testPost.copyWith(
          likesCount: 5,
          commentsCount: 2,
        );
        expect(unpopularPost.isPopular, false);
      });

      test('isActive should return true for non-deleted posts', () {
        final activePost = testPost.copyWith(isDeleted: false);
        expect(activePost.isActive, true);

        final deletedPost = testPost.copyWith(isDeleted: true);
        expect(deletedPost.isActive, false);
      });

      test('isRecent should return true for recent posts', () {
        final now = DateTime.now();
        
        // Recent post (within 24 hours)
        final recentPost = testPost.copyWith(
          createdAt: now.subtract(const Duration(hours: 12)),
        );
        expect(recentPost.isRecent, true);

        // Old post (more than 24 hours)
        final oldPost = testPost.copyWith(
          createdAt: now.subtract(const Duration(days: 2)),
        );
        expect(oldPost.isRecent, false);

        // Edge case: exactly 24 hours
        final exactlyOneDayPost = testPost.copyWith(
          createdAt: now.subtract(const Duration(hours: 24)),
        );
        expect(exactlyOneDayPost.isRecent, true);
      });

      test('isEdited should return true when updated after creation', () {
        final editedPost = testPost.copyWith(
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1, 12), // 12 hours later
        );
        expect(editedPost.isEdited, true);

        final notEditedPost = testPost.copyWith(
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1), // Same time
        );
        expect(notEditedPost.isEdited, false);
      });
    });

    group('PostType Enum', () {
      test('should have correct enum values', () {
        expect(PostType.values.length, 4);
        expect(PostType.values, contains(PostType.text));
        expect(PostType.values, contains(PostType.image));
        expect(PostType.values, contains(PostType.video));
        expect(PostType.values, contains(PostType.workoutShare));
      });

      test('should convert to string correctly', () {
        expect(PostType.text.toString(), 'PostType.text');
        expect(PostType.image.toString(), 'PostType.image');
        expect(PostType.video.toString(), 'PostType.video');
        expect(PostType.workoutShare.toString(), 'PostType.workoutShare');
      });

      test('should have correct extension values', () {
        expect(PostType.text.value, 'text');
        expect(PostType.image.value, 'image');
        expect(PostType.video.value, 'video');
        expect(PostType.workoutShare.value, 'workout_share');
      });
    });

    group('Validation Logic', () {
      test('should validate title requirements', () {
        // Test empty title
        final emptyTitleResult = testPost.copyWith(title: '');
        expect(emptyTitleResult.title, equals(''));
        
        // Test very long title
        final longTitle = 'A' * 300;
        final result = testPost.copyWith(title: longTitle);
        expect(result.title, equals(longTitle));
        
        // Test title with special characters
        final specialResult = testPost.copyWith(title: 'Post Special');
        expect(specialResult.title, equals('Post Special'));
      });

      test('should validate content requirements', () {
        // Test empty content
        final emptyResult = testPost.copyWith(content: '');
        expect(emptyResult.content, equals(''));
        
        // Test very long content
        final longContent = 'A' * 10000;
        final longResult = testPost.copyWith(content: longContent);
        expect(longResult.content, equals(longContent));
        
        // Test content with special characters
        final specialContentResult = testPost.copyWith(content: 'Content Special');
        expect(specialContentResult.content, equals('Content Special'));
      });

      test('should handle negative counts', () {
        // Test negative likes count
        final negLikesResult = testPost.copyWith(likesCount: -1);
        expect(negLikesResult.likesCount, equals(-1));
        
        // Test negative comments count
        final negCommentsResult = testPost.copyWith(commentsCount: -1);
        expect(negCommentsResult.commentsCount, equals(-1));
        
        // Test negative views count
        final negViewsResult = testPost.copyWith(viewsCount: -1);
        expect(negViewsResult.viewsCount, equals(-1));
      });

      test('should validate media URLs format', () {
        // Valid URLs
        final validUrlsResult = testPost.copyWith(
          mediaUrls: ['https://example.com/image.jpg', 'http://example.com/video.mp4'],
        );
        expect(validUrlsResult.mediaUrls.length, equals(2));
        
        // Invalid URLs (should still work as we don't validate format in entity)
        final invalidUrlsResult = testPost.copyWith(
          mediaUrls: ['not-a-url', ''],
        );
        expect(invalidUrlsResult.mediaUrls.length, equals(2));
      });

      test('should validate tags format', () {
        // Valid tags
        final validTagsResult = testPost.copyWith(
          tags: ['fitness', 'workout', 'health'],
        );
        expect(validTagsResult.tags.length, equals(3));
        
        // Tags with special characters
        final specialTagsResult = testPost.copyWith(
          tags: ['tag-with-dash', 'tag_with_underscore', 'tag123'],
        );
        expect(specialTagsResult.tags.length, equals(3));
        
        // Empty tags
        final emptyTagsResult = testPost.copyWith(tags: ['']);
        expect(emptyTagsResult.tags.length, equals(1));
      });
    });

    group('Edge Cases and Error Conditions', () {
      test('should handle null and empty string values appropriately', () {
        // Test with minimal required fields
        final minimalPost = CommunityPost(
          id: '',
          authorId: '',
          title: '',
          content: '',
          postType: PostType.text,
          categoryId: '',
          mediaUrls: [],
          tags: [],
          likesCount: 0,
          commentsCount: 0,
          viewsCount: 0,
          isPinned: false,
          isDeleted: false,
          createdAt: DateTime(1970, 1, 1),
          updatedAt: DateTime(1970, 1, 1),
        );

        expect(minimalPost.id, '');
        expect(minimalPost.authorId, '');
        expect(minimalPost.title, '');
        expect(minimalPost.content, '');
        expect(minimalPost.hasMedia, false);
        expect(minimalPost.hasTags, false);
      });

      test('should handle extreme date values', () {
        final extremePost = testPost.copyWith(
          createdAt: DateTime(1900, 1, 1),
          updatedAt: DateTime(2100, 12, 31),
        );

        expect(extremePost.createdAt.year, 1900);
        expect(extremePost.updatedAt.year, 2100);
        expect(extremePost.isEdited, true);
      });

      test('should handle boundary values for counts', () {
        final boundaryPost = testPost.copyWith(
          likesCount: 0,
          commentsCount: 0,
          viewsCount: 0,
        );

        expect(boundaryPost.likesCount, 0);
        expect(boundaryPost.commentsCount, 0);
        expect(boundaryPost.viewsCount, 0);
        expect(boundaryPost.isPopular, false);
      });

      test('should handle very large count values', () {
        final popularPost = testPost.copyWith(
          likesCount: 1000000,
          commentsCount: 100000,
          viewsCount: 10000000,
        );

        expect(popularPost.likesCount, 1000000);
        expect(popularPost.commentsCount, 100000);
        expect(popularPost.viewsCount, 10000000);
        expect(popularPost.isPopular, true);
      });
    });

    group('Comparison and Sorting', () {
      test('should support comparison by creation date', () {
        final post1 = testPost.copyWith(createdAt: DateTime(2024, 1, 1));
        final post2 = testPost.copyWith(createdAt: DateTime(2024, 1, 2));
        final post3 = testPost.copyWith(createdAt: DateTime(2024, 1, 3));

        final posts = [post3, post1, post2];
        posts.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        expect(posts[0].createdAt, DateTime(2024, 1, 1));
        expect(posts[1].createdAt, DateTime(2024, 1, 2));
        expect(posts[2].createdAt, DateTime(2024, 1, 3));
      });

      test('should support comparison by popularity', () {
        final post1 = testPost.copyWith(likesCount: 10);
        final post2 = testPost.copyWith(likesCount: 50);
        final post3 = testPost.copyWith(likesCount: 25);

        final posts = [post1, post2, post3];
        posts.sort((a, b) => b.likesCount.compareTo(a.likesCount)); // Descending

        expect(posts[0].likesCount, 50);
        expect(posts[1].likesCount, 25);
        expect(posts[2].likesCount, 10);
      });

      test('should support comparison by views count', () {
        final post1 = testPost.copyWith(viewsCount: 100);
        final post2 = testPost.copyWith(viewsCount: 500);
        final post3 = testPost.copyWith(viewsCount: 250);

        final posts = [post1, post2, post3];
        posts.sort((a, b) => b.viewsCount.compareTo(a.viewsCount)); // Descending

        expect(posts[0].viewsCount, 500);
        expect(posts[1].viewsCount, 250);
        expect(posts[2].viewsCount, 100);
      });
    });
  });
}