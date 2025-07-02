import 'package:flutter/material.dart';
import 'package:jfit/core/database/database_helper.dart';
import 'package:jfit/features/workout_session/presentation/widgets/exercise_card.dart';
import 'package:jfit/features/workout_session/presentation/widgets/workout_summary.dart';
import 'package:jfit/features/workout_session/presentation/widgets/add_exercise_modal.dart';
import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:jfit/core/navigation/main_navigation_page.dart';
import 'package:jfit/core/widgets/responsive_scaffold.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/core/extensions/context_extensions.dart';

class WorkoutSessionPage extends StatefulWidget {
  final String? sessionId; // null이면 새 세션(프리스타일)
  final String? programId; // 워크아웃 프로그램 ID
  final String? programDay; // 프로그램의 특정 day (예: "Day 1: 전신 A")
  final bool showNavigation; // 네비게이션 바 표시 여부 (ProgramDetail → Start 시 true)

  const WorkoutSessionPage({
    super.key, 
    this.sessionId,
    this.programId,
    this.programDay,
    this.showNavigation = false,
  });

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  late DatabaseHelper db;
  final _uuid = const Uuid();
  Map<String, dynamic>? session;
  Map<String, dynamic>? program; // 워크아웃 프로그램 정보
  List<Map<String, dynamic>> exercises = [];
  bool loading = true;
  int workoutTime = 0; // 초 단위
  Timer? _timer;
  Map<String, dynamic>? activeUserProgram;

  @override
  void initState() {
    super.initState();
    db = DatabaseHelper();
    _loadSession();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadSession() async {
    setState(() => loading = true);
    
    try {
      if (widget.sessionId != null) {
        // 기존 세션 불러오기
        final sessions = await db.getWorkoutSessions();
        session = sessions.firstWhere((s) => s['id'] == widget.sessionId, orElse: () => {});
        exercises = List<Map<String, dynamic>>.from(session?['exercises'] ?? []);
      } else {
        // 새 세션 생성
        String sessionName = '프리스타일 워크아웃';
        List<Map<String, dynamic>> programExercises = [];

        String? effectiveProgramId = widget.programId;

        // 1) 우선 위젯에서 프로그램 ID가 전달된 경우 사용
        // 2) 없으면 사용자의 활성 프로그램을 조회하여 사용
        if (effectiveProgramId == null) {
          final latestProgram = await db.getLatestActiveUserProgram();
          if (latestProgram != null) {
            activeUserProgram = latestProgram;
            effectiveProgramId = latestProgram['program_id'] as String?;
          }
        }

        if (effectiveProgramId != null) {
          program = await db.getWorkoutProgramById(effectiveProgramId);
          
          if (program != null && program!.isNotEmpty) {
            // 사용자 프로그램 인스턴스를 조회하거나 생성
            activeUserProgram ??= await db.getActiveUserProgram(effectiveProgramId);
            if (activeUserProgram == null) {
              activeUserProgram = {
                'id': _uuid.v4(),
                'program_id': effectiveProgramId,
                'current_week': 1,
                'current_day': 1,
                'started_at': DateTime.now().toIso8601String(),
              };
              await db.insertUserProgram(activeUserProgram!);
            }

            sessionName = program!['name'] ?? '프로그램 운동';
            if (widget.programDay != null) {
              sessionName += ' - ${widget.programDay}';
            }
            
            // 프로그램의 운동들을 로드
            int w = activeUserProgram!['current_week'];
            int d = activeUserProgram!['current_day'];
            programExercises = _loadProgramExercises(week: w, dayIndex: d-1);
          } else {
            // 프로그램을 찾을 수 없음
          }
        }

        final newSession = {
          'session_name': sessionName,
          'start_time': DateTime.now().toIso8601String(),
          'exercises': programExercises,
          'is_completed': 0,
          'program_id': effectiveProgramId,
          'program_day': activeUserProgram?['current_day'],
          'user_program_id': activeUserProgram?['id'],
          'program_week': activeUserProgram?['current_week'],
        };
        
        final id = await db.insertWorkoutSession(newSession);
        
        // 생성된 세션 정보를 직접 사용 (ID 추가)
        session = Map<String, dynamic>.from(newSession);
        session!['id'] = id;
        exercises = programExercises;
        
        // 새 세션 생성 완료
      }

      // 이전 기록을 기반으로 타겟 정보 적용
      await _applyPreviousTargets();
    } catch (e) {
      // 세션 로드 중 오류: $e
      // 오류 발생 시 기본 프리스타일 세션 생성
      final newSession = {
        'session_name': '프리스타일 워크아웃',
        'start_time': DateTime.now().toIso8601String(),
        'exercises': [],
        'is_completed': 0,
      };
      final id = await db.insertWorkoutSession(newSession);
      final sessions = await db.getWorkoutSessions();
      session = sessions.firstWhere((s) => s['id'] == id, orElse: () => {});
      exercises = [];
    }
    
    setState(() => loading = false);
    _startTimer();
  }

  List<Map<String, dynamic>> _loadProgramExercises({int? week, int? dayIndex}) {
    if (program == null) return [];

    try {
      final weeklySchedule = program!['weekly_schedule'] as List<dynamic>? ?? [];
      if (weeklySchedule.isEmpty) return [];

      // Determine week and day
      int weekIdx = (week != null) ? week - 1 : 0;
      if (weekIdx < 0 || weekIdx >= weeklySchedule.length) weekIdx = 0;
      final days = weeklySchedule[weekIdx]['days'] as List<dynamic>? ?? [];
      int dayIdx = dayIndex ?? 0;
      if (dayIdx < 0 || dayIdx >= days.length) dayIdx = 0;
      final day = days[dayIdx];
            final dayExercises = day['exercises'] as List<dynamic>? ?? [];
            
            return dayExercises.map<Map<String, dynamic>>((exercise) {
        final exerciseName = exercise['exercise_name'] as String? ?? exercise['name'] as String? ?? '운동';
              final sets = exercise['sets'] as int? ?? 3;
              final reps = exercise['reps'] as String? ?? '10';
              
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
                'notes': exercise['notes'] as String? ?? '',
              };
            }).toList();
    } catch (e) {
      // 프로그램 운동 로드 중 오류: $e
    }

    return [];
  }

  void _startTimer() {
    _timer?.cancel();
    if (session?['start_time'] != null) {
      final start = DateTime.tryParse(session!['start_time']);
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
    updated['exercises'] = exercises;
    
    try {
      
      await db.insertWorkoutSession(updated);
      
      // 세션 정보 업데이트
      setState(() {
        session = updated;
      
      });
    } catch (e) {
      
    }
  }

  void _addExercise(String exerciseName) async {
    
    // 이전 기록을 찾아 타겟 설정
    final exerciseId = await db.getExerciseIdByName(exerciseName);
    Map<String, dynamic>? lastLog;
    if (exerciseId != null) {
      lastLog = await db.getLastWorkoutLogByExerciseId(exerciseId);
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
      String? exerciseId = await db.getExerciseIdByName(exerciseName);
      if (exerciseId == null) {
        // 마스터 DB에만 존재하거나 사용자 정의 운동일 수 있으므로 exercises 테이블에 신규 추가
        final newId = _uuid.v4();
        final newExercise = {
          'id': newId,
          'exercise_name': exerciseName,
          'exercise_type': 'custom',
          'exercise_date': DateTime.now().toIso8601String(),
          'is_deleted': 0,
        };
        await db.insertExercise(newExercise);
        exerciseId = newId;
      }

      await db.insertWorkoutLog(
        exerciseId: exerciseId,
        sessionId: session?['id']?.toString(),
        sets: setIndex + 1,
        reps: reps,
        weight: weight,
      );
    } catch (e) {
      // 운동 로그 저장 실패: $e
    }
  }

  void _finishWorkout() {
    if (session != null) {
      final updated = Map<String, dynamic>.from(session!);
      updated['is_completed'] = 1;
      updated['end_time'] = DateTime.now().toIso8601String();
      updated['total_duration_minutes'] = workoutTime ~/ 60;
      db.insertWorkoutSession(updated);
    }

    bool programCompleted = false; // 추가: 프로그램 완료 여부

    // 사용자 프로그램 진행도 업데이트
    if (activeUserProgram != null) {
      int w = activeUserProgram!['current_week'];
      int d = activeUserProgram!['current_day'];

      // 프로그램 스케줄
      final schedule = program?['weekly_schedule'] as List<dynamic>? ?? [];
      final totalWeeks = schedule.length;

      // 현재 주차의 총 day 개수 계산
      int totalDaysInWeek = 0;
      if (schedule.isNotEmpty && w - 1 < schedule.length) {
        totalDaysInWeek = (schedule[w - 1]['days'] as List<dynamic>? ?? []).length;
      }

      // 다음 day 계산
      d += 1;
      if (d > totalDaysInWeek) {
        d = 1;
        w += 1;
      }

      // 프로그램 완료 여부 판단
      if (w > totalWeeks) {
        programCompleted = true;
      }

      if (programCompleted) {
        // 프로그램 완료 처리
        db.updateUserProgram(activeUserProgram!['id'], {
          'completed_at': DateTime.now().toIso8601String(),
          'is_active': 0,
        });
      } else {
        // 진행도 업데이트
        db.updateUserProgram(activeUserProgram!['id'], {
          'current_week': w,
          'current_day': d,
        });
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
            backgroundColor: AppTheme.secondaryBackground2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: const Text(
              '축하드립니다!',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            content: const Text(
              '운동 루틴을 완료하셨습니다!',
              style: TextStyle(color: Colors.white70),
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

  /// 각 운동에 대해 이전 기록을 찾아 세트마다 타겟 정보를 설정한다.
  Future<void> _applyPreviousTargets() async {
    for (final exercise in exercises) {
      final name = exercise['exercise_name'] as String? ?? '';
      if (name.isEmpty) continue;

      final exerciseId = await db.getExerciseIdByName(name);
      Map<String, dynamic>? lastLog;
      if (exerciseId != null) {
        lastLog = await db.getLastWorkoutLogByExerciseId(exerciseId);
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
    
      Widget page = Scaffold(
        backgroundColor: context.colors.background,
        body: Center(
          child: CircularProgressIndicator(color: context.colors.primary),
        ),
      );

      // 네비게이션 포함 옵션
      if (widget.showNavigation) {
        return ResponsiveScaffold(
          currentIndex: 2,
          onNavTap: (index) {
            // 다른 탭을 누르면 메인 네비게이션으로 이동
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => MainNavigationPage(initialIndex: index)),
              (route) => false,
            );
          },
          body: page,
        );
      }

      return page;
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
                        border: Border.all(color: AppTheme.surface2),
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
                                    color: Colors.white,
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
                                      const Text('•', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                      const SizedBox(width: 8),
                                    ],
                                    const Icon(Icons.play_arrow, color: Colors.white, size: 14),
                                    const SizedBox(width: 4),
                              Text(
                                _formatTime(workoutTime),
                                style: TextStyle(
                                  color: Colors.white,
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
                              foregroundColor: Colors.white,
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
                    final isDesktop = constraints.maxWidth >= 1024;
                    
                    if (isDesktop) {
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
          final isDesktop = constraints.maxWidth >= 1024;
          if (isDesktop) return const SizedBox.shrink();
          
          return FloatingActionButton(
            onPressed: () async {
              
              final result = await showDialog(
                context: context,
                barrierColor: Colors.black.withOpacity(0.5),
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
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
      ),
    );

    if (widget.showNavigation) {
      return ResponsiveScaffold(
        currentIndex: 2,
        onNavTap: (index) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => MainNavigationPage(initialIndex: index)),
            (route) => false,
          );
        },
        body: content,
      );
    }

    return content;
  }

  Widget _buildMainContent() {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
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
        border: Border.all(color: AppTheme.surface2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로그램 세션인 경우 프로그램명과 day 정보 표시
          if (isProgramSession && program != null) ...[
            Text(
              program!['name'] ?? '워크아웃 프로그램',
              style: const TextStyle(
                color: Colors.white,
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            '시작 시간: ${_formatStartTime()}',
            style: TextStyle(
              color: context.colors.onSurface,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatStartTime() {
    final start = DateTime.tryParse(session?['start_time'] ?? '');
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
            barrierColor: Colors.black.withOpacity(0.5),
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
          backgroundColor: AppTheme.secondaryBackground2,
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
          children: const [
            Icon(Icons.add, size: 32),
            SizedBox(height: 8),
            Text(
              '운동 추가',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
        border: Border.all(color: AppTheme.surface2),
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
              color: AppTheme.secondaryBackground2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.timer, color: AppTheme.accent2, size: 24),
                const SizedBox(height: 8),
                Text(
                  _formatTime(workoutTime),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '경과 시간',
                  style: TextStyle(
                    color: context.colors.onSurface,
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _progressPercentage / 100,
            backgroundColor: AppTheme.surface2,
            valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            '$_completedSets / $_totalSets 세트 완료 (${_progressPercentage.toStringAsFixed(0)}%)',
            style: TextStyle(
              color: context.colors.onSurface,
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
                foregroundColor: Colors.white,
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
        color: AppTheme.secondaryBackground2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.colors.onSurface,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
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