import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/theme/app_theme.dart';
import 'package:jfit/features/records/bloc/record_bloc.dart';
import 'package:jfit/features/records/bloc/record_event.dart';
import 'package:jfit/features/records/bloc/record_state.dart';
import 'package:jfit/features/workout_session/presentation/widgets/exercise_card.dart';
import 'package:jfit/models/exercise.dart';

class WorkoutSessionPage extends StatefulWidget {
  final UserProgram? userProgram;
  final List<Exercise>? exercises;

  const WorkoutSessionPage({
    super.key, 
    this.userProgram,
    this.exercises,
  });

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  late DateTime _startTime;
  bool _isSessionActive = false;
  int _currentExerciseIndex = 0;
  Map<int, List<Map<String, dynamic>>> _exerciseSets = {};
  
  // 기본 운동 목록
  List<Exercise> get _exercises => widget.exercises ?? [];
  UserProgram get _userProgram => widget.userProgram ?? UserProgram(
    id: 'default',
    name: '기본 운동',
    creator: 'JFit',
    description: '기본 운동 세션',
    currentWeek: 1,
    currentDay: 1,
    totalWeeks: 1,
    difficulty: 'beginner',
    programType: 'strength',
    workoutsPerWeek: 3,
    exercisesJson: {},
    startedAt: DateTime.now(),
    isActive: true,
    weeklySchedule: [],
  );

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _isSessionActive = true;
    _initializeExerciseSets();
  }

  void _initializeExerciseSets() {
    for (int i = 0; i < _exercises.length; i++) {
      final exercise = _exercises[i];
      final sets = exercise.sets ?? 3;
      _exerciseSets[i] = List.generate(sets, (index) => {
        'reps': exercise.reps ?? 10,
        'weight': 0.0,
        'completed': false,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_exercises.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('운동 세션'),
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text(
            '운동 세션을 시작하려면 운동을 선택해주세요.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${_userProgram.name} - ${_userProgram.currentDay}일차'),
        backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: _showFinishDialog,
                          ),
                        ],
                      ),
      body: Column(
                        children: [
          // 운동 세션 정보
          _buildSessionInfo(),
          
          // 운동 목록
          Expanded(
            child: PageView.builder(
              itemCount: _exercises.length,
              onPageChanged: (index) {
                setState(() {
                  _currentExerciseIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final exercise = _exercises[index];
                final sets = exercise.sets ?? 3;
                final exerciseData = {
                  'exercise_name': exercise.titleKo,
                  'reps': exercise.reps ?? 10,
                  'sets': _exerciseSets[index] ?? _generateSets(sets),
                };

                return ExerciseCard(
                  key: ObjectKey(exercise),
                  exercise: exerciseData,
                  exerciseIndex: index,
                  onAddSet: () => _addSet(index),
                  onRemove: () => _removeExercise(index),
                  onUpdateSet: (setIndex, updates) => _updateSet(index, setIndex, updates),
                  onRemoveSet: (setIndex) => _removeSet(index, setIndex),
          );
        },
      ),
          ),
          
          // 하단 네비게이션
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildSessionInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.primary.withOpacity(0.1),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            Text(
                    '진행 시간',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  StreamBuilder<DateTime>(
                    stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final duration = snapshot.data!.difference(_startTime);
                        return Text(
                          '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(
                            fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
                        );
                      }
                      return const Text('00:00');
                    },
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
              Text(
                    '운동 진행',
                style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                ),
              ),
            Text(
                    '${_currentExerciseIndex + 1}/${_exercises.length}',
              style: const TextStyle(
                      fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: ((_currentExerciseIndex + 1) / _exercises.length).clamp(0.0, 1.0),
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
                    color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
                ),
              ],
            ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _currentExerciseIndex > 0 ? _goToPreviousExercise : null,
              child: const Text('이전 운동'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentExerciseIndex < _exercises.length - 1
                  ? _goToNextExercise
                  : _showFinishDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(
                _currentExerciseIndex < _exercises.length - 1 ? '다음 운동' : '운동 완료',
              ),
            ),
          ),
        ],
        ),
    );
  }

  void _updateSet(int exerciseIndex, int setIndex, Map<String, dynamic> updates) {
    setState(() {
      if (_exerciseSets[exerciseIndex] != null && setIndex < _exerciseSets[exerciseIndex]!.length) {
        _exerciseSets[exerciseIndex]![setIndex] = {
          ..._exerciseSets[exerciseIndex]![setIndex],
          ...updates,
        };
      }
    });
  }

  List<Map<String, dynamic>> _generateSets(int count) {
    return List.generate(count, (index) => {
      'reps': 10,
      'weight': 0.0,
      'completed': false,
    });
  }

  void _addSet(int exerciseIndex) {
    setState(() {
      if (_exerciseSets[exerciseIndex] != null) {
        _exerciseSets[exerciseIndex]!.add({
          'reps': 10,
          'weight': 0.0,
          'completed': false,
        });
      }
    });
  }

  void _removeExercise(int exerciseIndex) {
    // 운동 삭제 확인 다이얼로그
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('운동 삭제'),
        content: const Text('이 운동을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _exercises.removeAt(exerciseIndex);
                _exerciseSets.remove(exerciseIndex);
                if (_currentExerciseIndex >= _exercises.length) {
                  _currentExerciseIndex = _exercises.length - 1;
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _removeSet(int exerciseIndex, int setIndex) {
    setState(() {
      if (_exerciseSets[exerciseIndex] != null && 
          setIndex < _exerciseSets[exerciseIndex]!.length &&
          _exerciseSets[exerciseIndex]!.length > 1) {
        _exerciseSets[exerciseIndex]!.removeAt(setIndex);
      }
    });
  }

  void _goToNextExercise() {
    if (_currentExerciseIndex < _exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
      });
    }
  }

  void _goToPreviousExercise() {
    if (_currentExerciseIndex > 0) {
      setState(() {
        _currentExerciseIndex--;
      });
    }
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('운동 완료'),
        content: const Text('운동을 완료하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('계속하기'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _finishWorkout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('완료'),
          ),
        ],
      ),
    );
  }

  void _finishWorkout() {
    // 운동 완료 처리
    final endTime = DateTime.now();
    final duration = endTime.difference(_startTime);
    
    // 프로그램 진행률 업데이트
    context.read<RecordBloc>().add(
      UpdateProgramProgress(
        _userProgram.id,
        _userProgram.currentWeek,
        _userProgram.currentDay + 1,
      ),
    );
    
    // 운동 완료 메시지 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('운동 완료! 총 ${duration.inMinutes}분 운동했습니다.'),
        backgroundColor: Colors.green,
      ),
    );
    
    // 페이지 닫기
    Navigator.pop(context);
  }
} 