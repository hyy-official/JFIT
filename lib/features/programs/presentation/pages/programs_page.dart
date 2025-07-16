import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:jfit/features/programs/presentation/widgets/popular_programs_section.dart';
import 'package:jfit/features/programs/presentation/widgets/matching_programs_section.dart';
import 'package:jfit/features/programs/presentation/widgets/daily_routines_section.dart';
import 'package:jfit/features/programs/presentation/widgets/filter_chips_row.dart';
import 'package:jfit/features/programs/presentation/widgets/search_bar_widget.dart';
import 'package:jfit/features/programs/presentation/widgets/programs_header.dart';
import '../bloc/programs_bloc.dart';
import '../bloc/programs_event.dart';
import '../bloc/programs_state.dart';

class ProgramsPage extends StatefulWidget {
  const ProgramsPage({super.key});

  @override
  State<ProgramsPage> createState() => _ProgramsPageState();
}

class _ProgramsPageState extends State<ProgramsPage> {
  final List<String> mainFilters = [
    '난이도', '무료', '운동 목적', '운동 빈도',
  ];
  final List<String> matchFilters = [
    '자세영상 포함', '파워리프팅', '근비대', '파워빌딩',
  ];
  final List<String> partFilters = [
    '전체', '가슴', '등', '하체', '어깨', '팔',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<ProgramsBloc>()
        ..add(LoadPopularPrograms())
        ..add(const LoadPrograms()),
      child: Scaffold(
              backgroundColor: context.colors.background,
      body: SafeArea(
          child: BlocConsumer<ProgramsBloc, ProgramsState>(
            listener: (context, state) {
              if (state is ProgramsError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              if (state is ProgramsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (state is ProgramsLoaded) {
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<ProgramsBloc>().add(RefreshPrograms());
                  },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          children: [
            const SizedBox(height: 16),
            // 상단 타이틀/검색
                      const ProgramsHeader(),
            const SizedBox(height: 16),
                      const SearchBarWidget(),
            const SizedBox(height: 16),
            // 카테고리/필터
            FilterChipsRow(filters: mainFilters),
            const SizedBox(height: 24),
            // 🔥 최근 인기 프로그램
                      PopularProgramsSection(popularPrograms: state.popularPrograms),
            const SizedBox(height: 28),
            // 나에게 맞는 프로그램 찾기
            MatchingProgramsSection(
              matchFilters: matchFilters,
                        matchPrograms: state.programs,
            ),
            const SizedBox(height: 28),
            // 부위별 데일리 루틴
            DailyRoutinesSection(
              partFilters: partFilters,
                        partPrograms: state.programs,
            ),
            const SizedBox(height: 32),
          ],
                  ),
                );
              }
              
              return Center(child: Text('프로그램을 불러오는 중...', style: TextStyle(color: context.colors.textPrimary)));
            },
          ),
        ),
      ),
    );
  }
}
