import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/theme/theme_system.dart';
import '../../domain/entities/workout_program.dart';
import '../bloc/programs_bloc.dart';
import '../bloc/programs_event.dart';
import '../bloc/programs_state.dart';
import 'dart:convert';

class ProgramDetailPage extends StatefulWidget {
  final WorkoutProgram program;
  const ProgramDetailPage({required this.program, super.key});

  @override
  State<ProgramDetailPage> createState() => _ProgramDetailPageState();
}

class _ProgramDetailPageState extends State<ProgramDetailPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _descKey = GlobalKey();
  final GlobalKey _routineKey = GlobalKey();
  int _selectedTab = 0;

  void _scrollToSection(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  void _showDuplicateDialog(BuildContext context, ProgramDuplicateFound state) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Text(
          '이미 추가된 프로그램입니다',
          style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '프로그램: ${state.programName}',
              style: TextStyle(color: context.colors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (state.isCompleted)
              Text(
                '✅ 이미 완료한 프로그램입니다',
                style: TextStyle(color: context.colors.success, fontSize: 14),
              )
            else ...[
              Text(
                '현재 진행 상황: ${state.currentWeek}주차 ${state.currentDay}일차',
                style: TextStyle(color: context.colors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                '진행률: ${state.progressPercent.toStringAsFixed(1)}%',
                style: TextStyle(color: context.colors.info, fontSize: 14),
              ),
            ],
            const SizedBox(height: 16),
            if (state.isCompleted)
              Text(
                '다시 도전하시겠습니까?',
                style: TextStyle(color: context.colors.textPrimary, fontSize: 14),
              )
            else
              Text(
                '어떻게 진행하시겠습니까?',
                style: TextStyle(color: context.colors.textPrimary, fontSize: 14),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('취소', style: TextStyle(color: context.colors.textMuted)),
          ),
          if (!state.isCompleted)
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<ProgramsBloc>().add(ContinueProgram(state.programId));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.success,
                foregroundColor: context.colors.onSuccess,
              ),
              child: const Text('이어서 하기'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<ProgramsBloc>().add(RestartProgram(state.programId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.onPrimary,
            ),
            child: Text(state.isCompleted ? '다시 도전하기' : '처음부터 하기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final program = widget.program;
    final isDesktop = MediaQuery.of(context).size.width > 600;
    return BlocListener<ProgramsBloc, ProgramsState>(
      listener: (context, state) {
        if (state is ProgramDuplicateFound) {
          _showDuplicateDialog(context, state);
        } else if (state is ProgramAddedToUser) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.colors.success,
            ),
          );
        } else if (state is ProgramRestarted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.colors.info,
            ),
          );
        } else if (state is ProgramContinued) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.colors.success,
            ),
          );
        } else if (state is RoutineSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.colors.success,
            ),
          );
        } else if (state is RoutineSaveError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.colors.error,
            ),
          );
        } else if (state is ProgramAddError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.colors.error,
            ),
          );
        }
      },
      child: Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: context.colors.background,
        elevation: 0,
          leading: BackButton(color: context.colors.onBackground),
          title: Text(program.name, style: TextStyle(color: context.colors.onBackground)),
              actions: [],
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단 이미지/동영상
                  if (program.imageUrl != null)
                        Container(
                      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                          decoration: BoxDecoration(
                        color: context.colors.surface,
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(0),
                        child: Image.network(
                          program.imageUrl!,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(program.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: context.colors.textPrimary)),
                        const SizedBox(height: 4),
                        Text(program.creator, style: TextStyle(color: context.colors.textMuted, fontSize: 15)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                            Icon(Icons.thumb_up, color: context.colors.success, size: 18),
                            const SizedBox(width: 4),
                            Text('100% 후기 2개', style: TextStyle(color: context.colors.success, fontSize: 13)),
                            const SizedBox(width: 16),
                            Icon(Icons.people, color: context.colors.textMuted, size: 18),
                      const SizedBox(width: 4),
                            Text('136명 도전', style: TextStyle(color: context.colors.textMuted, fontSize: 13)),
                    ],
                  ),
                        const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                              Icon(Icons.calendar_today, size: 18, color: context.colors.textMuted),
                        const SizedBox(width: 6),
                              Text('주 ${program.workoutsPerWeek ?? '-'}일 · 총 ${program.durationWeeks}주차', style: TextStyle(fontSize: 13, color: context.colors.textSecondary)),
                        const SizedBox(width: 16),
                              Icon(Icons.bar_chart, size: 18, color: context.colors.textMuted),
                        const SizedBox(width: 6),
                              Text(program.difficultyLevel, style: TextStyle(fontSize: 13, color: context.colors.textSecondary)),
                        const SizedBox(width: 16),
                              Icon(Icons.fitness_center, size: 18, color: context.colors.textMuted),
                        const SizedBox(width: 6),
                              Text(program.programType, style: TextStyle(fontSize: 13, color: context.colors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  // 탭바
                  Container(
                    color: context.colors.background,
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() => _selectedTab = 0);
                              _scrollToSection(_descKey);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: _selectedTab == 0 ? context.colors.primary : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text('소개', style: TextStyle(fontSize: 16, color: _selectedTab == 0 ? context.colors.textPrimary : context.colors.textMuted, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() => _selectedTab = 1);
                              _scrollToSection(_routineKey);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: _selectedTab == 1 ? context.colors.primary : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text('운동 상세', style: TextStyle(fontSize: 16, color: _selectedTab == 1 ? context.colors.textPrimary : context.colors.textMuted, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 소개 섹션
                  Container(
                    key: _descKey,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('소개', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.colors.textPrimary)),
                        const SizedBox(height: 8),
                        Text(program.description, style: TextStyle(fontSize: 15, color: context.colors.textSecondary)),
                ],
              ),
            ),
                  // 운동상세 섹션
                  Container(
                    key: _routineKey,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('운동 상세', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.colors.textPrimary)),
                        const SizedBox(height: 8),
                        Builder(
                          builder: (context) {
                            final schedule = program.weeklySchedule;
                            
                            if (schedule == null) {
                              return Text('운동 루틴 정보가 없습니다.', style: TextStyle(color: context.colors.textMuted));
                            }
                            
                            if (schedule is List) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final week in schedule)
                                    Builder(
                                      builder: (context) {
                                        final weekData = week as Map<String, dynamic>;
                                        final weekNum = weekData['week'] ?? 1;
                                        final days = weekData['days'] as List<dynamic>? ?? [];
                                        
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(bottom: 16, top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: context.colors.primary.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: context.colors.primary.withOpacity(0.3)),
                                              ),
                                              child: Text(
                                                'Week $weekNum',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: context.colors.primary,
                                                ),
                                              ),
                                            ),
                                            for (final day in days)
                                              Builder(
                                                builder: (context) {
                                                  final dayData = day as Map<String, dynamic>;
                                                  final dayNum = dayData['day'] ?? 1;
                                                  final exercisesRaw = dayData['exercises'];
                                                  final exercises = exercisesRaw is List<dynamic> 
                                                      ? exercisesRaw 
                                                      : exercisesRaw is String 
                                                          ? (json.decode(exercisesRaw) as List<dynamic>? ?? [])
                                                          : <dynamic>[];
                                                  
                                                  return Container(
                                                    margin: const EdgeInsets.only(bottom: 20),
                                                    padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(color: context.colors.border.withOpacity(0.3)),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                              decoration: BoxDecoration(
                                                                color: context.colors.secondary.withOpacity(0.2),
                                                                borderRadius: BorderRadius.circular(6),
                                                              ),
                                                              child: Text(
                                                                'Day $dayNum',
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 14,
                                                                  color: context.colors.secondary,
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(width: 8),
                                                            Text(
                                                              '${exercises.length}개 운동',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: context.colors.textMuted,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 12),
                                                        for (int i = 0; i < exercises.length; i++)
                                                          Builder(
                                                            builder: (context) {
                                                              final exercise = exercises[i] as Map<String, dynamic>;
                                                              final name = exercise['name'] ?? '운동';
                                                              final sets = exercise['sets'] ?? '-';
                                                              final reps = exercise['reps'] ?? '-';
                                                              
                                                              return Container(
                                                                margin: const EdgeInsets.only(bottom: 8),
                                                                padding: const EdgeInsets.all(12),
                                                                decoration: BoxDecoration(
                                                                  color: context.colors.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                                                                ),
                                                                child: Row(
                                                                  children: [
                                                                    Container(
                                                                      width: 24,
                                                                      height: 24,
                                                                      decoration: BoxDecoration(
                                                                        color: context.colors.secondary.withOpacity(0.2),
                                                                        borderRadius: BorderRadius.circular(4),
                                                                      ),
                                                                      child: Center(
                                                                        child: Text(
                                                                          '${i + 1}',
                                                                          style: TextStyle(
                                                                            fontSize: 12,
                                                                            fontWeight: FontWeight.bold,
                                                                            color: context.colors.secondary,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(width: 12),
                                                                    Expanded(
                                                                      child: Text(
                                                                        name,
                                                                        style: TextStyle(
                                                                          fontSize: 14,
                                                                          fontWeight: FontWeight.w500,
                                                                          color: context.colors.textPrimary,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(width: 12),
                                                                    Container(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                      decoration: BoxDecoration(
                                                                        color: context.colors.primary.withOpacity(0.2),
                                                                        borderRadius: BorderRadius.circular(4),
                                                                      ),
                                                                      child: Text(
                                                                        '$sets세트',
                                                                        style: TextStyle(
                                                                          fontSize: 12,
                                                                          color: context.colors.primary,
                                                                          fontWeight: FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(width: 8),
                                                                    Container(
                                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                      decoration: BoxDecoration(
                                                                        color: context.colors.secondary.withOpacity(0.2),
                                                                        borderRadius: BorderRadius.circular(4),
                                                                      ),
                                                                      child: Text(
                                                                        '$reps회',
                                                                        style: TextStyle(
                                                                          fontSize: 12,
                                                                          color: context.colors.secondary,
                                                                          fontWeight: FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                ],
                              );
                            } else {
                              return Text('운동 루틴 정보가 없습니다.', style: TextStyle(color: context.colors.textMuted));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: context.colors.background,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              // 새로운 "내 루틴으로 저장하기" 기능 호출
              context.read<ProgramsBloc>().add(SaveAsMyRoutine(program.id));
            },
          style: ElevatedButton.styleFrom(
                                  backgroundColor: context.colors.primary,
            foregroundColor: context.colors.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              elevation: 0,
          ),
                child: const Text('내 루틴으로 저장하기'),
          ),
        ),
      ),
    ),
    );
  }
}