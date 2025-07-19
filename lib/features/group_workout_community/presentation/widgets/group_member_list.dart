import 'package:flutter/material.dart';
import 'package:jfit/features/group_workout_community/domain/entities/group_member.dart';
import 'package:jfit/features/group_workout_community/domain/entities/workout_group.dart';

/// 그룹 멤버 목록을 표시하는 위젯
class GroupMemberList extends StatelessWidget {
  final String groupId;
  final List<GroupMember> members;
  final String currentUserId;
  final bool isAdmin;
  final bool isCompact;

  const GroupMemberList({
    super.key,
    required this.groupId,
    required this.members,
    required this.currentUserId,
    required this.isAdmin,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const Center(
        child: Text('멤버가 없습니다'),
      );
    }

    return ListView.builder(
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(member.username[0].toUpperCase()),
          ),
          title: Text(member.username),
          subtitle: Text(_getRoleText(member.role)),
          trailing: isAdmin && member.userId != currentUserId
              ? PopupMenuButton<String>(
                  onSelected: (action) => _handleMemberAction(context, member, action),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'remove',
                      child: Text('멤버 제거'),
                    ),
                    const PopupMenuItem(
                      value: 'promote',
                      child: Text('관리자로 승격'),
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }

  String _getRoleText(GroupRole role) {
    switch (role) {
      case GroupRole.admin:
        return '관리자';
      case GroupRole.moderator:
        return '모더레이터';
      case GroupRole.member:
        return '멤버';
    }
  }

  void _handleMemberAction(BuildContext context, GroupMember member, String action) {
    // TODO: Implement member actions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action 기능 구현 예정')),
    );
  }
}