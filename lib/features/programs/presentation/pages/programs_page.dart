import 'package:flutter/material.dart';
import 'package:jfit/features/programs/presentation/widgets/popular_programs_section.dart';
import 'package:jfit/features/programs/presentation/widgets/matching_programs_section.dart';
import 'package:jfit/features/programs/presentation/widgets/daily_routines_section.dart';
import 'package:jfit/features/programs/presentation/widgets/filter_chips_row.dart';
import 'package:jfit/features/programs/presentation/widgets/search_bar_widget.dart';
import 'package:jfit/features/programs/presentation/widgets/programs_header.dart';

class ProgramsPage extends StatefulWidget {
  const ProgramsPage({super.key});

  @override
  State<ProgramsPage> createState() => _ProgramsPageState();
}

class _ProgramsPageState extends State<ProgramsPage> {
  // 더미 데이터 (실제 데이터 연동 전)
  final List<Map<String, dynamic>> popularPrograms = [
    {
      'image': 'https://i.imgur.com/1.jpg',
      'title': 'GM369',
      'coach': '정성용(유튜브 굿헬스TV)',
      'level': '중급',
      'weeks': '주 6일',
      'badge': '추천',
      'participants': 16066,
      'isPro': true,
    },
    {
      'image': 'https://i.imgur.com/2.jpg',
      'title': '헬스장 초보 탈출 10주',
      'coach': '정성용(유튜브 굿헬스TV)',
      'level': '초급',
      'weeks': '주 4일',
      'badge': '',
      'participants': 0,
      'isPro': false,
    },
    {
      'image': 'https://i.imgur.com/3.jpg',
      'title': '타이탄메소드 2.0',
      'coach': '이경선(유튜브 권혁TV)',
      'level': '중급',
      'weeks': '주 6일',
      'badge': '',
      'participants': 5088,
      'isPro': true,
    },
  ];

  final List<String> mainFilters = [
    '난이도', '무료', '운동 목적', '운동 빈도',
  ];
  final List<String> matchFilters = [
    '자세영상 포함', '파워리프팅', '근비대', '파워빌딩',
  ];
  final List<Map<String, dynamic>> matchPrograms = [
    {
      'image': 'https://i.imgur.com/3.jpg',
      'title': '타이탄메소드 2.0',
      'coach': '이경선(유튜브 권혁TV)',
      'level': '중급',
      'weeks': '주 6일',
      'badge': 'PRO',
      'participants': 5088,
    },
    {
      'image': 'https://i.imgur.com/1.jpg',
      'title': 'GM369',
      'coach': '정성용(유튜브 굿헬스TV)',
      'level': '중급',
      'weeks': '주 6일',
      'badge': '추천',
      'participants': 16066,
    },
    {
      'image': 'https://i.imgur.com/4.jpg',
      'title': 'TW 직장인 주2일 루틴',
      'coach': '운동동(유튜브 동운)',
      'level': '중급',
      'weeks': '주 2일',
      'badge': 'PRO',
      'participants': 136,
    },
  ];
  final List<String> partFilters = [
    '전체', '가슴', '등', '하체', '어깨', '팔',
  ];
  final List<Map<String, dynamic>> partPrograms = [
    {
      'image': 'https://i.imgur.com/5.jpg',
      'title': '원펀맨 운동법',
      'coach': '원펀맨(만화)',
      'level': '초급',
      'weeks': '',
      'badge': '',
      'participants': 582,
    },
    {
      'image': 'https://i.imgur.com/6.jpg',
      'title': '김리니 등',
      'coach': '김리니(김리팀)',
      'level': '초급',
      'weeks': '',
      'badge': '',
      'participants': 619,
    },
    {
      'image': 'https://i.imgur.com/7.jpg',
      'title': '킹유진 등',
      'coach': '이유진(King유진)',
      'level': '중급',
      'weeks': '',
      'badge': '',
      'participants': 2072,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          children: [
            const SizedBox(height: 16),
            // 상단 타이틀/검색
            ProgramsHeader(),
            const SizedBox(height: 16),
            SearchBarWidget(),
            const SizedBox(height: 16),
            // 카테고리/필터
            FilterChipsRow(filters: mainFilters),
            const SizedBox(height: 24),
            // 🔥 최근 인기 프로그램
            PopularProgramsSection(popularPrograms: popularPrograms),
            const SizedBox(height: 28),
            // 나에게 맞는 프로그램 찾기
            MatchingProgramsSection(
              matchFilters: matchFilters,
              matchPrograms: matchPrograms,
            ),
            const SizedBox(height: 28),
            // 부위별 데일리 루틴
            DailyRoutinesSection(
              partFilters: partFilters,
              partPrograms: partPrograms,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
