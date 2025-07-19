import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

import 'package:jfit/core/error/failures.dart';
import 'package:jfit/core/interfaces/base_repository.dart';
import '../../domain/repositories/group_repository.dart';
import '../../domain/entities/workout_group.dart';
import '../../domain/entities/group_member.dart';
import '../../domain/entities/group_search_criteria.dart';
import '../models/workout_group_model.dart';
import '../models/group_member_model.dart';
import '../services/group_cache_service.dart';

/// Implementation of GroupRepository using Supabase as the data source
class GroupRepositoryImpl extends GroupRepository with BaseRepositoryMixin {
  final SupabaseClient _supabaseClient;
  final GroupCacheService _cacheService;
  final Uuid _uuid = const Uuid();

  GroupRepositoryImpl({
    SupabaseClient? supabaseClient,
    GroupCacheService? cacheService,
  }) : _supabaseClient = supabaseClient ?? Supabase.instance.client,
       _cacheService = cacheService ?? GroupCacheService();

  @override
  Future<Either<Failure, List<WorkoutGroup>>> getUserGroups(String userId) async {
    return safeCall(() async {
      // Try to get from cache first
      final cachedGroups = await _cacheService.getCachedUserGroups(userId);
      if (cachedGroups != null) {
        return cachedGroups;
      }

      final response = await _supabaseClient
          .from('group_members')
          .select('''
            workout_groups!inner(
              id,
              name,
              description,
              admin_id,
              privacy_type,
              max_members,
              invite_code,
              is_active,
              group_type,
              created_at,
              updated_at
            )
          ''')
          .eq('user_id', userId)
          .eq('is_active', true)
          .eq('workout_groups.is_active', true)
          .order('joined_at', ascending: false);

      final groups = <WorkoutGroup>[];
      for (final item in response as List) {
        final groupData = item['workout_groups'] as Map<String, dynamic>;
        
        // Get current member count
        final memberCountResponse = await _supabaseClient
            .from('group_members')
            .select('id')
            .eq('group_id', groupData['id'])
            .eq('is_active', true);
        
        groupData['current_member_count'] = (memberCountResponse as List).length;
        
        groups.add(WorkoutGroupModel.fromJson(groupData).toEntity());
      }

      // Cache the results
      await _cacheService.cacheUserGroups(userId, groups);

      return groups;
    });
  }

  @override
  Future<Either<Failure, List<WorkoutGroup>>> getPublicGroups({
    int limit = 20,
    int offset = 0,
    String? searchQuery,
  }) async {
    return safeCall(() async {
      var query = _supabaseClient
          .from('workout_groups')
          .select('*')
          .eq('privacy_type', 'public')
          .eq('is_active', true);

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('name.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final groups = <WorkoutGroup>[];
      for (final groupData in response as List) {
        // Get current member count
        final memberCountResponse = await _supabaseClient
            .from('group_members')
            .select('id')
            .eq('group_id', groupData['id'])
            .eq('is_active', true);
        
        groupData['current_member_count'] = (memberCountResponse as List).length;
        
        groups.add(WorkoutGroupModel.fromJson(groupData as Map<String, dynamic>).toEntity());
      }

      return groups;
    });
  }

  @override
  Future<Either<Failure, WorkoutGroup?>> getGroupById(String groupId) async {
    return safeCall(() async {
      try {
        final response = await _supabaseClient
            .from('workout_groups')
            .select('*')
            .eq('id', groupId)
            .eq('is_active', true)
            .single();

        // Get current member count
        final memberCountResponse = await _supabaseClient
            .from('group_members')
            .select('id')
            .eq('group_id', groupId)
            .eq('is_active', true);
        
        response['current_member_count'] = (memberCountResponse as List).length;
        
        return WorkoutGroupModel.fromJson(response).toEntity();
      } catch (e) {
        if (e is PostgrestException && (e.code == 'PGRST116' || e.message.contains('0 rows'))) {
          return null;
        }
        rethrow;
      }
    });
  }

  @override
  Future<Either<Failure, WorkoutGroup>> createGroup(
    CreateGroupRequest request,
    String creatorId,
  ) async {
    return safeCall(() async {
      final groupId = _uuid.v4();
      final now = DateTime.now();
      
      // Generate invite code for private groups
      String? inviteCode;
      if (request.privacyType == GroupPrivacyType.private) {
        inviteCode = _generateInviteCode();
      }

      // Create the group
      final groupData = {
        'id': groupId,
        'name': request.name,
        'description': request.description,
        'admin_id': creatorId,
        'privacy_type': request.privacyType == GroupPrivacyType.private ? 'private' : 'public',
        'max_members': request.maxMembers,
        'invite_code': inviteCode,
        'is_active': true,
        'group_type': request.groupType,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      await _supabaseClient
          .from('workout_groups')
          .insert(groupData);

      // Add creator as admin member
      await _supabaseClient
          .from('group_members')
          .insert({
            'id': _uuid.v4(),
            'group_id': groupId,
            'user_id': creatorId,
            'role': 'admin',
            'joined_at': now.toIso8601String(),
            'is_active': true,
            'last_active_at': now.toIso8601String(),
          });

      // Invalidate user's groups cache
      await _cacheService.invalidateUserCaches(creatorId);

      // Return the created group with member count
      groupData['current_member_count'] = 1;
      return WorkoutGroupModel.fromJson(groupData).toEntity();
    });
  }

  @override
  Future<Either<Failure, void>> joinGroup(JoinGroupRequest request) async {
    return safeCall(() async {
      // Check if group exists and is active
      final groupResult = await getGroupById(request.groupId);
      final group = groupResult.fold(
        (failure) => throw failure,
        (group) => group,
      );

      if (group == null) {
        throw const DatabaseFailure('그룹을 찾을 수 없습니다');
      }

      // Check if group is full
      if (group.isFull) {
        throw const DatabaseFailure('그룹이 최대 인원에 도달했습니다');
      }

      // Check if user is already a member
      final existingMember = await getGroupMembership(request.groupId, request.userId);
      final member = existingMember.fold(
        (failure) => throw failure,
        (member) => member,
      );

      if (member != null && member.isActive) {
        throw const DatabaseFailure('이미 그룹의 멤버입니다');
      }

      // For private groups, validate invite code
      if (group.privacyType == GroupPrivacyType.private) {
        if (request.inviteCode == null || request.inviteCode!.isEmpty) {
          throw const DatabaseFailure('비공개 그룹에 가입하려면 초대 코드가 필요합니다');
        }

        final isValidCode = await validateInviteCode(request.groupId, request.inviteCode!);
        final valid = isValidCode.fold(
          (failure) => throw failure,
          (valid) => valid,
        );

        if (!valid) {
          throw const DatabaseFailure('유효하지 않거나 만료된 초대 코드입니다');
        }
      }

      final now = DateTime.now();

      // If user was previously a member, reactivate membership
      if (member != null) {
        await _supabaseClient
            .from('group_members')
            .update({
              'is_active': true,
              'role': 'member',
              'last_active_at': now.toIso8601String(),
            })
            .eq('id', member.id);
      } else {
        // Add new member
        await _supabaseClient
            .from('group_members')
            .insert({
              'id': _uuid.v4(),
              'group_id': request.groupId,
              'user_id': request.userId,
              'role': 'member',
              'joined_at': now.toIso8601String(),
              'is_active': true,
              'last_active_at': now.toIso8601String(),
            });
      }
    });
  }

  @override
  Future<Either<Failure, void>> leaveGroup(String groupId, String userId) async {
    return safeCall(() async {
      // Check if user is a member
      final memberResult = await getGroupMembership(groupId, userId);
      final member = memberResult.fold(
        (failure) => throw failure,
        (member) => member,
      );

      if (member == null || !member.isActive) {
        throw const DatabaseFailure('그룹의 멤버가 아닙니다');
      }

      // Admin cannot leave unless they transfer ownership first
      if (member.isAdmin) {
        // Check if there are other members who can become admin
        final membersResult = await getGroupMembers(groupId);
        final members = membersResult.fold(
          (failure) => throw failure,
          (members) => members,
        );

        final activeMembersCount = members.where((m) => m.isActive && m.userId != userId).length;
        
        if (activeMembersCount > 0) {
          throw const DatabaseFailure('관리자는 다른 멤버에게 소유권을 이전한 후 그룹을 떠날 수 있습니다');
        } else {
          // If admin is the only member, deactivate the group
          await deactivateGroup(groupId, userId);
          return;
        }
      }

      // Deactivate membership
      await _supabaseClient
          .from('group_members')
          .update({
            'is_active': false,
            'last_active_at': DateTime.now().toIso8601String(),
          })
          .eq('id', member.id);
    });
  }

  @override
  Future<Either<Failure, List<GroupMember>>> getGroupMembers(String groupId) async {
    return safeCall(() async {
      // Try to get from cache first
      final cachedMembers = await _cacheService.getCachedGroupMembers(groupId);
      if (cachedMembers != null) {
        return cachedMembers;
      }

      final response = await _supabaseClient
          .from('group_members')
          .select('''
            *,
            user_profiles!inner(
              username,
              profile_image_url
            )
          ''')
          .eq('group_id', groupId)
          .eq('is_active', true)
          .order('joined_at', ascending: true);

      final members = (response as List).map((json) {
        final userProfile = json['user_profiles'] as Map<String, dynamic>;
        json['username'] = userProfile['username'] ?? 'Unknown User';
        json['profile_image_url'] = userProfile['profile_image_url'];
        return GroupMemberModel.fromJson(json).toEntity();
      }).toList();

      // Cache the results
      await _cacheService.cacheGroupMembers(groupId, members);

      return members;
    });
  }

  @override
  Future<Either<Failure, WorkoutGroup>> updateGroupSettings(
    String groupId,
    UpdateGroupRequest request,
    String adminId,
  ) async {
    return safeCall(() async {
      // Verify admin permissions
      final memberResult = await getGroupMembership(groupId, adminId);
      final member = memberResult.fold(
        (failure) => throw failure,
        (member) => member,
      );

      if (member == null || !member.isAdmin) {
        throw const DatabaseFailure('그룹 설정을 변경할 권한이 없습니다');
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (request.name != null) updateData['name'] = request.name;
      if (request.description != null) updateData['description'] = request.description;
      if (request.maxMembers != null) updateData['max_members'] = request.maxMembers;
      if (request.isActive != null) updateData['is_active'] = request.isActive;
      
      if (request.privacyType != null) {
        updateData['privacy_type'] = request.privacyType == GroupPrivacyType.private ? 'private' : 'public';
        
        // Generate invite code for newly private groups
        if (request.privacyType == GroupPrivacyType.private) {
          updateData['invite_code'] = _generateInviteCode();
        } else {
          updateData['invite_code'] = null;
        }
      }

      await _supabaseClient
          .from('workout_groups')
          .update(updateData)
          .eq('id', groupId);

      // Return updated group
      final updatedGroupResult = await getGroupById(groupId);
      return updatedGroupResult.fold(
        (failure) => throw failure,
        (group) => group!,
      );
    });
  }

  @override
  Future<Either<Failure, void>> removeGroupMember(
    String groupId,
    String memberUserId,
    String adminId,
  ) async {
    return safeCall(() async {
      // Verify admin permissions
      final adminMemberResult = await getGroupMembership(groupId, adminId);
      final adminMember = adminMemberResult.fold(
        (failure) => throw failure,
        (member) => member,
      );

      if (adminMember == null || !adminMember.hasManagementPermissions) {
        throw const DatabaseFailure('멤버를 제거할 권한이 없습니다');
      }

      // Get target member
      final targetMemberResult = await getGroupMembership(groupId, memberUserId);
      final targetMember = targetMemberResult.fold(
        (failure) => throw failure,
        (member) => member,
      );

      if (targetMember == null || !targetMember.isActive) {
        throw const DatabaseFailure('제거할 멤버를 찾을 수 없습니다');
      }

      // Cannot remove other admins or moderators (unless you're admin removing moderator)
      if (targetMember.hasManagementPermissions && 
          (!adminMember.isAdmin || targetMember.isAdmin)) {
        throw const DatabaseFailure('관리자나 모더레이터를 제거할 수 없습니다');
      }

      // Cannot remove yourself
      if (memberUserId == adminId) {
        throw const DatabaseFailure('자신을 제거할 수 없습니다');
      }

      // Deactivate membership
      await _supabaseClient
          .from('group_members')
          .update({
            'is_active': false,
            'last_active_at': DateTime.now().toIso8601String(),
          })
          .eq('id', targetMember.id);
    });
  }

  @override
  Future<Either<Failure, void>> updateMemberRole(
    String groupId,
    String memberUserId,
    GroupRole newRole,
    String adminId,
  ) async {
    return safeCall(() async {
      // Only admins can change roles
      final adminMemberResult = await getGroupMembership(groupId, adminId);
      final adminMember = adminMemberResult.fold(
        (failure) => throw failure,
        (member) => member,
      );

      if (adminMember == null || !adminMember.isAdmin) {
        throw const DatabaseFailure('역할을 변경할 권한이 없습니다');
      }

      // Get target member
      final targetMemberResult = await getGroupMembership(groupId, memberUserId);
      final targetMember = targetMemberResult.fold(
        (failure) => throw failure,
        (member) => member,
      );

      if (targetMember == null || !targetMember.isActive) {
        throw const DatabaseFailure('멤버를 찾을 수 없습니다');
      }

      // Cannot change admin role or change role to admin
      if (targetMember.isAdmin || newRole == GroupRole.admin) {
        throw const DatabaseFailure('관리자 역할은 소유권 이전을 통해서만 변경할 수 있습니다');
      }

      // Cannot change your own role
      if (memberUserId == adminId) {
        throw const DatabaseFailure('자신의 역할을 변경할 수 없습니다');
      }

      final roleString = newRole == GroupRole.moderator ? 'moderator' : 'member';

      await _supabaseClient
          .from('group_members')
          .update({
            'role': roleString,
            'last_active_at': DateTime.now().toIso8601String(),
          })
          .eq('id', targetMember.id);
    });
  }

  @override
  Future<Either<Failure, void>> transferOwnership(
    String groupId,
    String newAdminUserId,
    String currentAdminId,
  ) async {
    return safeCall(() async {
      // Verify current admin
      final currentAdminResult = await getGroupMembership(groupId, currentAdminId);
      final currentAdmin = currentAdminResult.fold(
        (failure) => throw failure,
        (member) => member,
      );

      if (currentAdmin == null || !currentAdmin.isAdmin) {
        throw const DatabaseFailure('소유권을 이전할 권한이 없습니다');
      }

      // Verify new admin is a member
      final newAdminResult = await getGroupMembership(groupId, newAdminUserId);
      final newAdmin = newAdminResult.fold(
        (failure) => throw failure,
        (member) => member,
      );

      if (newAdmin == null || !newAdmin.isActive) {
        throw const DatabaseFailure('새 관리자가 그룹 멤버가 아닙니다');
      }

      final now = DateTime.now();

      // Update both members in a transaction-like manner
      await _supabaseClient
          .from('group_members')
          .update({
            'role': 'member',
            'last_active_at': now.toIso8601String(),
          })
          .eq('id', currentAdmin.id);

      await _supabaseClient
          .from('group_members')
          .update({
            'role': 'admin',
            'last_active_at': now.toIso8601String(),
          })
          .eq('id', newAdmin.id);

      // Update group admin_id
      await _supabaseClient
          .from('workout_groups')
          .update({
            'admin_id': newAdminUserId,
            'updated_at': now.toIso8601String(),
          })
          .eq('id', groupId);
    });
  }

  @override
  Future<Either<Failure, String>> generateInviteCode(
    String groupId,
    String adminId,
  ) async {
    return safeCall(() async {
      // Verify admin permissions
      final memberResult = await getGroupMembership(groupId, adminId);
      final member = memberResult.fold(
        (failure) => throw failure,
        (member) => member,
      );

      if (member == null || !member.isAdmin) {
        throw const DatabaseFailure('초대 코드를 생성할 권한이 없습니다');
      }

      final newInviteCode = _generateInviteCode();

      await _supabaseClient
          .from('workout_groups')
          .update({
            'invite_code': newInviteCode,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', groupId);

      return newInviteCode;
    });
  }

  @override
  Future<Either<Failure, bool>> validateInviteCode(
    String groupId,
    String inviteCode,
  ) async {
    return safeCall(() async {
      try {
        final response = await _supabaseClient
            .from('workout_groups')
            .select('invite_code')
            .eq('id', groupId)
            .eq('is_active', true)
            .single();

        return response['invite_code'] == inviteCode;
      } catch (e) {
        if (e is PostgrestException && (e.code == 'PGRST116' || e.message.contains('0 rows'))) {
          return false;
        }
        rethrow;
      }
    });
  }

  @override
  Future<Either<Failure, GroupMember?>> getGroupMembership(
    String groupId,
    String userId,
  ) async {
    return safeCall(() async {
      try {
        final response = await _supabaseClient
            .from('group_members')
            .select('''
              *,
              user_profiles!inner(
                username,
                profile_image_url
              )
            ''')
            .eq('group_id', groupId)
            .eq('user_id', userId)
            .single();

        final userProfile = response['user_profiles'] as Map<String, dynamic>;
        response['username'] = userProfile['username'] ?? 'Unknown User';
        response['profile_image_url'] = userProfile['profile_image_url'];
        
        return GroupMemberModel.fromJson(response).toEntity();
      } catch (e) {
        if (e is PostgrestException && (e.code == 'PGRST116' || e.message.contains('0 rows'))) {
          return null;
        }
        rethrow;
      }
    });
  }

  @override
  Future<Either<Failure, List<WorkoutGroup>>> getManagedGroups(String userId) async {
    return safeCall(() async {
      final response = await _supabaseClient
          .from('group_members')
          .select('''
            workout_groups!inner(
              id,
              name,
              description,
              admin_id,
              privacy_type,
              max_members,
              invite_code,
              is_active,
              group_type,
              created_at,
              updated_at
            )
          ''')
          .eq('user_id', userId)
          .eq('is_active', true)
          .eq('workout_groups.is_active', true)
          .inFilter('role', ['admin', 'moderator'])
          .order('joined_at', ascending: false);

      final groups = <WorkoutGroup>[];
      for (final item in response as List) {
        final groupData = item['workout_groups'] as Map<String, dynamic>;
        
        // Get current member count
        final memberCountResponse = await _supabaseClient
            .from('group_members')
            .select('id')
            .eq('group_id', groupData['id'])
            .eq('is_active', true);
        
        groupData['current_member_count'] = (memberCountResponse as List).length;
        
        groups.add(WorkoutGroupModel.fromJson(groupData).toEntity());
      }

      return groups;
    });
  }

  @override
  Future<Either<Failure, void>> deactivateGroup(String groupId, String adminId) async {
    return safeCall(() async {
      // Verify admin permissions
      final memberResult = await getGroupMembership(groupId, adminId);
      final member = memberResult.fold(
        (failure) => throw failure,
        (member) => member,
      );

      if (member == null || !member.isAdmin) {
        throw const DatabaseFailure('그룹을 비활성화할 권한이 없습니다');
      }

      final now = DateTime.now();

      // Deactivate the group
      await _supabaseClient
          .from('workout_groups')
          .update({
            'is_active': false,
            'updated_at': now.toIso8601String(),
          })
          .eq('id', groupId);

      // Deactivate all memberships
      await _supabaseClient
          .from('group_members')
          .update({
            'is_active': false,
            'last_active_at': now.toIso8601String(),
          })
          .eq('group_id', groupId);
    });
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getGroupStats(String groupId) async {
    return safeCall(() async {
      // Get basic group info
      final groupResult = await getGroupById(groupId);
      final group = groupResult.fold(
        (failure) => throw failure,
        (group) => group,
      );

      if (group == null) {
        throw const DatabaseFailure('그룹을 찾을 수 없습니다');
      }

      // Get member statistics
      final membersResult = await getGroupMembers(groupId);
      final members = membersResult.fold(
        (failure) => throw failure,
        (members) => members,
      );

      final adminCount = members.where((m) => m.isAdmin).length;
      final moderatorCount = members.where((m) => m.isModerator).length;
      final memberCount = members.where((m) => m.role == GroupRole.member).length;
      final recentlyActiveCount = members.where((m) => m.isRecentlyActive).length;

      // Get activity count (last 30 days)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final activityResponse = await _supabaseClient
          .from('group_activities')
          .select('id')
          .eq('group_id', groupId)
          .gte('created_at', thirtyDaysAgo.toIso8601String());

      return {
        'group_id': groupId,
        'group_name': group.name,
        'total_members': members.length,
        'admin_count': adminCount,
        'moderator_count': moderatorCount,
        'member_count': memberCount,
        'recently_active_members': recentlyActiveCount,
        'activity_count_30_days': (activityResponse as List).length,
        'created_at': group.createdAt.toIso8601String(),
        'is_pt_group': group.isPTGroup,
        'privacy_type': group.privacyType.name,
      };
    });
  }

  @override
  Future<Either<Failure, List<WorkoutGroup>>> searchGroups({
    required GroupSearchCriteria criteria,
    int limit = 20,
    int offset = 0,
  }) async {
    return safeCall(() async {
      var query = _supabaseClient
          .from('workout_groups')
          .select('*')
          .eq('is_active', true);

      // Apply search query
      if (criteria.searchQuery != null && criteria.searchQuery!.trim().isNotEmpty) {
        final searchTerm = criteria.searchQuery!.trim();
        query = query.or('name.ilike.%$searchTerm%,description.ilike.%$searchTerm%');
      }

      // Apply privacy filter
      if (criteria.privacyType != null) {
        final privacyValue = criteria.privacyType == GroupPrivacyType.private ? 'private' : 'public';
        query = query.eq('privacy_type', privacyValue);
      }

      // Apply PT group filter
      if (criteria.isPTGroup != null) {
        if (criteria.isPTGroup!) {
          query = query.eq('group_type', 'personal_training');
        } else {
          query = query.or('group_type.is.null,group_type.neq.personal_training');
        }
      }

      // Exclude specific groups
      if (criteria.excludeGroupIds != null && criteria.excludeGroupIds!.isNotEmpty) {
        query = query.not('id', 'in', '(${criteria.excludeGroupIds!.join(',')})');
      }

      // Apply sorting
      final orderBy = criteria.sortOption.sqlOrderBy;
      final parts = orderBy.split(' ');
      final column = parts[0];
      final ascending = parts.length > 1 ? parts[1] == 'ASC' : true;
      
      final response = await query
          .order(column, ascending: ascending)
          .range(offset, offset + limit - 1);

      final groups = <WorkoutGroup>[];
      for (final groupData in response as List) {
        // Get current member count
        final memberCountResponse = await _supabaseClient
            .from('group_members')
            .select('id')
            .eq('group_id', groupData['id'])
            .eq('is_active', true);
        
        final memberCount = (memberCountResponse as List).length;
        groupData['current_member_count'] = memberCount;

        // Apply member count filters
        if (criteria.minMembers != null && memberCount < criteria.minMembers!) {
          continue;
        }
        if (criteria.maxMembers != null && memberCount > criteria.maxMembers!) {
          continue;
        }

        // Apply size filter
        if (criteria.sizeFilter != null) {
          final sizeFilter = criteria.sizeFilter!;
          if (memberCount < sizeFilter.minMembers) continue;
          if (sizeFilter.maxMembers != null && memberCount > sizeFilter.maxMembers!) continue;
        }
        
        groups.add(WorkoutGroupModel.fromJson(groupData as Map<String, dynamic>).toEntity());
      }

      return groups;
    });
  }

  @override
  Future<Either<Failure, List<WorkoutGroup>>> getSuggestedGroups(
    String userId, {
    int limit = 10,
  }) async {
    return safeCall(() async {
      // Get user's current groups to understand preferences
      final userGroupsResult = await getUserGroups(userId);
      final userGroups = userGroupsResult.fold(
        (failure) => <WorkoutGroup>[],
        (groups) => groups,
      );

      // Get user's group IDs to exclude from suggestions
      final userGroupIds = userGroups.map((g) => g.id).toList();

      // Create search criteria based on user's preferences
      final criteria = GroupSearchCriteria(
        privacyType: GroupPrivacyType.public, // Only suggest public groups
        sortOption: GroupSortOption.activity, // Prioritize active groups
        excludeGroupIds: userGroupIds,
      );

      // Get suggested groups
      final suggestedResult = await searchGroups(
        criteria: criteria,
        limit: limit * 2, // Get more to filter better matches
      );

      final allSuggested = suggestedResult.fold(
        (failure) => throw failure,
        (groups) => groups,
      );

      // Simple recommendation algorithm:
      // 1. Groups with similar member count to user's groups
      // 2. Groups that are not full
      // 3. Groups with recent activity
      final avgMemberCount = userGroups.isEmpty 
          ? 15 
          : userGroups.map((g) => g.currentMemberCount).reduce((a, b) => a + b) / userGroups.length;

      final scored = allSuggested.map((group) {
        double score = 0.0;
        
        // Prefer groups with similar member count
        final memberDiff = (group.currentMemberCount - avgMemberCount).abs();
        score += (20 - memberDiff.clamp(0, 20)) / 20 * 30; // 30% weight
        
        // Prefer groups that are not full
        final fillRatio = group.currentMemberCount / group.maxMembers;
        score += (1 - fillRatio) * 25; // 25% weight
        
        // Prefer newer groups (more likely to be active)
        final daysSinceCreated = DateTime.now().difference(group.createdAt).inDays;
        score += (30 - daysSinceCreated.clamp(0, 30)) / 30 * 20; // 20% weight
        
        // Prefer groups with good member count (not too small, not too large)
        if (group.currentMemberCount >= 3 && group.currentMemberCount <= 25) {
          score += 25; // 25% weight
        }

        return MapEntry(group, score);
      }).toList();

      // Sort by score and return top results
      scored.sort((a, b) => b.value.compareTo(a.value));
      
      return scored.take(limit).map((entry) => entry.key).toList();
    });
  }

  @override
  Future<Either<Failure, List<WorkoutGroup>>> getTrendingGroups({
    int limit = 10,
  }) async {
    return safeCall(() async {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      
      // Get groups with recent activity
      final activityResponse = await _supabaseClient
          .from('group_activities')
          .select('group_id, count(*)')
          .gte('created_at', sevenDaysAgo.toIso8601String())
          .order('count', ascending: false)
          .limit(limit * 2);

      final activeGroupIds = <String>[];
      for (final item in activityResponse as List) {
        activeGroupIds.add(item['group_id'] as String);
      }

      if (activeGroupIds.isEmpty) {
        // If no recent activity, return newest public groups
        final criteria = GroupSearchCriteria(
          privacyType: GroupPrivacyType.public,
          sortOption: GroupSortOption.newest,
        );
        
        final result = await searchGroups(criteria: criteria, limit: limit);
        return result.fold(
          (failure) => <WorkoutGroup>[],
          (groups) => groups,
        );
      }

      // Get group details for active groups
      final groupsResponse = await _supabaseClient
          .from('workout_groups')
          .select('*')
          .inFilter('id', activeGroupIds)
          .eq('is_active', true)
          .eq('privacy_type', 'public'); // Only show public trending groups

      final groups = <WorkoutGroup>[];
      for (final groupData in groupsResponse as List) {
        // Get current member count
        final memberCountResponse = await _supabaseClient
            .from('group_members')
            .select('id')
            .eq('group_id', groupData['id'])
            .eq('is_active', true);
        
        groupData['current_member_count'] = (memberCountResponse as List).length;
        
        groups.add(WorkoutGroupModel.fromJson(groupData as Map<String, dynamic>).toEntity());
      }

      // Sort by activity order and return
      final sortedGroups = <WorkoutGroup>[];
      for (final groupId in activeGroupIds) {
        final group = groups.where((g) => g.id == groupId).firstOrNull;
        if (group != null) {
          sortedGroups.add(group);
        }
      }

      return sortedGroups.take(limit).toList();
    });
  }

  /// Generate a random invite code
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(8, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }
}