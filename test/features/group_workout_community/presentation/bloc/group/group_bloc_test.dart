import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/features/group_workout_community/domain/entities/workout_group.dart';
import 'package:jfit/features/group_workout_community/domain/entities/group_member.dart';
import 'package:jfit/features/group_workout_community/domain/repositories/group_repository.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group/group_bloc.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group/group_event.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group/group_state.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'group_bloc_test.mocks.dart';

@GenerateMocks([GroupRepository])
void main() {
  group('GroupBloc', () {
    late GroupBloc groupBloc;
    late MockGroupRepository mockRepository;

    setUp(() {
      mockRepository = MockGroupRepository();
      groupBloc = GroupBloc(repository: mockRepository);
    });

    tearDown(() {
      groupBloc.close();
    });

    test('initial state is GroupInitial', () {
      expect(groupBloc.state, equals(const GroupInitial()));
    });

    group('LoadUserGroups', () {
      const userId = 'test-user-id';
      final testGroups = [
        WorkoutGroup(
          id: 'group-1',
          name: 'Test Group 1',
          description: 'Test Description 1',
          adminId: 'admin-1',
          privacyType: GroupPrivacyType.public,
          maxMembers: 50,
          currentMemberCount: 10,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          isActive: true,
        ),
        WorkoutGroup(
          id: 'group-2',
          name: 'Test Group 2',
          description: 'Test Description 2',
          adminId: 'admin-2',
          privacyType: GroupPrivacyType.private,
          maxMembers: 20,
          currentMemberCount: 5,
          createdAt: DateTime(2024, 1, 2),
          updatedAt: DateTime(2024, 1, 2),
          inviteCode: 'ABC123',
          isActive: true,
          groupType: 'personal_training',
        ),
      ];

      blocTest<GroupBloc, GroupState>(
        'emits [GroupLoading, UserGroupsLoaded] when LoadUserGroups succeeds',
        build: () {
          when(mockRepository.getUserGroups(userId))
              .thenAnswer((_) async => Right(testGroups));
          return groupBloc;
        },
        act: (bloc) => bloc.add(LoadUserGroups(userId: userId)),
        expect: () => [
          const GroupLoading(
            message: '내 그룹을 불러오고 있습니다...',
            operationType: 'loading_groups',
          ),
          isA<UserGroupsLoaded>()
              .having((state) => state.groups, 'groups', testGroups)
              .having((state) => state.groups.length, 'groups length', 2),
        ],
        verify: (_) {
          verify(mockRepository.getUserGroups(userId)).called(1);
        },
      );

      blocTest<GroupBloc, GroupState>(
        'emits [GroupLoading, GroupErrorState] when LoadUserGroups fails',
        build: () {
          when(mockRepository.getUserGroups(userId))
              .thenAnswer((_) async => Left(ServerFailure('Server error')));
          return groupBloc;
        },
        act: (bloc) => bloc.add(LoadUserGroups(userId: userId)),
        expect: () => [
          const GroupLoading(
            message: '내 그룹을 불러오고 있습니다...',
            operationType: 'loading_groups',
          ),
          isA<GroupErrorState>()
              .having((state) => state.error.message, 'error message', contains('Server error'))
              .having((state) => state.operationType, 'operationType', 'loading_groups'),
        ],
        verify: (_) {
          verify(mockRepository.getUserGroups(userId)).called(1);
        },
      );

      blocTest<GroupBloc, GroupState>(
        'emits [GroupLoading, UserGroupsLoaded] with empty list when user has no groups',
        build: () {
          when(mockRepository.getUserGroups(userId))
              .thenAnswer((_) async => const Right([]));
          return groupBloc;
        },
        act: (bloc) => bloc.add(LoadUserGroups(userId: userId)),
        expect: () => [
          const GroupLoading(
            message: '내 그룹을 불러오고 있습니다...',
            operationType: 'loading_groups',
          ),
          isA<UserGroupsLoaded>()
              .having((state) => state.groups, 'groups', isEmpty),
        ],
        verify: (_) {
          verify(mockRepository.getUserGroups(userId)).called(1);
        },
      );
    });

    group('LoadPublicGroups', () {
      final testGroups = [
        WorkoutGroup(
          id: 'public-group-1',
          name: 'Public Group 1',
          description: 'Public Description 1',
          adminId: 'admin-1',
          privacyType: GroupPrivacyType.public,
          maxMembers: 50,
          currentMemberCount: 25,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          isActive: true,
        ),
      ];

      blocTest<GroupBloc, GroupState>(
        'emits [GroupLoading, PublicGroupsLoaded] when LoadPublicGroups succeeds',
        build: () {
          when(mockRepository.getPublicGroups(
            limit: 20,
            offset: 0,
            searchQuery: null,
          )).thenAnswer((_) async => Right(testGroups));
          return groupBloc;
        },
        act: (bloc) => bloc.add(const LoadPublicGroups()),
        expect: () => [
          const GroupLoading(
            message: '공개 그룹을 불러오고 있습니다...',
            operationType: 'loading_public_groups',
          ),
          isA<PublicGroupsLoaded>()
              .having((state) => state.groups, 'groups', testGroups)
              .having((state) => state.hasMore, 'hasMore', false)
              .having((state) => state.totalCount, 'totalCount', 1),
        ],
        verify: (_) {
          verify(mockRepository.getPublicGroups(
            limit: 20,
            offset: 0,
            searchQuery: null,
          )).called(1);
        },
      );

      blocTest<GroupBloc, GroupState>(
        'emits [GroupLoading, PublicGroupsLoaded] with search query',
        build: () {
          when(mockRepository.getPublicGroups(
            limit: 20,
            offset: 0,
            searchQuery: 'fitness',
          )).thenAnswer((_) async => Right(testGroups));
          return groupBloc;
        },
        act: (bloc) => bloc.add(const LoadPublicGroups(searchQuery: 'fitness')),
        expect: () => [
          const GroupLoading(
            message: '공개 그룹을 불러오고 있습니다...',
            operationType: 'loading_public_groups',
          ),
          isA<PublicGroupsLoaded>()
              .having((state) => state.groups, 'groups', testGroups)
              .having((state) => state.searchQuery, 'searchQuery', 'fitness'),
        ],
        verify: (_) {
          verify(mockRepository.getPublicGroups(
            limit: 20,
            offset: 0,
            searchQuery: 'fitness',
          )).called(1);
        },
      );
    });

    group('CreateGroup', () {
      const creatorId = 'creator-id';
      const request = CreateGroupRequest(
        name: 'New Test Group',
        description: 'New Test Description',
        privacyType: GroupPrivacyType.public,
        maxMembers: 30,
      );

      final createdGroup = WorkoutGroup(
        id: 'new-group-id',
        name: 'New Test Group',
        description: 'New Test Description',
        adminId: creatorId,
        privacyType: GroupPrivacyType.public,
        maxMembers: 30,
        currentMemberCount: 1,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        isActive: true,
      );

      blocTest<GroupBloc, GroupState>(
        'emits [GroupLoading, GroupCreated] when CreateGroup succeeds',
        build: () {
          when(mockRepository.createGroup(request, creatorId))
              .thenAnswer((_) async => Right(createdGroup));
          return groupBloc;
        },
        act: (bloc) => bloc.add(CreateGroup(request: request, creatorId: creatorId)),
        expect: () => [
          const GroupLoading(
            message: '그룹을 생성하고 있습니다...',
            operationType: 'creating_group',
          ),
          isA<GroupCreated>()
              .having((state) => state.group, 'group', createdGroup)
              .having((state) => state.group.id, 'group id', 'new-group-id')
              .having((state) => state.group.name, 'group name', 'New Test Group'),
        ],
        verify: (_) {
          verify(mockRepository.createGroup(request, creatorId)).called(1);
        },
      );

      blocTest<GroupBloc, GroupState>(
        'emits [GroupLoading, GroupErrorState] when CreateGroup fails',
        build: () {
          when(mockRepository.createGroup(request, creatorId))
              .thenAnswer((_) async => Left(ValidationFailure('Invalid group name')));
          return groupBloc;
        },
        act: (bloc) => bloc.add(CreateGroup(request: request, creatorId: creatorId)),
        expect: () => [
          const GroupLoading(
            message: '그룹을 생성하고 있습니다...',
            operationType: 'creating_group',
          ),
          isA<GroupErrorState>()
              .having((state) => state.error.message, 'error message', contains('Invalid group name'))
              .having((state) => state.operationType, 'operationType', 'creating_group'),
        ],
        verify: (_) {
          verify(mockRepository.createGroup(request, creatorId)).called(1);
        },
      );
    });

    group('JoinGroup', () {
      const request = JoinGroupRequest(
        groupId: 'group-id',
        userId: 'user-id',
        inviteCode: null,
      );

      final testGroup = WorkoutGroup(
        id: 'group-id',
        name: 'Test Group',
        description: 'Test Description',
        adminId: 'admin-id',
        privacyType: GroupPrivacyType.public,
        maxMembers: 50,
        currentMemberCount: 10,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        isActive: true,
      );

      blocTest<GroupBloc, GroupState>(
        'emits [GroupLoading, GroupJoined] when JoinGroup succeeds',
        build: () {
          when(mockRepository.joinGroup(request))
              .thenAnswer((_) async => const Right(null));
          when(mockRepository.getGroupById('group-id'))
              .thenAnswer((_) async => Right(testGroup));
          return groupBloc;
        },
        act: (bloc) => bloc.add(JoinGroup(request)),
        expect: () => [
          const GroupLoading(
            message: '그룹에 가입하고 있습니다...',
            operationType: 'joining_group',
          ),
          isA<GroupJoined>()
              .having((state) => state.groupId, 'groupId', 'group-id')
              .having((state) => state.groupName, 'groupName', 'Test Group'),
        ],
        verify: (_) {
          verify(mockRepository.joinGroup(request)).called(1);
          verify(mockRepository.getGroupById('group-id')).called(1);
        },
      );

      blocTest<GroupBloc, GroupState>(
        'emits [GroupLoading, GroupErrorState] when group is full',
        build: () {
          when(mockRepository.joinGroup(request))
              .thenAnswer((_) async => Left(DatabaseFailure('Group is full')));
          return groupBloc;
        },
        act: (bloc) => bloc.add(JoinGroup(request)),
        expect: () => [
          const GroupLoading(
            message: '그룹에 가입하고 있습니다...',
            operationType: 'joining_group',
          ),
          isA<GroupErrorState>()
              .having((state) => state.userMessage, 'user message', contains('그룹이 가득 찼습니다')),
        ],
        verify: (_) {
          verify(mockRepository.joinGroup(request)).called(1);
        },
      );

      blocTest<GroupBloc, GroupState>(
        'emits [GroupLoading, GroupErrorState] when invite code is invalid',
        build: () {
          when(mockRepository.joinGroup(request))
              .thenAnswer((_) async => Left(ValidationFailure('Invalid invite code')));
          return groupBloc;
        },
        act: (bloc) => bloc.add(JoinGroup(request)),
        expect: () => [
          const GroupLoading(
            message: '그룹에 가입하고 있습니다...',
            operationType: 'joining_group',
          ),
          isA<GroupErrorState>()
              .having((state) => state.userMessage, 'user message', contains('유효하지 않거나 만료된 초대 코드입니다')),
        ],
        verify: (_) {
          verify(mockRepository.joinGroup(request)).called(1);
        },
      );
    });

    group('LeaveGroup', () {
      const groupId = 'group-id';
      const userId = 'user-id';

      final testGroup = WorkoutGroup(
        id: groupId,
        name: 'Test Group',
        description: 'Test Description',
        adminId: 'admin-id',
        privacyType: GroupPrivacyType.public,
        maxMembers: 50,
        currentMemberCount: 10,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        isActive: true,
      );

      blocTest<GroupBloc, GroupState>(
        'emits [GroupLoading, GroupLeft] when LeaveGroup succeeds',
        build: () {
          when(mockRepository.leaveGroup(groupId, userId))
              .thenAnswer((_) async => const Right(null));
          when(mockRepository.getGroupById(groupId))
              .thenAnswer((_) async => Right(testGroup));
          return groupBloc;
        },
        act: (bloc) => bloc.add(LeaveGroup(groupId: groupId, userId: userId)),
        expect: () => [
          const GroupLoading(
            message: '그룹에서 나가고 있습니다...',
            operationType: 'leaving_group',
          ),
          isA<GroupLeft>()
              .having((state) => state.groupId, 'groupId', groupId)
              .having((state) => state.groupName, 'groupName', 'Test Group'),
        ],
        verify: (_) {
          verify(mockRepository.leaveGroup(groupId, userId)).called(1);
          verify(mockRepository.getGroupById(groupId)).called(1);
        },
      );

      blocTest<GroupBloc, GroupState>(
        'emits [GroupLoading, GroupErrorState] when admin tries to leave',
        build: () {
          when(mockRepository.leaveGroup(groupId, userId))
              .thenAnswer((_) async => Left(PermissionFailure('Admin cannot leave group')));
          return groupBloc;
        },
        act: (bloc) => bloc.add(LeaveGroup(groupId: groupId, userId: userId)),
        expect: () => [
          const GroupLoading(
            message: '그룹에서 나가고 있습니다...',
            operationType: 'leaving_group',
          ),
          isA<GroupErrorState>()
              .having((state) => state.userMessage, 'user message', contains('관리자는 그룹을 떠날 수 없습니다')),
        ],
        verify: (_) {
          verify(mockRepository.leaveGroup(groupId, userId)).called(1);
        },
      );
    });

    group('LoadGroupMembers', () {
      const groupId = 'group-id';
      final testMembers = [
        GroupMember(
          id: 'member-1',
          groupId: groupId,
          userId: 'user-1',
          username: 'user1',
          role: GroupRole.admin,
          joinedAt: DateTime(2024, 1, 1),
          isActive: true,
          lastActiveAt: DateTime(2024, 1, 1),
        ),
        GroupMember(
          id: 'member-2',
          groupId: groupId,
          userId: 'user-2',
          username: 'user2',
          role: GroupRole.member,
          joinedAt: DateTime(2024, 1, 2),
          isActive: true,
          lastActiveAt: DateTime(2024, 1, 2),
        ),
      ];

      blocTest<GroupBloc, GroupState>(
        'emits [GroupLoading, GroupMembersLoaded] when LoadGroupMembers succeeds',
        build: () {
          when(mockRepository.getGroupMembers(groupId))
              .thenAnswer((_) async => Right(testMembers));
          return groupBloc;
        },
        act: (bloc) => bloc.add(LoadGroupMembers(groupId)),
        expect: () => [
          const GroupLoading(
            message: '그룹 멤버를 불러오고 있습니다...',
            operationType: 'loading_members',
          ),
          isA<GroupMembersLoaded>()
              .having((state) => state.groupId, 'groupId', groupId)
              .having((state) => state.members, 'members', testMembers)
              .having((state) => state.members.length, 'members length', 2),
        ],
        verify: (_) {
          verify(mockRepository.getGroupMembers(groupId)).called(1);
        },
      );

      blocTest<GroupBloc, GroupState>(
        'emits [GroupLoading, GroupMembersLoaded] with empty list when group has no members',
        build: () {
          when(mockRepository.getGroupMembers(groupId))
              .thenAnswer((_) async => const Right([]));
          return groupBloc;
        },
        act: (bloc) => bloc.add(LoadGroupMembers(groupId)),
        expect: () => [
          const GroupLoading(
            message: '그룹 멤버를 불러오고 있습니다...',
            operationType: 'loading_members',
          ),
          isA<GroupMembersLoaded>()
              .having((state) => state.groupId, 'groupId', groupId)
              .having((state) => state.members, 'members', isEmpty),
        ],
        verify: (_) {
          verify(mockRepository.getGroupMembers(groupId)).called(1);
        },
      );
    });

    group('UpdateGroupSettings', () {
      const groupId = 'group-id';
      const adminId = 'admin-id';
      const request = UpdateGroupRequest(
        name: 'Updated Group Name',
        description: 'Updated Description',
        maxMembers: 40,
      );

      final updatedGroup = WorkoutGroup(
        id: groupId,
        name: 'Updated Group Name',
        description: 'Updated Description',
        adminId: adminId,
        privacyType: GroupPrivacyType.public,
        maxMembers: 40,
        currentMemberCount: 10,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1, 12),
        isActive: true,
      );

      blocTest<GroupBloc, GroupState>(
        'emits [GroupLoading, GroupSettingsUpdated] when UpdateGroupSettings succeeds',
        build: () {
          when(mockRepository.updateGroupSettings(groupId, request, adminId))
              .thenAnswer((_) async => Right(updatedGroup));
          return groupBloc;
        },
        act: (bloc) => bloc.add(UpdateGroupSettings(
          groupId: groupId,
          request: request,
          adminId: adminId,
        )),
        expect: () => [
          const GroupLoading(
            message: '그룹 설정을 업데이트하고 있습니다...',
            operationType: 'updating_settings',
          ),
          isA<GroupSettingsUpdated>()
              .having((state) => state.updatedGroup, 'updatedGroup', updatedGroup)
              .having((state) => state.updatedGroup.name, 'group name', 'Updated Group Name'),
        ],
        verify: (_) {
          verify(mockRepository.updateGroupSettings(groupId, request, adminId)).called(1);
        },
      );

      blocTest<GroupBloc, GroupState>(
        'emits [GroupLoading, GroupErrorState] when user lacks permission',
        build: () {
          when(mockRepository.updateGroupSettings(groupId, request, adminId))
              .thenAnswer((_) async => Left(PermissionFailure('Insufficient permission')));
          return groupBloc;
        },
        act: (bloc) => bloc.add(UpdateGroupSettings(
          groupId: groupId,
          request: request,
          adminId: adminId,
        )),
        expect: () => [
          const GroupLoading(
            message: '그룹 설정을 업데이트하고 있습니다...',
            operationType: 'updating_settings',
          ),
          isA<GroupErrorState>()
              .having((state) => state.userMessage, 'user message', contains('이 작업을 수행할 권한이 없습니다')),
        ],
        verify: (_) {
          verify(mockRepository.updateGroupSettings(groupId, request, adminId)).called(1);
        },
      );
    });

    group('GenerateInviteCode', () {
      const groupId = 'group-id';
      const adminId = 'admin-id';
      const generatedCode = 'ABC123XYZ';

      blocTest<GroupBloc, GroupState>(
        'emits [GroupLoading, InviteCodeGenerated] when GenerateInviteCode succeeds',
        build: () {
          when(mockRepository.generateInviteCode(groupId, adminId))
              .thenAnswer((_) async => const Right(generatedCode));
          return groupBloc;
        },
        act: (bloc) => bloc.add(GenerateInviteCode(groupId: groupId, adminId: adminId)),
        expect: () => [
          const GroupLoading(
            message: '초대 코드를 생성하고 있습니다...',
            operationType: 'generating_invite_code',
          ),
          isA<InviteCodeGenerated>()
              .having((state) => state.groupId, 'groupId', groupId)
              .having((state) => state.inviteCode, 'inviteCode', generatedCode),
        ],
        verify: (_) {
          verify(mockRepository.generateInviteCode(groupId, adminId)).called(1);
        },
      );

      blocTest<GroupBloc, GroupState>(
        'emits [GroupLoading, GroupErrorState] when user lacks permission',
        build: () {
          when(mockRepository.generateInviteCode(groupId, adminId))
              .thenAnswer((_) async => Left(PermissionFailure('Insufficient permission')));
          return groupBloc;
        },
        act: (bloc) => bloc.add(GenerateInviteCode(groupId: groupId, adminId: adminId)),
        expect: () => [
          const GroupLoading(
            message: '초대 코드를 생성하고 있습니다...',
            operationType: 'generating_invite_code',
          ),
          isA<GroupErrorState>()
              .having((state) => state.userMessage, 'user message', contains('이 작업을 수행할 권한이 없습니다')),
        ],
        verify: (_) {
          verify(mockRepository.generateInviteCode(groupId, adminId)).called(1);
        },
      );
    });

    group('ValidateInviteCode', () {
      const groupId = 'group-id';
      const inviteCode = 'ABC123XYZ';

      blocTest<GroupBloc, GroupState>(
        'emits [GroupLoading, InviteCodeValidated] with valid code',
        build: () {
          when(mockRepository.validateInviteCode(groupId, inviteCode))
              .thenAnswer((_) async => const Right(true));
          return groupBloc;
        },
        act: (bloc) => bloc.add(ValidateInviteCode(groupId: groupId, inviteCode: inviteCode)),
        expect: () => [
          const GroupLoading(
            message: '초대 코드를 확인하고 있습니다...',
            operationType: 'validating_invite_code',
          ),
          isA<InviteCodeValidated>()
              .having((state) => state.groupId, 'groupId', groupId)
              .having((state) => state.inviteCode, 'inviteCode', inviteCode)
              .having((state) => state.isValid, 'isValid', true),
        ],
        verify: (_) {
          verify(mockRepository.validateInviteCode(groupId, inviteCode)).called(1);
        },
      );

      blocTest<GroupBloc, GroupState>(
        'emits [GroupLoading, InviteCodeValidated] with invalid code',
        build: () {
          when(mockRepository.validateInviteCode(groupId, inviteCode))
              .thenAnswer((_) async => const Right(false));
          return groupBloc;
        },
        act: (bloc) => bloc.add(ValidateInviteCode(groupId: groupId, inviteCode: inviteCode)),
        expect: () => [
          const GroupLoading(
            message: '초대 코드를 확인하고 있습니다...',
            operationType: 'validating_invite_code',
          ),
          isA<InviteCodeValidated>()
              .having((state) => state.groupId, 'groupId', groupId)
              .having((state) => state.inviteCode, 'inviteCode', inviteCode)
              .having((state) => state.isValid, 'isValid', false),
        ],
        verify: (_) {
          verify(mockRepository.validateInviteCode(groupId, inviteCode)).called(1);
        },
      );
    });

    group('SearchGroups', () {
      const query = 'fitness';
      final testGroups = [
        WorkoutGroup(
          id: 'fitness-group-1',
          name: 'Fitness Group 1',
          description: 'Fitness Description 1',
          adminId: 'admin-1',
          privacyType: GroupPrivacyType.public,
          maxMembers: 50,
          currentMemberCount: 25,
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
          isActive: true,
        ),
      ];

      blocTest<GroupBloc, GroupState>(
        'emits [GroupLoading, GroupSearchResults] when SearchGroups succeeds',
        build: () {
          when(mockRepository.getPublicGroups(
            limit: 20,
            searchQuery: query,
          )).thenAnswer((_) async => Right(testGroups));
          return groupBloc;
        },
        act: (bloc) => bloc.add(const SearchGroups(query: query)),
        expect: () => [
          const GroupLoading(
            message: '그룹을 검색하고 있습니다...',
            operationType: 'searching_groups',
          ),
          isA<GroupSearchResults>()
              .having((state) => state.groups, 'groups', testGroups)
              .having((state) => state.query, 'query', query)
              .having((state) => state.hasMore, 'hasMore', false)
              .having((state) => state.totalCount, 'totalCount', 1),
        ],
        verify: (_) {
          verify(mockRepository.getPublicGroups(
            limit: 20,
            searchQuery: query,
          )).called(1);
        },
      );

      blocTest<GroupBloc, GroupState>(
        'emits [GroupSearchCleared] when SearchGroups with empty query',
        build: () => groupBloc,
        act: (bloc) => bloc.add(const SearchGroups(query: '')),
        expect: () => [
          const GroupSearchCleared(),
        ],
        verify: (_) {
          verifyZeroInteractions(mockRepository);
        },
      );

      blocTest<GroupBloc, GroupState>(
        'emits [GroupSearchCleared] when SearchGroups with whitespace query',
        build: () => groupBloc,
        act: (bloc) => bloc.add(const SearchGroups(query: '   ')),
        expect: () => [
          const GroupSearchCleared(),
        ],
        verify: (_) {
          verifyZeroInteractions(mockRepository);
        },
      );
    });

    group('ClearGroupSearch', () {
      blocTest<GroupBloc, GroupState>(
        'emits [GroupSearchCleared] when ClearGroupSearch is called',
        build: () => groupBloc,
        act: (bloc) => bloc.add(const ClearGroupSearch()),
        expect: () => [
          const GroupSearchCleared(),
        ],
        verify: (_) {
          verifyZeroInteractions(mockRepository);
        },
      );
    });

    group('Error Handling', () {
      const userId = 'test-user-id';

      blocTest<GroupBloc, GroupState>(
        'handles unexpected exceptions during LoadUserGroups',
        setUp: () {
          reset(mockRepository);
        },
        build: () {
          when(mockRepository.getUserGroups(userId))
              .thenThrow(Exception('Unexpected error'));
          return groupBloc;
        },
        act: (bloc) => bloc.add(LoadUserGroups(userId: userId)),
        expect: () => [
          const GroupLoading(
            message: '내 그룹을 불러오고 있습니다...',
            operationType: 'loading_groups',
          ),
          isA<GroupErrorState>()
              .having((state) => state.operationType, 'operationType', 'loading_groups'),
        ],
      );

      blocTest<GroupBloc, GroupState>(
        'handles network failures gracefully',
        build: () {
          when(mockRepository.getUserGroups(userId))
              .thenAnswer((_) async => Left(NetworkFailure('Network error')));
          return groupBloc;
        },
        act: (bloc) => bloc.add(LoadUserGroups(userId: userId)),
        expect: () => [
          const GroupLoading(
            message: '내 그룹을 불러오고 있습니다...',
            operationType: 'loading_groups',
          ),
          isA<GroupErrorState>()
              .having((state) => state.error.message, 'error message', contains('Network error'))
              .having((state) => state.operationType, 'operationType', 'loading_groups'),
        ],
      );
    });
  });
}