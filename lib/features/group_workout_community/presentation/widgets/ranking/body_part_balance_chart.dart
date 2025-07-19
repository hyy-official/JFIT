import 'package:flutter/material.dart';
import '../../../domain/entities/body_part_mapping.dart';

class BodyPartBalanceChart extends StatelessWidget {
  final Map<BodyPart, double> bodyPartDistribution;
  final double height;

  const BodyPartBalanceChart({
    super.key,
    required this.bodyPartDistribution,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (bodyPartDistribution.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text('부위별 데이터가 없습니다'),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(
            child: _buildRadarChart(context),
          ),
          const SizedBox(height: 16),
          _buildLegend(context),
        ],
      ),
    );
  }

  Widget _buildRadarChart(BuildContext context) {
    // Placeholder for radar chart implementation
    // This would typically use a charting library like fl_chart
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.radar, size: 48),
            SizedBox(height: 8),
            Text('부위별 균형 차트'),
            Text('(구현 예정)', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: bodyPartDistribution.entries.map((entry) {
        final bodyPart = entry.key;
        final score = entry.value;
        final color = _getBodyPartColor(bodyPart);
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${bodyPart.displayName} ${score.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getBodyPartColor(BodyPart bodyPart) {
    switch (bodyPart) {
      case BodyPart.chest:
        return Colors.red;
      case BodyPart.back:
        return Colors.blue;
      case BodyPart.legs:
        return Colors.green;
      case BodyPart.shoulders:
        return Colors.orange;
      case BodyPart.arms:
        return Colors.purple;
      case BodyPart.core:
        return Colors.teal;
    }
  }
}