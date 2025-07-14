import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/features/programs/presentation/bloc/programs_bloc.dart';
import 'package:jfit/features/programs/presentation/bloc/programs_event.dart';
import 'package:jfit/features/programs/presentation/bloc/programs_state.dart';
import 'package:jfit/features/programs/data/models/exercise_model.dart';
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
  int selectedDay = 3;
  int? selectedSessionId;

  @override
  void initState() {
    super.initState();
    // 진입 시 Day별 상태/운동 루틴 fetch
    final bloc = BlocProvider.of<ProgramsBloc>(context, listen: false);
    bloc.add(LoadUserProgramDays(widget.userProgramId));
    bloc.add(LoadWorkoutSessionsByUserProgram(widget.userProgramId));
  }

  void _onDaySelected(int idx, List weekDays, List sessions) {
    setState(() {
      selectedDay = idx;
      final selectedDayObj = weekDays.isNotEmpty && idx < weekDays.length ? weekDays[idx] : null;
      if (selectedDayObj != null) {
        final session = sessions.firstWhere(
          (s) => s.sessionDate.toString().substring(0, 10) == selectedDayObj.createdAt.toString().substring(0, 10),
          orElse: () => null,
        );
        if (session != null) {
          selectedSessionId = session.id;
          // sessionId로 workout_logs fetch
          context.read<ProgramsBloc>().add(LoadWorkoutLogsBySession(session.id));
        } else {
          selectedSessionId = null;
        }
      }
    });
  }

  // 임시 mock 데이터
  final int totalWeeks = 6;
  final Map<int, List<Map<String, dynamic>>> weekDays = {
    1: [
      {'type': 'done', 'label': 'Day 3'},
      {'type': 'rest', 'label': '휴식'},
      {'type': 'today', 'label': 'Day 5'},
      {'type': 'rest', 'label': '휴식'},
      {'type': 'rest', 'label': '휴식'},
    ],
    2: [
      {'type': 'rest', 'label': '휴식'},
      {'type': 'rest', 'label': '휴식'},
      {'type': 'rest', 'label': '휴식'},
      {'type': 'rest', 'label': '휴식'},
      {'type': 'rest', 'label': '휴식'},
    ],
    // ...
  };

  // Day별 운동 루틴 mock 데이터
  final Map<int, List<Map<String, dynamic>>> dayRoutines = {
    2: [
      {
        'category': '가슴, 등, 복근, 어깨, 팔, 하체',
        'exercises': [
          {
            'name': '스쿼트',
            'sets': 3,
            'reps': 10,
            'image': null,
            'isMax': false,
          },
          {
            'name': '스쿼트',
            'sets': 1,
            'reps': null,
            'image': null,
            'isMax': true,
          },
          {
            'name': '와이드 그립 벤치 프레스',
            'sets': 2,
            'reps': 10,
            'image': null,
            'isMax': false,
          },
          {
            'name': '와이드 그립 벤치 프레스',
            'sets': 1,
            'reps': null,
            'image': null,
            'isMax': true,
          },
        ],
      },
    ],
    // ...
  };

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final sheetWidth = isDesktop ? 600.0 : double.infinity;
    final sheetHeight = isDesktop ? 600.0 : null;
    final borderRadius = isDesktop
        ? BorderRadius.circular(32)
        : const BorderRadius.vertical(top: Radius.circular(32));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: SafeArea(
        child: Center(
          child: Container(
            width: sheetWidth,
            height: sheetHeight,
            margin: isDesktop ? const EdgeInsets.all(32) : null,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: borderRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: BlocBuilder<ProgramsBloc, ProgramsState>(
              builder: (context, state) {
                // Day/주차/운동 데이터 준비
                List days = [];
                List sessions = [];
                if (state is UserProgramDaysLoaded) {
                  days = state.days;
                }
                if (state is WorkoutSessionsLoaded) {
                  sessions = state.sessions;
                }
                // 진행률 계산
                final totalDays = days.length;
                final completedDays = days.where((d) => d.completedAt != null).length;
                final progressPercent = totalDays > 0 ? (completedDays / totalDays * 100) : 0.0;

                // 선택된 Day 정보
                final weekDays = days.where((d) => d.week == selectedWeek).toList();
                final selectedDayObj = weekDays.isNotEmpty && selectedDay < weekDays.length ? weekDays[selectedDay] : null;
                // 해당 Day의 세션 찾기
                final session = selectedDayObj != null
                    ? sessions.firstWhere(
                        (s) => s.sessionDate.toString().substring(0, 10) == selectedDayObj.createdAt.toString().substring(0, 10),
                        orElse: () => null)
                    : null;
                // TODO: sessionId로 workout_logs fetch 및 운동 리스트 표시

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
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    // 프로그램명 & 진행률
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Column(
                        children: [
                          Text(
                            widget.programName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${progressPercent.toStringAsFixed(1)}% 진행 중',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 주차 네비게이션 (실제 데이터 기반)
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: days.isNotEmpty ? days.map((d) => d.week).toSet().length : 0,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, idx) {
                          final week = days.isNotEmpty ? days.map((d) => d.week).toSet().toList()[idx] : idx + 1;
                          final isSelected = week == selectedWeek;
                          return GestureDetector(
                            onTap: () => setState(() => selectedWeek = week),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.black87 : Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '${week}주차',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black54,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Day별 상태 시각화 (실제 데이터 기반)
                    SizedBox(
                      height: 60,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: weekDays.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, idx) {
                          final day = weekDays[idx];
                          final isDone = day.completedAt != null;
                          final isToday = idx == selectedDay;
                          Widget icon;
                          Color bgColor;
                          Color textColor;
                          FontWeight fontWeight = FontWeight.normal;
                          if (isDone) {
                            icon = const Icon(Icons.check_circle, color: Colors.green, size: 20);
                            bgColor = Colors.green[50]!;
                            textColor = Colors.green[800]!;
                            fontWeight = FontWeight.bold;
                          } else if (isToday) {
                            icon = const Icon(Icons.fitness_center, color: Colors.white, size: 20);
                            bgColor = Colors.blue[800]!;
                            textColor = Colors.white;
                            fontWeight = FontWeight.bold;
                          } else {
                            icon = const Icon(Icons.circle_outlined, color: Colors.grey, size: 20);
                            bgColor = Colors.grey[100]!;
                            textColor = Colors.black54;
                          }
                          return GestureDetector(
                            onTap: () => _onDaySelected(idx, weekDays, sessions),
                            child: Container(
                              width: 70,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(16),
                                border: isToday ? Border.all(color: Colors.blue, width: 2) : null,
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
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 24, thickness: 1),
                    // 운동 루틴/Day 상세 영역 (세션/운동 로그 기반)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (session != null) ...[
                              Text(
                                '운동 루틴 (세션: ${session.sessionDate.toString().substring(0, 10)})',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              BlocBuilder<ProgramsBloc, ProgramsState>(
                                builder: (context, state) {
                                  if (state is WorkoutLogsLoading) {
                                    return const Center(child: CircularProgressIndicator());
                                  } else if (state is WorkoutLogsLoaded) {
                                    final logs = state.logs;
                                    if (logs.isEmpty) {
                                      return const Center(child: Text('운동 로그가 없습니다.'));
                                    }
                                    // 운동별로 그룹핑
                                    final exerciseGroups = <String, List<dynamic>>{};
                                    final exerciseIdMap = <String, String?>{};
                                    for (final log in logs) {
                                      final key = log.exerciseName ?? '운동';
                                      exerciseGroups.putIfAbsent(key, () => []).add(log);
                                      if (log.exerciseId != null) {
                                        exerciseIdMap[key] = log.exerciseId;
                                      }
                                    }
                                    return ListView.separated(
                                      shrinkWrap: true,
                                      itemCount: exerciseGroups.length,
                                      separatorBuilder: (_, __) => const Divider(),
                                      itemBuilder: (context, idx) {
                                        final exerciseName = exerciseGroups.keys.elementAt(idx);
                                        final sets = exerciseGroups[exerciseName]!;
                                        final exerciseId = exerciseIdMap[exerciseName];
                                        return FutureBuilder<ExerciseModel?>(
                                          future: exerciseId != null
                                              ? _fetchExerciseById(context, exerciseId)
                                              : Future.value(null),
                                          builder: (context, snapshot) {
                                            final exercise = snapshot.data;
                                            return ExpansionTile(
                                              leading: exercise?.imageUrl != null
                                                  ? ClipRRect(
                                                      borderRadius: BorderRadius.circular(8),
                                                      child: Image.network(
                                                        exercise!.imageUrl!,
                                                        width: 40,
                                                        height: 40,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (_, __, ___) => const Icon(Icons.fitness_center),
                                                      ),
                                                    )
                                                  : const Icon(Icons.fitness_center),
                                              title: Text(exercise?.titleKo ?? exerciseName),
                                              subtitle: Text('${sets.length}세트'),
                                              trailing: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text('완료: ${sets.where((s) => s.completed).length}/${sets.length}'),
                                                ],
                                              ),
                                              children: [
                                                ...sets.map((set) => ListTile(
                                                      dense: true,
                                                      leading: set.completed
                                                          ? const Icon(Icons.check_circle, color: Colors.green)
                                                          : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                                                      title: Text('세트 ${set.setNumber}'),
                                                      subtitle: Text('무게: ${set.weight ?? '-'}kg, 반복: ${set.reps ?? '-'}회'),
                                                      trailing: set.completed
                                                          ? Text('완료', style: TextStyle(color: Colors.green[700]))
                                                          : null,
                                                    )),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    );
                                  } else if (state is WorkoutLogsError) {
                                    return Center(child: Text('에러: ${state.message}'));
                                  }
                                  return const Center(child: Text('운동 로그를 불러오세요.'));
                                },
                              ),
                            ] else ...[
                              const Expanded(
                                child: Center(
                                  child: Text('운동 세션 정보 없음'),
                                ),
                              ),
                            ],
                            // Day 시작하기 버튼 (오늘 Day에만 활성)
                            const SizedBox(height: 12),
                            Builder(
                              builder: (context) {
                                final isToday = weekDays.isNotEmpty && selectedDay < weekDays.length && selectedDayObj != null && weekDays[selectedDay] == selectedDayObj;
                                return SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: isToday && session != null
                                        ? () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('운동 시작! (workout_session_page로 이동 예정)')),
                                            );
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isToday && session != null ? Colors.blue : Colors.grey[300],
                                      foregroundColor: isToday && session != null ? Colors.white : Colors.black38,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: Text('Day${selectedDayObj != null ? selectedDayObj.day : ''} 시작하기'),
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