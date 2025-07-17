import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_bloc.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_event.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_state.dart';
import 'package:jfit/features/workout_session/bloc/workout_session_bloc.dart';
import 'package:jfit/features/workout_session/bloc/workout_session_event.dart';
import 'package:jfit/features/workout_session/bloc/workout_session_state.dart';
import 'package:jfit/features/workout_program/utils/exercise_data_parser.dart';
import 'package:jfit/core/error/failures.dart';
import '../widgets/exercise_day_selector.dart';
import '../widgets/exercise_today_list.dart';
import 'package:jfit/features/workout_session/presentation/pages/workout_session_page.dart';
import 'package:get_it/get_it.dart';

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
  
  late WorkoutProgramBloc _workoutProgramBloc;
  late WorkoutSessionBloc _workoutSessionBloc;

  @override
  void initState() {
    super.initState();
    _workoutProgramBloc = GetIt.instance<WorkoutProgramBloc>();
    _workoutSessionBloc = GetIt.instance<WorkoutSessionBloc>();
    _loadProgramDetails();
  }

  @override
  void dispose() {
    _workoutProgramBloc.close();
    _workoutSessionBloc.close();
    super.dispose();
  }

  void _loadProgramDetails() {
    _workoutProgramBloc.add(
      LoadProgramDetails(userProgramId: widget.userProgramId),
    );
    _workoutProgramBloc.add(
      LoadProgramDays(userProgramId: widget.userProgramId),
    );
  }

  Map<String, dynamic> _convertUserProgramToMap(dynamic userProgram) {
    if (userProgram is Map<String, dynamic>) {
      return userProgram;
    }
    // If it's a UserProgramModel, convert to Map
    return userProgram.toJson();
  }

  void _parseExerciseData(Map<String, dynamic> details) {
    // ExerciseDataParser를 사용하여 안전하게 파싱
    final exercisesData = details['exercises_json'];
    
    if (exercisesData != null) {
      final parseResult = ExerciseDataParser.parseExercisesForWeekDay(
        exercisesData, 
        widget.currentWeek, 
        widget.currentDay
      );
      
      parseResult.fold(
        (failure) {
          print('운동 데이터 파싱 실패: ${failure.message}');
          if (failure is DataParsingFailure) {
            print('기술적 오류: ${failure.technicalMessage}');
          }
          
          // 파싱 실패 시 폴백: 기존 방식으로 시도
          _parseExerciseDataFallback(details);
        },
        (exercises) {
          print('파싱된 운동 수: ${exercises.length}');
          
          // Exercise 객체를 UI에서 사용할 수 있는 Map 형태로 변환
          todayExercises = exercises.map((exercise) => {
            'id': exercise.id,
            'exercise_name': exercise.titleKo,
            'name': exercise.titleKo,
            'sets': int.tryParse(exercise.recommendedSets ?? '3') ?? 3,
            'reps': exercise.recommendedReps ?? '10',
            'type': exercise.type,
            'equipment': exercise.equipment,
            'target_muscles': exercise.primaryMusclesKo,
            'notes': '',
          }).toList();
          
          // 운동 부위 정보 설정
          if (exercises.isNotEmpty && exercises.first.primaryMusclesKo.isNotEmpty) {
            partDesc = exercises.first.primaryMusclesKo.join(', ');
          } else if (todayExercises.isNotEmpty) {
            partDesc = '오늘의 운동';
          }
        },
      );
    } else {
      // exercises_json이 없으면 workout_programs의 weekly_schedule 확인
      _parseExerciseDataFallback(details);
    }
  }

  /// 파싱 실패 시 사용할 폴백 메서드 (기존 방식)
  void _parseExerciseDataFallback(Map<String, dynamic> details) {
    try {
      // 먼저 user_programs의 exercises_json 확인 (안전한 타입 체크 포함)
      final exercisesJson = details['exercises_json'];
      
      if (exercisesJson is Map<String, dynamic> && 
          exercisesJson.containsKey('week_${widget.currentWeek}')) {
        final weekData = exercisesJson['week_${widget.currentWeek}'];
        if (weekData is Map<String, dynamic> && 
            weekData.containsKey('day_${widget.currentDay}')) {
          final dayData = weekData['day_${widget.currentDay}'];
          if (dayData is Map<String, dynamic>) {
            final exercises = dayData['exercises'];
            if (exercises is List<dynamic>) {
              todayExercises = exercises
                  .where((e) => e is Map<String, dynamic>)
                  .map((e) => Map<String, dynamic>.from(e as Map<String, dynamic>))
                  .toList();
            }
            
            // 운동 부위 정보 추출
            final targetMuscles = dayData['target_muscles'];
            if (targetMuscles is List<dynamic> && targetMuscles.isNotEmpty) {
              partDesc = targetMuscles.map((e) => e.toString()).join(', ');
            } else if (todayExercises.isNotEmpty) {
              partDesc = '오늘의 운동';
            }
          }
        }
      } else {
        // exercises_json이 없거나 비어있으면 workout_programs의 weekly_schedule 확인
        final workoutPrograms = details['workout_programs'];
        if (workoutPrograms is Map<String, dynamic>) {
          final weeklySchedule = workoutPrograms['weekly_schedule'];
          if (weeklySchedule is List<dynamic> && weeklySchedule.isNotEmpty) {
            // weekly_schedule 구조: [{"week": 1, "days": [{"day": 1, "exercises": [...]}]}]
            Map<String, dynamic>? currentWeekData;
            
            // 현재 주차 데이터 찾기
            for (var weekItem in weeklySchedule) {
              if (weekItem is Map<String, dynamic>) {
                final weekNum = weekItem['week'];
                if (weekNum is int && weekNum == widget.currentWeek) {
                  currentWeekData = weekItem;
                  break;
                }
              }
            }
            
            if (currentWeekData != null) {
              final days = currentWeekData['days'];
              if (days is List<dynamic>) {
                // 현재 일차 데이터 찾기
                Map<String, dynamic>? currentDayData;
                for (var dayItem in days) {
                  if (dayItem is Map<String, dynamic>) {
                    final dayNum = dayItem['day'];
                    if (dayNum is int && dayNum == widget.currentDay) {
                      currentDayData = dayItem;
                      break;
                    }
                  }
                }
                
                if (currentDayData != null) {
                  final exercises = currentDayData['exercises'];
                  if (exercises is List<dynamic>) {
                    todayExercises = exercises
                        .where((e) => e is Map<String, dynamic>)
                        .map((e) => Map<String, dynamic>.from(e as Map<String, dynamic>))
                        .toList();
                  }
                  
                  // 운동 부위 정보 추출
                  final targetMuscles = currentDayData['target_muscles'];
                  if (targetMuscles is List<dynamic> && targetMuscles.isNotEmpty) {
                    partDesc = targetMuscles.map((e) => e.toString()).join(', ');
                  } else {
                    final name = currentDayData['name'];
                    partDesc = (name is String) ? name : 'Day ${widget.currentDay} 운동';
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      print('폴백 방식 파싱도 실패: $e');
      // 최종 폴백: 빈 상태로 설정
      todayExercises = [];
      partDesc = 'Day ${widget.currentDay} 운동';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _workoutProgramBloc),
        BlocProvider.value(value: _workoutSessionBloc),
      ],
      child: Scaffold(
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
        body: MultiBlocListener(
          listeners: [
            BlocListener<WorkoutProgramBloc, WorkoutProgramState>(
              listener: (context, state) {
                if (state is ProgramDayCompleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Day ${state.day} 완료되었습니다!')),
                  );
                  _loadProgramDetails(); // 완료 후 새로고침
                } else if (state is ProgramProgressUpdated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('프로그램 진행 상황이 업데이트되었습니다')),
                  );
                }
              },
            ),
            BlocListener<WorkoutSessionBloc, WorkoutSessionState>(
              listener: (context, state) {
                if (state is WorkoutSessionCreated) {
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
            ),
          ],
          child: BlocBuilder<WorkoutProgramBloc, WorkoutProgramState>(
            builder: (context, state) {
              if (state is ProgramDetailsLoaded) {
                // Convert UserProgramModel to Map for compatibility
                programDetails = _convertUserProgramToMap(state.userProgram);
                _parseExerciseData(programDetails!);
                isLoading = false;
              } else if (state is ProgramDaysLoaded) {
                programDays = state.programDays.map((day) => day.toJson()).toList();
              } else if (state is WorkoutProgramErrorState) {
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
                        state.userMessage,
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
                        _workoutSessionBloc.add(
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