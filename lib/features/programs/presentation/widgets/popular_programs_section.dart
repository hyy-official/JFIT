import 'package:flutter/material.dart';
import 'package:jfit/features/programs/presentation/widgets/program_card_horizontal.dart';

class PopularProgramsSection extends StatelessWidget {
  final List<Map<String, dynamic>> popularPrograms;
  
  const PopularProgramsSection({
    required this.popularPrograms,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 인기 프로그램 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '인기 프로그램',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('더보기', style: TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // 인기 프로그램 가로 스크롤
        SizedBox(
          height: 220,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: popularPrograms.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, idx) => ProgramCardHorizontal(data: popularPrograms[idx]),
          ),
        ),
      ],
    );
  }
} 