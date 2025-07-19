import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/bloc/base_bloc.dart';
import 'package:jfit/core/bloc/bloc_event_bus.dart';
import 'package:jfit/core/error/bloc_errors.dart';
import 'package:jfit/features/group_workout_community/domain/entities/workout_group.dart';
import 'package:jfit/features/group_workout_community/domain/entities/group_member.dart';
import 'package:jfit/features/group_workout_community/domain/repositories/group_repository.dart';
import 'group_event.dart';
import 'group_state.dart';

/// BLoC for managing group-related operations
/// Handles group creation, membership management, real-time updates, and group settings
class GroupBloc extends BaseBloc<GroupEvent, GroupState> {
  final GroupRepository _repository;

  // Cache for performance optimization
  final Map<String, WorkoutGroup> _groupCache = {};
  final Map<String, List<GroupMember>> _membersCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiration = Duration(minutes: 10);

  // Real-time subscriptions
  final Map<String, StreamSubscription> _realtimeSubscriptions = {};

  // Performance metrics
  int _cacheHits = 0;
  int _cacheMisses = 0;

  GroupBloc({
    required GroupRepository repository,
  })  : _repository = repository,
        super(const GroupInitial()) {
    
    // Register event handlers
    on<LoadUserGroups>(_onLoadUserGroups);
    on<LoadPublicGroups>(_onLoadPublicGroups);
    on<LoadGroupDetails>(_onLoadGroupDetails);
    on<CreateGroup>(_onCreateGroup);
    on<JoinGroup>(_onJoinGroup);
    on<LeaveGroup>(_onLeaveGroup);
    on<LoadGroupMembers>(_onLoadGroupMembers);
    on<UpdateGroupSettings>(_onUpdateGroupSettings);
    on<RemoveGroupMember>(_onRemoveGroupMember);
    on<UpdateMemberRole>(_onUpdateMemberRole);
    on<TransferOwnership>(_onTransferOwnership);
    on<GenerateInviteCode>(_onGenerateInviteCode);
    on<ValidateInviteCode>(_onValidateInviteCode);
    on<CheckGroupMembership>(_onCheckGroupMembership);
    on<LoadManagedGroups>(_onLoadManagedGroups);
    on<DeactivateGroup>(_onDeactivateGroup);
    on<LoadGroupStats>(_onLoadGroupStats);
    on<SearchGroupsWithCriteria>(_onSearchGroupsWithCriteria);
    on<LoadMoreSearchResults>(_onLoadMoreSearchResults);
    on<LoadSuggestedGroups>(_onLoadSuggestedGroups);
    on<LoadTrendingGroups>(_onLoadTrendingGroups);
    on<SearchGroups>(_onSearchGroups);
    on<ClearGroupSearch>(_onClearGroupSearch);
    on<RefreshGroupData>(_onRefreshGroupData);
    on<HandleGroupUpdate>(_onHandleGroupUpdate);
    on<HandleMemberUpdate>(_onHandleMemberUpdate);
  }

  /// Helper method to update group cache
  void _updateGroupCache(WorkoutGroup group) {
    _groupCache[group.id] = group;
    _cacheTimestamps[group.id] = DateTime.now();
  }

  /// Helper method to update members cache
  void _updateMembersCache(String groupId, List<GroupMember> members) {
    _membersCache[groupId] = members;
    _cacheTimestamps['members_$groupId'] = DateTime.now();
  }

  /// Check if group cache is valid
  bool _isGroupCacheValid(String groupId) {
    if (!_groupCache.containsKey(groupId)) return false;
    final timestamp = _cacheTimestamps[groupId];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < _cacheExpiration;
  }

  /// Check if members cache is valid
  bool _isMembersCacheValid(String groupId) {
    if (!_membersCache.containsKey(groupId)) return false;
    final timestamp = _cacheTimestamps['members_$groupId'];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < _cacheExpiration;
  }

  /// Setup real-time subscriptions for groups
  void _setupRealtimeSubscriptions(List<WorkoutGroup> groups) {
    for (final group in groups) {
      // This would be implemented with actual real-time service
      // For now, just placeholder
    }
  }

  /// Handle load user groups event
  Future<void> _onLoadUserGroups(
    LoadUserGroups event,
    Emitter<GroupState> emit,
  ) async {
    emit(const GroupLoading(
      message: '내 그룹을 불러오고 있습니다...',
      operationType: 'loading_groups',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getUserGroups(event.userId);
        
        result.fold(
          (failure) => emit(GroupErrorState.fromError(
            failure,
            operationType: 'loading_groups',
          )),
          (groups) {
            // Update cache
            for (final group in groups) {
              _updateGroupCache(group);
            }
            
            emit(UserGroupsLoaded(
              groups: groups,
              loadedAt: DateTime.now(),
            ));

            // Set up real-time subscriptions for user's groups
            _setupRealtimeSubscriptions(groups);
          },
        );
      },
      (error) => emit(GroupErrorState.fromError(
        error,
        operationType: 'loading_groups',
      )),
    );
  }

  /// Handle load public groups event
  Future<void> _onLoadPublicGroups(
    LoadPublicGroups event,
    Emitter<GroupState> emit,
  ) async {
    emit(const GroupLoading(
      message: '공개 그룹을 불러오고 있습니다...',
      operationType: 'loading_public_groups',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getPublicGroups(
          limit: event.limit,
          offset: event.offset,
          searchQuery: event.searchQuery,
        );
        
        result.fold(
          (failure) => emit(GroupErrorState.fromError(
            failure,
            operationType: 'loading_public_groups',
          )),
          (groups) {
            // Update cache
            for (final group in groups) {
              _updateGroupCache(group);
            }
            
            emit(PublicGroupsLoaded(
              groups: groups,
              hasMore: groups.length == event.limit,
              totalCount: groups.length,
              searchQuery: event.searchQuery,
            ));
          },
        );
      },
      (error) => emit(GroupErrorState.fromError(
        error,
        operationType: 'loading_public_groups',
      )),
    );
  }

  /// Handle load group details event
  Future<void> _onLoadGroupDetails(
    LoadGroupDetails event,
    Emitter<GroupState> emit,
  ) async {
    // Check cache first
    if (_isGroupCacheValid(event.groupId)) {
      _cacheHits++;
      final cachedGroup = _groupCache[event.groupId]!;
      emit(GroupDetailsLoaded(
        group: cachedGroup,
        loadedAt: _cacheTimestamps[event.groupId]!,
      ));
      return;
    }

    _cacheMisses++;
    emit(const GroupLoading(
      message: '그룹 정보를 불러오고 있습니다...',
      operationType: 'loading_group_details',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getGroupById(event.groupId);
        
        result.fold(
          (failure) => emit(GroupErrorState.fromError(
            failure,
            operationType: 'loading_group_details',
          )),
          (group) {
            if (group == null) {
              emit(GroupErrorState.groupNotFound(event.groupId));
            } else {
              _updateGroupCache(group);
              emit(GroupDetailsLoaded(
                group: group,
                loadedAt: DateTime.now(),
              ));
            }
          },
        );
      },
      (error) => emit(GroupErrorState.fromError(
        error,
        operationType: 'loading_group_details',
      )),
    );
  }

  /// Handle create group event
  Future<void> _onCreateGroup(
    CreateGroup event,
    Emitter<GroupState> emit,
  ) async {
    emit(const GroupLoading(
      message: '그룹을 생성하고 있습니다...',
      operationType: 'creating_group',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.createGroup(
          event.request,
          event.creatorId,
        );
        
        result.fold(
          (failure) => emit(GroupErrorState.fromError(
            failure,
            operationType: 'creating_group',
          )),
          (group) {
            _updateGroupCache(group);
            emit(GroupCreated(
              group: group,
              createdAt: DateTime.now(),
            ));

            // Emit communication event for other BLOCs
            // Group created - emit member joined event for admin
            emitCommunicationEvent(GroupMemberJoinedEvent(
              groupId: group.id,
              userId: group.adminId,
              username: 'Admin', // Would need to get actual username
            ));
          },
        );
      },
      (error) => emit(GroupErrorState.fromError(
        error,
        operationType: 'creating_group',
      )),
    );
  }

  /// Handle join group event
  Future<void> _onJoinGroup(
    JoinGroup event,
    Emitter<GroupState> emit,
  ) async {
    emit(const GroupLoading(
      message: '그룹에 가입하고 있습니다...',
      operationType: 'joining_group',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.joinGroup(event.request);
        
        await result.fold(
          (failure) async {
            // Handle specific join failures
            if (failure.message.contains('full')) {
              emit(GroupErrorState.groupFull('그룹'));
            } else if (failure.message.contains('invite')) {
              emit(GroupErrorState.invalidInviteCode());
            } else if (failure.message.contains('already')) {
              emit(GroupErrorState.alreadyMember('그룹'));
            } else {
              emit(GroupErrorState.fromError(
                failure,
                operationType: 'joining_group',
              ));
            }
          },
          (_) async {
            // Get group details to show success message
            final groupResult = await _repository.getGroupById(event.request.groupId);
            groupResult.fold(
              (failure) => emit(GroupErrorState.fromError(failure)),
              (group) {
                if (group != null) {
                  _updateGroupCache(group);
                  emit(GroupJoined(
                    groupId: group.id,
                    groupName: group.name,
                    joinedAt: DateTime.now(),
                  ));

                  // Emit communication event
                  emitCommunicationEvent(GroupMemberJoinedEvent(
                    groupId: group.id,
                    userId: event.request.userId,
                    username: 'User', // Would need to get actual username
                  ));
                }
              },
            );
          },
        );
      },
      (error) => emit(GroupErrorState.fromError(
        error,
        operationType: 'joining_group',
      )),
    );
  }

  /// Handle leave group event
  Future<void> _onLeaveGroup(
    LeaveGroup event,
    Emitter<GroupState> emit,
  ) async {
    emit(const GroupLoading(
      message: '그룹에서 나가고 있습니다...',
      operationType: 'leaving_group',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.leaveGroup(event.groupId, event.userId);
        
        await result.fold(
          (failure) async {
            if (failure.message.toLowerCase().contains('admin')) {
              emit(GroupErrorState.cannotLeaveAsAdmin());
            } else {
              emit(GroupErrorState.fromError(
                failure,
                operationType: 'leaving_group',
              ));
            }
          },
          (_) async {
            // Get group name for success message
            final groupResult = await _repository.getGroupById(event.groupId);
            final groupName = groupResult.fold(
              (failure) => '그룹',
              (group) => group?.name ?? '그룹',
            );

            // Remove from cache
            _groupCache.remove(event.groupId);
            _membersCache.remove(event.groupId);
            _cacheTimestamps.remove(event.groupId);

            // Cancel real-time subscription
            _realtimeSubscriptions[event.groupId]?.cancel();
            _realtimeSubscriptions.remove(event.groupId);

            emit(GroupLeft(
              groupId: event.groupId,
              groupName: groupName,
              leftAt: DateTime.now(),
            ));

            // Emit communication event
            emitCommunicationEvent(GroupMemberLeftEvent(
              groupId: event.groupId,
              userId: event.userId,
              username: 'User', // Would need to get actual username
            ));
          },
        );
      },
      (error) => emit(GroupErrorState.fromError(
        error,
        operationType: 'leaving_group',
      )),
    );
  }

  /// Handle load group members event
  Future<void> _onLoadGroupMembers(
    LoadGroupMembers event,
    Emitter<GroupState> emit,
  ) async {
    // Check cache first
    if (_isMembersCacheValid(event.groupId)) {
      _cacheHits++;
      final cachedMembers = _membersCache[event.groupId]!;
      emit(GroupMembersLoaded(
        groupId: event.groupId,
        members: cachedMembers,
        loadedAt: _cacheTimestamps['members_${event.groupId}']!,
      ));
      return;
    }

    _cacheMisses++;
    emit(const GroupLoading(
      message: '그룹 멤버를 불러오고 있습니다...',
      operationType: 'loading_members',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getGroupMembers(event.groupId);
        
        result.fold(
          (failure) => emit(GroupErrorState.fromError(
            failure,
            operationType: 'loading_members',
          )),
          (members) {
            _updateMembersCache(event.groupId, members);
            emit(GroupMembersLoaded(
              groupId: event.groupId,
              members: members,
              loadedAt: DateTime.now(),
            ));
          },
        );
      },
      (error) => emit(GroupErrorState.fromError(
        error,
        operationType: 'loading_members',
      )),
    );
  }

  /// Handle update group settings event
  Future<void> _onUpdateGroupSettings(
    UpdateGroupSettings event,
    Emitter<GroupState> emit,
  ) async {
    emit(const GroupLoading(
      message: '그룹 설정을 업데이트하고 있습니다...',
      operationType: 'updating_settings',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.updateGroupSettings(
          event.groupId,
          event.request,
          event.adminId,
        );
        
        result.fold(
          (failure) {
            if (failure.message.contains('permission')) {
              emit(GroupErrorState.insufficientPermissions('그룹 설정 변경'));
            } else {
              emit(GroupErrorState.fromError(
                failure,
                operationType: 'updating_settings',
              ));
            }
          },
          (updatedGroup) {
            _updateGroupCache(updatedGroup);
            emit(GroupSettingsUpdated(
              updatedGroup: updatedGroup,
              updatedAt: DateTime.now(),
            ));

            // Emit communication event
            emitCommunicationEvent(GenericBlocCommunicationEvent(
              type: 'group_settings_updated',
              data: {
                'group_id': updatedGroup.id,
                'group_name': updatedGroup.name,
              },
            ));
          },
        );
      },
      (error) => emit(GroupErrorState.fromError(
        error,
        operationType: 'updating_settings',
      )),
    );
  }

  /// Handle remove group member event
  Future<void> _onRemoveGroupMember(
    RemoveGroupMember event,
    Emitter<GroupState> emit,
  ) async {
    emit(const GroupLoading(
      message: '멤버를 제거하고 있습니다...',
      operationType: 'removing_member',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.removeGroupMember(
          event.groupId,
          event.memberUserId,
          event.adminId,
        );
        
        result.fold(
          (failure) {
            if (failure.message.contains('permission')) {
              emit(GroupErrorState.insufficientPermissions('멤버 제거'));
            } else {
              emit(GroupErrorState.fromError(
                failure,
                operationType: 'removing_member',
              ));
            }
          },
          (_) {
            // Update members cache
            final cachedMembers = _membersCache[event.groupId];
            if (cachedMembers != null) {
              cachedMembers.removeWhere((member) => member.userId == event.memberUserId);
              _updateMembersCache(event.groupId, cachedMembers);
            }

            emit(GroupMemberRemoved(
              groupId: event.groupId,
              removedMemberId: event.memberUserId,
              removedMemberName: '멤버', // Could be enhanced with actual name
              removedAt: DateTime.now(),
            ));

            // Emit communication event
            emitCommunicationEvent(GenericBlocCommunicationEvent(
              type: 'member_removed',
              data: {
                'group_id': event.groupId,
                'removed_member_id': event.memberUserId,
                'admin_id': event.adminId,
              },
            ));
          },
        );
      },
      (error) => emit(GroupErrorState.fromError(
        error,
        operationType: 'removing_member',
      )),
    );
  }

  /// Handle update member role event
  Future<void> _onUpdateMemberRole(
    UpdateMemberRole event,
    Emitter<GroupState> emit,
  ) async {
    emit(const GroupLoading(
      message: '멤버 역할을 변경하고 있습니다...',
      operationType: 'updating_role',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.updateMemberRole(
          event.groupId,
          event.memberUserId,
          event.newRole,
          event.adminId,
        );
        
        result.fold(
          (failure) {
            if (failure.message.contains('permission')) {
              emit(GroupErrorState.insufficientPermissions('역할 변경'));
            } else {
              emit(GroupErrorState.fromError(
                failure,
                operationType: 'updating_role',
              ));
            }
          },
          (_) {
            // Update members cache
            final cachedMembers = _membersCache[event.groupId];
            if (cachedMembers != null) {
              final memberIndex = cachedMembers.indexWhere(
                (member) => member.userId == event.memberUserId,
              );
              if (memberIndex != -1) {
                cachedMembers[memberIndex] = cachedMembers[memberIndex].copyWith(
                  role: event.newRole,
                );
                _updateMembersCache(event.groupId, cachedMembers);
              }
            }

            emit(MemberRoleUpdated(
              groupId: event.groupId,
              memberId: event.memberUserId,
              newRole: event.newRole,
              updatedAt: DateTime.now(),
            ));

            // Emit communication event
            emitCommunicationEvent(GenericBlocCommunicationEvent(
              type: 'member_role_updated',
              data: {
                'group_id': event.groupId,
                'member_id': event.memberUserId,
                'new_role': event.newRole.toString(),
                'admin_id': event.adminId,
              },
            ));
          },
        );
      },
      (error) => emit(GroupErrorState.fromError(
        error,
        operationType: 'updating_role',
      )),
    );
  }

  /// Handle transfer ownership event
  Future<void> _onTransferOwnership(
    TransferOwnership event,
    Emitter<GroupState> emit,
  ) async {
    emit(const GroupLoading(
      message: '관리자 권한을 이양하고 있습니다...',
      operationType: 'transferring_ownership',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.transferOwnership(
          event.groupId,
          event.newAdminUserId,
          event.currentAdminId,
        );
        
        result.fold(
          (failure) {
            if (failure.message.contains('permission')) {
              emit(GroupErrorState.insufficientPermissions('관리자 권한 이양'));
            } else {
              emit(GroupErrorState.fromError(
                failure,
                operationType: 'transferring_ownership',
              ));
            }
          },
          (_) {
            // Update group cache
            final cachedGroup = _groupCache[event.groupId];
            if (cachedGroup != null) {
              final updatedGroup = cachedGroup.copyWith(
                adminId: event.newAdminUserId,
                updatedAt: DateTime.now(),
              );
              _updateGroupCache(updatedGroup);
            }

            // Update members cache
            final cachedMembers = _membersCache[event.groupId];
            if (cachedMembers != null) {
              for (int i = 0; i < cachedMembers.length; i++) {
                if (cachedMembers[i].userId == event.newAdminUserId) {
                  cachedMembers[i] = cachedMembers[i].copyWith(role: GroupRole.admin);
                } else if (cachedMembers[i].userId == event.currentAdminId) {
                  cachedMembers[i] = cachedMembers[i].copyWith(role: GroupRole.member);
                }
              }
              _updateMembersCache(event.groupId, cachedMembers);
            }

            emit(OwnershipTransferred(
              groupId: event.groupId,
              newAdminId: event.newAdminUserId,
              previousAdminId: event.currentAdminId,
              transferredAt: DateTime.now(),
            ));

            // Emit communication event
            emitCommunicationEvent(GenericBlocCommunicationEvent(
              type: 'ownership_transferred',
              data: {
                'group_id': event.groupId,
                'new_admin_id': event.newAdminUserId,
                'previous_admin_id': event.currentAdminId,
              },
            ));
          },
        );
      },
      (error) => emit(GroupErrorState.fromError(
        error,
        operationType: 'transferring_ownership',
      )),
    );
  }

  /// Handle generate invite code event
  Future<void> _onGenerateInviteCode(
    GenerateInviteCode event,
    Emitter<GroupState> emit,
  ) async {
    emit(const GroupLoading(
      message: '초대 코드를 생성하고 있습니다...',
      operationType: 'generating_invite_code',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.generateInviteCode(
          event.groupId,
          event.adminId,
        );
        
        result.fold(
          (failure) {
            if (failure.message.contains('permission')) {
              emit(GroupErrorState.insufficientPermissions('초대 코드 생성'));
            } else {
              emit(GroupErrorState.fromError(
                failure,
                operationType: 'generating_invite_code',
              ));
            }
          },
          (inviteCode) {
            // Update group cache with new invite code
            final cachedGroup = _groupCache[event.groupId];
            if (cachedGroup != null) {
              final updatedGroup = cachedGroup.copyWith(
                inviteCode: inviteCode,
                updatedAt: DateTime.now(),
              );
              _updateGroupCache(updatedGroup);
            }

            emit(InviteCodeGenerated(
              groupId: event.groupId,
              inviteCode: inviteCode,
              generatedAt: DateTime.now(),
            ));
          },
        );
      },
      (error) => emit(GroupErrorState.fromError(
        error,
        operationType: 'generating_invite_code',
      )),
    );
  }

  /// Handle validate invite code event
  Future<void> _onValidateInviteCode(
    ValidateInviteCode event,
    Emitter<GroupState> emit,
  ) async {
    emit(const GroupLoading(
      message: '초대 코드를 확인하고 있습니다...',
      operationType: 'validating_invite_code',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.validateInviteCode(
          event.groupId,
          event.inviteCode,
        );
        
        result.fold(
          (failure) => emit(GroupErrorState.fromError(
            failure,
            operationType: 'validating_invite_code',
          )),
          (isValid) => emit(InviteCodeValidated(
            groupId: event.groupId,
            inviteCode: event.inviteCode,
            isValid: isValid,
            validatedAt: DateTime.now(),
          )),
        );
      },
      (error) => emit(GroupErrorState.fromError(
        error,
        operationType: 'validating_invite_code',
      )),
    );
  }

  /// Handle check group membership event
  Future<void> _onCheckGroupMembership(
    CheckGroupMembership event,
    Emitter<GroupState> emit,
  ) async {
    await safeAsyncOperation(
      () async {
        final result = await _repository.getGroupMembership(
          event.groupId,
          event.userId,
        );
        
        result.fold(
          (failure) => emit(GroupErrorState.fromError(
            failure,
            operationType: 'checking_membership',
          )),
          (membership) => emit(GroupMembershipChecked(
            groupId: event.groupId,
            userId: event.userId,
            membership: membership,
            checkedAt: DateTime.now(),
          )),
        );
      },
      (error) => emit(GroupErrorState.fromError(
        error,
        operationType: 'checking_membership',
      )),
    );
  }

  /// Handle load managed groups event
  Future<void> _onLoadManagedGroups(
    LoadManagedGroups event,
    Emitter<GroupState> emit,
  ) async {
    emit(const GroupLoading(
      message: '관리 중인 그룹을 불러오고 있습니다...',
      operationType: 'loading_managed_groups',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getManagedGroups(event.userId);
        
        result.fold(
          (failure) => emit(GroupErrorState.fromError(
            failure,
            operationType: 'loading_managed_groups',
          )),
          (groups) {
            // Update cache
            for (final group in groups) {
              _updateGroupCache(group);
            }
            
            emit(ManagedGroupsLoaded(
              groups: groups,
              loadedAt: DateTime.now(),
            ));
          },
        );
      },
      (error) => emit(GroupErrorState.fromError(
        error,
        operationType: 'loading_managed_groups',
      )),
    );
  }

  /// Handle deactivate group event
  Future<void> _onDeactivateGroup(
    DeactivateGroup event,
    Emitter<GroupState> emit,
  ) async {
    emit(const GroupLoading(
      message: '그룹을 비활성화하고 있습니다...',
      operationType: 'deactivating_group',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.deactivateGroup(
          event.groupId,
          event.adminId,
        );
        
        result.fold(
          (failure) {
            if (failure.message.contains('permission')) {
              emit(GroupErrorState.insufficientPermissions('그룹 비활성화'));
            } else {
              emit(GroupErrorState.fromError(
                failure,
                operationType: 'deactivating_group',
              ));
            }
          },
          (_) async {
            // Get group name for success message
            final groupResult = await _repository.getGroupById(event.groupId);
            final groupName = groupResult.fold(
              (failure) => '그룹',
              (group) => group?.name ?? '그룹',
            );

            // Remove from cache
            _groupCache.remove(event.groupId);
            _membersCache.remove(event.groupId);
            _cacheTimestamps.remove(event.groupId);

            // Cancel real-time subscription
            _realtimeSubscriptions[event.groupId]?.cancel();
            _realtimeSubscriptions.remove(event.groupId);

            emit(GroupDeactivated(
              groupId: event.groupId,
              groupName: groupName,
              deactivatedAt: DateTime.now(),
            ));

            // Emit communication event
            emitCommunicationEvent(GenericBlocCommunicationEvent(
              type: 'group_deactivated',
              data: {
                'group_id': event.groupId,
                'group_name': groupName,
                'admin_id': event.adminId,
              },
            ));
          },
        );
      },
      (error) => emit(GroupErrorState.fromError(
        error,
        operationType: 'deactivating_group',
      )),
    );
  }

  /// Handle load group stats event
  Future<void> _onLoadGroupStats(
    LoadGroupStats event,
    Emitter<GroupState> emit,
  ) async {
    emit(const GroupLoading(
      message: '그룹 통계를 불러오고 있습니다...',
      operationType: 'loading_stats',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getGroupStats(event.groupId);
        
        result.fold(
          (failure) => emit(GroupErrorState.fromError(
            failure,
            operationType: 'loading_stats',
          )),
          (stats) => emit(GroupStatsLoaded(
            groupId: event.groupId,
            stats: stats,
            loadedAt: DateTime.now(),
          )),
        );
      },
      (error) => emit(GroupErrorState.fromError(
        error,
        operationType: 'loading_stats',
      )),
    );
  }

  /// Handle search groups event
  Future<void> _onSearchGroups(
    SearchGroups event,
    Emitter<GroupState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(const GroupSearchCleared());
      return;
    }

    emit(const GroupLoading(
      message: '그룹을 검색하고 있습니다...',
      operationType: 'searching_groups',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getPublicGroups(
          limit: event.limit,
          searchQuery: event.query.trim(),
        );
        
        result.fold(
          (failure) => emit(GroupErrorState.fromError(
            failure,
            operationType: 'searching_groups',
          )),
          (groups) => emit(GroupSearchResults(
            groups: groups,
            query: event.query.trim(),
            hasMore: groups.length == event.limit,
            totalCount: groups.length,
          )),
        );
      },
      (error) => emit(GroupErrorState.fromError(
        error,
        operationType: 'searching_groups',
      )),
    );
  }

  /// Handle clear group search event
  Future<void> _onClearGroupSearch(
    ClearGroupSearch event,
    Emitter<GroupState> emit,
  ) async {
    emit(const GroupSearchCleared());
  }

  /// Handle refresh group data event
  Future<void> _onRefreshGroupData(
    RefreshGroupData event,
    Emitter<GroupState> emit,
  ) async {
    if (event.groupId != null) {
      // Refresh specific group
      _groupCache.remove(event.groupId);
      _membersCache.remove(event.groupId);
      _cacheTimestamps.remove(event.groupId);
      _cacheTimestamps.remove('members_${event.groupId}');
    } else {
      // Refresh all cached data
      _groupCache.clear();
      _membersCache.clear();
      _cacheTimestamps.clear();
    }
  }

  /// Handle real-time group update event
  Future<void> _onHandleGroupUpdate(
    HandleGroupUpdate event,
    Emitter<GroupState> emit,
  ) async {
    // Update cache with real-time data
    final cachedGroup = _groupCache[event.groupId];
    if (cachedGroup != null) {
      // Update group properties based on updateData
      WorkoutGroup updatedGroup = cachedGroup;
      
      if (event.updateData.containsKey('name')) {
        updatedGroup = updatedGroup.copyWith(name: event.updateData['name']);
      }
      if (event.updateData.containsKey('description')) {
        updatedGroup = updatedGroup.copyWith(description: event.updateData['description']);
      }
      if (event.updateData.containsKey('current_member_count')) {
        updatedGroup = updatedGroup.copyWith(
          currentMemberCount: event.updateData['current_member_count'],
        );
      }
      if (event.updateData.containsKey('is_active')) {
        updatedGroup = updatedGroup.copyWith(isActive: event.updateData['is_active']);
      }
      
      updatedGroup = updatedGroup.copyWith(updatedAt: DateTime.now());
      _updateGroupCache(updatedGroup);
    }

    emit(GroupUpdatedRealtime(
      groupId: event.groupId,
      updateData: event.updateData,
      updatedAt: DateTime.now(),
    ));
  }

  /// Handle real-time member update event
  Future<void> _onHandleMemberUpdate(
    HandleMemberUpdate event,
    Emitter<GroupState> emit,
  ) async {
    // Update members cache based on update type
    final cachedMembers = _membersCache[event.groupId];
    if (cachedMembers != null) {
      switch (event.updateType) {
        case 'joined':
          // Add new member if not already in cache
          if (!cachedMembers.any((m) => m.userId == event.memberId)) {
            // Would need member data from updateData to add properly
            // For now, just invalidate cache to force reload
            _membersCache.remove(event.groupId);
            _cacheTimestamps.remove('members_${event.groupId}');
          }
          break;
        case 'left':
          // Remove member from cache
          cachedMembers.removeWhere((m) => m.userId == event.memberId);
          _updateMembersCache(event.groupId, cachedMembers);
          break;
        case 'role_changed':
          // Update member role
          final memberIndex = cachedMembers.indexWhere((m) => m.userId == event.memberId);
          if (memberIndex != -1 && event.updateData != null) {
            final newRoleString = event.updateData!['role'] as String?;
            if (newRoleString != null) {
              final newRole = GroupRole.values.firstWhere(
                (role) => role.toString().split('.').last == newRoleString,
                orElse: () => GroupRole.member,
              );
              cachedMembers[memberIndex] = cachedMembers[memberIndex].copyWith(role: newRole);
              _updateMembersCache(event.groupId, cachedMembers);
            }
          }
          break;
      }
    }

    emit(MemberUpdatedRealtime(
      groupId: event.groupId,
      memberId: event.memberId,
      updateType: event.updateType,
      updateData: event.updateData,
      updatedAt: DateTime.now(),
    ));
  }



  /// Clean up expired cache entries
  void _cleanupExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];
    
    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value) >= _cacheExpiration) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (final key in expiredKeys) {
      if (key.startsWith('members_')) {
        final groupId = key.substring(8);
        _membersCache.remove(groupId);
      } else {
        _groupCache.remove(key);
      }
      _cacheTimestamps.remove(key);
    }
  }

  /// Get cache performance metrics
  Map<String, dynamic> getCacheMetrics() {
    final totalRequests = _cacheHits + _cacheMisses;
    final hitRate = totalRequests > 0 ? (_cacheHits / totalRequests) * 100 : 0.0;
    
    return {
      'cache_hits': _cacheHits,
      'cache_misses': _cacheMisses,
      'hit_rate_percentage': hitRate.toStringAsFixed(2),
      'cached_groups': _groupCache.length,
      'cached_member_lists': _membersCache.length,
      'total_cache_entries': _cacheTimestamps.length,
      'active_subscriptions': _realtimeSubscriptions.length,
    };
  }

  @override
  void onInactivity() {
    // Clean up caches and subscriptions when inactive
    _cleanupExpiredCache();
    
    // Cancel some subscriptions to save resources
    if (_realtimeSubscriptions.length > 5) {
      final oldestSubscriptions = _realtimeSubscriptions.entries.take(3);
      for (final entry in oldestSubscriptions) {
        entry.value.cancel();
        _realtimeSubscriptions.remove(entry.key);
      }
    }
  }

  @override
  Future<void> close() {
    // Cancel all real-time subscriptions
    for (final subscription in _realtimeSubscriptions.values) {
      subscription.cancel();
    }
    _realtimeSubscriptions.clear();
    
    // Clear caches
    _groupCache.clear();
    _membersCache.clear();
    _cacheTimestamps.clear();
    
    return super.close();
  }

  // Convenience methods for easier usage
  void loadUserGroups(String userId, {bool forceRefresh = false}) {
    add(LoadUserGroups(userId: userId, forceRefresh: forceRefresh));
  }

  void loadPublicGroups({int limit = 20, int offset = 0, String? searchQuery}) {
    add(LoadPublicGroups(limit: limit, offset: offset, searchQuery: searchQuery));
  }

  void loadGroupDetails(String groupId) {
    add(LoadGroupDetails(groupId));
  }

  void createGroup(CreateGroupRequest request, String creatorId) {
    add(CreateGroup(request: request, creatorId: creatorId));
  }

  void joinGroup(JoinGroupRequest request) {
    add(JoinGroup(request));
  }

  void leaveGroup(String groupId, String userId) {
    add(LeaveGroup(groupId: groupId, userId: userId));
  }

  void loadGroupMembers(String groupId) {
    add(LoadGroupMembers(groupId));
  }

  void searchGroups(String query, {int limit = 20}) {
    add(SearchGroups(query: query, limit: limit));
  }

  void clearSearch() {
    add(const ClearGroupSearch());
  }

  void refreshGroupData({String? groupId}) {
    add(RefreshGroupData(groupId: groupId));
  }

  /// Handle search groups with criteria event
  Future<void> _onSearchGroupsWithCriteria(
    SearchGroupsWithCriteria event,
    Emitter<GroupState> emit,
  ) async {
    final startTime = DateTime.now();
    
    emit(const GroupLoading(
      message: '그룹을 검색하고 있습니다...',
      operationType: 'searching_groups_with_criteria',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.searchGroups(
          criteria: event.criteria,
          limit: event.limit,
          offset: event.offset,
        );
        
        result.fold(
          (failure) => emit(GroupErrorState.fromError(
            failure,
            operationType: 'searching_groups_with_criteria',
          )),
          (groups) {
            final searchDuration = DateTime.now().difference(startTime);
            
            // Update cache for found groups
            for (final group in groups) {
              _updateGroupCache(group);
            }
            
            emit(EnhancedGroupSearchResults(
              groups: groups,
              criteria: event.criteria,
              hasMore: groups.length == event.limit,
              totalCount: groups.length,
              searchDuration: searchDuration,
              searchedAt: DateTime.now(),
            ));
          },
        );
      },
      (error) => emit(GroupErrorState.fromError(
        error,
        operationType: 'searching_groups_with_criteria',
      )),
    );
  }

  /// Handle load more search results event
  Future<void> _onLoadMoreSearchResults(
    LoadMoreSearchResults event,
    Emitter<GroupState> emit,
  ) async {
    final currentState = state;
    if (currentState is! EnhancedGroupSearchResults || !currentState.hasMore) {
      return;
    }

    emit(const GroupLoading(
      message: '더 많은 검색 결과를 불러오고 있습니다...',
      operationType: 'loading_more_search_results',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.searchGroups(
          criteria: currentState.criteria,
          limit: 20,
          offset: currentState.groups.length,
        );
        
        result.fold(
          (failure) => emit(GroupErrorState.fromError(
            failure,
            operationType: 'loading_more_search_results',
          )),
          (newGroups) {
            // Update cache for new groups
            for (final group in newGroups) {
              _updateGroupCache(group);
            }
            
            final allGroups = [...currentState.groups, ...newGroups];
            
            emit(currentState.copyWith(
              groups: allGroups,
              hasMore: newGroups.length == 20,
              totalCount: allGroups.length,
              searchedAt: DateTime.now(),
            ));
          },
        );
      },
      (error) => emit(GroupErrorState.fromError(
        error,
        operationType: 'loading_more_search_results',
      )),
    );
  }

  /// Handle load suggested groups event
  Future<void> _onLoadSuggestedGroups(
    LoadSuggestedGroups event,
    Emitter<GroupState> emit,
  ) async {
    emit(const GroupLoading(
      message: '추천 그룹을 불러오고 있습니다...',
      operationType: 'loading_suggested_groups',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getSuggestedGroups(
          event.userId,
          limit: event.limit,
        );
        
        result.fold(
          (failure) => emit(GroupErrorState.fromError(
            failure,
            operationType: 'loading_suggested_groups',
          )),
          (groups) {
            // Update cache for suggested groups
            for (final group in groups) {
              _updateGroupCache(group);
            }
            
            emit(SuggestedGroupsLoaded(
              groups: groups,
              userId: event.userId,
              loadedAt: DateTime.now(),
            ));
          },
        );
      },
      (error) => emit(GroupErrorState.fromError(
        error,
        operationType: 'loading_suggested_groups',
      )),
    );
  }

  /// Handle load trending groups event
  Future<void> _onLoadTrendingGroups(
    LoadTrendingGroups event,
    Emitter<GroupState> emit,
  ) async {
    emit(const GroupLoading(
      message: '인기 그룹을 불러오고 있습니다...',
      operationType: 'loading_trending_groups',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getTrendingGroups(
          limit: event.limit,
        );
        
        result.fold(
          (failure) => emit(GroupErrorState.fromError(
            failure,
            operationType: 'loading_trending_groups',
          )),
          (groups) {
            // Update cache for trending groups
            for (final group in groups) {
              _updateGroupCache(group);
            }
            
            emit(TrendingGroupsLoaded(
              groups: groups,
              loadedAt: DateTime.now(),
            ));
          },
        );
      },
      (error) => emit(GroupErrorState.fromError(
        error,
        operationType: 'loading_trending_groups',
      )),
    );
  }
}