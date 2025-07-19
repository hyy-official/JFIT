import 'package:flutter/material.dart';
import '../../domain/entities/group_member.dart';
import '../../domain/entities/workout_group.dart';
import '../../domain/entities/group_permission.dart';
import '../mixins/group_permission_mixin.dart';
import 'permission_aware_widget.dart';

/// 그룹 멤버 관리 위젯 - 권한 시스템 사용 예시
class GroupMemberManagementWidget extends StatefulWidget {
  final WorkoutGroup group;
  final GroupMember currentUser;
  final List<GroupMember> members;
  final Function(GroupMember member)? onRemoveMember;
  final Function(GroupMember member, GroupRole newRole)? onChangeRole;
  final VoidCallback? onInviteMembers;

  const GroupMemberManagementWidget({
    super.key,
    required this.group,
    required this.currentUser,
    required this.members,
    this.onRemoveMember,
    this.onChangeRole,
    this.onInviteMembers,
  });

  @override
  State<GroupMemberManagementWidget> createState() => _GroupMemberManagementWidgetState();
}

class _GroupMemberManagementWidgetState extends State<GroupMemberManagementWidget>
    with GroupPermissionMixin {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildMemberList(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '그룹 멤버 (${widget.members.length}/${widget.group.maxMembers})',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        // 멤버 초대 버튼 - 권한 기반 표시
        buildWithPermission(
          member: widget.currentUser,
          group: widget.group,
          permission: GroupPermissionType.inviteMembers,
          child: ElevatedButton.icon(
            onPressed: widget.onInviteMembers,
            icon: const Icon(Icons.person_add),
            label: const Text('멤버 초대'),
          ),
        ),
      ],
    );
  }

  Widget _buildMemberList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.members.length,
      itemBuilder: (context, index) {
        final member = widget.members[index];
        return _buildMemberTile(member);
      },
    );
  }

  Widget _buildMemberTile(GroupMember member) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: member.profileImageUrl != null
              ? NetworkImage(member.profileImageUrl!)
              : null,
          child: member.profileImageUrl == null
              ? Text(member.username.substring(0, 1).toUpperCase())
              : null,
        ),
        title: Row(
          children: [
            Text(member.username),
            const SizedBox(width: 8),
            _buildRoleBadge(member.role),
            if (member.userId == widget.group.adminId) ...[
              const SizedBox(width: 8),
              const Icon(Icons.admin_panel_settings, size: 16, color: Colors.amber),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('가입일: ${_formatDate(member.joinedAt)}'),
            if (!member.isActive)
              const Text(
                '비활성 멤버',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
        trailing: _buildMemberActions(member),
      ),
    );
  }

  Widget _buildRoleBadge(GroupRole role) {
    Color color;
    String text;
    
    switch (role) {
      case GroupRole.admin:
        color = Colors.red;
        text = '관리자';
        break;
      case GroupRole.moderator:
        color = Colors.orange;
        text = '모더레이터';
        break;
      case GroupRole.member:
        color = Colors.blue;
        text = '멤버';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMemberActions(GroupMember member) {
    // 자기 자신에 대한 액션은 표시하지 않음
    if (member.userId == widget.currentUser.userId) {
      return const SizedBox.shrink();
    }

    return PermissionAwarePopupMenuButton<String>(
      member: widget.currentUser,
      group: widget.group,
      itemBuilder: [
        // 역할 변경 메뉴
        if (canPerformAction(
          member: widget.currentUser,
          group: widget.group,
          action: GroupAction.promoteMember,
          targetMember: member,
        ) && member.role == GroupRole.member)
          const PermissionAwarePopupMenuItem(
            value: 'promote',
            permission: GroupPermissionType.promoteMembers,
            child: Row(
              children: [
                Icon(Icons.arrow_upward),
                SizedBox(width: 8),
                Text('모더레이터로 승격'),
              ],
            ),
          ),
        if (canPerformAction(
          member: widget.currentUser,
          group: widget.group,
          action: GroupAction.demoteMember,
          targetMember: member,
        ) && member.role == GroupRole.moderator)
          const PermissionAwarePopupMenuItem(
            value: 'demote',
            permission: GroupPermissionType.demoteMembers,
            child: Row(
              children: [
                Icon(Icons.arrow_downward),
                SizedBox(width: 8),
                Text('일반 멤버로 강등'),
              ],
            ),
          ),
        // 멤버 제거 메뉴
        if (canPerformAction(
          member: widget.currentUser,
          group: widget.group,
          action: GroupAction.removeMember,
          targetMember: member,
        ))
          const PermissionAwarePopupMenuItem(
            value: 'remove',
            permission: GroupPermissionType.removeMembers,
            child: Row(
              children: [
                Icon(Icons.person_remove, color: Colors.red),
                SizedBox(width: 8),
                Text('그룹에서 제거', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
      ],
      onSelected: (action) => _handleMemberAction(action, member),
    );
  }

  void _handleMemberAction(String action, GroupMember member) {
    switch (action) {
      case 'promote':
        executeWithAction(
          context: context,
          member: widget.currentUser,
          group: widget.group,
          action: GroupAction.promoteMember,
          targetMember: member,
          callback: () => widget.onChangeRole?.call(member, GroupRole.moderator),
          deniedMessage: '멤버를 승격할 권한이 없습니다.',
        );
        break;
      case 'demote':
        executeWithAction(
          context: context,
          member: widget.currentUser,
          group: widget.group,
          action: GroupAction.demoteMember,
          targetMember: member,
          callback: () => widget.onChangeRole?.call(member, GroupRole.member),
          deniedMessage: '멤버를 강등할 권한이 없습니다.',
        );
        break;
      case 'remove':
        _showRemoveConfirmDialog(member);
        break;
    }
  }

  void _showRemoveConfirmDialog(GroupMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('멤버 제거'),
        content: Text('${member.username}님을 그룹에서 제거하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              executeWithAction(
                context: context,
                member: widget.currentUser,
                group: widget.group,
                action: GroupAction.removeMember,
                targetMember: member,
                callback: () => widget.onRemoveMember?.call(member),
                deniedMessage: '멤버를 제거할 권한이 없습니다.',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('제거'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}

/// 그룹 설정 위젯 - 권한 기반 UI 예시
class GroupSettingsWidget extends StatefulWidget {
  final WorkoutGroup group;
  final GroupMember currentUser;
  final Function(WorkoutGroup updatedGroup)? onUpdateGroup;
  final VoidCallback? onDeleteGroup;

  const GroupSettingsWidget({
    super.key,
    required this.group,
    required this.currentUser,
    this.onUpdateGroup,
    this.onDeleteGroup,
  });

  @override
  State<GroupSettingsWidget> createState() => _GroupSettingsWidgetState();
}

class _GroupSettingsWidgetState extends State<GroupSettingsWidget>
    with GroupPermissionMixin {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group.name);
    _descriptionController = TextEditingController(text: widget.group.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '그룹 설정',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildBasicSettings(),
        const SizedBox(height: 24),
        _buildDangerZone(),
      ],
    );
  }

  Widget _buildBasicSettings() {
    return buildWithPermission(
      member: widget.currentUser,
      group: widget.group,
      permission: GroupPermissionType.editGroupInfo,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '기본 정보',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '그룹 이름',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '그룹 설명',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveSettings,
                child: const Text('설정 저장'),
              ),
            ],
          ),
        ),
      ),
      fallback: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.lock, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              Text(
                '그룹 설정을 변경할 권한이 없습니다',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDangerZone() {
    return buildWithAction(
      member: widget.currentUser,
      group: widget.group,
      action: GroupAction.deleteGroup,
      child: Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '위험 구역',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '그룹을 삭제하면 모든 데이터가 영구적으로 삭제됩니다.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _showDeleteConfirmDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: const Text('그룹 삭제'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveSettings() {
    executeWithPermission(
      context: context,
      member: widget.currentUser,
      group: widget.group,
      permission: GroupPermissionType.editGroupInfo,
      action: () {
        final updatedGroup = widget.group.copyWith(
          name: _nameController.text,
          description: _descriptionController.text,
          updatedAt: DateTime.now(),
        );
        widget.onUpdateGroup?.call(updatedGroup);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('그룹 설정이 저장되었습니다.')),
        );
      },
      deniedMessage: '그룹 설정을 변경할 권한이 없습니다.',
    );
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('그룹 삭제'),
        content: const Text(
          '정말로 이 그룹을 삭제하시겠습니까?\n\n'
          '이 작업은 되돌릴 수 없으며, 모든 그룹 데이터가 영구적으로 삭제됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              executeWithAction(
                context: context,
                member: widget.currentUser,
                group: widget.group,
                action: GroupAction.deleteGroup,
                callback: () => widget.onDeleteGroup?.call(),
                deniedMessage: '그룹을 삭제할 권한이 없습니다.',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}