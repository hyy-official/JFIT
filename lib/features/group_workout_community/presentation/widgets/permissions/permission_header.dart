import 'package:flutter/material.dart';

class PermissionHeader extends StatelessWidget {
  final String groupId;
  final String memberId;

  const PermissionHeader({
    super.key,
    required this.groupId,
    required this.memberId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('권한 헤더 구현 예정'),
      ),
    );
  }
}