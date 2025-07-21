import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_it/get_it.dart';

// BLoC imports
import 'package:jfit/features/programs/presentation/bloc/programs_bloc.dart';
import 'package:jfit/features/programs/presentation/bloc/programs_event.dart' as programs_events;
import 'package:jfit/features/programs/presentation/bloc/programs_state.dart';
import 'package:jfit/features/programs/domain/repositories/program_repository.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_bloc.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_event.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_state.dart';

// Model imports
import 'package:jfit/features/programs/data/models/user_program_day_model.dart';
import 'package:jfit/features/programs/data/models/workout_session_model.dart';

// Theme imports
import 'package:jfit/core/theme/theme_system.dart';

// Navigation imports
import 'package:go_router/go_router.dart';

// Component imports
import 'program_detail/components/program_header.dart';
import 'program_detail/components/week_navigation.dart';
import 'program_detail/components/day_cards.dart';
import 'program_detail/components/exercise_list.dart';
import 'program_detail/components/start_workout_button.dart';
import 'program_detail/program_detail_controller.dart';

class ProgramDetailSheet extends StatefulWidget {
  final String programName;
  final double progressPercent;
  final String userProgramId;

  const ProgramDetailSheet({
    super.key,
    required this.programName,
    required this.progressPercent,
    required this.userProgramId,
  });

  @override
  State<ProgramDetailSheet> createState() => _ProgramDetailSheetState();
}

class _ProgramDetailSheetState extends State<ProgramDetailSheet> {
  late ProgramDetailController _controller;
  late ProgramsBloc _programsBloc;

  @override
  void initState() {
    super.initState();
    _controller = ProgramDetailController();
    // 내부에서 ProgramsBloc 생성
    _programsBloc = ProgramsBloc(
      repository: GetIt.instance<ProgramRepository>(),
    );
    print('ProgramDetailSheet initState - userProgramId: ${widget.userProgramId}');
    _loadInitialData();
  }

  @override
  void dispose() {
    _controller.dispose();
    _programsBloc.close();
    super.dispose();
  }

  /// 초기 데이터 로드
  Future<void> _loadInitialData() async {
    final workoutProgramBloc = GetIt.instance<WorkoutProgramBloc>();
    
    // 사용자 프로그램 상세 정보 로드
    workoutProgramBloc.add(LoadProgramDetails(userProgramId: widget.userProgramId));
    
    // Day별 상태와 세션 정보 로드
    _programsBloc.add(programs_events.LoadUserProgramDays(widget.userProgramId));
    _programsBloc.add(programs_events.LoadWorkoutSessionsByUserProgram(widget.userProgramId));
  }

  /// 운동 세션 시작
  void _startWorkoutSession(UserProgramDayModel selectedDayObj, WorkoutSessionModel session) async {
    try {
      final supabaseClient = Supabase.instance.client;
      final userProgramResponse = await supabaseClient
          .from('user_programs')
          .select('''
            *,
            workout_programs(id, name, creator, description)
          ''')
          .eq('id', widget.userProgramId)
          .single();

      final workoutProgram = userProgramResponse['workout_programs'] as Map<String, dynamic>?;
      
      if (workoutProgram != null) {
        final programDay = 'Week ${_controller.selectedWeek} - Day ${selectedDayObj.day}';
        
        // 바텀시트를 닫고 WorkoutSessionPage로 이동
        Navigator.of(context).pop();
        
        // GoRouter를 사용하여 workout 페이지로 이동
        context.go('/workout?programId=${workoutProgram['id']}&programDay=${Uri.encodeComponent(programDay)}&targetWeek=${_controller.selectedWeek}&targetDay=${selectedDayObj.day}&showNavigation=false');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('프로그램 정보를 불러올 수 없습니다: $e'),
          backgroundColor: context.colors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProgramsBloc>.value(
      value: _programsBloc,
      child: ChangeNotifierProvider.value(
        value: _controller,
        child: Consumer<ProgramDetailController>(
          builder: (context, controller, child) {
            return _buildSheet(context, controller);
          },
        ),
      ),
    );
  }

  Widget _buildSheet(BuildContext context, ProgramDetailController controller) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDesktop = screenWidth > 768;
    final isTablet = screenWidth > 600 && screenWidth <= 768;
    
    final sheetWidth = isDesktop 
        ? 600.0 
        : isTablet 
            ? screenWidth * 0.9 
            : double.infinity;
    final sheetHeight = isDesktop 
        ? screenHeight * 0.8 
        : isTablet 
            ? screenHeight * 0.85 
            : null;
    final borderRadius = (isDesktop || isTablet)
        ? BorderRadius.circular(24)
        : const BorderRadius.vertical(top: Radius.circular(24));
    final horizontalPadding = isDesktop ? 24.0 : isTablet ? 20.0 : 16.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: SafeArea(
        child: Center(
          child: Container(
            width: sheetWidth,
            height: sheetHeight,
            margin: (isDesktop || isTablet) ? EdgeInsets.all(horizontalPadding) : null,
            decoration: BoxDecoration(
              color: context.colors.surfaceVariant.withOpacity(0.95),
              borderRadius: borderRadius,
              border: Border.all(
                color: context.colors.border.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.colors.primary.withOpacity(0.4),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
                BoxShadow(
                  color: context.colors.primary.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: MultiBlocProvider(
              providers: [
                BlocProvider.value(value: GetIt.instance<WorkoutProgramBloc>()),
              ],
              child: MultiBlocListener(
                listeners: [
                  BlocListener<WorkoutProgramBloc, WorkoutProgramState>(
                    listener: (context, state) {
                      if (state is ProgramDetailsLoaded) {
                        final programDetails = state.userProgram.toJson();
                        final programsState = context.read<ProgramsBloc>().state;
                        if (programsState is ProgramDetailData && programsState.days.isNotEmpty) {
                          controller.setNextWorkoutDay(programDetails, programsState.days);
                        }
                      }
                    },
                  ),
                ],
                child: BlocBuilder<ProgramsBloc, ProgramsState>(
                  builder: (context, state) {
                    if (state is! ProgramDetailData) {
                      return Center(
                        child: CircularProgressIndicator(color: context.colors.primary),
                      );
                    }

                    return _buildContent(context, state, controller, horizontalPadding);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProgramDetailData detailData, ProgramDetailController controller, double horizontalPadding) {
    if (detailData.error != null) {
      return _buildErrorState();
    }

    final days = detailData.days;
    final sessions = detailData.sessions;

    // 진행률 계산
    final totalDays = days.length;
    final completedDays = days.where((d) => d.completedAt != null).length;
    final progressPercent = totalDays > 0 ? (completedDays / totalDays * 100) : 0.0;

    // 선택된 주차의 일차들
    final weekDays = days.where((d) => d.week == controller.selectedWeek).toList()
      ..sort((a, b) => a.day.compareTo(b.day));
    
    final selectedDayObj = weekDays.isNotEmpty && controller.selectedDay < weekDays.length 
        ? weekDays[controller.selectedDay] 
        : null;

    // 해당 Day의 세션 찾기
    WorkoutSessionModel? session;
    if (selectedDayObj != null && sessions.isNotEmpty) {
      final sessionIndex = selectedDayObj.day - 1;
      if (sessionIndex >= 0 && sessionIndex < sessions.length) {
        session = sessions[sessionIndex];
      } else {
        session = sessions.first;
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 상단 드래그 바
        _buildDragHandle(),
        
        // 프로그램 헤더
        ProgramHeader(
          programName: widget.programName,
          progressPercent: progressPercent,
        ),
        
        // 주차 네비게이션
        WeekNavigation(
          days: days,
          selectedWeek: controller.selectedWeek,
          horizontalPadding: horizontalPadding,
          onWeekSelected: controller.selectWeek,
        ),
        
        const SizedBox(height: 12),
        
        // Day 카드들
        DayCards(
          weekDays: weekDays,
          selectedDay: controller.selectedDay,
          horizontalPadding: horizontalPadding,
          onDaySelected: (dayIndex, weekDays) {
            controller.selectDay(dayIndex, weekDays, widget.userProgramId, sessions);
            // 세션 로그 로드
            if (session != null) {
              context.read<ProgramsBloc>().add(
                programs_events.LoadWorkoutLogsBySession(session.id)
              );
            }
          },
        ),
        
        Divider(height: 24, thickness: 1, color: context.colors.border),
        
        // 운동 루틴 영역
        Expanded(
          child: _buildExerciseSection(context, controller, selectedDayObj, session, weekDays, horizontalPadding),
        ),
      ],
    );
  }

  Widget _buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Container(
        width: 48,
        height: 5,
        decoration: BoxDecoration(
          color: context.colors.textMuted,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: context.colors.error, size: 48),
          const SizedBox(height: 16),
          Text(
            '데이터를 불러오는 중 오류가 발생했습니다',
            style: TextStyle(color: context.colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseSection(BuildContext context, ProgramDetailController controller, UserProgramDayModel? selectedDayObj, WorkoutSessionModel? session, List<UserProgramDayModel> weekDays, double horizontalPadding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (session != null) ...[
            Row(
              children: [
                Icon(Icons.fitness_center, color: context.colors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  '운동 루틴 (Day ${selectedDayObj?.day ?? controller.selectedDay + 1})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ExerciseList(
                exercisesFuture: controller.getExercisesForDisplay(
                  widget.userProgramId,
                  controller.selectedWeek,
                  selectedDayObj?.day ?? controller.selectedDay + 1,
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: context.colors.textMuted),
                    const SizedBox(height: 16),
                    Text(
                      '운동 세션 정보 없음',
                      style: TextStyle(color: context.colors.textSecondary, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          // 시작 버튼
          const SizedBox(height: 12),
          StartWorkoutButton(
            weekDays: weekDays,
            selectedDay: controller.selectedDay,
            selectedDayObj: selectedDayObj,
            session: session,
            onPressed: selectedDayObj != null && session != null
                ? () => _startWorkoutSession(selectedDayObj, session)
                : null,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}