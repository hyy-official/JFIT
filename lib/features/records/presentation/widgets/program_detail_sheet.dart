import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/features/programs/presentation/bloc/programs_bloc.dart';
import 'package:jfit/features/programs/presentation/bloc/programs_event.dart';
import 'package:jfit/features/programs/presentation/bloc/programs_state.dart';
import 'package:jfit/features/programs/data/models/exercise_model.dart';
import 'package:jfit/features/programs/data/models/workout_session_model.dart';
import 'package:jfit/features/programs/data/models/user_program_day_model.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/core/theme/second_theme.dart';
import 'package:jfit/features/workout_session/presentation/pages/workout_session_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  int selectedWeek = 1;
  int selectedDay = 0; // 첫 번째 Day 선택 (0-based index)
  String? selectedSessionId;
  
  // 캐시 저장소
  Map<String, WorkoutSessionModel> _sessionCache = {};
  Map<String, List<dynamic>> _exerciseCache = {};
  List<UserProgramDayModel>? _cachedDays;
  List<WorkoutSessionModel>? _cachedSessions;
  int? _cachedWeek;

  @override
  void initState() {
    super.initState();
    print('ProgramDetailSheet initState - userProgramId: ${widget.userProgramId}');
    // 진입 시 Day별 상태/운동 루틴 fetch
    final bloc = BlocProvider.of<ProgramsBloc>(context, listen: false);
    bloc.add(LoadUserProgramDays(widget.userProgramId));
    bloc.add(LoadWorkoutSessionsByUserProgram(widget.userProgramId));
  }

  void _onDaySelected(int idx, List<UserProgramDayModel> weekDays) {
    setState(() {
      selectedDay = idx;
      final selectedDayObj = weekDays.isNotEmpty && idx < weekDays.length ? weekDays[idx] : null;
      if (selectedDayObj != null) {
        // 캐시된 세션 확인
        final sessionKey = '${widget.userProgramId}_day_${selectedDayObj.day}';
        if (_sessionCache.containsKey(sessionKey)) {
          selectedSessionId = _sessionCache[sessionKey]!.id;
          return; // 캐시된 데이터 사용, 추가 로딩 불필요
        }
        
        // 현재 BLoC 상태에서 sessions 가져오기
        final currentState = context.read<ProgramsBloc>().state;
        if (currentState is ProgramDetailData) {
          final sessions = currentState.sessions;
          WorkoutSessionModel? session;
          
          // sessionDate가 null인 경우 순서로 매칭
          if (sessions.isNotEmpty) {
            // day 번호에 맞는 세션 찾기 (1-based index를 0-based로 변환)
            final sessionIndex = selectedDayObj.day - 1;
            if (sessionIndex >= 0 && sessionIndex < sessions.length) {
              session = sessions[sessionIndex];
            } else {
              // 세션이 충분하지 않으면 첫 번째 세션 사용
              session = sessions.first;
            }
          }
          
          if (session != null) {
            selectedSessionId = session.id;
            // 세션을 캐시에 저장
            _sessionCache[sessionKey] = session;
            // 운동 루틴도 캐시에 저장
            if (session.exercisesJson != null) {
              _exerciseCache[sessionKey] = session.exercisesJson!;
            }
            // sessionId로 workout_logs fetch (필요한 경우에만)
            context.read<ProgramsBloc>().add(LoadWorkoutLogsBySession(session.id));
          } else {
            selectedSessionId = null;
          }
        }
      }
    });
  }


  @override
  Widget build(BuildContext context) {
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
              color: SecondTheme.bgTertiary.withOpacity(0.95),
              borderRadius: borderRadius,
              border: Border.all(
                color: SecondTheme.border.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
                BoxShadow(
                  color: AppTheme.accent1.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: BlocBuilder<ProgramsBloc, ProgramsState>(
              builder: (context, state) {
                
                // ProgramDetailData 상태가 아니면 로딩 표시
                if (state is! ProgramDetailData) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.accent1,
                    ),
                  );
                }
                
                final detailData = state as ProgramDetailData;
                
                // 에러가 있으면 에러 표시
                if (detailData.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red[400], size: 48),
                        const SizedBox(height: 16),
                        Text(
                          '데이터를 불러오는 중 오류가 발생했습니다',
                          style: TextStyle(color: SecondTheme.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          detailData.error!,
                          style: TextStyle(color: SecondTheme.textMuted, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                
                // 로딩 중이면 로딩 표시 (캐시된 데이터가 없는 경우에만)
                if (detailData.isLoading && _cachedDays == null && _cachedSessions == null) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.accent1,
                    ),
                  );
                }
                
                // 안전한 데이터 접근
                final days = <UserProgramDayModel>[];
                final sessions = <WorkoutSessionModel>[];
                
                if (detailData.days.isNotEmpty) {
                  days.addAll(detailData.days);
                  _cachedDays = detailData.days;
                } else if (_cachedDays != null && _cachedDays!.isNotEmpty) {
                  days.addAll(_cachedDays!.cast<UserProgramDayModel>());
                }
                
                if (detailData.sessions.isNotEmpty) {
                  sessions.addAll(detailData.sessions);
                  _cachedSessions = detailData.sessions;
                } else if (_cachedSessions != null && _cachedSessions!.isNotEmpty) {
                  sessions.addAll(_cachedSessions!.cast<WorkoutSessionModel>());
                }
                

                
                // 진행률 계산
                final totalDays = days.length;
                final completedDays = days.where((d) => d.completedAt != null).length;
                final progressPercent = totalDays > 0 ? (completedDays / totalDays * 100) : 0.0;

                // 선택된 Day 정보 (day 번호로 오름차순 정렬)
                final weekDays = days.where((d) => d.week == selectedWeek).toList()
                  ..sort((a, b) => a.day.compareTo(b.day));
                final selectedDayObj = weekDays.isNotEmpty && selectedDay < weekDays.length ? weekDays[selectedDay] : null;
                
                // 해당 Day의 세션 찾기
                WorkoutSessionModel? session;
                if (selectedDayObj != null && sessions.isNotEmpty) {
                  // sessionDate가 null인 경우 순서로 매칭
                  final sessionIndex = selectedDayObj.day - 1;
                  if (sessionIndex >= 0 && sessionIndex < sessions.length) {
                    session = sessions[sessionIndex];
                  } else {
                    // 세션이 충분하지 않으면 첫 번째 세션 사용
                    session = sessions.first;
                  }
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 상단 드래그 바
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: SecondTheme.textMuted,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    // 프로그램명 & 진행률
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            SecondTheme.bgTertiary.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            widget.programName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: SecondTheme.textPrimary,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.accent1.withOpacity(0.2),
                                  AppTheme.accent2.withOpacity(0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.accent1.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${progressPercent.toStringAsFixed(1)}% 진행 중',
                              style: TextStyle(
                                color: AppTheme.accent1,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 주차 네비게이션 (실제 데이터 기반)
                    _WeekNavigationRow(
                      days: days,
                      selectedWeek: selectedWeek,
                      horizontalPadding: horizontalPadding,
                      onWeekSelected: (week) => setState(() => selectedWeek = week),
                    ),
                    const SizedBox(height: 12),
                    // Day별 상태 시각화 (실제 데이터 기반)
                    _DayCardsRow(
                      weekDays: weekDays,
                      selectedDay: selectedDay,
                      horizontalPadding: horizontalPadding,
                      onDaySelected: _onDaySelected,
                      week: selectedWeek, // 캐시 키로 사용
                    ),
                    Divider(
                      height: 24, 
                      thickness: 1,
                      color: SecondTheme.border,
                    ),
                    // 운동 루틴/Day 상세 영역 (세션/운동 로그 기반)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (session != null) ...[
                              Row(
                                children: [
                                  Icon(
                                    Icons.fitness_center,
                                    color: AppTheme.accent1,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '운동 루틴 (Day ${selectedDayObj?.day ?? selectedDay + 1})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 16,
                                      color: SecondTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Builder(
                                  builder: (context) {
                                    // 캐시에서 운동 루틴 확인
                                    final sessionKey = selectedDayObj != null 
                                        ? '${widget.userProgramId}_day_${selectedDayObj.day}' 
                                        : null;
                                    List<dynamic>? exercises;
                                    
                                    if (sessionKey != null && _exerciseCache.containsKey(sessionKey)) {
                                      exercises = _exerciseCache[sessionKey];
                                    } else {
                                      exercises = session?.exercisesJson;
                                    }
                                    
                                    if (exercises == null || exercises.isEmpty) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.fitness_center_outlined,
                                              size: 48,
                                              color: SecondTheme.textMuted,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              '운동 루틴이 없습니다.',
                                              style: TextStyle(
                                                color: SecondTheme.textSecondary,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    
                                    // exercisesJson을 Map<String, dynamic> 리스트로 변환
                                    final exerciseList = exercises.cast<Map<String, dynamic>>();
                                    return ListView.separated(
                                      shrinkWrap: true,
                                      itemCount: exerciseList.length,
                                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                                      itemBuilder: (context, idx) {
                                        final exercise = exerciseList[idx];
                                        final exerciseName = exercise['exercise_name'] ?? exercise['custom_name'] ?? '운동 ${idx + 1}';
                                        final sets = exercise['sets'] ?? 1;
                                        final reps = exercise['reps'] ?? '-';
                                        final order = exercise['order'] ?? idx + 1;
                                        
                                        return Container(
                                          margin: const EdgeInsets.symmetric(vertical: 2),
                                          decoration: BoxDecoration(
                                            color: SecondTheme.bgSecondary.withOpacity(0.8),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: SecondTheme.border.withOpacity(0.6),
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.1),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            child: Row(
                                              children: [
                                                // Leading - Order number
                                                Container(
                                                  width: 36,
                                                  height: 36,
                                                  decoration: BoxDecoration(
                                                    gradient: AppTheme.accentGradient,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '$order',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                // Content
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        exerciseName,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          color: SecondTheme.textPrimary,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        '$sets세트 × $reps회',
                                                        style: TextStyle(
                                                          color: SecondTheme.textSecondary,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Trailing
                                                Icon(
                                                  Icons.fitness_center,
                                                  color: AppTheme.accent2,
                                                  size: 20,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ] else ...[
                              Expanded(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        size: 48,
                                        color: SecondTheme.textMuted,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        '운동 세션 정보 없음',
                                        style: TextStyle(
                                          color: SecondTheme.textSecondary,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            // Day 시작하기 버튼 (오늘 Day에만 활성)
                            const SizedBox(height: 12),
                            Builder(
                              builder: (context) {
                                final isToday = weekDays.isNotEmpty && selectedDay < weekDays.length && selectedDayObj != null && weekDays[selectedDay] == selectedDayObj;
                                final isEnabled = isToday && session != null;
                                return Container(
                                  width: double.infinity,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    gradient: isEnabled ? AppTheme.accentGradient : null,
                                    color: isEnabled ? null : SecondTheme.bgSecondary,
                                    borderRadius: BorderRadius.circular(16),
                                    border: isEnabled ? null : Border.all(
                                      color: SecondTheme.border,
                                      width: 1,
                                    ),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: isEnabled
                                        ? () {
                                            _startWorkoutSession(context, selectedDayObj!, session!);
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: isEnabled ? Colors.white : SecondTheme.textMuted,
                                      shadowColor: Colors.transparent,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.play_arrow,
                                          color: isEnabled ? Colors.white : SecondTheme.textMuted,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Day${selectedDayObj != null ? selectedDayObj.day : ''} 시작하기',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _startWorkoutSession(BuildContext context, UserProgramDayModel selectedDayObj, WorkoutSessionModel session) async {
    try {
      // userProgramId를 통해 프로그램 정보 조회
      final supabaseClient = Supabase.instance.client;
      final userProgramResponse = await supabaseClient
          .from('user_programs')
          .select('''
            *,
            workout_programs(
              id,
              name,
              creator,
              description
            )
          ''')
          .eq('id', widget.userProgramId)
          .single();
      
      final workoutProgram = userProgramResponse['workout_programs'] as Map<String, dynamic>?;
      
      if (workoutProgram != null) {
        final programDay = 'Week ${selectedWeek} - Day ${selectedDayObj.day}';
        
        // 바텀시트를 닫고 WorkoutSessionPage로 이동
        Navigator.of(context).pop(); // 바텀시트 닫기
        
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => WorkoutSessionPage(
              sessionId: null, // 새 세션 생성 (기존 템플릿 세션 사용하지 않음)
              programId: workoutProgram['id'] as String,
              programDay: programDay,
              targetWeek: selectedWeek, // 선택된 주차 전달
              targetDay: selectedDayObj.day, // 선택된 day 전달
              showNavigation: true, // 네비게이션 바 표시
            ),
          ),
        );
      }
    } catch (e) {
      // 오류 발생 시 스낵바 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('프로그램 정보를 불러올 수 없습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<ExerciseModel?> _fetchExerciseById(BuildContext context, String exerciseId) async {
    try {
      final supabaseClient = Supabase.instance.client;
      final response = await supabaseClient
          .from('exercises')
          .select()
          .eq('id', exerciseId)
          .single();
      return ExerciseModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }
}

/// 주차 네비게이션 최적화된 위젯
class _WeekNavigationRow extends StatelessWidget {
  final List<UserProgramDayModel> days;
  final int selectedWeek;
  final double horizontalPadding;
  final ValueChanged<int> onWeekSelected;

  const _WeekNavigationRow({
    required this.days,
    required this.selectedWeek,
    required this.horizontalPadding,
    required this.onWeekSelected,
  });

  @override
  Widget build(BuildContext context) {
    List<int> weeks;
    if (days.isNotEmpty) {
      weeks = days.map((d) => d.week).toSet().toList();
      weeks.sort();
    } else {
      weeks = <int>[];
    }
    
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: weeks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final week = weeks[idx];
          return _WeekTab(
            week: week,
            isSelected: week == selectedWeek,
            onTap: () => onWeekSelected(week),
          );
        },
      ),
    );
  }
}

/// 개별 주차 탭 위젯 (메모이제이션 적용)
class _WeekTab extends StatelessWidget {
  final int week;
  final bool isSelected;
  final VoidCallback onTap;

  const _WeekTab({
    required this.week,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.accentGradient : null,
          color: isSelected ? null : SecondTheme.bgSecondary,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? null : Border.all(
            color: SecondTheme.border,
            width: 1,
          ),
        ),
        child: Text(
          '${week}주차',
          style: TextStyle(
            color: isSelected ? Colors.white : SecondTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// Day 카드들을 담는 최적화된 위젯
class _DayCardsRow extends StatelessWidget {
  final List<UserProgramDayModel> weekDays;
  final int selectedDay;
  final double horizontalPadding;
  final Function(int, List<UserProgramDayModel>) onDaySelected;
  final int week;

  const _DayCardsRow({
    required this.weekDays,
    required this.selectedDay,
    required this.horizontalPadding,
    required this.onDaySelected,
    required this.week,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: weekDays.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          return _DayCard(
            day: weekDays[idx],
            isSelected: idx == selectedDay,
            onTap: () => onDaySelected(idx, weekDays),
          );
        },
      ),
    );
  }
}

/// 개별 Day 카드 위젯 (메모이제이션 적용)
class _DayCard extends StatelessWidget {
  final UserProgramDayModel day;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayCard({
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = day.completedAt != null;
    Widget icon;
    Color? bgColor;
    Gradient? gradient;
    Color textColor;
    FontWeight fontWeight = FontWeight.normal;
    Border? border;
    
    if (isDone) {
      icon = const Icon(Icons.check_circle, color: Colors.green, size: 20);
      bgColor = const Color(0xFF22C55E).withOpacity(0.2);
      textColor = const Color(0xFF22C55E);
      fontWeight = FontWeight.bold;
      border = Border.all(color: const Color(0xFF22C55E), width: 1);
    } else if (isSelected) {
      icon = const Icon(Icons.fitness_center, color: Colors.white, size: 20);
      gradient = AppTheme.accentGradient;
      textColor = Colors.white;
      fontWeight = FontWeight.bold;
    } else {
      icon = Icon(Icons.circle_outlined, color: SecondTheme.textMuted, size: 20);
      bgColor = SecondTheme.bgSecondary;
      textColor = SecondTheme.textSecondary;
      border = Border.all(color: SecondTheme.border, width: 1);
    }
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          border: border,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 4),
            Text(
              'Day ${day.day}',
              style: TextStyle(
                color: textColor,
                fontWeight: fontWeight,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 