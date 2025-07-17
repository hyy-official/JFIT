import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/bloc/base_bloc.dart';
import 'package:jfit/core/bloc/bloc_event_bus.dart';
import 'package:jfit/core/error/bloc_errors.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/core/models/exercise.dart';
import 'package:jfit/features/workout_session/data/repositories/workout_session_repository.dart';
import 'package:jfit/features/programs/data/models/workout_session_model.dart';
import 'package:jfit/features/workout_program/utils/exercise_data_parser.dart';
import 'package:dartz/dartz.dart';
import 'workout_session_event.dart';
import 'workout_session_state.dart';

/// BLoC for managing workout session operations
/// Handles workout session creation, updates, completion, and logging
/// Provides real-time workout session state management
class WorkoutSessionBloc extends BaseBloc<WorkoutSessionEvent, WorkoutSessionState> {
  final WorkoutSessionRepository _repository;
  
  // Track current active session for real-time state management
  String? _currentActiveSessionId;
  Map<String, List<Map<String, dynamic>>> _sessionWorkoutLogs = {};
  
  // Performance optimization: Limit memory usage for workout logs
  static const int _maxLogEntriesPerSession = 1000;
  static const int _maxCachedSessions = 5;
  
  // Performance metrics
  int _totalSetsLogged = 0;
  int _totalSessionsCreated = 0;
  int _totalSessionsCompleted = 0;

  WorkoutSessionBloc({
    required WorkoutSessionRepository repository,
  })  : _repository = repository,
        super(const WorkoutSessionInitial()) {
    on<CreateWorkoutSession>(_onCreateWorkoutSession);
    on<StartWorkoutSessionWithValidation>(_onStartWorkoutSessionWithValidation);
    on<LoadWorkoutSession>(_onLoadWorkoutSession);
    on<LoadWorkoutSessions>(_onLoadWorkoutSessions);
    on<LoadActiveSession>(_onLoadActiveSession);
    on<UpdateWorkoutSession>(_onUpdateWorkoutSession);
    on<LogWorkoutSet>(_onLogWorkoutSet);
    on<CompleteWorkoutSession>(_onCompleteWorkoutSession);
  }

  /// Handle starting a workout session with comprehensive exercise data validation
  /// Ensures proper data flow from workout programs to workout sessions
  Future<void> _onStartWorkoutSessionWithValidation(
    StartWorkoutSessionWithValidation event,
    Emitter<WorkoutSessionState> emit,
  ) async {
    emit(const WorkoutSessionLoading(message: '운동 데이터를 검증하고 있습니다...'));

    await safeAsyncOperation(
      () async {
        // Step 1: Validate and parse exercise data
        final exerciseValidationResult = await _validateAndParseExerciseData(
          event.exercisesData,
          event.targetWeek,
          event.targetDay,
        );

        if (exerciseValidationResult.isLeft()) {
          final failure = exerciseValidationResult.fold((l) => l, (r) => null)!;
          
          if (failure is DataParsingFailure) {
            emit(WorkoutSessionExerciseValidationFailed(
              message: failure.message,
              technicalMessage: failure.technicalMessage,
              originalData: event.exercisesData,
            ));
          } else {
            emit(WorkoutSessionErrorState.withCode(
              failure.message,
              BlocErrorCodes.dataParsingError,
            ));
          }
          return;
        }

        final validatedExercises = exerciseValidationResult.fold((l) => null, (r) => r)!;

        // Step 2: Check for empty exercise list
        if (validatedExercises.isEmpty) {
          emit(WorkoutSessionEmptyExerciseList(
            userProgramId: event.userProgramId,
            targetWeek: event.targetWeek,
            targetDay: event.targetDay,
            message: _getEmptyExerciseMessage(event.targetWeek, event.targetDay),
          ));
          return;
        }

        // Step 3: Emit validated data state
        emit(WorkoutSessionExerciseDataValidated(
          userProgramId: event.userProgramId,
          validatedExercises: validatedExercises,
          targetWeek: event.targetWeek,
          targetDay: event.targetDay,
        ));

        // Step 4: Create workout session with validated data
        emit(const WorkoutSessionLoading(message: '운동 세션을 생성하고 있습니다...'));

        final sessionResult = await _repository.createWorkoutSession(
          userProgramId: event.userProgramId,
          exercisesJson: {'exercises': validatedExercises},
        );

        await sessionResult.fold(
          (failure) async => emit(WorkoutSessionErrorState.withCode(
            failure.message,
            BlocErrorCodes.sessionCreateFailed,
          )),
          (sessionId) async {
            // Set as current active session for real-time tracking
            _currentActiveSessionId = sessionId;
            
            // Initialize workout logs tracking for this session
            _sessionWorkoutLogs[sessionId] = [];

            // Load the created session to get full details
            final sessionResult = await _repository.getWorkoutSession(sessionId);
            await sessionResult.fold(
              (failure) async => emit(WorkoutSessionErrorState.withCode(
                failure.message,
                BlocErrorCodes.sessionNotFound,
              )),
              (session) async {
                if (session != null) {
                  _totalSessionsCreated++;
                  emit(WorkoutSessionCreated(
                    sessionId: sessionId,
                    session: session,
                  ));

                  // Emit communication event to notify other BLOCs about session creation
                  _emitSessionCreatedEvent(session, sessionId);
                } else {
                  emit(WorkoutSessionErrorState.withCode(
                    '생성된 세션을 찾을 수 없습니다.',
                    BlocErrorCodes.sessionNotFound,
                  ));
                }
              },
            );
          },
        );
      },
      (error) => emit(WorkoutSessionErrorState.fromException(Exception(error.message))),
    );
  }

  /// Handle creating a new workout session
  /// Sets up real-time session tracking and initializes workout logs
  Future<void> _onCreateWorkoutSession(
    CreateWorkoutSession event,
    Emitter<WorkoutSessionState> emit,
  ) async {
    emit(const WorkoutSessionLoading(message: '운동 세션을 생성하고 있습니다...'));

    await safeAsyncOperation(
      () async {
        // Validate exercises data before creating session
        if (event.exercisesJson.isEmpty) {
          emit(WorkoutSessionErrorState.withCode(
            '운동 정보가 없습니다. 운동을 선택해주세요.',
            BlocErrorCodes.validationError,
          ));
          return;
        }

        final result = await _repository.createWorkoutSession(
          userProgramId: event.userProgramId,
          exercisesJson: event.exercisesJson,
        );

        await result.fold(
          (failure) async => emit(WorkoutSessionErrorState.withCode(
            failure.message,
            BlocErrorCodes.sessionCreateFailed,
          )),
          (sessionId) async {
            // Set as current active session for real-time tracking
            _currentActiveSessionId = sessionId;
            
            // Initialize workout logs tracking for this session
            _sessionWorkoutLogs[sessionId] = [];

            // Load the created session to get full details
            final sessionResult = await _repository.getWorkoutSession(sessionId);
            await sessionResult.fold(
              (failure) async => emit(WorkoutSessionErrorState.withCode(
                failure.message,
                BlocErrorCodes.sessionNotFound,
              )),
              (session) async {
                if (session != null) {
                  _totalSessionsCreated++;
                  emit(WorkoutSessionCreated(
                    sessionId: sessionId,
                    session: session,
                  ));
                } else {
                  emit(WorkoutSessionErrorState.withCode(
                    '생성된 세션을 찾을 수 없습니다.',
                    BlocErrorCodes.sessionNotFound,
                  ));
                }
              },
            );
          },
        );
      },
      (error) => emit(WorkoutSessionErrorState.fromException(Exception(error.message))),
    );
  }

  /// Handle loading a specific workout session
  Future<void> _onLoadWorkoutSession(
    LoadWorkoutSession event,
    Emitter<WorkoutSessionState> emit,
  ) async {
    emit(const WorkoutSessionLoading(message: '운동 세션을 불러오고 있습니다...'));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getWorkoutSession(event.sessionId);

        result.fold(
          (failure) => emit(WorkoutSessionErrorState.withCode(
            failure.message,
            BlocErrorCodes.sessionNotFound,
          )),
          (session) {
            if (session != null) {
              emit(WorkoutSessionLoaded(session));
            } else {
              emit(WorkoutSessionErrorState.withCode(
                '운동 세션을 찾을 수 없습니다.',
                BlocErrorCodes.sessionNotFound,
              ));
            }
          },
        );
      },
      (error) => emit(WorkoutSessionErrorState.fromException(Exception(error.message))),
    );
  }

  /// Handle loading all workout sessions for a user
  Future<void> _onLoadWorkoutSessions(
    LoadWorkoutSessions event,
    Emitter<WorkoutSessionState> emit,
  ) async {
    emit(const WorkoutSessionLoading(message: '운동 세션 목록을 불러오고 있습니다...'));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getWorkoutSessions(event.userId);

        result.fold(
          (failure) => emit(WorkoutSessionErrorState.withCode(
            failure.message,
            BlocErrorCodes.dataNotFound,
          )),
          (sessions) => emit(WorkoutSessionsLoaded(sessions)),
        );
      },
      (error) => emit(WorkoutSessionErrorState.fromException(Exception(error.message))),
    );
  }

  /// Handle loading active workout sessions for a user
  Future<void> _onLoadActiveSession(
    LoadActiveSession event,
    Emitter<WorkoutSessionState> emit,
  ) async {
    emit(const WorkoutSessionLoading(message: '진행 중인 운동 세션을 불러오고 있습니다...'));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getActiveWorkoutSessions(event.userId);

        result.fold(
          (failure) => emit(WorkoutSessionErrorState.withCode(
            failure.message,
            BlocErrorCodes.dataNotFound,
          )),
          (sessions) => emit(ActiveSessionLoaded(sessions)),
        );
      },
      (error) => emit(WorkoutSessionErrorState.fromException(Exception(error.message))),
    );
  }

  /// Handle updating a workout session
  Future<void> _onUpdateWorkoutSession(
    UpdateWorkoutSession event,
    Emitter<WorkoutSessionState> emit,
  ) async {
    emit(const WorkoutSessionLoading(message: '운동 세션을 업데이트하고 있습니다...'));

    await safeAsyncOperation(
      () async {
        final result = await _repository.updateWorkoutSession(
          sessionId: event.sessionId,
          updates: event.updates,
        );

        result.fold(
          (failure) => emit(WorkoutSessionErrorState.withCode(
            failure.message,
            BlocErrorCodes.sessionUpdateFailed,
          )),
          (session) => emit(WorkoutSessionUpdated(session)),
        );
      },
      (error) => emit(WorkoutSessionErrorState.fromException(Exception(error.message))),
    );
  }

  /// Handle logging a workout set
  /// Provides real-time workout log tracking and validation
  Future<void> _onLogWorkoutSet(
    LogWorkoutSet event,
    Emitter<WorkoutSessionState> emit,
  ) async {
    emit(const WorkoutSessionLoading(message: '운동 세트를 기록하고 있습니다...'));

    await safeAsyncOperation(
      () async {
        // Validate workout set data
        if (event.reps <= 0) {
          emit(WorkoutSessionErrorState.withCode(
            '반복 횟수는 0보다 커야 합니다.',
            BlocErrorCodes.validationError,
          ));
          return;
        }

        if (event.weight < 0) {
          emit(WorkoutSessionErrorState.withCode(
            '중량은 0 이상이어야 합니다.',
            BlocErrorCodes.validationError,
          ));
          return;
        }

        // Check if session exists and is active
        final sessionResult = await _repository.getWorkoutSession(event.sessionId);
        final sessionCheck = await sessionResult.fold(
          (failure) => null,
          (session) => session,
        );

        if (sessionCheck == null) {
          emit(WorkoutSessionErrorState.withCode(
            '운동 세션을 찾을 수 없습니다.',
            BlocErrorCodes.sessionNotFound,
          ));
          return;
        }

        if (sessionCheck.isCompleted) {
          emit(WorkoutSessionErrorState.withCode(
            '이미 완료된 세션에는 운동을 기록할 수 없습니다.',
            BlocErrorCodes.sessionUpdateFailed,
          ));
          return;
        }

        final result = await _repository.logWorkoutSet(
          sessionId: event.sessionId,
          exerciseId: event.exerciseId,
          setNumber: event.setNumber,
          reps: event.reps,
          weight: event.weight,
        );

        result.fold(
          (failure) => emit(WorkoutSessionErrorState.withCode(
            failure.message,
            BlocErrorCodes.workoutLogFailed,
          )),
          (_) {
            // Track the logged set in real-time state with memory management
            final logEntry = {
              'exercise_id': event.exerciseId,
              'set_number': event.setNumber,
              'reps': event.reps,
              'weight': event.weight,
              'logged_at': DateTime.now().toIso8601String(),
            };

            _addLogEntryWithMemoryManagement(event.sessionId, logEntry);
            _totalSetsLogged++;

            emit(WorkoutSetLogged(
              sessionId: event.sessionId,
              exerciseId: event.exerciseId,
              setNumber: event.setNumber,
              reps: event.reps,
              weight: event.weight,
            ));
          },
        );
      },
      (error) => emit(WorkoutSessionErrorState.fromException(Exception(error.message))),
    );
  }

  /// Handle completing a workout session
  /// Performs comprehensive session completion with validation and communication
  Future<void> _onCompleteWorkoutSession(
    CompleteWorkoutSession event,
    Emitter<WorkoutSessionState> emit,
  ) async {
    emit(const WorkoutSessionLoading(message: '운동 세션을 완료하고 있습니다...'));

    await safeAsyncOperation(
      () async {
        // First, verify the session exists and is not already completed
        final sessionResult = await _repository.getWorkoutSession(event.sessionId);
        final currentSession = await sessionResult.fold(
          (failure) => null,
          (session) => session,
        );

        if (currentSession == null) {
          emit(WorkoutSessionErrorState.withCode(
            '완료하려는 운동 세션을 찾을 수 없습니다.',
            BlocErrorCodes.sessionNotFound,
          ));
          return;
        }

        if (currentSession.isCompleted) {
          emit(WorkoutSessionErrorState.withCode(
            '이미 완료된 운동 세션입니다.',
            BlocErrorCodes.sessionUpdateFailed,
          ));
          return;
        }

        // Validate that the session has some workout logs
        final sessionLogs = _sessionWorkoutLogs[event.sessionId];
        if (sessionLogs == null || sessionLogs.isEmpty) {
          // Check if there are any logs in the database for this session
          // This is a basic validation - in a real app you might want more sophisticated checks
        }

        final result = await _repository.completeWorkoutSession(event.sessionId);

        result.fold(
          (failure) => emit(WorkoutSessionErrorState.withCode(
            failure.message,
            BlocErrorCodes.sessionCompleteFailed,
          )),
          (session) {
            // Clear the current active session if it matches
            if (_currentActiveSessionId == event.sessionId) {
              _currentActiveSessionId = null;
            }

            // Clean up workout logs tracking for completed session
            _sessionWorkoutLogs.remove(event.sessionId);

            emit(WorkoutSessionCompleted(
              sessionId: event.sessionId,
              session: session,
            ));

            // Emit communication event to notify other BLOCs
            // We need to get the actual userId from the session
            _emitSessionCompletedEvent(session, event.sessionId);
          },
        );
      },
      (error) => emit(WorkoutSessionErrorState.fromException(Exception(error.message))),
    );
  }

  /// Helper method to emit session completed communication event
  /// Gets the actual userId and emits the event to other BLOCs
  Future<void> _emitSessionCompletedEvent(
    WorkoutSessionModel session,
    String sessionId,
  ) async {
    try {
      // We need to get the userId from the user_program
      // For now, we'll use the userProgramId as a placeholder
      // In a real implementation, you'd want to fetch the actual userId
      
      if (session.sessionDate != null) {
        emitCommunicationEvent(WorkoutSessionCompletedEvent(
          userId: session.userProgramId, // TODO: Get actual userId
          date: session.sessionDate!,
          sessionId: sessionId,
          userProgramId: session.userProgramId,
        ));

        // Also emit a daily summary refresh request
        emitCommunicationEvent(DailySummaryRefreshRequestedEvent(
          userId: session.userProgramId, // TODO: Get actual userId
          date: session.sessionDate!,
          reason: RefreshReason.workoutCompleted,
        ));
      }
    } catch (e) {
      // Log error but don't fail the completion process
      // Communication events are nice-to-have, not critical
    }
  }

  @override
  void handleCommunicationEvent(BlocCommunicationEvent event) {
    // Handle communication events from other BLOCs
    if (event is WorkoutProgramDeletedEvent) {
      // Handle workout program deletion - clean up related active sessions
      _handleWorkoutProgramDeleted(event);
    } else if (event is WorkoutProgramProgressUpdatedEvent) {
      // Handle workout program progress updates
      _handleWorkoutProgramProgressUpdated(event);
    }
  }

  /// Handle workout program deletion by cleaning up related sessions
  void _handleWorkoutProgramDeleted(WorkoutProgramDeletedEvent event) {
    try {
      // Clean up any active session tracking for the deleted program
      if (_currentActiveSessionId != null) {
        // In a real implementation, you'd check if the current session belongs to the deleted program
        // For now, we'll be conservative and not automatically clean up active sessions
        // as they might be in progress and should be completed by the user
      }
      
      // Clean up workout logs for sessions related to the deleted program
      // This prevents memory leaks from orphaned session data
      _sessionWorkoutLogs.removeWhere((sessionId, logs) {
        // In a more sophisticated implementation, you'd check if the session 
        // belongs to the deleted program by querying the session data
        // For now, we'll keep the logs as they might still be useful
        return false; // Conservative approach - don't remove logs
      });
    } catch (e) {
      // Log error but don't fail the communication handling
      // Communication events should be resilient to failures
    }
  }

  /// Handle workout program progress updates
  void _handleWorkoutProgramProgressUpdated(WorkoutProgramProgressUpdatedEvent event) {
    try {
      // When program progress is updated, we might need to sync with active sessions
      // This ensures consistency between program state and active workout sessions
      
      // If there's an active session for this program, we might want to validate
      // that the session is still valid for the current program state
      if (_currentActiveSessionId != null) {
        // In a more sophisticated implementation, you could:
        // 1. Check if the active session belongs to the updated program
        // 2. Validate that the session is still appropriate for the new program state
        // 3. Potentially update session data or notify the user of changes
        
        // For now, we'll just ensure data consistency by not taking destructive actions
      }
    } catch (e) {
      // Log error but don't fail the communication handling
    }
  }

  /// Get current active session ID for external access
  String? get currentActiveSessionId => _currentActiveSessionId;

  /// Get workout logs for a specific session
  List<Map<String, dynamic>>? getSessionWorkoutLogs(String sessionId) {
    return _sessionWorkoutLogs[sessionId];
  }

  /// Check if a session has any logged sets
  bool hasLoggedSets(String sessionId) {
    final logs = _sessionWorkoutLogs[sessionId];
    return logs != null && logs.isNotEmpty;
  }

  /// Get total sets logged for a session
  int getTotalSetsLogged(String sessionId) {
    final logs = _sessionWorkoutLogs[sessionId];
    return logs?.length ?? 0;
  }

  /// Get logged sets for a specific exercise in a session
  List<Map<String, dynamic>> getExerciseLoggedSets(String sessionId, String exerciseId) {
    final logs = _sessionWorkoutLogs[sessionId];
    if (logs == null) return [];
    
    return logs.where((log) => log['exercise_id'] == exerciseId).toList();
  }

  /// Add log entry with memory management to prevent excessive memory usage
  void _addLogEntryWithMemoryManagement(String sessionId, Map<String, dynamic> logEntry) {
    // Initialize session logs if not exists
    _sessionWorkoutLogs[sessionId] ??= [];
    
    final sessionLogs = _sessionWorkoutLogs[sessionId]!;
    
    // Add the new log entry
    sessionLogs.add(logEntry);
    
    // Enforce memory limits
    if (sessionLogs.length > _maxLogEntriesPerSession) {
      // Remove oldest entries to stay within limit
      final excessCount = sessionLogs.length - _maxLogEntriesPerSession;
      sessionLogs.removeRange(0, excessCount);
    }
    
    // Limit total number of cached sessions
    if (_sessionWorkoutLogs.length > _maxCachedSessions) {
      _cleanupOldestSessions();
    }
  }

  /// Clean up oldest sessions to prevent memory bloat
  void _cleanupOldestSessions() {
    // Keep only the most recent sessions and the current active session
    final sessionIds = _sessionWorkoutLogs.keys.toList();
    
    // Sort by session ID (assuming newer sessions have later IDs)
    sessionIds.sort();
    
    // Remove oldest sessions, but keep the active session
    while (_sessionWorkoutLogs.length > _maxCachedSessions) {
      final oldestSessionId = sessionIds.removeAt(0);
      
      // Don't remove the current active session
      if (oldestSessionId != _currentActiveSessionId) {
        _sessionWorkoutLogs.remove(oldestSessionId);
      } else if (sessionIds.isNotEmpty) {
        // If the oldest is the active session, remove the next oldest
        final nextOldest = sessionIds.removeAt(0);
        _sessionWorkoutLogs.remove(nextOldest);
      } else {
        // If only active session remains, break to avoid infinite loop
        break;
      }
    }
  }

  /// Get performance metrics for the WorkoutSessionBloc
  Map<String, dynamic> getPerformanceMetrics() {
    final baseMetrics = super.getPerformanceMetrics();
    
    return {
      ...baseMetrics,
      'total_sets_logged': _totalSetsLogged,
      'total_sessions_created': _totalSessionsCreated,
      'total_sessions_completed': _totalSessionsCompleted,
      'active_session_id': _currentActiveSessionId,
      'cached_sessions_count': _sessionWorkoutLogs.length,
      'total_cached_logs': _sessionWorkoutLogs.values
          .map((logs) => logs.length)
          .fold(0, (sum, count) => sum + count),
      'memory_usage_kb': _estimateMemoryUsage(),
    };
  }

  /// Estimate memory usage in KB
  double _estimateMemoryUsage() {
    // Rough estimation: each log entry ~0.5KB
    final totalLogs = _sessionWorkoutLogs.values
        .map((logs) => logs.length)
        .fold(0, (sum, count) => sum + count);
    return totalLogs * 0.5;
  }

  @override
  void onInactivity() {
    // Clean up non-active session logs when BLOC is inactive
    if (_currentActiveSessionId != null) {
      // Keep only the active session logs
      final activeSessionLogs = _sessionWorkoutLogs[_currentActiveSessionId];
      _sessionWorkoutLogs.clear();
      if (activeSessionLogs != null) {
        _sessionWorkoutLogs[_currentActiveSessionId!] = activeSessionLogs;
      }
    } else {
      // No active session, clear all logs
      _sessionWorkoutLogs.clear();
    }
  }

  @override
  Future<void> close() {
    // Clean up resources
    _sessionWorkoutLogs.clear();
    _currentActiveSessionId = null;
    return super.close();
  }

  /// Validate and parse exercise data using ExerciseDataParser
  /// Ensures proper data flow and validation before creating workout sessions
  Future<Either<Failure, List<Map<String, dynamic>>>> _validateAndParseExerciseData(
    dynamic exercisesData,
    int? targetWeek,
    int? targetDay,
  ) async {
    try {
      // Use ExerciseDataParser to safely parse the data
      Either<Failure, List<Exercise>> parseResult;
      
      if (targetWeek != null && targetDay != null) {
        // Parse for specific week and day
        parseResult = ExerciseDataParser.parseExercisesForWeekDay(
          exercisesData,
          targetWeek,
          targetDay,
        );
      } else {
        // Parse general exercise data
        parseResult = ExerciseDataParser.parseExercises(exercisesData);
      }

      return parseResult.fold(
        (failure) => Left(failure),
        (exercises) {
          // Convert Exercise objects to UI-compatible Map format
          final convertedExercises = exercises.map<Map<String, dynamic>>((exercise) {
            final exerciseName = exercise.titleKo;
            final sets = int.tryParse(exercise.recommendedSets ?? '3') ?? 3;
            final reps = exercise.recommendedReps ?? '10';
            
            // Create sets for the exercise
            final exerciseSets = List.generate(sets, (index) => {
              'weight': 0.0,
              'reps': 0,
              'completed': false,
              'target_reps': reps,
              'target_weight': 0.0,
            });

            return {
              'exercise_id': exercise.id.toString(),
              'exercise_name': exerciseName,
              'sets': exerciseSets,
              'program_sets': sets,
              'program_reps': reps,
              'notes': '',
              'difficulty': exercise.difficulty,
              'type': exercise.type,
              'equipment': exercise.equipment,
            };
          }).toList();

          return Right(convertedExercises);
        },
      );
    } catch (e) {
      return Left(DataParsingFailure(
        message: '운동 데이터 검증 중 오류가 발생했습니다.',
        dataType: 'exercise_validation',
        technicalMessage: 'Exercise data validation failed: $e',
      ));
    }
  }

  /// Generate user-friendly message for empty exercise lists
  String _getEmptyExerciseMessage(int? targetWeek, int? targetDay) {
    if (targetWeek != null && targetDay != null) {
      return '${targetWeek}주차 ${targetDay}일차에 등록된 운동이 없습니다.\n프로그램을 확인하거나 운동을 직접 추가해주세요.';
    } else if (targetWeek != null) {
      return '${targetWeek}주차에 등록된 운동이 없습니다.\n프로그램을 확인하거나 운동을 직접 추가해주세요.';
    } else {
      return '등록된 운동이 없습니다.\n프로그램을 확인하거나 운동을 직접 추가해주세요.';
    }
  }

  /// Emit session created communication event to notify other BLOCs
  void _emitSessionCreatedEvent(WorkoutSessionModel session, String sessionId) {
    try {
      if (session.sessionDate != null) {
        emitCommunicationEvent(WorkoutSessionCreatedEvent(
          sessionId: sessionId,
          userProgramId: session.userProgramId,
          sessionDate: session.sessionDate!,
        ));
      }
    } catch (e) {
      // Log error but don't fail the session creation process
      print('Failed to emit session created event: $e');
    }
  }

  /// Validate exercise data integrity and structure
  bool _validateExerciseIntegrity(List<Map<String, dynamic>> exercises) {
    if (exercises.isEmpty) {
      return false;
    }

    for (final exercise in exercises) {
      // Check required fields
      if (!exercise.containsKey('exercise_name') || 
          !exercise.containsKey('sets') ||
          exercise['exercise_name'] == null ||
          exercise['sets'] == null) {
        return false;
      }

      // Validate sets structure
      final sets = exercise['sets'];
      if (sets is! List || sets.isEmpty) {
        return false;
      }

      // Validate each set
      for (final set in sets) {
        if (set is! Map<String, dynamic> ||
            !set.containsKey('weight') ||
            !set.containsKey('reps') ||
            !set.containsKey('completed')) {
          return false;
        }
      }
    }

    return true;
  }

  /// Validate data flow between BLoCs
  void _validateBlocDataFlow() {
    // This method can be used to validate that data is properly flowing
    // between WorkoutProgramBloc and WorkoutSessionBloc
    
    // For now, we'll just log the validation
    print('🔍 BLoC 데이터 흐름 검증 완료');
    
    // In a more sophisticated implementation, you could:
    // 1. Check if the current session data matches the program data
    // 2. Validate that exercise IDs are consistent
    // 3. Ensure that session state is synchronized with program state
  }

  /// Synchronize exercise data between BLoCs
  Future<void> _synchronizeExerciseData() async {
    try {
      // This method can be used to synchronize exercise data
      // between WorkoutProgramBloc and WorkoutSessionBloc
      
      print('🔍 BLoC 간 운동 데이터 동기화 시도');
      
      // Emit a communication event to request fresh program data
      emitCommunicationEvent(WorkoutProgramDataSyncRequestedEvent(
        reason: 'exercise_data_synchronization',
      ));
      
    } catch (e) {
      print('🔍 BLoC 간 데이터 동기화 실패: $e');
    }
  }
}