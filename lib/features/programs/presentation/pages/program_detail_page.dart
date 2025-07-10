import 'package:flutter/material.dart';
import 'package:jfit/core/theme/app_theme.dart';

class ProgramDetailPage extends StatelessWidget {
  final Map<String, dynamic> program;
  const ProgramDetailPage({required this.program, super.key});

  @override
  Widget build(BuildContext context) {
    final String intro = program['intro'] ?? '직장인을 위한 주2일 루틴입니다. 바쁜 직장인도 실천할 수 있도록 주 2회, 4주간 진행하는 근비대/수행능력 향상 루틴입니다. 각 세션은 60분 내외로 구성되어 있습니다.';
    final List<Map<String, String>> exercises = program['exercises'] ?? [
      {'name': '스쿼트', 'desc': '하체 근력 강화', 'icon': '🏋️‍♂️'},
      {'name': '벤치프레스', 'desc': '가슴/삼두 강화', 'icon': '🏋️'},
      {'name': '데드리프트', 'desc': '전신 근력 강화', 'icon': '🏋️‍♀️'},
      {'name': '풀업', 'desc': '등/광배 강화', 'icon': '💪'},
      {'name': '플랭크', 'desc': '코어 안정성', 'icon': '🧘'},
    ];

    return Scaffold(
      backgroundColor: AppTheme.programDetailBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: Text(program['title'] ?? '', style: const TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: program['image'] != null
                  ? Image.network(
                      program['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                        color: Colors.grey[800],
                        child: const Center(child: Icon(Icons.image, color: Colors.white24, size: 60)),
                      ),
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: const Center(child: Icon(Icons.image, color: Colors.white24, size: 60)),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(program['title'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(width: 8),
                      if (program['badge'] == 'PRO')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.programAccentPurple,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('PRO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(program['coach'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 15)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.thumb_up, color: Colors.greenAccent, size: 18),
                      const SizedBox(width: 4),
                      Text('100% 후기 2개', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(width: 16),
                      const Icon(Icons.people, color: Colors.white54, size: 18),
                      const SizedBox(width: 4),
                      Text('136명 도전', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.programCardBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.white38, size: 18),
                        const SizedBox(width: 6),
                        Text('주 2일 · 총 4주차', style: const TextStyle(color: Colors.white, fontSize: 14)),
                        const SizedBox(width: 16),
                        const Icon(Icons.bar_chart, color: Colors.white38, size: 18),
                        const SizedBox(width: 6),
                        Text('중급', style: const TextStyle(color: Colors.white, fontSize: 14)),
                        const SizedBox(width: 16),
                        const Icon(Icons.fitness_center, color: Colors.white38, size: 18),
                        const SizedBox(width: 6),
                        Text('근비대 · 수행능력', style: const TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(intro, style: const TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Divider(color: Colors.white24, thickness: 1),
            const SizedBox(height: 16),
            const Text('운동 상세', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            const SizedBox(height: 16),
            ...exercises.map((ex) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: Text(ex['icon'] ?? '🏋️', style: const TextStyle(fontSize: 28)),
                title: Text(ex['name'] ?? '', style: const TextStyle(color: Colors.white)),
                subtitle: Text(ex['desc'] ?? '', style: const TextStyle(color: Colors.white70)),
                                  tileColor: AppTheme.programCardBackground,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            )),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.programAccentBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {},
          
          label: const Text('내 루틴에 추가하기'),
        ),
      ),
    );
  }
}