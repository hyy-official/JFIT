import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/features/workout_session/presentation/widgets/exercise_card.dart';
import 'package:jfit/features/workout_session/presentation/widgets/add_exercise_modal.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:jfit/core/navigation/main_navigation_page.dart';
import 'package:jfit/core/widgets/responsive_scaffold.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:jfit/core/constants/navigation_constants.dart';
import 'package:jfit/core/extensions/context_extensions.dart';
import 'package:jfit/features/workout_session/presentation/widgets/workout_summary.dart';
import 'package:jfit/core/utils/responsive_utils.dart';
import 'package:jfit/features/workout_session/bloc/workout_session_bloc.dart';
import 'package:jfit/features/workout_session/bloc/workout_session_event.dart';
import 'package:jfit/features/workout_session/bloc/workout_session_state.dart';
import 'package:jfit/features/auth/bloc/auth_bloc.dart';
import 'package:jfit/features/auth/bloc/auth_state.dart';
import 'package:jfit/features/workout_program/utils/exercise_data_parser.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/features/workout_session/data/repositories/workout_session_repository.dart';
import 'package:jfit/features/records/data/repositories/record_repository.dart';
import 'package:get_it/get_it.dart';
import 'dart:convert';

class WorkoutSessionPage extends StatefulWidget {
  final String? sessionId; // null이면 새 세션(프리스타일)
  final String? programId; // 워크아웃 프로그램 ID
  final String? programDay; // 프로그램의 특정 day (예: "Day 1: 전신 A")
  final int? targetWeek; // 특정 주차 선택 (null이면 current_week 사용)
  final int? targetDay; // 특정 day 선택 (null이면 current_day 사용)
  final bool showNavigation; // 네비게이션 바 표시 여부 (ProgramDetail → Start 시 true)

  const WorkoutSessionPage({
    super.key, 
    this.sessionId,
    this.programId,
    this.programDay,
    this.targetWeek,
    this.targetDay,
    this.showNavigation = false,
  });

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  late WorkoutSessionBloc _workoutSessionBloc;
  final _uuid = const Uuid();
  Map<String, dynamic>? session;
  Map<String, dynamic>? program; // 워크아웃 프로그램 정보
  List<Map<String, dynamic>> exercises = [];
  bool loading = true;
  int workoutTime = 0; // 초 단위
  
  // TODO: Remove this temporary field - this file needs proper refactoring to use WorkoutSessionBloc
  dynamic _recordRepository;
  Timer? _timer;
  Map<String, dynamic>? activeUserProgram;

  @override
  void initState() {
    super.initState();
    _workoutSessionBloc = GetIt.instance<WorkoutSessionBloc>();
    _initializeRepository();
    _loadSession();
  }

  /// 리포지토리 초기화 - 안전한 방식으로 의존성 주입
  void _initializeRepository() {
    try {
      // 타입을 명시해서 RecordRepository 가져오기
      _recordRepository = GetIt.instance.get<RecordRepository>();
      print('🔍 recordRepository 초기화 성공');
    } catch (e) {
      print('🔍 recordRepository 초기화 실패: $e');
      
      try {
        // 직접 생성해서 사용
        _recordRepository = RecordRepository();
        print('🔍 recordRepository 직접 생성 성공');
      } catch (e2) {
        print('🔍 recordRepository 직접 생성도 실패: $e2');
        
        // 최후의 수단: null로 설정하고 에러 상태로 처리
        _recordRepository = null;
        print('🔍 recordRepository를 null로 설정');
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _workoutSessionBloc.close();
    super.dispose();
  }

  String? get _currentUserId {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user.id;
    }
    return null;
  }

  String _getAppBarTitle() {
    if (widget.programDay != null) {
      return widget.programDay!;
    }
    if (session != null) {
      return session!['session_name'] ?? '워크아웃 세션';
    }
    return '워크아웃 세션';
  }



  Future<void> _loadSession() async {
    setState(() => loading = true);
    
    final userId = _currentUserId;
    if (userId == null) {
      print('🔍 사용자 ID가 null입니다');
      setState(() => loading = false);
      return;
    }
    
    // 리포지토리 null 체크
    if (_recordRepository == null) {
      print('🔍 recordRepository가 null입니다 - 재초기화 시도');
      _initializeRepository();
      
      if (_recordRepository == null) {
        print('🔍 recordRepository 재초기화 실패 - 빈 세션으로 진행');
        session = {
          'user_id': userId,
          'started_at': DateTime.now().toIso8601String(),
          'exercises_json': [],
          'is_completed': false,
        };
        exercises = [];
        setState(() => loading = false);
        _startTimer();
        return;
      }
    }
    
    try {
      if (widget.sessionId != null) {
        // 기존 세션 불러오기
        session = await _recordRepository.getWorkoutSession(widget.sessionId!);
        if (session != null) {
          exercises = List<Map<String, dynamic>>.from(session!['exercises_json'] ?? []);
        }
      } else {
        // 새 세션 생성
        String sessionName = '프리스타일 워크아웃';
        List<Map<String, dynamic>> programExercises = [];

        String? effectiveProgramId = widget.programId;

        // 1) 우선 위젯에서 프로그램 ID가 전달된 경우 사용
        if (effectiveProgramId != null) {
          // 특정 프로그램 ID에 해당하는 사용자 프로그램 조회
          final userPrograms = await _recordRepository.getUserPrograms(userId);
          for (final userProgram in userPrograms) {
            final workoutProgram = userProgram['workout_programs'];
            if (workoutProgram != null && workoutProgram['id'] == effectiveProgramId) {
              activeUserProgram = userProgram;
              break;
            }
          }
        }
        // 2) 없으면 사용자의 활성 프로그램을 조회하여 사용
        if (effectiveProgramId == null) {
          activeUserProgram = await _recordRepository.getLatestActiveUserProgram(userId);
          if (activeUserProgram != null) {
            effectiveProgramId = activeUserProgram!['program_id'] as String?;
          }
        }

        if (effectiveProgramId != null && activeUserProgram != null) {
          // 프로그램 정보와 사용자 프로그램 정보 조회
          final userProgramDetails = await _recordRepository.getUserProgramDetails(activeUserProgram!['id']);
          if (userProgramDetails != null) {
            program = userProgramDetails['workout_programs'];
            activeUserProgram = userProgramDetails;
            
            sessionName = program!['name'] ?? '프로그램 운동';
            if (widget.programDay != null) {
              sessionName += ' - ${widget.programDay}';
            }
            
            // 프로그램의 운동들을 로드
            // targetWeek/targetDay가 있으면 사용, 없으면 current 값 사용
            int w = widget.targetWeek ?? activeUserProgram!['current_week'];
            int d = widget.targetDay ?? activeUserProgram!['current_day'];
            print('🔍 프로그램 운동 로드 시작 - Week: $w, Day: $d');
            print('🔍 targetWeek: ${widget.targetWeek}, targetDay: ${widget.targetDay}');
            print('🔍 activeUserProgram current_week: ${activeUserProgram!['current_week']}, current_day: ${activeUserProgram!['current_day']}');
            programExercises = _loadProgramExercises(week: w, dayIndex: d-1);
            print('🔍 로드된 프로그램 운동 수: ${programExercises.length}');
            for (int i = 0; i < programExercises.length; i++) {
              print('🔍 운동 $i: ${programExercises[i]['exercise_name']}');
            }
          }
        }

        final newSession = {
          'user_id': userId,
          'started_at': DateTime.now().toIso8601String(),
          'exercises_json': programExercises,
          'is_completed': false,
          'user_program_id': activeUserProgram?['id'],
        };
        
        final sessionId = await _recordRepository.upsertWorkoutSession(newSession);
        
        // 생성된 세션 정보를 직접 사용 (ID 추가)
        session = Map<String, dynamic>.from(newSession);
        session!['id'] = sessionId;
        exercises = programExercises;
        print('🔍 최종 exercises 설정 완료 - 운동 수: ${exercises.length}');
        print('🔍 setState 호출 전 - loading: $loading');
        
        // 운동 데이터 검증
        _validateExerciseData();
        
        // 운동이 로드되지 않은 경우 추가 디버깅
        if (exercises.isEmpty) {
          print('🔍 ⚠️ 운동이 로드되지 않았습니다 - 추가 디버깅 시작');
          _debugExerciseLoadingFailure();
          
          // 빈 운동 목록에 대한 에러 상태 설정
          _handleEmptyExerciseList();
          
          // BLoC 간 데이터 동기화 시도
          await _synchronizeExerciseData();
        } else {
          // 운동 데이터 유효성 검증
          _validateExerciseIntegrity();
          
          // BLoC 간 데이터 흐름 검증
          _validateBlocDataFlow();
        }
      }

      // 이전 기록을 기반으로 타겟 정보 적용
      await _applyPreviousTargets();
    } catch (e) {
      print('🔍 세션 로드 중 오류: $e');
      // 세션 로드 중 오류 발생 시 기본 프리스타일 세션 생성
      final newSession = {
        'user_id': userId,
        'started_at': DateTime.now().toIso8601String(),
        'exercises_json': [],
        'is_completed': false,
      };
      try {
        final sessionId = await _recordRepository.upsertWorkoutSession(newSession);
        session = Map<String, dynamic>.from(newSession);
        session!['id'] = sessionId;
        exercises = [];
      } catch (e2) {
        // 기본 세션 생성도 실패한 경우
        session = newSession;
        exercises = [];
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
        print('🔍 setState 완료 - loading: $loading, exercises.length: ${exercises.length}');
      }
      _startTimer();
    }
  }

  List<Map<String, dynamic>> _loadProgramExercises({int? week, int? dayIndex}) {
    print('🔍 _loadProgramExercises 시작 - week: $week, dayIndex: $dayIndex');
    
    if (activeUserProgram == null) {
      print('🔍 activeUserProgram이 null입니다');
      return [];
    }

    try {
      final exercisesData = activeUserProgram!['exercises_json'];
      print('🔍 exercises_json 데이터 타입: ${exercisesData.runtimeType}');
      print('🔍 exercises_json 내용 (처음 200자): ${exercisesData.toString().length > 200 ? exercisesData.toString().substring(0, 200) + '...' : exercisesData.toString()}');
      
      // 데이터 형식 감지
      final dataFormat = ExerciseDataParser.detectDataFormat(exercisesData);
      print('🔍 감지된 데이터 형식: ${dataFormat.description}');
      
      // ExerciseDataParser를 사용하여 안전하게 파싱
      final parseResult = ExerciseDataParser.parseExercisesForWeekDay(
        exercisesData, 
        week ?? 1, 
        (dayIndex ?? 0) + 1
      );
      
      return parseResult.fold(
        (failure) {
          print('🔍 운동 데이터 파싱 실패: ${failure.message}');
          print('🔍 기술적 오류: ${failure is DataParsingFailure ? failure.technicalMessage : 'N/A'}');
          print('🔍 실패 타입: ${failure.runtimeType}');
          
          // 파싱 실패 시 폴백: 기존 방식으로 시도
          print('🔍 폴백 방식으로 전환');
          return _loadProgramExercisesFallback(week: week, dayIndex: dayIndex);
        },
        (exercises) {
          print('🔍 파싱된 운동 수: ${exercises.length}');
          
          if (exercises.isEmpty) {
            print('🔍 파싱된 운동이 없음 - 폴백 방식 시도');
            return _loadProgramExercisesFallback(week: week, dayIndex: dayIndex);
          }
          
          // Exercise 객체를 UI에서 사용할 수 있는 Map 형태로 변환
          final convertedExercises = exercises.map<Map<String, dynamic>>((exercise) {
            final exerciseName = exercise.titleKo;
            final sets = int.tryParse(exercise.recommendedSets ?? '3') ?? 3;
            final reps = exercise.recommendedReps ?? '10';
            
            print('🔍 운동 매핑: $exerciseName, sets: $sets, reps: $reps');
            
            // 각 운동에 대해 지정된 세트 수만큼 세트 생성
            final exerciseSets = List.generate(sets, (index) => {
              'weight': 0,
              'reps': 0,
              'completed': false,
              'target_reps': reps,
              'target_weight': 0,
            });

            return {
              'exercise_name': exerciseName,
              'sets': exerciseSets,
              'program_sets': sets,
              'program_reps': reps,
              'notes': '',
            };
          }).toList();
          
          print('🔍 변환된 운동 수: ${convertedExercises.length}');
          return convertedExercises;
        },
      );
    } catch (e, stackTrace) {
      print('🔍 프로그램 운동 로드 중 예상치 못한 오류: $e');
      print('🔍 스택 트레이스: $stackTrace');
      return _loadProgramExercisesFallback(week: week, dayIndex: dayIndex);
    }
  }

  /// 파싱 실패 시 사용할 폴백 메서드 (기존 방식)
  List<Map<String, dynamic>> _loadProgramExercisesFallback({int? week, int? dayIndex}) {
    print('🔍 폴백 방식으로 운동 데이터 로드 시도 - week: $week, dayIndex: $dayIndex');
    
    try {
      final exercisesJson = activeUserProgram!['exercises_json'];
      
      // 기본적인 null 체크
      if (exercisesJson == null) {
        print('🔍 [폴백] exercises_json이 null입니다');
        return [];
      }
      
      print('🔍 [폴백] exercises_json 타입: ${exercisesJson.runtimeType}');
      print('🔍 [폴백] exercises_json 내용 샘플: ${exercisesJson.toString().length > 300 ? exercisesJson.toString().substring(0, 300) + '...' : exercisesJson.toString()}');
      
      // 다양한 데이터 형식 처리
      List<dynamic> exercisesList = [];
      
      if (exercisesJson is String) {
        print('🔍 [폴백] JSON 문자열 파싱 시도');
        try {
          final decoded = jsonDecode(exercisesJson);
          if (decoded is List) {
            exercisesList = decoded;
          } else {
            print('🔍 [폴백] 디코딩된 JSON이 List가 아님: ${decoded.runtimeType}');
            return [];
          }
        } catch (e) {
          print('🔍 [폴백] JSON 파싱 실패: $e');
          return [];
        }
      } else if (exercisesJson is List) {
        exercisesList = exercisesJson;
      } else {
        print('🔍 [폴백] 지원하지 않는 데이터 타입: ${exercisesJson.runtimeType}');
        return [];
      }
      
      print('🔍 [폴백] exercises_json 길이: ${exercisesList.length}');
      
      if (exercisesList.isEmpty) {
        print('🔍 [폴백] exercises_json이 비어있습니다');
        return [];
      }

      // Determine week and day
      int weekIdx = (week != null) ? week - 1 : 0;
      if (weekIdx < 0 || weekIdx >= exercisesList.length) {
        print('🔍 [폴백] weekIdx 범위 초과, 0으로 설정: $weekIdx -> 0');
        weekIdx = 0;
      }
      print('🔍 [폴백] weekIdx: $weekIdx (week: $week)');
      
      final weekData = exercisesList[weekIdx];
      if (weekData is! Map<String, dynamic>) {
        print('🔍 [폴백] weekData가 Map 타입이 아닙니다: ${weekData.runtimeType}');
        print('🔍 [폴백] weekData 내용: $weekData');
        return [];
      }
      
      print('🔍 [폴백] weekData keys: ${weekData.keys.toList()}');
      final days = weekData['days'];
      if (days is! List<dynamic>) {
        print('🔍 [폴백] days가 List 타입이 아닙니다: ${days.runtimeType}');
        print('🔍 [폴백] days 내용: $days');
        return [];
      }
      
      print('🔍 [폴백] days 길이: ${days.length}');
      
      int dayIdx = dayIndex ?? 0;
      if (dayIdx < 0 || dayIdx >= days.length) {
        print('🔍 [폴백] dayIdx 범위 초과, 0으로 설정: $dayIdx -> 0');
        dayIdx = 0;
      }
      print('🔍 [폴백] dayIdx: $dayIdx (dayIndex: $dayIndex)');
      
      final day = days[dayIdx];
      if (day is! Map<String, dynamic>) {
        print('🔍 [폴백] day가 Map 타입이 아닙니다: ${day.runtimeType}');
        print('🔍 [폴백] day 내용: $day');
        return [];
      }
      
      print('🔍 [폴백] day keys: ${day.keys.toList()}');
      final dayExercises = day['exercises'];
      if (dayExercises is! List<dynamic>) {
        print('🔍 [폴백] dayExercises가 List 타입이 아닙니다: ${dayExercises.runtimeType}');
        print('🔍 [폴백] dayExercises 내용: $dayExercises');
        return [];
      }
      
      print('🔍 [폴백] dayExercises 길이: ${dayExercises.length}');
      
      final convertedExercises = dayExercises.map<Map<String, dynamic>>((exercise) {
        if (exercise is! Map<String, dynamic>) {
          print('🔍 [폴백] 개별 운동이 Map 타입이 아닙니다: ${exercise.runtimeType}');
          return {
            'exercise_name': '알 수 없는 운동',
            'sets': [],
            'program_sets': 3,
            'program_reps': '10',
            'notes': '',
          };
        }
        
        final exerciseName = exercise['name'] as String? ?? exercise['exercise_name'] as String? ?? '운동';
        final sets = exercise['sets'] as int? ?? 3;
        final reps = exercise['reps'];
        print('🔍 [폴백] 운동 매핑: $exerciseName, sets: $sets, reps: $reps');
              
        // 각 운동에 대해 지정된 세트 수만큼 세트 생성
        final exerciseSets = List.generate(sets, (index) => {
          'weight': 0,
          'reps': 0,
          'completed': false,
          'target_reps': reps.toString(),
          'target_weight': 0,
        });

        return {
          'exercise_name': exerciseName,
          'sets': exerciseSets,
          'program_sets': sets,
          'program_reps': reps.toString(),
          'notes': exercise['notes'] as String? ?? '',
        };
      }).toList();
      
      print('🔍 [폴백] 변환된 운동 수: ${convertedExercises.length}');
      return convertedExercises;
    } catch (e, stackTrace) {
      print('🔍 [폴백] 폴백 방식도 실패: $e');
      print('🔍 [폴백] 스택 트레이스: $stackTrace');
      return [];
    }
  }

  void _startTimer() {
    _timer?.cancel();
    final startTimeKey = session?['started_at'] ?? session?['start_time'];
    if (startTimeKey != null) {
      final start = DateTime.tryParse(startTimeKey);
      if (start != null) {
        workoutTime = DateTime.now().difference(start).inSeconds;
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          setState(() {
            workoutTime = DateTime.now().difference(start).inSeconds;
          });
        });
      }
    }
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _saveExercisesToSession() async {
    if (session == null) {
      return;
    }
    
    final updated = Map<String, dynamic>.from(session!);
    updated['exercises_json'] = exercises;
    
    try {
      await _recordRepository.upsertWorkoutSession(updated);
      
      // 세션 정보 업데이트
      setState(() {
        session = updated;
      });
    } catch (e) {
      // 저장 실패 처리 (선택적)
      print('Failed to save exercises to session: $e');
    }
  }

  void _addExercise(String exerciseName) async {
    final userId = _currentUserId;
    if (userId == null) return;
    
    // 이전 기록을 찾아 타겟 설정
    final exerciseId = await _recordRepository.getExerciseIdByName(exerciseName);
    Map<String, dynamic>? lastLog;
    if (exerciseId != null) {
      lastLog = await _recordRepository.getLastWorkoutLogByExercise(exerciseId, userId);
    }
    double? targetWeight;
    int? targetReps;
    if (lastLog != null) {
      targetWeight = (lastLog['weight'] is num) ? (lastLog['weight'] as num).toDouble() : null;
      targetReps = lastLog['reps'] is int ? lastLog['reps'] as int : null;
    }
    
    setState(() {
      exercises.add({
        'exercise_name': exerciseName,
        'sets': [
          {
            'weight': 0,
            'reps': 0,
            'completed': false,
            'target_weight': targetWeight ?? 0,
            'target_reps': targetReps?.toString() ?? '(기록 없음)',
          }
        ],
      });
    });
    
    _saveExercisesToSession();
  }

  void _removeExercise(int exerciseIndex) {
    setState(() {
      exercises.removeAt(exerciseIndex);
    });
    _saveExercisesToSession();
  }

  void _addSet(int exerciseIndex) {
    // Add set
    setState(() {
      final sets = List<Map<String, dynamic>>.from(exercises[exerciseIndex]['sets']);
      final last = sets.isNotEmpty ? sets.last : {'weight': 0, 'reps': 0, 'completed': false};
      sets.add({
        'weight': last['weight'] ?? 0,
        'reps': last['reps'] ?? 0,
        'completed': false,
        'target_reps': last['target_reps'] ?? '10',
        'target_weight': last['target_weight'] ?? 0,
      });
      exercises[exerciseIndex]['sets'] = sets;
    });
    _saveExercisesToSession();
  }

  void _removeSet(int exerciseIndex, int setIndex) {
    // Remove set
    setState(() {
      final sets = List<Map<String, dynamic>>.from(exercises[exerciseIndex]['sets']);
      if (setIndex >= 0 && setIndex < sets.length) {
        sets.removeAt(setIndex);
        exercises[exerciseIndex]['sets'] = sets;
      }
    });
    _saveExercisesToSession();
  }

  void _updateSet(int exerciseIndex, int setIndex, Map<String, dynamic> updates) {
    // Update set
    setState(() {
      final sets = List<Map<String, dynamic>>.from(exercises[exerciseIndex]['sets']);
      final prevCompleted = sets[setIndex]['completed'] == true;

      sets[setIndex] = {...sets[setIndex], ...updates};
      exercises[exerciseIndex]['sets'] = sets;

      final newCompleted = sets[setIndex]['completed'] == true;
      if (!prevCompleted && newCompleted) {
        final exerciseName = exercises[exerciseIndex]['exercise_name'] as String? ?? '';
        double weight = (sets[setIndex]['weight'] is num) ? (sets[setIndex]['weight'] as num).toDouble() : 0.0;
        int reps = sets[setIndex]['reps'] is int
            ? sets[setIndex]['reps'] as int
            : int.tryParse(sets[setIndex]['reps'].toString()) ?? 0;

        // 입력이 없다면 타겟 값을 사용
        if (weight == 0) {
          final tgtW = sets[setIndex]['target_weight'];
          if (tgtW is num) weight = tgtW.toDouble();
        }
        if (reps == 0) {
          final tgtR = sets[setIndex]['target_reps'];
          reps = int.tryParse(tgtR.toString()) ?? reps;
        }
        _logCompletedSet(exerciseName, setIndex, weight, reps);
      }
    });
    _saveExercisesToSession();
  }

  /// 해당 세트 완료 시 운동 로그 테이블에 기록한다.
  Future<void> _logCompletedSet(String exerciseName, int setIndex, double weight, int reps) async {
    try {
      String? exerciseId = await _recordRepository.getExerciseIdByName(exerciseName);
      if (exerciseId == null) {
        // 마스터 DB에 없으면 새로운 커스텀 운동으로 생성
        exerciseId = await _recordRepository.createCustomExercise(exerciseName);
      }

      await _recordRepository.insertWorkoutLog(
        exerciseId: exerciseId,
        sessionId: session?['id']?.toString() ?? '',
        sets: setIndex + 1,
        reps: reps,
        weight: weight,
      );
    } catch (e) {
      print('운동 로그 저장 실패: $e');
    }
  }

  void _finishWorkout() async {
    if (session != null) {
      final updated = Map<String, dynamic>.from(session!);
      updated['is_completed'] = true;
      updated['ended_at'] = DateTime.now().toIso8601String();
      // total_duration_minutes 컬럼이 존재하지 않으므로 제거
      // 운동 시간은 started_at과 ended_at의 차이로 계산 가능
      await _recordRepository.upsertWorkoutSession(updated);
    }

    bool programCompleted = false; // 추가: 프로그램 완료 여부

    // 사용자 프로그램 진행도 업데이트
    if (activeUserProgram != null) {
      int currentWeek = activeUserProgram!['current_week'];
      int currentDay = activeUserProgram!['current_day'];

      try {
        // 현재 day 완료 처리
        await _recordRepository.completeUserProgramDay(
          activeUserProgram!['id'],
          currentWeek,
          currentDay,
        );

      // 프로그램 스케줄 - 안전한 파싱 사용
      final exercisesData = activeUserProgram!['exercises_json'];
      int totalWeeks = 0;
      int totalDaysInWeek = 0;
      
      // 데이터 형식 감지 및 안전한 파싱
      final dataFormat = ExerciseDataParser.detectDataFormat(exercisesData);
      print('🔍 운동 데이터 형식: ${dataFormat.description}');
      
      try {
        if (exercisesData != null) {
          if (exercisesData is List) {
            final exercisesList = exercisesData as List<dynamic>;
            totalWeeks = exercisesList.length;
            
            // 현재 주차의 총 day 개수 계산
            if (exercisesList.isNotEmpty && currentWeek - 1 < exercisesList.length) {
              final weekData = exercisesList[currentWeek - 1];
              if (weekData is Map<String, dynamic> && weekData.containsKey('days')) {
                final days = weekData['days'];
                if (days is List<dynamic>) {
                  totalDaysInWeek = days.length;
                }
              }
            }
          } else if (exercisesData is Map<String, dynamic>) {
            // 맵 형식의 경우 주차 키 개수로 총 주차 계산
            final weekKeys = exercisesData.keys.where((key) => key.toString().startsWith('week_')).toList();
            totalWeeks = weekKeys.length;
            
            // 현재 주차의 총 day 개수 계산
            final currentWeekKey = 'week_$currentWeek';
            if (exercisesData.containsKey(currentWeekKey)) {
              final weekData = exercisesData[currentWeekKey];
              if (weekData is Map<String, dynamic>) {
                final dayKeys = weekData.keys.where((key) => key.toString().startsWith('day_')).toList();
                totalDaysInWeek = dayKeys.length;
              }
            }
          }
        }
        
        print('🔍 총 주차: $totalWeeks, 현재 주차 총 일수: $totalDaysInWeek');
      } catch (e) {
        print('🔍 프로그램 스케줄 파싱 중 오류: $e');
        // 파싱 실패 시 기본값 사용
        totalWeeks = 1;
        totalDaysInWeek = 1;
      }

      // 다음 day 계산
        int nextDay = currentDay + 1;
        int nextWeek = currentWeek;
        if (nextDay > totalDaysInWeek) {
          nextDay = 1;
          nextWeek += 1;
      }

      // 프로그램 완료 여부 판단
        if (nextWeek > totalWeeks) {
        programCompleted = true;
          // 프로그램 완료 시 비활성화
          await _recordRepository.deleteUserProgram(activeUserProgram!['id']);
        } else {
          // 진행도 업데이트
          await _recordRepository.updateUserProgramProgress(
            activeUserProgram!['id'],
            nextWeek,
            nextDay,
          );
        }
      } catch (e) {
        print('프로그램 진행도 업데이트 실패: $e');
      }
    }

    // 네비게이션 처리 (프로그램 완료 시 축하 다이얼로그 후 이동)
    void navigateHome() {
      final navigator = Navigator.of(context);
      if (navigator.canPop()) {
        navigator.pop();
      } else {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigationPage(initialIndex: 0)),
          (route) => false,
        );
      }
    }

    if (programCompleted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: context.colors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              '축하드립니다!',
              style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold),
            ),
            content: Text(
              '운동 루틴을 완료하셨습니다!',
              style: TextStyle(color: context.colors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                  navigateHome();
                },
                child: Text('확인', style: TextStyle(color: context.colors.primary)),
              ),
            ],
          );
        },
      );
    } else {
      navigateHome();
    }
  }

  int get _totalSets => exercises.fold(0, (sum, ex) => sum + (ex['sets'] as List).length);
  
  int get _completedSets => exercises.fold(0, (sum, ex) => 
    sum + (ex['sets'] as List).where((set) => set['completed'] == true).length);

  double get _progressPercentage => _totalSets > 0 ? (_completedSets / _totalSets) * 100 : 0;

  /// 운동 로딩 실패 시 추가 디버깅 정보 수집
  void _debugExerciseLoadingFailure() {
    print('🔍 === 운동 로딩 실패 디버깅 시작 ===');
    
    // 1. 기본 상태 확인
    print('🔍 widget.programId: ${widget.programId}');
    print('🔍 widget.targetWeek: ${widget.targetWeek}');
    print('🔍 widget.targetDay: ${widget.targetDay}');
    print('🔍 activeUserProgram null 여부: ${activeUserProgram == null}');
    
    if (activeUserProgram != null) {
      print('🔍 activeUserProgram 상세 정보:');
      print('🔍   - id: ${activeUserProgram!['id']}');
      print('🔍   - current_week: ${activeUserProgram!['current_week']}');
      print('🔍   - current_day: ${activeUserProgram!['current_day']}');
      print('🔍   - program_id: ${activeUserProgram!['program_id']}');
      
      final exercisesJson = activeUserProgram!['exercises_json'];
      if (exercisesJson != null) {
        print('🔍   - exercises_json 타입: ${exercisesJson.runtimeType}');
        
        // 데이터 구조 분석
        if (exercisesJson is List) {
          final list = exercisesJson as List<dynamic>;
          print('🔍   - exercises_json 리스트 길이: ${list.length}');
          
          for (int i = 0; i < list.length && i < 3; i++) {
            print('🔍   - 주차 $i 타입: ${list[i].runtimeType}');
            if (list[i] is Map<String, dynamic>) {
              final weekData = list[i] as Map<String, dynamic>;
              print('🔍   - 주차 $i 키들: ${weekData.keys.toList()}');
              
              if (weekData.containsKey('days')) {
                final days = weekData['days'];
                if (days is List) {
                  print('🔍   - 주차 $i 일수: ${days.length}');
                  
                  for (int j = 0; j < days.length && j < 2; j++) {
                    if (days[j] is Map<String, dynamic>) {
                      final dayData = days[j] as Map<String, dynamic>;
                      print('🔍   - 주차 $i 일차 $j 키들: ${dayData.keys.toList()}');
                      
                      if (dayData.containsKey('exercises')) {
                        final exercises = dayData['exercises'];
                        if (exercises is List) {
                          print('🔍   - 주차 $i 일차 $j 운동 수: ${exercises.length}');
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        } else if (exercisesJson is String) {
          print('🔍   - exercises_json 문자열 길이: ${exercisesJson.length}');
          print('🔍   - exercises_json 시작 부분: ${exercisesJson.length > 100 ? exercisesJson.substring(0, 100) + '...' : exercisesJson}');
        } else {
          print('🔍   - exercises_json 예상치 못한 타입: ${exercisesJson.runtimeType}');
        }
      } else {
        print('🔍   - exercises_json이 null입니다!');
      }
    }
    
    // 2. 파싱 재시도 테스트
    if (activeUserProgram != null) {
      final exercisesData = activeUserProgram!['exercises_json'];
      final targetWeek = widget.targetWeek ?? activeUserProgram!['current_week'];
      final targetDay = widget.targetDay ?? activeUserProgram!['current_day'];
      
      print('🔍 파싱 재시도 - Week: $targetWeek, Day: $targetDay');
      
      // 직접 파싱 시도
      final parseResult = ExerciseDataParser.parseExercisesForWeekDay(
        exercisesData, 
        targetWeek, 
        targetDay
      );
      
      parseResult.fold(
        (failure) {
          print('🔍 재시도 파싱 실패: ${failure.message}');
          if (failure is DataParsingFailure) {
            print('🔍 재시도 기술적 오류: ${failure.technicalMessage}');
            print('🔍 재시도 데이터 타입: ${failure.dataType}');
          }
        },
        (exercises) {
          print('🔍 재시도 파싱 성공: ${exercises.length}개 운동');
          for (int i = 0; i < exercises.length; i++) {
            print('🔍   - 재시도 운동 $i: ${exercises[i].titleKo}');
          }
        },
      );
    }
    
    print('🔍 === 운동 로딩 실패 디버깅 완료 ===');
  }

  /// 빈 운동 목록에 대한 에러 상태 처리
  void _handleEmptyExerciseList() {
    print('🔍 === 빈 운동 목록 에러 처리 시작 ===');
    
    // 사용자에게 표시할 에러 상태 설정
    // 이 경우 UI에서 적절한 메시지를 표시해야 함
    
    // 프로그램이 있지만 운동이 없는 경우와 프로그램 자체가 없는 경우를 구분
    if (activeUserProgram != null) {
      print('🔍 프로그램은 존재하지만 운동 데이터가 없습니다');
      // 이 경우 데이터 파싱 문제일 가능성이 높음
    } else {
      print('🔍 활성 프로그램이 없습니다');
      // 이 경우 프리스타일 운동으로 진행
    }
    
    print('🔍 === 빈 운동 목록 에러 처리 완료 ===');
  }

  /// 운동 데이터 무결성 검증
  void _validateExerciseIntegrity() {
    print('🔍 === 운동 데이터 무결성 검증 시작 ===');
    
    int validExercises = 0;
    int invalidExercises = 0;
    
    for (int i = 0; i < exercises.length; i++) {
      final exercise = exercises[i];
      bool isValid = true;
      
      // 필수 필드 검증
      if (exercise['exercise_name'] == null || exercise['exercise_name'].toString().trim().isEmpty) {
        print('🔍 ⚠️ 운동 $i: 이름이 없습니다');
        isValid = false;
      }
      
      final sets = exercise['sets'];
      if (sets == null || sets is! List || sets.isEmpty) {
        print('🔍 ⚠️ 운동 $i: 세트 정보가 없습니다');
        isValid = false;
      } else {
        // 세트 데이터 검증
        for (int j = 0; j < sets.length; j++) {
          final set = sets[j];
          if (set is! Map<String, dynamic>) {
            print('🔍 ⚠️ 운동 $i 세트 $j: 잘못된 세트 데이터 형식');
            isValid = false;
            break;
          }
          
          // 필수 세트 필드 검증
          if (!set.containsKey('weight') || !set.containsKey('reps') || !set.containsKey('completed')) {
            print('🔍 ⚠️ 운동 $i 세트 $j: 필수 필드 누락');
            isValid = false;
            break;
          }
        }
      }
      
      if (isValid) {
        validExercises++;
      } else {
        invalidExercises++;
      }
    }
    
    print('🔍 검증 결과: 유효한 운동 $validExercises개, 무효한 운동 $invalidExercises개');
    
    if (invalidExercises > 0) {
      print('🔍 ⚠️ 일부 운동 데이터에 문제가 있습니다');
      // 필요시 무효한 운동 제거 또는 수정 로직 추가
      _fixInvalidExercises();
    }
    
    print('🔍 === 운동 데이터 무결성 검증 완료 ===');
  }

  /// 무효한 운동 데이터 수정
  void _fixInvalidExercises() {
    print('🔍 === 무효한 운동 데이터 수정 시작 ===');
    
    final List<Map<String, dynamic>> fixedExercises = [];
    
    for (int i = 0; i < exercises.length; i++) {
      final exercise = Map<String, dynamic>.from(exercises[i]);
      
      // 운동 이름 수정
      if (exercise['exercise_name'] == null || exercise['exercise_name'].toString().trim().isEmpty) {
        exercise['exercise_name'] = '운동 ${i + 1}';
        print('🔍 운동 $i: 이름을 "${exercise['exercise_name']}"로 수정');
      }
      
      // 세트 데이터 수정
      final sets = exercise['sets'];
      if (sets == null || sets is! List || sets.isEmpty) {
        exercise['sets'] = [
          {
            'weight': 0,
            'reps': 0,
            'completed': false,
            'target_reps': '10',
            'target_weight': 0,
          }
        ];
        print('🔍 운동 $i: 기본 세트 데이터 생성');
      } else {
        // 기존 세트 데이터 검증 및 수정
        final List<Map<String, dynamic>> fixedSets = [];
        for (int j = 0; j < sets.length; j++) {
          final set = sets[j];
          if (set is Map<String, dynamic>) {
            final fixedSet = Map<String, dynamic>.from(set);
            
            // 필수 필드 보장
            fixedSet['weight'] ??= 0;
            fixedSet['reps'] ??= 0;
            fixedSet['completed'] ??= false;
            fixedSet['target_reps'] ??= '10';
            fixedSet['target_weight'] ??= 0;
            
            fixedSets.add(fixedSet);
          }
        }
        exercise['sets'] = fixedSets;
      }
      
      // 기타 필수 필드 보장
      exercise['program_sets'] ??= exercise['sets'].length;
      exercise['program_reps'] ??= '10';
      exercise['notes'] ??= '';
      
      fixedExercises.add(exercise);
    }
    
    // 수정된 운동 데이터로 교체
    setState(() {
      exercises = fixedExercises;
    });
    
    print('🔍 === 무효한 운동 데이터 수정 완료 ===');
  }

  /// 운동 데이터 검증 및 디버깅 정보 출력
  void _validateExerciseData() {
    print('🔍 === 운동 데이터 검증 시작 ===');
    print('🔍 exercises 리스트 길이: ${exercises.length}');
    
    if (exercises.isEmpty) {
      print('🔍 ⚠️ 운동 리스트가 비어있습니다!');
      print('🔍 activeUserProgram: ${activeUserProgram != null ? 'exists' : 'null'}');
      if (activeUserProgram != null) {
        print('🔍 activeUserProgram keys: ${activeUserProgram!.keys.toList()}');
        final exercisesJson = activeUserProgram!['exercises_json'];
        print('🔍 exercises_json 존재: ${exercisesJson != null}');
        if (exercisesJson != null) {
          print('🔍 exercises_json 타입: ${exercisesJson.runtimeType}');
          print('🔍 exercises_json 길이/크기: ${exercisesJson is List ? exercisesJson.length : exercisesJson.toString().length}');
        }
      }
      return;
    }
    
    for (int i = 0; i < exercises.length; i++) {
      final exercise = exercises[i];
      final exerciseName = exercise['exercise_name'] ?? 'Unknown';
      final sets = exercise['sets'] as List? ?? [];
      
      print('🔍 운동 $i: $exerciseName');
      print('🔍   - 세트 수: ${sets.length}');
      print('🔍   - 프로그램 세트: ${exercise['program_sets']}');
      print('🔍   - 프로그램 반복: ${exercise['program_reps']}');
      
      if (sets.isEmpty) {
        print('🔍   ⚠️ 세트가 없습니다!');
      }
    }
    
    print('🔍 === 운동 데이터 검증 완료 ===');
  }

  /// BLoC 간 데이터 흐름 검증
  void _validateBlocDataFlow() {
    print('🔍 === BLoC 간 데이터 흐름 검증 시작 ===');
    
    // 1. WorkoutSessionBloc 상태 확인
    final sessionBlocState = _workoutSessionBloc.state;
    print('🔍 WorkoutSessionBloc 현재 상태: ${sessionBlocState.runtimeType}');
    
    // 2. 운동 데이터가 BLoC를 통해 전달되었는지 확인
    if (sessionBlocState is WorkoutSessionLoaded) {
      print('🔍 BLoC를 통해 세션이 로드됨');
      final sessionModel = sessionBlocState.session;
      print('🔍 BLoC 세션 ID: ${sessionModel.id}');
      print('🔍 BLoC 세션 완료 여부: ${sessionModel.isCompleted}');
    } else if (sessionBlocState is WorkoutSessionErrorState) {
      print('🔍 ⚠️ BLoC에서 에러 상태: ${sessionBlocState.error.message}');
    } else {
      print('🔍 BLoC 상태가 예상과 다름: ${sessionBlocState.runtimeType}');
    }
    
    // 3. 운동 데이터 일관성 검증
    if (session != null && exercises.isNotEmpty) {
      final sessionExercises = session!['exercises_json'] as List?;
      if (sessionExercises != null) {
        print('🔍 세션 내 운동 수: ${sessionExercises.length}');
        print('🔍 UI 운동 수: ${exercises.length}');
        
        if (sessionExercises.length != exercises.length) {
          print('🔍 ⚠️ 세션과 UI 운동 수가 다릅니다!');
        }
      }
    }
    
    print('🔍 === BLoC 간 데이터 흐름 검증 완료 ===');
  }

  /// 운동 데이터 동기화 - BLoC와 UI 상태 일치 보장
  Future<void> _synchronizeExerciseData() async {
    print('🔍 === 운동 데이터 동기화 시작 ===');
    
    if (session == null || session!['id'] == null) {
      print('🔍 세션 정보가 없어 동기화 불가');
      return;
    }
    
    try {
      // BLoC를 통해 최신 세션 데이터 로드
      _workoutSessionBloc.add(LoadWorkoutSession(session!['id']));
      
      // BLoC 상태 변화 대기 (간단한 구현)
      await Future.delayed(const Duration(milliseconds: 500));
      
      final currentState = _workoutSessionBloc.state;
      if (currentState is WorkoutSessionLoaded) {
        final sessionModel = currentState.session;
        
        // 세션 데이터와 UI 데이터 동기화
        if (sessionModel.exercisesJson != null) {
          print('🔍 BLoC에서 운동 데이터 동기화');
          
          // 안전한 파싱으로 운동 데이터 추출
          final parseResult = ExerciseDataParser.parseExercises(sessionModel.exercisesJson);
          
          parseResult.fold(
            (failure) {
              print('🔍 BLoC 데이터 파싱 실패: ${failure.message}');
            },
            (parsedExercises) {
              if (parsedExercises.isNotEmpty && exercises.isEmpty) {
                print('🔍 BLoC에서 운동 데이터 복원: ${parsedExercises.length}개');
                
                // UI 형식으로 변환
                final uiExercises = parsedExercises.map<Map<String, dynamic>>((exercise) {
                  final sets = int.tryParse(exercise.recommendedSets ?? '3') ?? 3;
                  final exerciseSets = List.generate(sets, (index) => {
                    'weight': 0,
                    'reps': 0,
                    'completed': false,
                    'target_reps': exercise.recommendedReps ?? '10',
                    'target_weight': 0,
                  });

                  return {
                    'exercise_name': exercise.titleKo,
                    'sets': exerciseSets,
                    'program_sets': sets,
                    'program_reps': exercise.recommendedReps ?? '10',
                    'notes': '',
                  };
                }).toList();
                
                setState(() {
                  exercises = uiExercises;
                });
                
                print('🔍 UI 운동 데이터 복원 완료');
              }
            },
          );
        }
      }
    } catch (e) {
      print('🔍 운동 데이터 동기화 중 오류: $e');
    }
    
    print('🔍 === 운동 데이터 동기화 완료 ===');
  }

  /// 각 운동에 대해 이전 기록을 찾아 세트마다 타겟 정보를 설정한다.
  Future<void> _applyPreviousTargets() async {
    final userId = _currentUserId;
    if (userId == null) return;

    for (final exercise in exercises) {
      final name = exercise['exercise_name'] as String? ?? '';
      if (name.isEmpty) continue;

      final exerciseId = await _recordRepository.getExerciseIdByName(name);
      Map<String, dynamic>? lastLog;
      if (exerciseId != null) {
        lastLog = await _recordRepository.getLastWorkoutLogByExercise(exerciseId, userId);
      }
      double? targetWeight;
      int? targetReps;

      if (lastLog != null) {
        targetWeight = (lastLog['weight'] is num) ? (lastLog['weight'] as num).toDouble() : null;
        targetReps = lastLog['reps'] is int ? lastLog['reps'] as int : null;
      }

      final sets = List<Map<String, dynamic>>.from(exercise['sets']);
      for (var set in sets) {
        set['target_weight'] = targetWeight ?? 0;
        set['target_reps'] = targetReps?.toString() ?? '(기록 없음)';
      }
      exercise['sets'] = sets;
    }
  }

  @override
  Widget build(BuildContext context) {
    
    
    if (loading) {
      print('🔍 로딩 스피너 표시 중');
    
      return Scaffold(
        backgroundColor: context.colors.background,
        body: Center(
          child: CircularProgressIndicator(color: context.colors.primary),
        ),
      );
    }

    
    Widget content = Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              // 모바일 상단 헤더 (타이머)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 1024;
                  
                  if (!isDesktop) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: context.colors.background.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.colors.surfaceVariant),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 왼쪽: 루틴 정보 + 타이머
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 루틴 이름 / 세션 이름
                                Text(
                                  _getMobileHeaderTitle(),
                                  style: TextStyle(
                                    color: context.colors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                // 주차·일차 정보 + 타이머
                          Row(
                            children: [
                                    if (_getMobileSubtitle().isNotEmpty) ...[
                                      Text(
                                        _getMobileSubtitle(),
                                        style: TextStyle(
                                          color: context.colors.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              const SizedBox(width: 8),
                                      Text('•', style: TextStyle(color: context.colors.textMuted, fontSize: 12)),
                                      const SizedBox(width: 8),
                                    ],
                                    Icon(Icons.play_arrow, color: context.colors.textPrimary, size: 14),
                                    const SizedBox(width: 4),
                              Text(
                                _formatTime(workoutTime),
                                style: TextStyle(
                                  color: context.colors.textPrimary,
                                        fontSize: 14,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                              ],
                            ),
                          ),
                          // 오른쪽: 완료 버튼
                          ElevatedButton(
                            onPressed: _finishWorkout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colors.primary,
                              foregroundColor: context.colors.textPrimary,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('완료'),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // 메인 콘텐츠
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    
                    if (constraints.maxWidth >= 1024) {
                      // 데스크톱 레이아웃: 헤더 카드 + 사이드바를 한 컬럼으로 묶기
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 메인 콘텐츠 (2/3)
                          Expanded(
                            flex: 2,
                            child: _buildMainContent(),
                          ),
                          const SizedBox(width: 32),
                          // 우측 컬럼 (헤더 + 사이드바)
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildWorkoutHeader(),
                                const SizedBox(height: 24),
                                Expanded(child: _buildSidebar()),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      // 모바일 레이아웃
                      return _buildMainContent();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // FloatingActionButton (모바일에서만 표시)
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 1024) return const SizedBox.shrink();
          
          return FloatingActionButton(
            onPressed: () async {
              final result = await showDialog(
                context: context,
                barrierColor: context.colors.scrim,
                builder: (context) {
                  return AddExerciseModal(
                    onAdd: (exerciseName) {
                      _addExercise(exerciseName);
                      Navigator.of(context).pop();
                    },
                    onCancel: () {
                      Navigator.of(context).pop();
                    },
                  );
                },
              );
            },
            backgroundColor: context.colors.primary,
            child: Icon(Icons.add, color: context.colors.textPrimary),
          );
        },
      ),
    );

    return content;
  }

  Widget _buildMainContent() {
    final isDesktop = context.isDesktop;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 모바일에서는 헤더 카드를 숨깁니다 (루틴 정보는 상단 바에 표시)
          
          // 운동 카드들
          ...exercises.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: ExerciseCard(
                exercise: entry.value,
                exerciseIndex: entry.key,
                onAddSet: () => _addSet(entry.key),
                onRemove: () => _removeExercise(entry.key),
                onUpdateSet: (setIdx, updates) => _updateSet(entry.key, setIdx, updates),
                onRemoveSet: (setIdx) => _removeSet(entry.key, setIdx),
              ),
            );
          }).toList(),
          
          // 운동 추가 버튼
          _buildAddExerciseButton(),
        ],
      ),
    );
  }

  Widget _buildWorkoutHeader() {
    final sessionName = session?['session_name'] ?? '프리스타일 워크아웃';
    final isProgramSession = (widget.programId != null) || (activeUserProgram != null);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로그램 세션인 경우 프로그램명과 day 정보 표시
          if (isProgramSession && program != null) ...[
            Text(
              program!['name'] ?? '워크아웃 프로그램',
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            // 프로그램 주차/요일 표시
            if (activeUserProgram != null) ...[
              Text(
                'Week ${activeUserProgram?['current_week']}  •  Day ${activeUserProgram?['current_day']}',
                style: TextStyle(
                  color: context.colors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else if (widget.programDay != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.programDay!,
                style: TextStyle(
                  color: context.colors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ] else ...[
            Text(
              sessionName,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            '시작 시간: ${_formatStartTime()}',
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatStartTime() {
    final startTimeKey = session?['started_at'] ?? session?['start_time'];
    final start = DateTime.tryParse(startTimeKey ?? '');
    if (start == null) return '알 수 없음';
    return '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildAddExerciseButton() {
    return Container(
      width: double.infinity,
      height: 120,
      child: ElevatedButton(
        onPressed: () async {
          final result = await showDialog(
            context: context,
            barrierColor: context.colors.scrim,
            builder: (context) {
              return AddExerciseModal(
                onAdd: (exerciseName) {
                  _addExercise(exerciseName);
                  Navigator.of(context).pop();
                },
                onCancel: () {
                  Navigator.of(context).pop();
                },
              );
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colors.surfaceVariant,
          foregroundColor: context.colors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: context.colors.primary.withOpacity(0.3),
              width: 2,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 32, color: context.colors.primary),
            const SizedBox(height: 8),
            Text(
              '운동 추가',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: context.colors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.surfaceVariant),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
          // 타이머
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.colors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.timer, color: context.colors.secondary, size: 24),
                const SizedBox(height: 8),
                Text(
                  _formatTime(workoutTime),
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 24,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '경과 시간',
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // 진행률
          Text(
            '진행률',
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _progressPercentage / 100,
            backgroundColor: context.colors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            '$_completedSets / $_totalSets 세트 완료 (${_progressPercentage.toStringAsFixed(0)}%)',
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          
          // 통계
          _buildStatCard('운동 수', exercises.length.toString()),
          const SizedBox(height: 12),
          _buildStatCard('총 세트', _totalSets.toString()),
          const SizedBox(height: 12),
          _buildStatCard('완료된 세트', _completedSets.toString()),
          
          const SizedBox(height: 32),
          
          // 완료 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _finishWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '운동 완료',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.secondaryBackground2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getMobileHeaderTitle() {
    final sessionName = session?['session_name'] ?? '프리스타일 워크아웃';
    final isProgramSession = (widget.programId != null) || (activeUserProgram != null);
    
    if (isProgramSession && program != null) {
      return program!['name'] ?? '워크아웃 프로그램';
    }
    return sessionName;
  }

  String _getMobileSubtitle() {
    final isProgramSession = (widget.programId != null) || (activeUserProgram != null);
    
    if (isProgramSession && program != null) {
      if (activeUserProgram != null) {
        return 'Week ${activeUserProgram?['current_week']}  •  Day ${activeUserProgram?['current_day']}';
      } else if (widget.programDay != null) {
        return widget.programDay!;
      }
    }
    return '';
  }
} 