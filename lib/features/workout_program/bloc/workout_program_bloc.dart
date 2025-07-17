import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/bloc/base_bloc.dart';
import 'package:jfit/core/bloc/bloc_event_bus.dart';
import 'package:jfit/core/error/bloc_errors.dart';
import 'package:jfit/core/error/workout_program_failures.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_event.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_state.dart';
import 'package:jfit/features/workout_program/data/repositories/workout_program_repository.dart';
import 'package:jfit/features/workout_program/utils/workout_program_repository_manager.dart';

class WorkoutProgramBloc extends BaseBloc<WorkoutProgramEvent, WorkoutProgramState> {
  final WorkoutProgramRepository? _workoutProgramRepository;

  WorkoutProgramBloc({
    WorkoutProgramRepository? workoutProgramRepository,
  })  : _workoutProgramRepository = workoutProgramRepository,
        super(const WorkoutProgramInitial()) {
    on<LoadUserPrograms>(_onLoadUserPrograms);
    on<LoadProgramDetails>(_onLoadProgramDetails);
    on<LoadProgramDays>(_onLoadProgramDays);
    on<UpdateProgramProgress>(_onUpdateProgramProgress);
    on<CompleteProgramDay>(_onCompleteProgramDay);
    on<DeleteUserProgram>(_onDeleteUserProgram);
    on<LoadCurrentWorkoutInfo>(_onLoadCurrentWorkoutInfo);
  }

  @override
  void handleCommunicationEvent(BlocCommunicationEvent event) {
    if (event is WorkoutSessionCompletedEvent) {
      _handleWorkoutSessionCompleted(event);
    } else if (event is WorkoutProgramDataSyncRequestedEvent) {
      _handleDataSyncRequest(event);
    }
  }

  /// 리포지토리 인스턴스를 안전하게 가져옴
  /// null인 경우 초기화를 시도하고, 실패하면 null 반환
  WorkoutProgramRepository? _ensureRepositoryInitialized() {
    // 생성자에서 주입된 리포지토리가 있으면 사용
    if (_workoutProgramRepository != null) {
      return _workoutProgramRepository;
    }

    // 없으면 리포지토리 매니저를 통해 가져오기 시도
    return WorkoutProgramRepositoryManager.getInstance();
  }

  /// 리포지토리 초기화 실패 시 에러 상태 방출
  void _emitRepositoryNotInitializedError(Emitter<WorkoutProgramState> emit) {
    final failure = WorkoutProgramRepositoryManager.createInitializationFailure();
    emit(WorkoutProgramErrorState(
      failure: WorkoutProgramError(
        failure.userMessage,
        code: BlocErrorCodes.repositoryNotInitialized,
      ),
    ));
  }

  /// Handle workout session completion by updating program progress
  void _handleWorkoutSessionCompleted(WorkoutSessionCompletedEvent event) {
    if (event.userProgramId != null) {
      // Auto-advance program progress when a workout session is completed
      // This ensures the program stays in sync with actual workout completion
      try {
        // We need to get the current program state to determine next week/day
        // For now, we'll emit a refresh event to reload the program data
        // In a more sophisticated implementation, we could track the current state
        // and automatically advance to the next day/week
        
        // Emit a communication event to request program data refresh
        emitCommunicationEvent(DailySummaryRefreshRequestedEvent(
          userId: event.userId,
          date: event.date,
          reason: RefreshReason.workoutCompleted,
        ));
      } catch (e) {
        // Log error but don't fail the communication handling
        // Communication events should be resilient to failures
      }
    }
  }

  /// Handle data synchronization request from other BLoCs
  void _handleDataSyncRequest(WorkoutProgramDataSyncRequestedEvent event) {
    try {
      // Log the sync request for debugging
      print('🔍 WorkoutProgramBloc: 데이터 동기화 요청 수신 - ${event.reason}');
      
      // For now, we acknowledge the sync request
      // In a more sophisticated implementation, you could:
      // 1. Refresh current program data
      // 2. Validate data consistency
      // 3. Emit updated program state
      // 4. Notify other BLoCs of sync completion
      
      // Emit a communication event to acknowledge sync completion
      emitCommunicationEvent(DailySummaryRefreshRequestedEvent(
        userId: 'system', // System-level refresh
        date: DateTime.now(),
        reason: RefreshReason.manualRefresh,
      ));
      
    } catch (e) {
      // Log error but don't fail the communication handling
      print('🔍 WorkoutProgramBloc: 데이터 동기화 처리 실패 - $e');
    }
  }

  Future<void> _onLoadUserPrograms(
    LoadUserPrograms event,
    Emitter<WorkoutProgramState> emit,
  ) async {
    // Validate input parameters
    if (event.userId.isEmpty) {
      emit(WorkoutProgramErrorState(
        failure: WorkoutProgramError(
          'User ID cannot be empty',
          code: BlocErrorCodes.validationError,
        ),
      ));
      return;
    }

    // Ensure repository is initialized
    final repository = _ensureRepositoryInitialized();
    if (repository == null) {
      _emitRepositoryNotInitializedError(emit);
      return;
    }

    emit(const WorkoutProgramLoading(message: 'Loading user programs...'));

    try {
      final result = await repository.getUserPrograms(event.userId);

      result.fold(
        (failure) {
          final workoutProgramError = _convertFailureToBlocError(failure);
          _handleRetryableError(
            emit,
            workoutProgramError,
            () => add(LoadUserPrograms(userId: event.userId)),
          );
        },
        (userPrograms) {
          emit(UserProgramsLoaded(userPrograms: userPrograms));
        },
      );
    } catch (e) {
      // Handle unexpected errors
      emit(WorkoutProgramErrorState(
        failure: WorkoutProgramError(
          'Unexpected error occurred while loading user programs: ${e.toString()}',
          code: BlocErrorCodes.unknown,
        ),
      ));
    }
  }

  Future<void> _onLoadProgramDetails(
    LoadProgramDetails event,
    Emitter<WorkoutProgramState> emit,
  ) async {
    // Validate input parameters
    if (event.userProgramId.isEmpty) {
      emit(WorkoutProgramErrorState(
        failure: WorkoutProgramError(
          'User program ID cannot be empty',
          code: BlocErrorCodes.validationError,
        ),
      ));
      return;
    }

    // Ensure repository is initialized
    final repository = _ensureRepositoryInitialized();
    if (repository == null) {
      _emitRepositoryNotInitializedError(emit);
      return;
    }

    emit(const WorkoutProgramLoading(message: 'Loading program details...'));

    try {
      final result = await repository.getUserProgramDetails(event.userProgramId);

      result.fold(
        (failure) {
          final workoutProgramError = _convertFailureToBlocError(failure);
          _handleRetryableError(
            emit,
            workoutProgramError,
            () => add(LoadProgramDetails(userProgramId: event.userProgramId)),
          );
        },
        (userProgram) {
          if (userProgram != null) {
            emit(ProgramDetailsLoaded(userProgram: userProgram));
          } else {
            emit(WorkoutProgramErrorState.nonRetryable(
              failure: WorkoutProgramError(
                '운동 프로그램을 찾을 수 없습니다.',
                code: BlocErrorCodes.dataNotFound,
              ),
              recoverySuggestion: '프로그램 목록을 새로고침하고 다시 시도해주세요.',
            ));
          }
        },
      );
    } catch (e) {
      // Handle unexpected errors
      emit(WorkoutProgramErrorState(
        failure: WorkoutProgramError(
          'Unexpected error occurred while loading program details: ${e.toString()}',
          code: BlocErrorCodes.unknown,
        ),
      ));
    }
  }

  Future<void> _onLoadProgramDays(
    LoadProgramDays event,
    Emitter<WorkoutProgramState> emit,
  ) async {
    // Validate input parameters
    if (event.userProgramId.isEmpty) {
      emit(WorkoutProgramErrorState(
        failure: WorkoutProgramError(
          'User program ID cannot be empty',
          code: BlocErrorCodes.validationError,
        ),
      ));
      return;
    }

    // Ensure repository is initialized
    final repository = _ensureRepositoryInitialized();
    if (repository == null) {
      _emitRepositoryNotInitializedError(emit);
      return;
    }

    emit(const WorkoutProgramLoading(message: 'Loading program days...'));

    try {
      final result = await repository.getUserProgramDays(event.userProgramId);

      result.fold(
        (failure) {
          final workoutProgramError = _convertFailureToBlocError(failure);
          _handleRetryableError(
            emit,
            workoutProgramError,
            () => add(LoadProgramDays(userProgramId: event.userProgramId)),
          );
        },
        (programDays) {
          emit(ProgramDaysLoaded(
            programDays: programDays,
            userProgramId: event.userProgramId,
          ));
        },
      );
    } catch (e) {
      // Handle unexpected errors
      emit(WorkoutProgramErrorState(
        failure: WorkoutProgramError(
          'Unexpected error occurred while loading program days: ${e.toString()}',
          code: BlocErrorCodes.unknown,
        ),
      ));
    }
  }

  Future<void> _onUpdateProgramProgress(
    UpdateProgramProgress event,
    Emitter<WorkoutProgramState> emit,
  ) async {
    // Validate input parameters
    if (event.userProgramId.isEmpty) {
      emit(WorkoutProgramErrorState(
        failure: WorkoutProgramError(
          'User program ID cannot be empty',
          code: BlocErrorCodes.validationError,
        ),
      ));
      return;
    }

    if (event.currentWeek < 1 || event.currentDay < 1) {
      emit(WorkoutProgramErrorState(
        failure: WorkoutProgramError(
          'Week and day must be positive numbers',
          code: BlocErrorCodes.validationError,
        ),
      ));
      return;
    }

    // Ensure repository is initialized
    final repository = _ensureRepositoryInitialized();
    if (repository == null) {
      _emitRepositoryNotInitializedError(emit);
      return;
    }

    emit(const WorkoutProgramLoading(message: 'Updating program progress...'));

    try {
      final result = await repository.updateUserProgramProgress(
        event.userProgramId,
        event.currentWeek,
        event.currentDay,
      );

      result.fold(
        (failure) {
          final workoutProgramError = _convertFailureToBlocError(failure);
          _handleRetryableError(
            emit,
            workoutProgramError,
            () => add(UpdateProgramProgress(
              userProgramId: event.userProgramId,
              currentWeek: event.currentWeek,
              currentDay: event.currentDay,
            )),
          );
        },
        (_) {
          emit(ProgramProgressUpdated(
            userProgramId: event.userProgramId,
            currentWeek: event.currentWeek,
            currentDay: event.currentDay,
          ));

          // Emit communication event for other BLOCs
          emitCommunicationEvent(WorkoutProgramProgressUpdatedEvent(
            userProgramId: event.userProgramId,
            currentWeek: event.currentWeek,
            currentDay: event.currentDay,
          ));
        },
      );
    } catch (e) {
      // Handle unexpected errors
      emit(WorkoutProgramErrorState(
        failure: WorkoutProgramError(
          'Unexpected error occurred while updating program progress: ${e.toString()}',
          code: BlocErrorCodes.workoutProgramUpdateFailed,
        ),
      ));
    }
  }

  Future<void> _onCompleteProgramDay(
    CompleteProgramDay event,
    Emitter<WorkoutProgramState> emit,
  ) async {
    // Validate input parameters
    if (event.userProgramId.isEmpty) {
      emit(WorkoutProgramErrorState(
        failure: WorkoutProgramError(
          'User program ID cannot be empty',
          code: BlocErrorCodes.validationError,
        ),
      ));
      return;
    }

    if (event.week < 1 || event.day < 1) {
      emit(WorkoutProgramErrorState(
        failure: WorkoutProgramError(
          'Week and day must be positive numbers',
          code: BlocErrorCodes.validationError,
        ),
      ));
      return;
    }

    // Ensure repository is initialized
    final repository = _ensureRepositoryInitialized();
    if (repository == null) {
      _emitRepositoryNotInitializedError(emit);
      return;
    }

    emit(const WorkoutProgramLoading(message: 'Completing program day...'));

    try {
      final result = await repository.completeUserProgramDay(
        event.userProgramId,
        event.week,
        event.day,
        note: event.note,
      );

      result.fold(
        (failure) {
          final workoutProgramError = _convertFailureToBlocError(failure);
          emit(WorkoutProgramErrorState(failure: workoutProgramError));
        },
        (_) {
          emit(ProgramDayCompleted(
            userProgramId: event.userProgramId,
            week: event.week,
            day: event.day,
            note: event.note,
          ));

          // Emit communication event for other BLOCs
          emitCommunicationEvent(WorkoutProgramDayCompletedEvent(
            userProgramId: event.userProgramId,
            week: event.week,
            day: event.day,
            completedAt: DateTime.now(),
          ));
        },
      );
    } catch (e) {
      // Handle unexpected errors
      emit(WorkoutProgramErrorState(
        failure: WorkoutProgramError(
          'Unexpected error occurred while completing program day: ${e.toString()}',
          code: BlocErrorCodes.workoutProgramUpdateFailed,
        ),
      ));
    }
  }

  Future<void> _onDeleteUserProgram(
    DeleteUserProgram event,
    Emitter<WorkoutProgramState> emit,
  ) async {
    // Validate input parameters
    if (event.userProgramId.isEmpty) {
      emit(WorkoutProgramErrorState(
        failure: WorkoutProgramError(
          'User program ID cannot be empty',
          code: BlocErrorCodes.validationError,
        ),
      ));
      return;
    }

    if (event.userId.isEmpty) {
      emit(WorkoutProgramErrorState(
        failure: WorkoutProgramError(
          'User ID cannot be empty',
          code: BlocErrorCodes.validationError,
        ),
      ));
      return;
    }

    // Ensure repository is initialized
    final repository = _ensureRepositoryInitialized();
    if (repository == null) {
      _emitRepositoryNotInitializedError(emit);
      return;
    }

    emit(const WorkoutProgramLoading(message: 'Deleting user program...'));

    try {
      final result = await repository.deleteUserProgram(event.userProgramId);

      result.fold(
        (failure) {
          final workoutProgramError = _convertFailureToBlocError(failure);
          emit(WorkoutProgramErrorState(failure: workoutProgramError));
        },
        (_) {
          emit(UserProgramDeleted(userProgramId: event.userProgramId));

          // Emit communication event for other BLOCs
          emitCommunicationEvent(WorkoutProgramDeletedEvent(
            userProgramId: event.userProgramId,
            userId: event.userId,
          ));
        },
      );
    } catch (e) {
      // Handle unexpected errors
      emit(WorkoutProgramErrorState(
        failure: WorkoutProgramError(
          'Unexpected error occurred while deleting user program: ${e.toString()}',
          code: BlocErrorCodes.workoutProgramDeleteFailed,
        ),
      ));
    }
  }

  Future<void> _onLoadCurrentWorkoutInfo(
    LoadCurrentWorkoutInfo event,
    Emitter<WorkoutProgramState> emit,
  ) async {
    // Validate input parameters
    if (event.userId.isEmpty) {
      emit(WorkoutProgramErrorState(
        failure: WorkoutProgramError(
          'User ID cannot be empty',
          code: BlocErrorCodes.validationError,
        ),
      ));
      return;
    }

    // Ensure repository is initialized
    final repository = _ensureRepositoryInitialized();
    if (repository == null) {
      _emitRepositoryNotInitializedError(emit);
      return;
    }

    emit(const WorkoutProgramLoading(message: 'Loading current workout info...'));

    try {
      final result = await repository.getCurrentWorkoutInfo(event.userId);

      result.fold(
        (failure) {
          final workoutProgramError = _convertFailureToBlocError(failure);
          emit(WorkoutProgramErrorState(failure: workoutProgramError));
        },
        (currentWorkoutInfo) {
          emit(CurrentWorkoutInfoLoaded(currentWorkoutInfo: currentWorkoutInfo));
        },
      );
    } catch (e) {
      // Handle unexpected errors
      emit(WorkoutProgramErrorState(
        failure: WorkoutProgramError(
          'Unexpected error occurred while loading current workout info: ${e.toString()}',
          code: BlocErrorCodes.unknown,
        ),
      ));
    }
  }

  /// Convert generic Failure to WorkoutProgramError for consistent error handling
  /// Enhanced to handle new workout program failure types with Korean messages
  WorkoutProgramError _convertFailureToBlocError(dynamic failure) {
    if (failure is WorkoutProgramError) {
      return failure;
    }
    
    // Handle specific WorkoutProgramFailure types
    if (failure is WorkoutProgramFailure) {
      return WorkoutProgramError(
        failure.userMessage,
        code: failure.errorCode ?? _mapFailureTypeToCode(failure.type),
        details: failure.details,
      );
    }
    
    // Handle generic failures
    String code = BlocErrorCodes.unknown;
    String userMessage = '알 수 없는 오류가 발생했습니다.';
    final technicalMessage = failure.toString();
    
    // Map technical messages to user-friendly Korean messages
    if (technicalMessage.contains('network') || technicalMessage.contains('connection')) {
      code = BlocErrorCodes.networkError;
      userMessage = '네트워크 연결을 확인해주세요.';
    } else if (technicalMessage.contains('server') || technicalMessage.contains('http')) {
      code = BlocErrorCodes.serverError;
      userMessage = '서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요.';
    } else if (technicalMessage.contains('validation')) {
      code = BlocErrorCodes.validationError;
      userMessage = '입력한 정보를 다시 확인해주세요.';
    } else if (technicalMessage.contains('not found')) {
      code = BlocErrorCodes.dataNotFound;
      userMessage = '요청한 데이터를 찾을 수 없습니다.';
    } else if (technicalMessage.contains('duplicate')) {
      code = BlocErrorCodes.programDuplicate;
      userMessage = '이미 저장된 프로그램입니다.';
    } else if (technicalMessage.contains('parsing') || technicalMessage.contains('format')) {
      code = BlocErrorCodes.dataParsingError;
      userMessage = '데이터를 불러오는 중 오류가 발생했습니다.';
    } else if (technicalMessage.contains('permission') || technicalMessage.contains('unauthorized')) {
      code = BlocErrorCodes.permissionDenied;
      userMessage = '해당 작업을 수행할 권한이 없습니다.';
    } else if (technicalMessage.contains('timeout')) {
      code = BlocErrorCodes.connectionTimeout;
      userMessage = '연결 시간이 초과되었습니다. 다시 시도해주세요.';
    }
    
    return WorkoutProgramError(
      userMessage,
      code: code,
      details: {'technicalMessage': technicalMessage},
    );
  }

  /// Map WorkoutProgramErrorType to BLoC error codes
  String _mapFailureTypeToCode(WorkoutProgramErrorType type) {
    switch (type) {
      case WorkoutProgramErrorType.duplicate:
        return BlocErrorCodes.programDuplicate;
      case WorkoutProgramErrorType.repositoryNotInitialized:
        return BlocErrorCodes.repositoryNotInitialized;
      case WorkoutProgramErrorType.dataParsingError:
        return BlocErrorCodes.dataParsingError;
      case WorkoutProgramErrorType.networkError:
        return BlocErrorCodes.networkError;
      case WorkoutProgramErrorType.serverError:
        return BlocErrorCodes.serverError;
      case WorkoutProgramErrorType.permissionDenied:
        return BlocErrorCodes.permissionDenied;
      case WorkoutProgramErrorType.programNotFound:
        return BlocErrorCodes.programNotFound;
      case WorkoutProgramErrorType.exerciseDataEmpty:
        return BlocErrorCodes.exerciseDataEmpty;
      case WorkoutProgramErrorType.validationError:
        return BlocErrorCodes.validationError;
      case WorkoutProgramErrorType.unknown:
      default:
        return BlocErrorCodes.unknown;
    }
  }

  /// Check if an error is retryable and emit appropriate state
  void _handleRetryableError(
    Emitter<WorkoutProgramState> emit,
    WorkoutProgramError error,
    VoidCallback retryAction,
  ) {
    final isRetryable = _isErrorRetryable(error.code);
    
    emit(WorkoutProgramErrorState(
      failure: error,
      isRetryable: isRetryable,
      retryAction: isRetryable ? retryAction : null,
    ));
  }

  /// Determine if an error is retryable based on error code
  bool _isErrorRetryable(String? errorCode) {
    switch (errorCode) {
      case BlocErrorCodes.networkError:
      case BlocErrorCodes.serverError:
      case BlocErrorCodes.connectionTimeout:
      case BlocErrorCodes.repositoryNotInitialized:
      case BlocErrorCodes.dataParsingError:
      case BlocErrorCodes.operationFailed:
        return true;
      case BlocErrorCodes.programDuplicate:
      case BlocErrorCodes.validationError:
      case BlocErrorCodes.permissionDenied:
      case BlocErrorCodes.authenticationRequired:
      case BlocErrorCodes.programAlreadyCompleted:
        return false;
      default:
        return true; // Default to retryable for unknown errors
    }
  }
}