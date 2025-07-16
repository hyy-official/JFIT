import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:jfit/features/records/bloc/record_bloc.dart';
import 'package:jfit/features/records/bloc/record_event.dart';
import 'package:jfit/features/records/bloc/record_state.dart';
import '../widgets/exercise_day_selector.dart';
import '../widgets/exercise_today_list.dart';
import 'package:jfit/features/workout_session/presentation/pages/workout_session_page.dart';

class ExerciseRoutineDetailPage extends StatefulWidget {
  final String routineName;
  final String userProgramId;
  final int currentWeek;
  final int currentDay;
  final double progress;
  final bool isRestDay;

  const ExerciseRoutineDetailPage({
    super.key,
    required this.routineName,
    required this.userProgramId,
    required this.currentWeek,
    required this.currentDay,
    required this.progress,
    required this.isRestDay,
  });

  @override
  State<ExerciseRoutineDetailPage> createState() => _ExerciseRoutineDetailPageState();
}

class _ExerciseRoutineDetailPageState extends State<ExerciseRoutineDetailPage> {
  Map<String, dynamic>? programDetails;
  List<Map<String, dynamic>> programDays = [];
  List<Map<String, dynamic>> todayExercises = [];
  String partDesc = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgramDetails();
  }

  void _loadProgramDetails() {
    context.read<RecordBloc>().add(
      LoadUserProgramDetails(userProgramId: widget.userProgramId),
    );
    context.read<RecordBloc>().add(
      LoadUserProgramDays(userProgramId: widget.userProgramId),
    );
  }

  void _parseExerciseData(Map<String, dynamic> details) {
    // 먼저 user_programs의 exercises_json 확인
    final exercisesJson = details['exercises_json'] as Map<String, dynamic>?;
    
    if (exercisesJson != null && exercisesJson.containsKey('week_${widget.currentWeek}')) {
      final weekData = exercisesJson['week_${widget.currentWeek}'] as Map<String, dynamic>?;
      if (weekData != null && weekData.containsKey('day_${widget.currentDay}')) {
        final dayData = weekData['day_${widget.currentDay}'] as Map<String, dynamic>?;
        if (dayData != null) {
          final exercises = dayData['exercises'] as List<dynamic>?;
          if (exercises != null) {
            todayExercises = exercises.map((e) => Map<String, dynamic>.from(e)).toList();
          }
          
          // 운동 부위 정보 추출
          final targetMuscles = dayData['target_muscles'] as List<dynamic>?;
          if (targetMuscles != null && targetMuscles.isNotEmpty) {
            partDesc = targetMuscles.join(', ');
          } else {
            // 운동 이름에서 추론
            if (todayExercises.isNotEmpty) {
              partDesc = '오늘의 운동';
            }
          }
        }
      }
    } else {
      // exercises_json이 없거나 비어있으면 workout_programs의 weekly_schedule 확인
      final workoutPrograms = details['workout_programs'] as Map<String, dynamic>?;
      if (workoutPrograms != null) {
        final weeklySchedule = workoutPrograms['weekly_schedule'] as List<dynamic>?;
        if (weeklySchedule != null && weeklySchedule.isNotEmpty) {
          // weekly_schedule 구조: [{"week": 1, "days": [{"day": 1, "exercises": [...]}]}]
          Map<String, dynamic>? currentWeekData;
          
          // 현재 주차 데이터 찾기
          for (var weekItem in weeklySchedule) {
            final weekItemMap = weekItem as Map<String, dynamic>;
            final weekNum = weekItemMap['week'] as int?;
            if (weekNum == widget.currentWeek) {
              currentWeekData = weekItemMap;
              break;
            }
          }
          
          if (currentWeekData != null) {
            final days = currentWeekData['days'] as List<dynamic>?;
            if (days != null) {
              // 현재 일차 데이터 찾기
              Map<String, dynamic>? currentDayData;
              for (var dayItem in days) {
                final dayItemMap = dayItem as Map<String, dynamic>;
                final dayNum = dayItemMap['day'] as int?;
                if (dayNum == widget.currentDay) {
                  currentDayData = dayItemMap;
                  break;
                }
              }
              
              if (currentDayData != null) {
                final exercises = currentDayData['exercises'] as List<dynamic>?;
                if (exercises != null) {
                  todayExercises = exercises.map((e) => Map<String, dynamic>.from(e)).toList();
                }
                
                // 운동 부위 정보 추출
                final targetMuscles = currentDayData['target_muscles'] as List<dynamic>?;
                if (targetMuscles != null && targetMuscles.isNotEmpty) {
                  partDesc = targetMuscles.join(', ');
                } else {
                  partDesc = currentDayData['name'] as String? ?? 'Day ${widget.currentDay} 운동';
                }
              }
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: context.colors.textPrimary),
        title: Text(
          widget.routineName,
          style: TextStyle(color: context.colors.textPrimary),
        ),
      ),
      body: BlocConsumer<RecordBloc, RecordState>(
        listener: (context, state) {
          if (state is UserProgramDayCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            _loadProgramDetails(); // 완료 후 새로고침
          } else if (state is UserProgramProgressUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is WorkoutSessionCreated) {
            // 운동 세션 생성 후 운동 세션 페이지로 이동
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WorkoutSessionPage(
                  sessionId: state.sessionId,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is UserProgramDetailsLoaded) {
            programDetails = state.programDetails;
            _parseExerciseData(programDetails!);
            isLoading = false;
          } else if (state is UserProgramDaysLoaded) {
            programDays = state.programDays;
          } else if (state is RecordError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: context.colors.error, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    '프로그램 정보를 불러올 수 없습니다',
                    style: TextStyle(color: context.colors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(color: context.colors.textMuted, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProgramDetails,
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(
                          widget.routineName,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(widget.progress * 100).toStringAsFixed(0)}% 진행 중',
                          style: TextStyle(color: context.colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ExerciseDaySelector(
                    userProgramId: widget.userProgramId,
                    currentWeek: widget.currentWeek,
                    currentDay: widget.currentDay,
                    programDays: programDays,
                    totalWeeks: programDetails?['workout_programs']?['duration_weeks'] ?? 1,
                  ),
                  const SizedBox(height: 16),
                  if (partDesc.isNotEmpty)
                    Text(
                      partDesc,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: widget.isRestDay
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bedtime,
                                  color: context.colors.textMuted,
                                  size: 64,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '휴식일입니다',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: context.colors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '오늘은 몸을 쉬어주세요',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: context.colors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : todayExercises.isNotEmpty
                            ? ExerciseTodayList(exercises: todayExercises)
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.fitness_center,
                                      color: context.colors.textMuted,
                                      size: 64,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      '오늘의 운동 정보가 없습니다',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: context.colors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                  ),
                  const SizedBox(height: 16),
                  if (!widget.isRestDay && todayExercises.isNotEmpty)
                    ElevatedButton(
                      onPressed: () {
                        context.read<RecordBloc>().add(
                          CreateWorkoutSession(
                            userProgramId: widget.userProgramId,
                            exercisesJson: {
                              'week': widget.currentWeek,
                              'day': widget.currentDay,
                              'exercises': todayExercises,
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        foregroundColor: context.colors.onPrimary,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('운동 시작하기'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 