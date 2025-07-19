import 'package:flutter/material.dart';
import '../../../domain/entities/group_ranking.dart';

class RankingPeriodSelector extends StatelessWidget {
  final RankingPeriod selectedPeriod;
  final ValueChanged<RankingPeriod> onPeriodChanged;
  final bool isVertical;

  const RankingPeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isVertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '기간 선택',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...RankingPeriod.values.map((period) => RadioListTile<RankingPeriod>(
            title: Text(_getPeriodText(period)),
            value: period,
            groupValue: selectedPeriod,
            onChanged: (value) {
              if (value != null) {
                onPeriodChanged(value);
              }
            },
            dense: true,
            contentPadding: EdgeInsets.zero,
          )),
        ],
      );
    }

    return SegmentedButton<RankingPeriod>(
      segments: RankingPeriod.values.map((period) => ButtonSegment(
        value: period,
        label: Text(_getPeriodText(period)),
      )).toList(),
      selected: {selectedPeriod},
      onSelectionChanged: (Set<RankingPeriod> selection) {
        onPeriodChanged(selection.first);
      },
    );
  }

  String _getPeriodText(RankingPeriod period) {
    switch (period) {
      case RankingPeriod.daily:
        return '일간';
      case RankingPeriod.weekly:
        return '주간';
      case RankingPeriod.monthly:
        return '월간';
    }
  }
}