import 'package:flutter/material.dart';
import 'package:jfit/features/programs/presentation/widgets/program_card_vertical.dart';

class MatchingProgramsSection extends StatelessWidget {
  final List<String> matchFilters;
  final List<Map<String, dynamic>> matchPrograms;
  
  const MatchingProgramsSection({
    required this.matchFilters,
    required this.matchPrograms,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 맞춤 프로그램 헤더
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '나에게 맞는 프로그램 찾기',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        const SizedBox(height: 12),
        // 맞춤 프로그램 필터
        SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: matchFilters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = matchFilters[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  filter,
                  style: const TextStyle(color: Colors.white70),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // 맞춤 프로그램 리스트
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              ...matchPrograms.map((p) => ProgramCardVertical(data: p)),
            ],
          ),
        ),
      ],
    );
  }
} 