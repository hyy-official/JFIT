import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/widgets/responsive_layout.dart';
import 'package:jfit/core/utils/breakpoint_utils.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group/group_bloc.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group/group_event.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group/group_state.dart';
import 'package:jfit/features/group_workout_community/presentation/widgets/group_member_list.dart';
import 'package:jfit/features/group_workout_community/presentation/widgets/group_activity_feed.dart';
import 'package:jfit/features/group_workout_community/presentation/widgets/group_settings_panel.dart';
import 'package:jfit/features/group_workout_community/domain/entities/workout_group.dart';
import 'package:jfit/features/group_workout_community/domain/entities/group_member.dart';

/// 그룹 상세 화면 - 멤버 목록, 설정, 활동 피드
class GroupDetailPage extends StatefulWidget {
  final String groupId;

  const GroupDetailPage({
    super.key,
    required this.groupId,
  });

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  WorkoutGroup? _currentGroup;
  List<GroupMember> _members = [];
  bool _isLoading = true;
  String? _currentUserId; // TODO: Get from auth service

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentUserId = 'current_user_id'; // TODO: Get from auth service
    _loadGroupData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadGroupData() {
    context.read<GroupBloc>().add(LoadGroupDetails(widget.groupId));
    context.read<GroupBloc>().add(LoadGroupMembers(widget.groupId));
  }

  bool get _isAdmin {
    return _currentGroup?.adminId == _currentUserId;
  }

  bool get _isMember {
    return _members.any((member) => member.userId == _currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupBloc, GroupState>(
      listener: (context, state) {
        if (state is GroupDetailsLoaded) {
          setState(() {
            _currentGroup = state.group;
            _isLoading = false;
          });
        } else if (state is GroupMembersLoaded) {
          setState(() {
            _members = state.members;
          });
        } else if (state is GroupErrorState) {
          setState(() {
            _isLoading = false;
          });
          _showErrorSnackBar(state);
        }
      },
      child: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    if (_isLoading || _currentGroup == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('그룹 정보')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentGroup!.name),
        actions: [
          if (_isAdmin)
            IconButton(
              onPressed: () => _showGroupSettings(),
              icon: const Icon(Icons.settings),
            ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              if (!_isMember)
                const PopupMenuItem(
                  value: 'join',
                  child: ListTile(
                    leading: Icon(Icons.group_add),
                    title: Text('그룹 가입'),
                  ),
                ),
              if (_isMember && !_isAdmin)
                const PopupMenuItem(
                  value: 'leave',
                  child: ListTile(
                    leading: Icon(Icons.exit_to_app),
                    title: Text('그룹 나가기'),
                  ),
                ),
              const PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('그룹 공유'),
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '활동', icon: Icon(Icons.timeline)),
            Tab(text: '멤버', icon: Icon(Icons.people)),
            Tab(text: '정보', icon: Icon(Icons.info)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          GroupActivityFeed(groupId: widget.groupId),
          GroupMemberList(
            groupId: widget.groupId,
            members: _members,
            currentUserId: _currentUserId!,
            isAdmin: _isAdmin,
          ),
          _buildGroupInfo(),
        ],
      ),
      floatingActionButton: _isMember
          ? FloatingActionButton(
              onPressed: () => _showShareRoutineDialog(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildTabletLayout() {
    if (_isLoading || _currentGroup == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('그룹 정보')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentGroup!.name),
        actions: [
          if (_isAdmin)
            IconButton(
              onPressed: () => _showGroupSettings(),
              icon: const Icon(Icons.settings),
            ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar with group info and members
          SizedBox(
            width: 320,
            child: Column(
              children: [
                // Group info header
                Container(
                  padding: const EdgeInsets.all(16),
                  child: _buildGroupHeader(),
                ),
                const Divider(),
                // Member list
                Expanded(
                  child: GroupMemberList(
                    groupId: widget.groupId,
                    members: _members,
                    currentUserId: _currentUserId!,
                    isAdmin: _isAdmin,
                    isCompact: true,
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          // Main content - Activity feed
          Expanded(
            child: GroupActivityFeed(groupId: widget.groupId),
          ),
        ],
      ),
      floatingActionButton: _isMember
          ? FloatingActionButton(
              onPressed: () => _showShareRoutineDialog(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildDesktopLayout() {
    if (_isLoading || _currentGroup == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('그룹 정보')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentGroup!.name),
        actions: [
          if (!_isMember)
            ElevatedButton.icon(
              onPressed: () => _joinGroup(),
              icon: const Icon(Icons.group_add),
              label: const Text('그룹 가입'),
            ),
          if (_isMember)
            ElevatedButton.icon(
              onPressed: () => _showShareRoutineDialog(),
              icon: const Icon(Icons.add),
              label: const Text('루틴 공유'),
            ),
          if (_isAdmin) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _showGroupSettings(),
              icon: const Icon(Icons.settings),
            ),
          ],
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Left sidebar - Group info
          SizedBox(
            width: 280,
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildGroupInfo(),
              ),
            ),
          ),
          // Main content - Activity feed
          Expanded(
            flex: 2,
            child: GroupActivityFeed(groupId: widget.groupId),
          ),
          // Right sidebar - Members
          SizedBox(
            width: 280,
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '멤버 (${_members.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: GroupMemberList(
                      groupId: widget.groupId,
                      members: _members,
                      currentUserId: _currentUserId!,
                      isAdmin: _isAdmin,
                      isCompact: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupHeader() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Group avatar
        CircleAvatar(
          radius: 40,
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(
            Icons.group,
            size: 40,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 16),
        // Group name
        Text(
          _currentGroup!.name,
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        // Member count and privacy
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people,
              size: 16,
              color: colorScheme.outline,
            ),
            const SizedBox(width: 4),
            Text(
              '${_currentGroup!.currentMemberCount}/${_currentGroup!.maxMembers}명',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              _currentGroup!.privacyType == GroupPrivacyType.public
                  ? Icons.public
                  : Icons.lock,
              size: 16,
              color: colorScheme.outline,
            ),
            const SizedBox(width: 4),
            Text(
              _currentGroup!.privacyType == GroupPrivacyType.public
                  ? '공개'
                  : '비공개',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
        if (_currentGroup!.description?.isNotEmpty == true) ...[
          const SizedBox(height: 12),
          Text(
            _currentGroup!.description!,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildGroupInfo() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGroupHeader(),
          const SizedBox(height: 24),
          
          // Group stats
          Text(
            '그룹 통계',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _buildStatItem('생성일', _formatDate(_currentGroup!.createdAt)),
          _buildStatItem('관리자', '관리자 이름'), // TODO: Get admin name
          _buildStatItem('활성 멤버', '${_members.length}명'),
          
          const SizedBox(height: 24),
          
          // Action buttons
          if (!_isMember) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _joinGroup(),
                icon: const Icon(Icons.group_add),
                label: const Text('그룹 가입하기'),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showShareRoutineDialog(),
                icon: const Icon(Icons.add),
                label: const Text('루틴 공유하기'),
              ),
            ),
            const SizedBox(height: 8),
            if (!_isAdmin)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _leaveGroup(),
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('그룹 나가기'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'join':
        _joinGroup();
        break;
      case 'leave':
        _leaveGroup();
        break;
      case 'share':
        _shareGroup();
        break;
    }
  }

  void _joinGroup() {
    // TODO: Implement join group logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('그룹 가입 기능 구현 예정')),
    );
  }

  void _leaveGroup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('그룹 나가기'),
        content: Text('정말로 "${_currentGroup!.name}" 그룹을 나가시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<GroupBloc>().add(LeaveGroup(
                groupId: widget.groupId,
                userId: _currentUserId!,
              ));
            },
            child: const Text('나가기'),
          ),
        ],
      ),
    );
  }

  void _shareGroup() {
    // TODO: Implement share group logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('그룹 공유 기능 구현 예정')),
    );
  }

  void _showGroupSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => GroupSettingsPanel(
        group: _currentGroup!,
        onSettingsChanged: () => _loadGroupData(),
      ),
    );
  }

  void _showShareRoutineDialog() {
    // TODO: Implement share routine dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('루틴 공유 기능 구현 예정')),
    );
  }

  void _showErrorSnackBar(GroupErrorState state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.userMessage),
        backgroundColor: Theme.of(context).colorScheme.error,
        action: state.isRetryable && state.retryAction != null
            ? SnackBarAction(
                label: state.actionButtonText,
                onPressed: state.retryAction!,
              )
            : null,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}