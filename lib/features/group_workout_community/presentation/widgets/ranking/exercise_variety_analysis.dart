import 'package:flutter/material.dart';
import '../../../domain/entities/body_part_mapping.dart';

class ExerciseVarietyAnalysis extends StatelessWidget {
  final Map<String, dynamic> workoutAnalysis;
  final Map<BodyPart, double>? bodyPartDistribution;
  final bool isDetailed;

  const ExerciseVarietyAnalysis({
    super.key,
    required this.workoutAnalysis,
    this.bodyPartDistribution,
    this.isDetailed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildVarietyOverview(context),
        if (isDetailed) ...[
          const SizedBox(height: 16),
          _buildDetailedAnalysis(context),
        ],
      ],
    );
  }

  Widget _buildVarietyOverview(BuildContext context) {
    final totalExercises = workoutAnalysis['totalExercises'] as int? ?? 0;
    final uniqueExercises = workoutAnalysis['uniqueExercises'] as int? ?? 0;
    final varietyScore = workoutAnalysis['varietyScore'] as double? ?? 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildVarietyCard(
            context,
            '총 운동',
            '$totalExercises개',
            Icons.fitness_center,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildVarietyCard(
            context,
            '고유 운동',
            '$uniqueExercises개',
            Icons.category,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildVarietyCard(
            context,
            '다양성 점수',
            varietyScore.toStringAsFixed(1),
            Icons.star,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildVarietyCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
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

  Widget _buildDetailedAnalysis(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '상세 분석',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        if (bodyPartDistribution != null && bodyPartDistribution!.isNotEmpty)
          _buildBodyPartDistribution(context)
        else
          _buildPlaceholderChart(context),
        const SizedBox(height: 16),
        _buildVarietyMetrics(context),
      ],
    );
  }

  Widget _buildBodyPartDistribution(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart, size: 48),
            SizedBox(height: 8),
            Text('부위별 운동 분포'),
            Text('(구현 예정)', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderChart(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text('부위별 분포 데이터가 없습니다'),
      ),
    );
  }

  Widget _buildVarietyMetrics(BuildContext context) {
    final metrics = [
      ('새로운 운동', '${workoutAnalysis['newExercises'] ?? 0}개'),
      ('반복 운동', '${workoutAnalysis['repeatedExercises'] ?? 0}개'),
      ('평균 세트 수', '${workoutAnalysis['averageSets'] ?? 0}세트'),
      ('평균 반복 수', '${workoutAnalysis['averageReps'] ?? 0}회'),
      ('운동 강도', '${workoutAnalysis['averageIntensity'] ?? 0}%'),
      ('다양성 등급', _getVarietyGrade(workoutAnalysis['varietyScore'] as double? ?? 0.0)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final (label, value) = metrics[index];
        return _buildMetricItem(context, label, value);
      },
    );
  }

  Widget _buildMetricItem(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getVarietyGrade(double score) {
    if (score >= 90) return 'S';
    if (score >= 80) return 'A';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    if (score >= 50) return 'D';
    return 'F';
  }
}