import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:jfit/core/error/failures.dart';
import 'package:jfit/core/interfaces/base_repository.dart';
import '../../domain/repositories/group_activity_repository.dart';
import '../../domain/entities/group_activity.dart';
import '../../domain/entities/shared_routine.dart';
import '../../domain/entities/workout_group.dart';
import '../models/group_activity_model.dart';
import '../models/shared_routine_model.dart';

/// Implementation of GroupActivityRepository using Supabase as the data source
class GroupActivityRepositoryImpl extends GroupActivityRepository with BaseRepositoryMixin {
  final SupabaseClient _supabaseClient;
  final Uuid _uuid = const Uuid();

  GroupActivityRepositoryImpl({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client;

  @override
  Future<Either<Failure, List<GroupActivity>>> getGroupActivities(
    String groupId, {
    int limit = 50,
    int offset = 0,
    List<GroupActivityType>? activityTypes,
  }) async {
    return safeCall(() async {
      var query = _supabaseClient
          .from('group_activities')
          .select('''
            *,
            user_profiles!inner(
              username,
              profile_image_url
            )
          ''')
          .eq('group_id', groupId);

      if (activityTypes != null && activityTypes.isNotEmpty) {
        final typeStrings = activityTypes.map(_activityTypeToString).toList();
        query = query.inFilter('activity_type', typeStrings);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List).map((json) {
        // Add user profile data to activity data for easier access
        final userProfile = json['user_profiles'] as Map<String, dynamic>;
        json['activity_data'] = {
          ...json['activity_data'] as Map<String, dynamic>,
          'username': userProfile['username'],
          'profile_image_url': userProfile['profile_image_url'],
        };
        
        return GroupActivityModel.fromJson(json).toEntity();
      }).toList();
    });
  }

  @override
  Future<Either<Failure, List<GroupActivity>>> getUserActivitiesInGroup(
    String groupId,
    String userId, {
    int limit = 20,
    DateTime? since,
  }) async {
    return safeCall(() async {
      var query = _supabaseClient
          .from('group_activities')
          .select('''
            *,
            user_profiles!inner(
              username,
              profile_image_url
            )
          ''')
          .eq('group_id', groupId)
          .eq('user_id', userId);

      if (since != null) {
        query = query.gte('created_at', since.toIso8601String());
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List).map((json) {
        final userProfile = json['user_profiles'] as Map<String, dynamic>;
        json['activity_data'] = {
          ...json['activity_data'] as Map<String, dynamic>,
          'username': userProfile['username'],
          'profile_image_url': userProfile['profile_image_url'],
        };
        
        return GroupActivityModel.fromJson(json).toEntity();
      }).toList();
    });
  }

  @override
  Future<Either<Failure, SharedRoutine>> shareRoutine(ShareRoutineRequest request) async {
    return safeCall(() async {
      final routineId = _uuid.v4();
      final now = DateTime.now();

      // Create shared routine record
      final routineData = {
        'id': routineId,
        'group_id': request.groupId,
        'shared_by_user_id': request.userId,
        'user_program_id': request.userProgramId,
        'routine_name': request.routineName,
        'description': request.description,
        'exercise_ids': request.exerciseIds,
        'shared_at': now.toIso8601String(),
        'likes_count': 0,
        'copies_count': 0,
      };

      await _supabaseClient
          .from('shared_routines')
          .insert(routineData);

      // Create group activity
      await _createGroupActivity(
        groupId: request.groupId,
        userId: request.userId,
        activityType: GroupActivityType.routineShared,
        activityData: {
          'routine_id': routineId,
          'routine_name': request.routineName,
          'exercise_count': request.exerciseIds.length,
          'description': request.description,
        },
      );

      return SharedRoutineModel.fromJson(routineData).toEntity();
    });
  }

  @override
  Future<Either<Failure, GroupActivity>> logWorkoutCompletion(
    WorkoutCompletionRequest request,
  ) async {
    return safeCall(() async {
      return await _createGroupActivity(
        groupId: request.groupId,
        userId: request.userId,
        activityType: GroupActivityType.workoutCompleted,
        activityData: {
          'session_id': request.sessionId,
          'duration_minutes': request.durationMinutes,
          'exercises_completed': request.exercisesCompleted,
          'note': request.note,
        },
        mentionedUserIds: request.mentionedUserIds,
      );
    });
  }

  @override
  Future<Either<Failure, GroupActivity>> sendEncouragement(
    EncouragementRequest request,
  ) async {
    return safeCall(() async {
      return await _createGroupActivity(
        groupId: request.groupId,
        userId: request.fromUserId,
        activityType: GroupActivityType.encouragementSent,
        activityData: {
          'target_user_id': request.toUserId,
          'message': request.message,
          'activity_id': request.activityId,
        },
        mentionedUserIds: [request.toUserId],
      );
    });
  }

  @override
  Future<Either<Failure, List<SharedRoutine>>> getSharedRoutines(
    String groupId, {
    int limit = 20,
    int offset = 0,
    String? orderBy,
  }) async {
    return safeCall(() async {
      var query = _supabaseClient
          .from('shared_routines')
          .select('''
            *,
            user_profiles!inner(
              username,
              profile_image_url
            )
          ''')
          .eq('group_id', groupId);

      // Apply ordering and execute query
      switch (orderBy) {
        case 'popular':
          final response = await query
              .order('likes_count', ascending: false)
              .range(offset, offset + limit - 1);
          return _processSharedRoutinesResponse(response);
        case 'likes':
          final response = await query
              .order('likes_count', ascending: false)
              .range(offset, offset + limit - 1);
          return _processSharedRoutinesResponse(response);
        case 'copies':
          final response = await query
              .order('copies_count', ascending: false)
              .range(offset, offset + limit - 1);
          return _processSharedRoutinesResponse(response);
        case 'recent':
        default:
          final response = await query
              .order('shared_at', ascending: false)
              .range(offset, offset + limit - 1);
          return _processSharedRoutinesResponse(response);
      }
    });
  }

  @override
  Future<Either<Failure, SharedRoutine?>> getSharedRoutineById(String routineId) async {
    return safeCall(() async {
      try {
        final response = await _supabaseClient
            .from('shared_routines')
            .select('''
              *,
              user_profiles!inner(
                username,
                profile_image_url
              )
            ''')
            .eq('id', routineId)
            .single();

        return SharedRoutineModel.fromJson(response).toEntity();
      } catch (e) {
        if (e is PostgrestException && (e.code == 'PGRST116' || e.message.contains('0 rows'))) {
          return null;
        }
        rethrow;
      }
    });
  }

  @override
  Future<Either<Failure, String>> copySharedRoutine(CopyRoutineRequest request) async {
    return safeCall(() async {
      // Get the shared routine details
      final routineResult = await getSharedRoutineById(request.sharedRoutineId);
      final routine = routineResult.fold(
        (failure) => throw failure,
        (routine) => routine,
      );

      if (routine == null) {
        throw const DatabaseFailure('공유된 루틴을 찾을 수 없습니다');
      }

      // Get the original user program details
      final originalProgramResponse = await _supabaseClient
          .from('user_programs')
          .select('''
            *,
            workout_programs(*)
          ''')
          .eq('id', routine.userProgramId)
          .single();

      final workoutProgram = originalProgramResponse['workout_programs'] as Map<String, dynamic>;
      
      // Create new user program for the copying user
      final newUserProgramId = _uuid.v4();
      final now = DateTime.now();
      
      final newUserProgramData = {
        'id': newUserProgramId,
        'user_id': request.userId,
        'program_id': workoutProgram['id'],
        'current_week': 1,
        'current_day': 1,
        'started_at': now.toIso8601String(),
        'is_active': true,
        'exercises_json': originalProgramResponse['exercises_json'],
        'custom_name': request.customName ?? '${routine.routineName} (복사됨)',
      };

      await _supabaseClient
          .from('user_programs')
          .insert(newUserProgramData);

      // Increment copies count
      await _supabaseClient
          .from('shared_routines')
          .update({
            'copies_count': routine.copiesCount + 1,
          })
          .eq('id', request.sharedRoutineId);

      // Create activity for copying routine
      await _createGroupActivity(
        groupId: routine.groupId,
        userId: request.userId,
        activityType: GroupActivityType.routineShared,
        activityData: {
          'action': 'copied',
          'original_routine_id': request.sharedRoutineId,
          'routine_name': routine.routineName,
          'copied_from_user': routine.sharedByUserId,
        },
      );

      return newUserProgramId;
    });
  }

  @override
  Future<Either<Failure, void>> toggleRoutineLike(
    String sharedRoutineId,
    String userId,
  ) async {
    return safeCall(() async {
      // Check if user already liked this routine
      final existingLike = await _supabaseClient
          .from('shared_routine_likes')
          .select('id')
          .eq('shared_routine_id', sharedRoutineId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingLike != null) {
        // Unlike - remove like and decrement count
        await _supabaseClient
            .from('shared_routine_likes')
            .delete()
            .eq('id', existingLike['id']);

        await _supabaseClient.rpc('decrement_routine_likes', params: {
          'routine_id': sharedRoutineId,
        });
      } else {
        // Like - add like and increment count
        await _supabaseClient
            .from('shared_routine_likes')
            .insert({
              'id': _uuid.v4(),
              'shared_routine_id': sharedRoutineId,
              'user_id': userId,
              'created_at': DateTime.now().toIso8601String(),
            });

        await _supabaseClient.rpc('increment_routine_likes', params: {
          'routine_id': sharedRoutineId,
        });
      }
    });
  }

  @override
  Future<Either<Failure, bool>> hasUserLikedRoutine(
    String sharedRoutineId,
    String userId,
  ) async {
    return safeCall(() async {
      final response = await _supabaseClient
          .from('shared_routine_likes')
          .select('id')
          .eq('shared_routine_id', sharedRoutineId)
          .eq('user_id', userId)
          .maybeSingle();

      return response != null;
    });
  }

  @override
  Future<Either<Failure, List<SharedRoutine>>> getUserSharedRoutines(
    String userId, {
    int limit = 20,
  }) async {
    return safeCall(() async {
      final response = await _supabaseClient
          .from('shared_routines')
          .select('*')
          .eq('shared_by_user_id', userId)
          .order('shared_at', ascending: false)
          .limit(limit);

      return (response as List).map((json) {
        return SharedRoutineModel.fromJson(json).toEntity();
      }).toList();
    });
  }

  @override
  Future<Either<Failure, void>> deleteSharedRoutine(
    String sharedRoutineId,
    String userId,
  ) async {
    return safeCall(() async {
      // Get routine to verify ownership or admin rights
      final routineResult = await getSharedRoutineById(sharedRoutineId);
      final routine = routineResult.fold(
        (failure) => throw failure,
        (routine) => routine,
      );

      if (routine == null) {
        throw const DatabaseFailure('공유된 루틴을 찾을 수 없습니다');
      }

      // Check if user is the sharer or group admin
      bool canDelete = routine.sharedByUserId == userId;
      
      if (!canDelete) {
        // Check if user is group admin
        final memberResponse = await _supabaseClient
            .from('group_members')
            .select('role')
            .eq('group_id', routine.groupId)
            .eq('user_id', userId)
            .eq('is_active', true)
            .maybeSingle();

        canDelete = memberResponse != null && memberResponse['role'] == 'admin';
      }

      if (!canDelete) {
        throw const DatabaseFailure('루틴을 삭제할 권한이 없습니다');
      }

      // Soft delete - we could add an is_deleted column or actually delete
      await _supabaseClient
          .from('shared_routines')
          .delete()
          .eq('id', sharedRoutineId);
    });
  }

  @override
  Future<Either<Failure, GroupActivity>> logMemberJoined(
    String groupId,
    String userId,
    String? welcomeMessage,
  ) async {
    return safeCall(() async {
      return await _createGroupActivity(
        groupId: groupId,
        userId: userId,
        activityType: GroupActivityType.memberJoined,
        activityData: {
          'welcome_message': welcomeMessage,
          'joined_at': DateTime.now().toIso8601String(),
        },
      );
    });
  }

  @override
  Future<Either<Failure, GroupActivity>> logMemberLeft(
    String groupId,
    String userId,
    String? farewell,
  ) async {
    return safeCall(() async {
      return await _createGroupActivity(
        groupId: groupId,
        userId: userId,
        activityType: GroupActivityType.memberLeft,
        activityData: {
          'farewell_message': farewell,
          'left_at': DateTime.now().toIso8601String(),
        },
      );
    });
  }

  @override
  Future<Either<Failure, GroupActivity>> logAchievementUnlocked(
    String groupId,
    String userId,
    String achievementName,
    String achievementDescription,
  ) async {
    return safeCall(() async {
      return await _createGroupActivity(
        groupId: groupId,
        userId: userId,
        activityType: GroupActivityType.achievementUnlocked,
        activityData: {
          'achievement_name': achievementName,
          'achievement_description': achievementDescription,
          'unlocked_at': DateTime.now().toIso8601String(),
        },
      );
    });
  }

  @override
  Future<Either<Failure, GroupActivity>> logProgramStarted(
    String groupId,
    String userId,
    String programName,
    int durationWeeks,
  ) async {
    return safeCall(() async {
      return await _createGroupActivity(
        groupId: groupId,
        userId: userId,
        activityType: GroupActivityType.programStarted,
        activityData: {
          'program_name': programName,
          'duration_weeks': durationWeeks,
          'started_at': DateTime.now().toIso8601String(),
        },
      );
    });
  }

  @override
  Future<Either<Failure, GroupActivity>> logMilestoneReached(
    String groupId,
    String userId,
    String milestoneType,
    Map<String, dynamic> milestoneData,
  ) async {
    return safeCall(() async {
      return await _createGroupActivity(
        groupId: groupId,
        userId: userId,
        activityType: GroupActivityType.milestoneReached,
        activityData: {
          'milestone_type': milestoneType,
          'milestone_data': milestoneData,
          'reached_at': DateTime.now().toIso8601String(),
        },
      );
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getGroupActivityStats(
    String groupId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return safeCall(() async {
      var query = _supabaseClient
          .from('group_activities')
          .select('activity_type, created_at')
          .eq('group_id', groupId);

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query;
      final activities = response as List;

      // Count activities by type
      final activityCounts = <String, int>{};
      for (final activity in activities) {
        final type = activity['activity_type'] as String;
        activityCounts[type] = (activityCounts[type] ?? 0) + 1;
      }

      return {
        'total_activities': activities.length,
        'activity_counts': activityCounts,
        'period_start': startDate?.toIso8601String(),
        'period_end': endDate?.toIso8601String(),
      };
    });
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getMostActiveMembers(
    String groupId, {
    int limit = 10,
    int days = 30,
  }) async {
    return safeCall(() async {
      final startDate = DateTime.now().subtract(Duration(days: days));

      final response = await _supabaseClient
          .from('group_activities')
          .select('''
            user_id,
            user_profiles!inner(
              username,
              profile_image_url
            )
          ''')
          .eq('group_id', groupId)
          .gte('created_at', startDate.toIso8601String());

      // Count activities per user
      final userActivityCounts = <String, Map<String, dynamic>>{};
      for (final activity in response as List) {
        final userId = activity['user_id'] as String;
        final userProfile = activity['user_profiles'] as Map<String, dynamic>;
        
        if (userActivityCounts.containsKey(userId)) {
          userActivityCounts[userId]!['activity_count'] = 
              (userActivityCounts[userId]!['activity_count'] as int) + 1;
        } else {
          userActivityCounts[userId] = {
            'user_id': userId,
            'username': userProfile['username'],
            'profile_image_url': userProfile['profile_image_url'],
            'activity_count': 1,
          };
        }
      }

      // Sort by activity count and return top members
      final sortedMembers = userActivityCounts.values.toList()
        ..sort((a, b) => (b['activity_count'] as int).compareTo(a['activity_count'] as int));

      return sortedMembers.take(limit).toList();
    });
  }

  @override
  Future<Either<Failure, List<GroupActivity>>> getActivitiesMentioningUser(
    String userId, {
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    return safeCall(() async {
      var query = _supabaseClient
          .from('group_activities')
          .select('''
            *,
            user_profiles!inner(
              username,
              profile_image_url
            )
          ''')
          .contains('mentioned_user_ids', [userId]);

      if (unreadOnly) {
        // This would require an additional table to track read status
        // For now, we'll return all mentions
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List).map((json) {
        final userProfile = json['user_profiles'] as Map<String, dynamic>;
        json['activity_data'] = {
          ...json['activity_data'] as Map<String, dynamic>,
          'username': userProfile['username'],
          'profile_image_url': userProfile['profile_image_url'],
        };
        
        return GroupActivityModel.fromJson(json).toEntity();
      }).toList();
    });
  }

  @override
  Future<Either<Failure, void>> markActivitiesAsRead(
    List<String> activityIds,
    String userId,
  ) async {
    return safeCall(() async {
      // This would require an additional table to track read status
      // For now, we'll implement a simple version using activity_reads table
      final readRecords = activityIds.map((activityId) => {
        'id': _uuid.v4(),
        'activity_id': activityId,
        'user_id': userId,
        'read_at': DateTime.now().toIso8601String(),
      }).toList();

      await _supabaseClient
          .from('activity_reads')
          .upsert(readRecords, onConflict: 'activity_id,user_id');
    });
  }

  /// Helper method to create group activities
  Future<GroupActivity> _createGroupActivity({
    required String groupId,
    required String userId,
    required GroupActivityType activityType,
    required Map<String, dynamic> activityData,
    List<String> mentionedUserIds = const [],
  }) async {
    final activityId = _uuid.v4();
    final now = DateTime.now();

    final activityRecord = {
      'id': activityId,
      'group_id': groupId,
      'user_id': userId,
      'activity_type': _activityTypeToString(activityType),
      'activity_data': activityData,
      'created_at': now.toIso8601String(),
      'mentioned_user_ids': mentionedUserIds,
    };

    await _supabaseClient
        .from('group_activities')
        .insert(activityRecord);

    return GroupActivityModel.fromJson(activityRecord).toEntity();
  }

  /// Helper method to process shared routines response
  List<SharedRoutine> _processSharedRoutinesResponse(List response) {
    return response.map((json) {
      return SharedRoutineModel.fromJson(json).toEntity();
    }).toList();
  }

  /// Helper method to convert activity type to string
  String _activityTypeToString(GroupActivityType type) {
    switch (type) {
      case GroupActivityType.workoutCompleted:
        return 'workout_completed';
      case GroupActivityType.routineShared:
        return 'routine_shared';
      case GroupActivityType.memberJoined:
        return 'member_joined';
      case GroupActivityType.memberLeft:
        return 'member_left';
      case GroupActivityType.encouragementSent:
        return 'encouragement_sent';
      case GroupActivityType.achievementUnlocked:
        return 'achievement_unlocked';
      case GroupActivityType.programStarted:
        return 'program_started';
      case GroupActivityType.milestoneReached:
        return 'milestone_reached';
    }
  }
}