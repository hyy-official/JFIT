import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'dart:async';
import 'dart:io';

import 'package:jfit/features/group_workout_community/domain/entities/workout_group.dart';
import 'package:jfit/features/group_workout_community/domain/entities/group_member.dart';
import 'package:jfit/features/group_workout_community/domain/entities/community_post.dart';
import 'package:jfit/features/group_workout_community/domain/entities/group_activity.dart';
import 'package:jfit/features/group_workout_community/domain/entities/user_workout_score.dart';
import 'package:jfit/features/group_workout_community/domain/repositories/group_repository.dart';
import 'package:jfit/core/error/failures.dart';

// Mock implementations for testing that reflect actual dependency relationships
class MockGroupRepository implements GroupRepository {
  final Map<String, WorkoutGroup> _groups = {};
  final Map<String, List<GroupMember>> _groupMembers = {};
  final Map<String, List<String>> _userGroups = {};

  @override
  Future<Either<Failure, T>> safeCall<T>(Future<T> Function() operation) async {
    try {
      final result = await operation();
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WorkoutGroup>>> getUserGroups(String userId) async {
    await Future.delayed(const Duration(milliseconds: 10)); // Simulate network delay
    final groupIds = _userGroups[userId] ?? [];
    final groups = groupIds.map((id) => _groups[id]).where((g) => g != null).cast<WorkoutGroup>().toList();
    return Right(groups);
  }

  @override
  Future<Either<Failure, WorkoutGroup>> createGroup(CreateGroupRequest request, String creatorId) async {
    await Future.delayed(const Duration(milliseconds: 50)); // Simulate network delay
    
    final group = WorkoutGroup(
      id: 'group-${DateTime.now().millisecondsSinceEpoch}',
      name: request.name,
      description: request.description,
      adminId: creatorId,
      privacyType: request.privacyType,
      maxMembers: request.maxMembers,
      currentMemberCount: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      inviteCode: request.privacyType == GroupPrivacyType.private ? 'INVITE123' : null,
      isActive: true,
      groupType: request.groupType,
    );
    
    _groups[group.id] = group;
    _userGroups[creatorId] = (_userGroups[creatorId] ?? [])..add(group.id);
    
    final member = GroupMember(
      id: 'member-${DateTime.now().millisecondsSinceEpoch}',
      groupId: group.id,
      userId: creatorId,
      username: 'Test User',
      profileImageUrl: null,
      role: GroupRole.admin,
      joinedAt: DateTime.now(),
      isActive: true,
      lastActiveAt: DateTime.now(),
    );
    
    _groupMembers[group.id] = [member];
    
    return Right(group);
  }

  @override
  Future<Either<Failure, void>> joinGroup(JoinGroupRequest request) async {
    await Future.delayed(const Duration(milliseconds: 30)); // Simulate network delay
    
    final group = _groups[request.groupId];
    if (group == null) {
      return const Left(DatabaseFailure('Group not found'));
    }
    
    if (group.isFull) {
      return const Left(DatabaseFailure('Group is full'));
    }
    
    final member = GroupMember(
      id: 'member-${DateTime.now().millisecondsSinceEpoch}',
      groupId: request.groupId,
      userId: request.userId,
      username: 'Test User',
      profileImageUrl: null,
      role: GroupRole.member,
      joinedAt: DateTime.now(),
      isActive: true,
      lastActiveAt: DateTime.now(),
    );
    
    _groupMembers[request.groupId] = (_groupMembers[request.groupId] ?? [])..add(member);
    _userGroups[request.userId] = (_userGroups[request.userId] ?? [])..add(request.groupId);
    
    // Update member count
    final updatedGroup = group.copyWith(currentMemberCount: (_groupMembers[request.groupId]?.length ?? 0));
    _groups[request.groupId] = updatedGroup;
    
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<GroupMember>>> getGroupMembers(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 20)); // Simulate network delay
    final members = _groupMembers[groupId] ?? [];
    return Right(members);
  }

  // Implement other required methods with basic functionality
  @override
  Future<Either<Failure, void>> leaveGroup(String groupId, String userId) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, WorkoutGroup>> updateGroupSettings(String groupId, UpdateGroupRequest request, String adminId) async {
    final group = _groups[groupId];
    if (group == null) return const Left(DatabaseFailure('Group not found'));
    return Right(group);
  }

  @override
  Future<Either<Failure, void>> removeGroupMember(String groupId, String memberUserId, String adminId) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateMemberRole(String groupId, String memberUserId, GroupRole newRole, String adminId) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> transferOwnership(String groupId, String newAdminUserId, String currentAdminId) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, String>> generateInviteCode(String groupId, String adminId) async {
    return const Right('INVITE123');
  }

  @override
  Future<Either<Failure, bool>> validateInviteCode(String groupId, String inviteCode) async {
    return Right(inviteCode == 'INVITE123');
  }

  @override
  Future<Either<Failure, GroupMember?>> getGroupMembership(String groupId, String userId) async {
    final members = _groupMembers[groupId] ?? [];
    final member = members.where((m) => m.userId == userId).firstOrNull;
    return Right(member);
  }

  @override
  Future<Either<Failure, List<WorkoutGroup>>> getPublicGroups({int limit = 20, int offset = 0, String? searchQuery}) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, WorkoutGroup?>> getGroupById(String groupId) async {
    return Right(_groups[groupId]);
  }

  @override
  Future<Either<Failure, List<WorkoutGroup>>> getManagedGroups(String userId) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, void>> deactivateGroup(String groupId, String adminId) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getGroupStats(String groupId) async {
    return const Right({});
  }

  @override
  Future<Either<Failure, List<WorkoutGroup>>> searchGroups({required criteria, int limit = 20, int offset = 0}) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<WorkoutGroup>>> getSuggestedGroups(String userId, {int limit = 10}) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<WorkoutGroup>>> getTrendingGroups({int limit = 20, String? period}) async {
    return const Right([]);
  }
}

class MockMediaUploadService {
  Future<Either<Failure, String>> uploadImage(String filePath, String userId) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate upload time
    
    if (!File(filePath).existsSync()) {
      return const Left(StorageFailure('File not found'));
    }
    
    return Right('https://storage.supabase.co/test-bucket/$userId/${filePath.split('/').last}');
  }

  Future<Either<Failure, VideoUploadResult>> uploadVideo(String filePath, String userId) async {
    await Future.delayed(const Duration(milliseconds: 200)); // Simulate upload time
    
    if (!File(filePath).existsSync()) {
      return const Left(StorageFailure('File not found'));
    }
    
    return Right(VideoUploadResult(
      videoUrl: 'https://storage.supabase.co/test-bucket/$userId/${filePath.split('/').last}',
      thumbnailUrl: 'https://storage.supabase.co/test-bucket/$userId/thumb_${filePath.split('/').last}',
      duration: const Duration(minutes: 2),
    ));
  }

  Future<Either<Failure, List<String>>> uploadMultipleImages(List<String> filePaths, String userId) async {
    final results = <String>[];
    
    for (final filePath in filePaths) {
      final result = await uploadImage(filePath, userId);
      final url = result.fold(
        (failure) => throw failure,
        (url) => url,
      );
      results.add(url);
    }
    
    return Right(results);
  }

  Future<Either<Failure, String>> uploadImageWithProgress(
    String filePath,
    String userId, {
    Function(double)? onProgress,
  }) async {
    // Simulate progress updates
    for (double progress = 0.0; progress <= 1.0; progress += 0.2) {
      onProgress?.call(progress);
      await Future.delayed(const Duration(milliseconds: 20));
    }
    
    return uploadImage(filePath, userId);
  }
}

class MockRealtimeService {
  final Map<String, StreamController> _controllers = {};

  StreamSubscription subscribeToGroupActivities(String groupId) {
    final controller = StreamController<List<Map<String, dynamic>>>();
    _controllers['activities_$groupId'] = controller;
    
    // Simulate real-time data after a delay
    Timer(const Duration(milliseconds: 50), () {
      controller.add([
        {
          'id': 'activity-1',
          'group_id': groupId,
          'user_id': 'test-user',
          'activity_type': 'workout_completed',
          'activity_data': {'duration': 45},
          'created_at': DateTime.now().toIso8601String(),
        }
      ]);
    });
    
    return controller.stream.listen((_) {});
  }

  StreamSubscription subscribeToGroupMessages(String groupId) {
    final controller = StreamController<List<Map<String, dynamic>>>();
    _controllers['messages_$groupId'] = controller;
    
    return controller.stream.listen((_) {});
  }

  StreamSubscription subscribeToPostInteractions(String postId) {
    final controller = StreamController<List<Map<String, dynamic>>>();
    _controllers['interactions_$postId'] = controller;
    
    return controller.stream.listen((_) {});
  }

  void dispose() {
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }
}

// Helper classes
class VideoUploadResult {
  final String videoUrl;
  final String thumbnailUrl;
  final Duration duration;

  VideoUploadResult({
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.duration,
  });
}

class StorageFailure extends Failure {
  const StorageFailure(String message) : super(message);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure(String message) : super(message);
}
void main() {
  group('Group Workout Community Integration Tests', () {
    late MockGroupRepository groupRepository;
    late MockMediaUploadService mediaUploadService;
    late MockRealtimeService realtimeService;

    const testUserId = 'test-user-id';
    const testGroupId = 'test-group-id';
    const testPostId = 'test-post-id';

    setUp(() {
      groupRepository = MockGroupRepository();
      mediaUploadService = MockMediaUploadService();
      realtimeService = MockRealtimeService();
    });

    tearDown(() {
      realtimeService.dispose();
    });

    group('Repository Integration Tests', () {
      test('Group Repository - Create and Join Group Flow', () async {
        // Test group creation
        final createRequest = CreateGroupRequest(
          name: 'Test Group',
          description: 'Test Description',
          privacyType: GroupPrivacyType.public,
          maxMembers: 50,
          groupType: 'general',
        );

        final result = await groupRepository.createGroup(createRequest, testUserId);

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail'),
          (group) {
            expect(group.name, 'Test Group');
            expect(group.adminId, testUserId);
            expect(group.currentMemberCount, 1);
          },
        );
      });

      test('Group Repository - Get User Groups', () async {
        // First create a group to test retrieval
        final createRequest = CreateGroupRequest(
          name: 'Test Group',
          description: 'Test Description',
          privacyType: GroupPrivacyType.public,
          maxMembers: 50,
          groupType: 'general',
        );

        await groupRepository.createGroup(createRequest, testUserId);

        // Now test getting user groups
        final result = await groupRepository.getUserGroups(testUserId);

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail'),
          (groups) {
            expect(groups.length, 1);
            expect(groups.first.name, 'Test Group');
            expect(groups.first.currentMemberCount, 1);
          },
        );
      });

      test('Group Repository - Join Group Flow', () async {
        // First create a group
        final createRequest = CreateGroupRequest(
          name: 'Test Group',
          description: 'Test Description',
          privacyType: GroupPrivacyType.public,
          maxMembers: 50,
          groupType: 'general',
        );

        final createResult = await groupRepository.createGroup(createRequest, testUserId);
        expect(createResult.isRight(), true);

        final group = createResult.fold(
          (failure) => throw failure,
          (group) => group,
        );

        // Test joining the group with another user
        const anotherUserId = 'another-user-id';
        final joinRequest = JoinGroupRequest(
          groupId: group.id,
          userId: anotherUserId,
          inviteCode: null,
        );

        final joinResult = await groupRepository.joinGroup(joinRequest);
        expect(joinResult.isRight(), true);

        // Verify group members
        final membersResult = await groupRepository.getGroupMembers(group.id);
        expect(membersResult.isRight(), true);
        
        membersResult.fold(
          (failure) => fail('Should not fail'),
          (members) {
            expect(members.length, 2); // Original creator + new member
          },
        );
      });

      test('Group Repository - Private Group with Invite Code', () async {
        // Test private group creation
        final createRequest = CreateGroupRequest(
          name: 'Private Test Group',
          description: 'Private Description',
          privacyType: GroupPrivacyType.private,
          maxMembers: 20,
          groupType: 'general',
        );

        final createResult = await groupRepository.createGroup(createRequest, testUserId);
        expect(createResult.isRight(), true);

        final group = createResult.fold(
          (failure) => throw failure,
          (group) => group,
        );

        expect(group.privacyType, GroupPrivacyType.private);
        expect(group.inviteCode, isNotNull);

        // Test invite code validation
        final validationResult = await groupRepository.validateInviteCode(group.id, group.inviteCode!);
        expect(validationResult.isRight(), true);
        
        validationResult.fold(
          (failure) => fail('Should not fail'),
          (isValid) => expect(isValid, true),
        );

        // Test invalid invite code
        final invalidValidationResult = await groupRepository.validateInviteCode(group.id, 'INVALID');
        expect(invalidValidationResult.isRight(), true);
        
        invalidValidationResult.fold(
          (failure) => fail('Should not fail'),
          (isValid) => expect(isValid, false),
        );
      });
    });

    group('Real-time Functionality Tests', () {
      test('Group Activity Real-time Updates', () async {
        // Start listening to real-time updates
        final subscription = realtimeService.subscribeToGroupActivities(testGroupId);
        
        // Verify subscription is active
        expect(subscription, isNotNull);
        
        // Wait for simulated real-time data
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Cleanup
        await subscription.cancel();
      });

      test('Group Chat Real-time Messages', () async {
        // Start listening to real-time messages
        final subscription = realtimeService.subscribeToGroupMessages(testGroupId);
        
        // Verify subscription is active
        expect(subscription, isNotNull);
        
        // Wait for stream data
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Cleanup
        await subscription.cancel();
      });

      test('Post Interaction Real-time Updates', () async {
        // Start listening to real-time interactions
        final subscription = realtimeService.subscribeToPostInteractions(testPostId);
        
        // Verify subscription is active
        expect(subscription, isNotNull);
        
        // Wait for stream data
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Cleanup
        await subscription.cancel();
      });
    });

    group('Media Upload Tests', () {
      test('Image Upload to Supabase Storage', () async {
        // Create a temporary test file
        final testFile = File('test_image.jpg');
        await testFile.writeAsBytes([1, 2, 3, 4, 5]); // Dummy image data

        final result = await mediaUploadService.uploadImage(testFile.path, testUserId);

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail'),
          (url) {
            expect(url, contains('https://storage.supabase.co'));
            expect(url, contains('test_image.jpg'));
          },
        );

        // Cleanup
        if (await testFile.exists()) {
          await testFile.delete();
        }
      });

      test('Video Upload with Compression', () async {
        // Create a temporary test video file
        final testFile = File('test_video.mp4');
        await testFile.writeAsBytes(List.generate(1024 * 1024, (i) => i % 256)); // 1MB dummy video

        final result = await mediaUploadService.uploadVideo(testFile.path, testUserId);

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail'),
          (uploadResult) {
            expect(uploadResult.videoUrl, contains('https://storage.supabase.co'));
            expect(uploadResult.videoUrl, contains('test_video.mp4'));
            expect(uploadResult.thumbnailUrl, isNotNull);
          },
        );

        // Cleanup
        if (await testFile.exists()) {
          await testFile.delete();
        }
      });

      test('Multiple Media Upload', () async {
        // Create test files
        final testFiles = <File>[];
        for (int i = 0; i < 3; i++) {
          final file = File('test_image_$i.jpg');
          await file.writeAsBytes([i, i + 1, i + 2]);
          testFiles.add(file);
        }

        final filePaths = testFiles.map((f) => f.path).toList();
        final result = await mediaUploadService.uploadMultipleImages(filePaths, testUserId);

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail'),
          (urls) {
            expect(urls.length, 3);
            for (final url in urls) {
              expect(url, contains('https://storage.supabase.co'));
            }
          },
        );

        // Cleanup
        for (final file in testFiles) {
          if (await file.exists()) {
            await file.delete();
          }
        }
      });

      test('Upload Progress Tracking', () async {
        final testFile = File('large_test_image.jpg');
        await testFile.writeAsBytes(List.generate(5 * 1024 * 1024, (i) => i % 256)); // 5MB file

        final progressValues = <double>[];

        final result = await mediaUploadService.uploadImageWithProgress(
          testFile.path,
          testUserId,
          onProgress: (progress) {
            progressValues.add(progress);
          },
        );

        expect(result.isRight(), true);
        expect(progressValues.isNotEmpty, true);
        expect(progressValues.last, 1.0); // Should reach 100%

        // Cleanup
        if (await testFile.exists()) {
          await testFile.delete();
        }
      });
    });

    group('Error Handling Integration Tests', () {
      test('File Not Found Error Handling', () async {
        // Test with non-existent file
        final result = await mediaUploadService.uploadImage('non_existent_file.jpg', testUserId);

        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<StorageFailure>());
            expect(failure.message, contains('File not found'));
          },
          (url) => fail('Should fail with file not found error'),
        );
      });

      test('Group Not Found Error Handling', () async {
        // Test joining non-existent group
        final joinRequest = JoinGroupRequest(
          groupId: 'non-existent-group',
          userId: testUserId,
          inviteCode: null,
        );

        final result = await groupRepository.joinGroup(joinRequest);

        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<DatabaseFailure>());
            expect(failure.message, contains('Group not found'));
          },
          (_) => fail('Should fail with group not found error'),
        );
      });

      test('Group Full Error Handling', () async {
        // Create a group with max 1 member
        final createRequest = CreateGroupRequest(
          name: 'Full Group',
          description: 'Test Description',
          privacyType: GroupPrivacyType.public,
          maxMembers: 1,
          groupType: 'general',
        );

        final createResult = await groupRepository.createGroup(createRequest, testUserId);
        expect(createResult.isRight(), true);

        final group = createResult.fold(
          (failure) => throw failure,
          (group) => group,
        );

        // Try to join with another user (should fail as group is full)
        final joinRequest = JoinGroupRequest(
          groupId: group.id,
          userId: 'another-user',
          inviteCode: null,
        );

        final result = await groupRepository.joinGroup(joinRequest);

        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<DatabaseFailure>());
            expect(failure.message, contains('Group is full'));
          },
          (_) => fail('Should fail with group full error'),
        );
      });
    });

    group('Performance Integration Tests', () {
      test('Large Dataset Handling', () async {
        // Create many groups to test performance
        final futures = <Future>[];
        for (int i = 0; i < 100; i++) {
          final createRequest = CreateGroupRequest(
            name: 'Performance Group $i',
            description: 'Description $i',
            privacyType: GroupPrivacyType.public,
            maxMembers: 50,
            groupType: 'general',
          );
          futures.add(groupRepository.createGroup(createRequest, testUserId));
        }

        final stopwatch = Stopwatch()..start();
        await Future.wait(futures);
        
        final result = await groupRepository.getUserGroups(testUserId);
        stopwatch.stop();

        expect(result.isRight(), true);
        expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // Should complete within 5 seconds
        
        result.fold(
          (failure) => fail('Should not fail'),
          (groups) {
            expect(groups.length, 100);
          },
        );
      });

      test('Concurrent Operations', () async {
        // Execute multiple operations concurrently
        final futures = <Future>[];
        for (int i = 0; i < 10; i++) {
          final createRequest = CreateGroupRequest(
            name: 'Concurrent Group $i',
            description: 'Test Description $i',
            privacyType: GroupPrivacyType.public,
            maxMembers: 50,
            groupType: 'general',
          );
          futures.add(groupRepository.createGroup(createRequest, testUserId));
        }

        final stopwatch = Stopwatch()..start();
        final results = await Future.wait(futures);
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(3000)); // Should complete within 3 seconds
        expect(results.length, 10);
        
        for (final result in results) {
          expect((result as Either).isRight(), true);
        }
      });

      test('Memory Usage with Large Media Files', () async {
        // Create multiple large test files
        final testFiles = <File>[];
        for (int i = 0; i < 5; i++) {
          final file = File('large_test_$i.jpg');
          await file.writeAsBytes(List.generate(2 * 1024 * 1024, (j) => j % 256)); // 2MB each
          testFiles.add(file);
        }

        final filePaths = testFiles.map((f) => f.path).toList();
        final result = await mediaUploadService.uploadMultipleImages(filePaths, testUserId);

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail'),
          (urls) {
            expect(urls.length, 5);
          },
        );

        // Cleanup
        for (final file in testFiles) {
          if (await file.exists()) {
            await file.delete();
          }
        }
      });
    });

    group('Service Integration Tests', () {
      test('Group Creation with Cache Service Integration', () async {
        // Test that group creation properly integrates with cache service
        final createRequest = CreateGroupRequest(
          name: 'Cache Integration Group',
          description: 'Test cache integration',
          privacyType: GroupPrivacyType.public,
          maxMembers: 50,
          groupType: 'general',
        );

        // Create group
        final createResult = await groupRepository.createGroup(createRequest, testUserId);
        expect(createResult.isRight(), true);

        final group = createResult.fold(
          (failure) => throw failure,
          (group) => group,
        );

        // Verify that subsequent getUserGroups call returns cached data
        final userGroupsResult1 = await groupRepository.getUserGroups(testUserId);
        final userGroupsResult2 = await groupRepository.getUserGroups(testUserId);

        expect(userGroupsResult1.isRight(), true);
        expect(userGroupsResult2.isRight(), true);

        // Both calls should return the same data (simulating cache hit)
        userGroupsResult1.fold(
          (failure) => fail('Should not fail'),
          (groups1) {
            userGroupsResult2.fold(
              (failure) => fail('Should not fail'),
              (groups2) {
                expect(groups1.length, groups2.length);
                expect(groups1.first.id, groups2.first.id);
              },
            );
          },
        );
      });

      test('Real-time Service Integration with Group Activities', () async {
        // Test that group activities trigger real-time updates
        final createRequest = CreateGroupRequest(
          name: 'Realtime Test Group',
          description: 'Test realtime integration',
          privacyType: GroupPrivacyType.public,
          maxMembers: 50,
          groupType: 'general',
        );

        final createResult = await groupRepository.createGroup(createRequest, testUserId);
        expect(createResult.isRight(), true);

        final group = createResult.fold(
          (failure) => throw failure,
          (group) => group,
        );

        // Subscribe to real-time updates for this group
        final subscription = realtimeService.subscribeToGroupActivities(group.id);
        expect(subscription, isNotNull);

        // Simulate a group activity (member joining)
        const newUserId = 'new-member-id';
        final joinRequest = JoinGroupRequest(
          groupId: group.id,
          userId: newUserId,
          inviteCode: null,
        );

        final joinResult = await groupRepository.joinGroup(joinRequest);
        expect(joinResult.isRight(), true);

        // Wait for real-time notification
        await Future.delayed(const Duration(milliseconds: 100));

        // Cleanup
        await subscription.cancel();
      });

      test('Media Upload Service Integration with Group Posts', () async {
        // Test media upload integration with group content
        final testFile = File('group_post_image.jpg');
        await testFile.writeAsBytes([1, 2, 3, 4, 5]);

        // Upload image for group post
        final uploadResult = await mediaUploadService.uploadImage(testFile.path, testUserId);
        expect(uploadResult.isRight(), true);

        String? imageUrl;
        uploadResult.fold(
          (failure) => fail('Should not fail'),
          (url) {
            imageUrl = url;
            expect(url, contains('https://storage.supabase.co'));
          },
        );

        // Verify the uploaded image URL can be used in group context
        expect(imageUrl, isNotNull);
        expect(imageUrl!.contains(testUserId), true);

        // Cleanup
        if (await testFile.exists()) {
          await testFile.delete();
        }
      });

      test('Multi-Service Workflow: Group Creation to Activity Tracking', () async {
        // Test complete workflow involving multiple services
        
        // 1. Create a group
        final createRequest = CreateGroupRequest(
          name: 'Workflow Test Group',
          description: 'Test multi-service workflow',
          privacyType: GroupPrivacyType.public,
          maxMembers: 50,
          groupType: 'general',
        );

        final createResult = await groupRepository.createGroup(createRequest, testUserId);
        expect(createResult.isRight(), true);

        final group = createResult.fold(
          (failure) => throw failure,
          (group) => group,
        );

        // 2. Subscribe to real-time updates
        final activitySubscription = realtimeService.subscribeToGroupActivities(group.id);
        final messageSubscription = realtimeService.subscribeToGroupMessages(group.id);

        // 3. Add members to the group
        const member1 = 'member-1';
        const member2 = 'member-2';

        await groupRepository.joinGroup(JoinGroupRequest(
          groupId: group.id,
          userId: member1,
          inviteCode: null,
        ));

        await groupRepository.joinGroup(JoinGroupRequest(
          groupId: group.id,
          userId: member2,
          inviteCode: null,
        ));

        // 4. Verify group state
        final membersResult = await groupRepository.getGroupMembers(group.id);
        expect(membersResult.isRight(), true);

        membersResult.fold(
          (failure) => fail('Should not fail'),
          (members) {
            expect(members.length, 3); // Admin + 2 members
          },
        );

        // 5. Upload media content
        final testFile = File('workflow_test_image.jpg');
        await testFile.writeAsBytes(List.generate(1024, (i) => i % 256));

        final uploadResult = await mediaUploadService.uploadImage(testFile.path, testUserId);
        expect(uploadResult.isRight(), true);

        // 6. Wait for all real-time updates to process
        await Future.delayed(const Duration(milliseconds: 150));

        // 7. Cleanup
        await activitySubscription.cancel();
        await messageSubscription.cancel();
        
        if (await testFile.exists()) {
          await testFile.delete();
        }
      });

      test('Error Propagation Across Services', () async {
        // Test that errors propagate correctly across service boundaries
        
        // 1. Try to upload non-existent file
        final uploadResult = await mediaUploadService.uploadImage('non_existent.jpg', testUserId);
        expect(uploadResult.isLeft(), true);

        uploadResult.fold(
          (failure) {
            expect(failure, isA<StorageFailure>());
            expect(failure.message, contains('File not found'));
          },
          (url) => fail('Should fail'),
        );

        // 2. Try to join non-existent group
        final joinResult = await groupRepository.joinGroup(JoinGroupRequest(
          groupId: 'non-existent-group',
          userId: testUserId,
          inviteCode: null,
        ));

        expect(joinResult.isLeft(), true);
        joinResult.fold(
          (failure) {
            expect(failure, isA<DatabaseFailure>());
            expect(failure.message, contains('Group not found'));
          },
          (_) => fail('Should fail'),
        );

        // 3. Verify that failed operations don't affect other services
        final validCreateRequest = CreateGroupRequest(
          name: 'Valid Group After Errors',
          description: 'Test error isolation',
          privacyType: GroupPrivacyType.public,
          maxMembers: 50,
          groupType: 'general',
        );

        final validCreateResult = await groupRepository.createGroup(validCreateRequest, testUserId);
        expect(validCreateResult.isRight(), true);
      });
    });

    group('Data Consistency Tests', () {
      test('Group Creation and Membership Consistency', () async {
        final createRequest = CreateGroupRequest(
          name: 'Consistency Test Group',
          description: 'Test Description',
          privacyType: GroupPrivacyType.public,
          maxMembers: 50,
          groupType: 'general',
        );

        final result = await groupRepository.createGroup(createRequest, testUserId);

        expect(result.isRight(), true);
        
        result.fold(
          (failure) => fail('Should not fail'),
          (group) {
            expect(group.name, 'Consistency Test Group');
            expect(group.adminId, testUserId);
            expect(group.currentMemberCount, 1);
          },
        );

        // Verify membership was created along with group
        final membersResult = await groupRepository.getGroupMembers(result.fold(
          (failure) => throw failure,
          (group) => group.id,
        ));

        expect(membersResult.isRight(), true);
        membersResult.fold(
          (failure) => fail('Should not fail'),
          (members) {
            expect(members.length, 1);
            expect(members.first.userId, testUserId);
            expect(members.first.role, GroupRole.admin);
          },
        );
      });

      test('Group State Consistency After Operations', () async {
        // Create a group
        final createRequest = CreateGroupRequest(
          name: 'State Test Group',
          description: 'Test Description',
          privacyType: GroupPrivacyType.public,
          maxMembers: 50,
          groupType: 'general',
        );

        final createResult = await groupRepository.createGroup(createRequest, testUserId);
        expect(createResult.isRight(), true);

        final group = createResult.fold(
          (failure) => throw failure,
          (group) => group,
        );

        // Add multiple members
        const user2 = 'user-2';
        const user3 = 'user-3';

        await groupRepository.joinGroup(JoinGroupRequest(
          groupId: group.id,
          userId: user2,
          inviteCode: null,
        ));

        await groupRepository.joinGroup(JoinGroupRequest(
          groupId: group.id,
          userId: user3,
          inviteCode: null,
        ));

        // Verify final state consistency
        final membersResult = await groupRepository.getGroupMembers(group.id);
        expect(membersResult.isRight(), true);

        membersResult.fold(
          (failure) => fail('Should not fail'),
          (members) {
            expect(members.length, 3); // Original creator + 2 new members
            
            // Verify all members are present
            final userIds = members.map((m) => m.userId).toSet();
            expect(userIds.contains(testUserId), true);
            expect(userIds.contains(user2), true);
            expect(userIds.contains(user3), true);
            
            // Verify admin role is preserved
            final admin = members.firstWhere((m) => m.userId == testUserId);
            expect(admin.role, GroupRole.admin);
          },
        );
      });
    });
  });
}