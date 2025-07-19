import 'package:flutter/material.dart';
import 'package:jfit/features/group_workout_community/domain/entities/workout_group.dart';

/// 그룹 설정 패널 위젯
class GroupSettingsPanel extends StatelessWidget {
  final WorkoutGroup group;
  final VoidCallback? onSettingsChanged;

  const GroupSettingsPanel({
    super.key,
    required this.group,
    this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '그룹 설정',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('그룹 정보 수정'),
            subtitle: const Text('이름, 설명, 최대 인원 변경'),
            onTap: () => _showEditDialog(context),
          ),
          
          ListTile(
            leading: const Icon(Icons.vpn_key),
            title: const Text('초대 코드 관리'),
            subtitle: const Text('새 초대 코드 생성'),
            onTap: () => _generateInviteCode(context),
          ),
          
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('멤버 관리'),
            subtitle: const Text('멤버 역할 변경 및 제거'),
            onTap: () => _showMemberManagement(context),
          ),
          
          const Divider(),
          
          ListTile(
            leading: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              '그룹 삭제',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            subtitle: const Text('그룹을 영구적으로 삭제합니다'),
            onTap: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    // TODO: Implement edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('그룹 정보 수정 기능 구현 예정')),
    );
  }

  void _generateInviteCode(BuildContext context) {
    // TODO: Implement invite code generation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('초대 코드 생성 기능 구현 예정')),
    );
  }

  void _showMemberManagement(BuildContext context) {
    // TODO: Implement member management
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('멤버 관리 기능 구현 예정')),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('그룹 삭제'),
        content: Text('정말로 "${group.name}" 그룹을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement group deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('그룹 삭제 기능 구현 예정')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}