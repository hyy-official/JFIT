import 'package:flutter/material.dart';

class WorkoutAnalysisWidget extends StatelessWidget {
  final Map<String, dynamic> workoutAnalysis;
  final bool isDetailed;

  const WorkoutAnalysisWidget({
    super.key,
    required this.workoutAnalysis,
    this.isDetailed = false,
  });

  @override
  Widget build(BuildContext context) {
    if (workoutAnalysis.isEmpty) {
      return const Center(
        child: Text('운동 분석 데이터가 없습니다'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryCards(context),
        if (isDetailed) ...[
          const SizedBox(height: 16),
          _buildDetailedMetrics(context),
        ],
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    final summaryData = [
      (
        '총 운동 시간',
        '${workoutAnalysis['totalWorkoutTime'] ?? 0}분',
        Icons.timer,
        Colors.blue,
      ),
      (
        '평균 세션 시간',
        '${workoutAnalysis['averageSessionTime'] ?? 0}분',
        Icons.schedule,
        Colors.green,
      ),
      (
        '운동 빈도',
        '주 ${workoutAnalysis['weeklyFrequency'] ?? 0}회',
        Icons.fitness_center,
        Colors.orange,
      ),
      (
        '운동 다양성',
        '${workoutAnalysis['exerciseVariety'] ?? 0}종류',
        Icons.category,
        Colors.purple,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDetailed ? 4 : 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: summaryData.length,
      itemBuilder: (context, index) {
        final (label, value, icon, color) = summaryData[index];
        return _buildSummaryCard(context, label, value, icon, color);
      },
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedMetrics(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '상세 지표',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        _buildMetricsList(context),
      ],
    );
  }

  Widget _buildMetricsList(BuildContext context) {
    final metrics = [
      ('최장 운동 시간', '${workoutAnalysis['maxSessionTime'] ?? 0}분'),
      ('최단 운동 시간', '${workoutAnalysis['minSessionTime'] ?? 0}분'),
      ('총 볼륨', '${workoutAnalysis['totalVolume'] ?? 0} kg'),
      ('평균 볼륨', '${workoutAnalysis['averageVolume'] ?? 0} kg'),
      ('운동 일수', '${workoutAnalysis['workoutDays'] ?? 0}일'),
      ('휴식 일수', '${workoutAnalysis['restDays'] ?? 0}일'),
      ('완료율', '${workoutAnalysis['completionRate'] ?? 0}%'),
      ('목표 달성률', '${workoutAnalysis['goalAchievementRate'] ?? 0}%'),
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final (label, value) = metrics[index];
        return _buildMetricItem(context, label, value);
      },
    );
  }

  Widget _buildMetricItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}