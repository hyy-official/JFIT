import 'package:flutter/material.dart';

class TrainerInfoCard extends StatelessWidget {
  final String trainerId;
  final String groupId;

  const TrainerInfoCard({
    super.key,
    required this.trainerId,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('트레이너 정보 카드 구현 예정'),
      ),
    );
  }
}