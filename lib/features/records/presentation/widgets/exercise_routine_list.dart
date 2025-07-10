import 'package:flutter/material.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'exercise_routine_card.dart';

class ExerciseRoutineList extends StatelessWidget {
  const ExerciseRoutineList({super.key});

  @override
  Widget build(BuildContext context) {
    // 더미 루틴 데이터
    final routines = [
      {
        'title': '아놀드 골든 식스',
        'subtitle': 'Day 6 휴식일',
        'desc': '루틴 쉬는 날입니다.',
        'image': 'https://i.imgur.com/Arnold.png',
      },
      {
        'title': '원펀맨 운동법',
        'subtitle': '기타, 가슴, 하체, 복근',
        'desc': '윗몸 일으키기, 스쿼트',
        'image': 'https://i.imgur.com/Onepunch.png',
      },
    ];
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: routines.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, idx) => ExerciseRoutineCard(
        title: routines[idx]['title']!,
        subtitle: routines[idx]['subtitle']!,
        desc: routines[idx]['desc']!,
        imageUrl: routines[idx]['image']!,
      ),
    );
  }
} 