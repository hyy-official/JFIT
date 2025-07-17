import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/bloc_errors.dart';
import '../../../../core/error/workout_program_failures.dart';
import '../../domain/repositories/program_repository.dart';
import 'programs_event.dart';
import 'programs_state.dart';

class ProgramsBloc extends Bloc<ProgramsEvent, ProgramsState> {
  final ProgramRepository _repository;

  ProgramsBloc({required ProgramRepository repository})
      : _repository = repository,
        super(ProgramsInitial()) {
    on<LoadPopularPrograms>(_onLoadPopularPrograms);
    on<LoadPrograms>(_onLoadPrograms);
    on<LoadProgramById>(_onLoadProgramById);
    on<AddProgramToUser>(_onAddProgramToUser);
    on<SaveAsMyRoutine>(_onSaveAsMyRoutine);
    on<LoadUserPrograms>(_onLoadUserPrograms);
    on<SearchPrograms>(_onSearchPrograms);
    on<RefreshPrograms>(_onRefreshPrograms);
    on<ClearSearch>(_onClearSearch);
    on<LoadUserProgramDays>(_onLoadUserProgramDays);
    on<LoadWorkoutSessionsByUserProgram>(_onLoadWorkoutSessionsByUserProgram);
    on<LoadWorkoutLogsBySession>(_onLoadWorkoutLogsBySession);
    on<LoadExerciseById>(_onLoadExerciseById);
    on<CheckProgramDuplicate>(_onCheckProgramDuplicate);
    on<RestartProgram>(_onRestartProgram);
    on<ContinueProgram>(_onContinueProgram);
    on<ResolveDuplicateProgram>(_onResolveDuplicateProgram);
    on<CancelDuplicateResolution>(_onCancelDuplicateResolution);
  }

  Future<void> _onLoadPopularPrograms(
    LoadPopularPrograms event,
    Emitter<ProgramsState> emit,
  ) async {
    if (state is! ProgramsLoaded) {
      emit(ProgramsLoading());
    }

    final result = await _repository.getPopularPrograms();
    
    result.fold(
      (failure) => _handleProgramsError(
        emit,
        failure,
        () => add(LoadPopularPrograms()),
      ),
      (popularPrograms) {
        if (state is ProgramsLoaded) {
          emit((state as ProgramsLoaded).copyWith(
            popularPrograms: popularPrograms,
          ));
        } else {
          emit(ProgramsLoaded(popularPrograms: popularPrograms));
        }
      },
    );
  }

  Future<void> _onLoadPrograms(
    LoadPrograms event,
    Emitter<ProgramsState> emit,
  ) async {
    if (state is! ProgramsLoaded) {
      emit(ProgramsLoading());
    }

    final result = await _repository.getPrograms(
      searchQuery: event.searchQuery,
      difficultyLevel: event.difficultyLevel,
      programType: event.programType,
      workoutsPerWeek: event.workoutsPerWeek,
      tags: event.tags,
    );
    
    result.fold(
      (failure) => _handleProgramsError(
        emit,
        failure,
        () => add(LoadPrograms(
          searchQuery: event.searchQuery,
          difficultyLevel: event.difficultyLevel,
          programType: event.programType,
          workoutsPerWeek: event.workoutsPerWeek,
          tags: event.tags,
        )),
      ),
      (programs) {
        if (state is ProgramsLoaded) {
          emit((state as ProgramsLoaded).copyWith(
            programs: programs,
          ));
        } else {
          emit(ProgramsLoaded(programs: programs));
        }
      },
    );
  }

  Future<void> _onLoadProgramById(
    LoadProgramById event,
    Emitter<ProgramsState> emit,
  ) async {
    emit(ProgramDetailLoading());

    final result = await _repository.getProgramById(event.id);
    
    result.fold(
      (failure) => emit(ProgramDetailError(_getKoreanErrorMessage(failure))),
      (program) => emit(ProgramDetailLoaded(program)),
    );
  }

  Future<void> _onAddProgramToUser(
    AddProgramToUser event,
    Emitter<ProgramsState> emit,
  ) async {
    final result = await _repository.addProgramToUser(event.programId);
    
    result.fold(
      (failure) => emit(ProgramAddError(_getKoreanErrorMessage(failure))),
      (_) => emit(const ProgramAddedToUser('프로그램이 내 루틴에 추가되었습니다!')),
    );
  }

  Future<void> _onSaveAsMyRoutine(
    SaveAsMyRoutine event,
    Emitter<ProgramsState> emit,
  ) async {
    final result = await _repository.saveAsMyRoutine(event.templateProgramId);
    
    result.fold(
      (failure) {
        // 중복 프로그램 실패인 경우 특별 처리
        if (failure is ProgramDuplicateFailure) {
          emit(RoutineDuplicateFound(failure.duplicateInfo));
        } else {
          emit(RoutineSaveError(_getKoreanErrorMessage(failure)));
        }
      },
      (duplicateCheckResult) {
        // 중복이 없는 경우 성공 메시지 표시
        if (!duplicateCheckResult.isDuplicate) {
          emit(const RoutineSaved('프로그램이 내 루틴으로 저장되었습니다!'));
        } else {
          // 이 경우는 발생하지 않아야 하지만 안전장치
          emit(RoutineDuplicateFound(duplicateCheckResult.duplicateInfo!));
        }
      },
    );
  }

  Future<void> _onLoadUserPrograms(
    LoadUserPrograms event,
    Emitter<ProgramsState> emit,
  ) async {
    if (state is! ProgramsLoaded) {
      emit(ProgramsLoading());
    }

    final result = await _repository.getUserPrograms();
    
    result.fold(
      (failure) => _handleProgramsError(
        emit,
        failure,
        () => add(LoadUserPrograms()),
      ),
      (userPrograms) {
        if (state is ProgramsLoaded) {
          emit((state as ProgramsLoaded).copyWith(
            userPrograms: userPrograms,
          ));
        } else {
          emit(ProgramsLoaded(userPrograms: userPrograms));
        }
      },
    );
  }

  Future<void> _onSearchPrograms(
    SearchPrograms event,
    Emitter<ProgramsState> emit,
  ) async {
    if (state is ProgramsLoaded) {
      emit((state as ProgramsLoaded).copyWith(
        isSearching: true,
        searchQuery: event.query,
      ));
    } else {
      emit(const ProgramsLoaded(isSearching: true));
    }

    final result = await _repository.searchPrograms(event.query);
    
    result.fold(
      (failure) => _handleProgramsError(
        emit,
        failure,
        () => add(SearchPrograms(event.query)),
      ),
      (searchResults) {
        if (state is ProgramsLoaded) {
          emit((state as ProgramsLoaded).copyWith(
            searchResults: searchResults,
            isSearching: false,
          ));
        } else {
          emit(ProgramsLoaded(
            searchResults: searchResults,
            isSearching: false,
            searchQuery: event.query,
          ));
        }
      },
    );
  }

  Future<void> _onRefreshPrograms(
    RefreshPrograms event,
    Emitter<ProgramsState> emit,
  ) async {
    emit(ProgramsLoading());
    
    // 인기 프로그램과 일반 프로그램 모두 새로고침
    final popularResult = await _repository.getPopularPrograms();
    final programsResult = await _repository.getPrograms();
    
    if (popularResult.isRight() && programsResult.isRight()) {
      emit(ProgramsLoaded(
        popularPrograms: popularResult.getOrElse(() => []),
        programs: programsResult.getOrElse(() => []),
      ));
    } else {
      emit(const ProgramsError('프로그램을 새로고침하는 중 오류가 발생했습니다.'));
    }
  }

  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<ProgramsState> emit,
  ) async {
    if (state is ProgramsLoaded) {
      emit((state as ProgramsLoaded).copyWith(
        searchResults: [],
        isSearching: false,
        searchQuery: null,
      ));
    }
  }

  Future<void> _onLoadUserProgramDays(
    LoadUserProgramDays event,
    Emitter<ProgramsState> emit,
  ) async {
    // 기존 ProgramDetailData 상태가 있으면 로딩 상태로 업데이트
    if (state is ProgramDetailData) {
      emit((state as ProgramDetailData).copyWith(isLoading: true));
    } else {
      emit(const ProgramDetailData(isLoading: true));
    }
    
    final result = await _repository.getUserProgramDays(event.userProgramId);
    result.fold(
      (failure) {
        if (state is ProgramDetailData) {
          emit((state as ProgramDetailData).copyWith(
            isLoading: false,
            error: failure.message,
          ));
        } else {
          emit(ProgramDetailData(
            isLoading: false,
            error: failure.message,
          ));
        }
      },
      (days) {
        if (state is ProgramDetailData) {
          emit((state as ProgramDetailData).copyWith(
            days: days,
            isLoading: false,
            error: null,
          ));
        } else {
          emit(ProgramDetailData(
            days: days,
            isLoading: false,
          ));
        }
      },
    );
  }

  Future<void> _onLoadWorkoutSessionsByUserProgram(
    LoadWorkoutSessionsByUserProgram event,
    Emitter<ProgramsState> emit,
  ) async {
    // 기존 ProgramDetailData 상태가 있으면 로딩 상태로 업데이트
    if (state is ProgramDetailData) {
      emit((state as ProgramDetailData).copyWith(isLoading: true));
    } else {
      emit(const ProgramDetailData(isLoading: true));
    }
    
    final result = await _repository.getWorkoutSessionsByUserProgram(event.userProgramId);
    result.fold(
      (failure) {
        if (state is ProgramDetailData) {
          emit((state as ProgramDetailData).copyWith(
            isLoading: false,
            error: failure.message,
          ));
        } else {
          emit(ProgramDetailData(
            isLoading: false,
            error: failure.message,
          ));
        }
      },
      (sessions) {
        if (state is ProgramDetailData) {
          emit((state as ProgramDetailData).copyWith(
            sessions: sessions,
            isLoading: false,
            error: null,
          ));
        } else {
          emit(ProgramDetailData(
            sessions: sessions,
            isLoading: false,
          ));
        }
      },
    );
  }

  Future<void> _onLoadWorkoutLogsBySession(
    LoadWorkoutLogsBySession event,
    Emitter<ProgramsState> emit,
  ) async {
    if (state is ProgramDetailData) {
      emit((state as ProgramDetailData).copyWith(isLoading: true));
    } else {
      emit(const ProgramDetailData(isLoading: true));
    }
    
    final result = await _repository.getWorkoutLogsBySession(event.sessionId);
    result.fold(
      (failure) {
        if (state is ProgramDetailData) {
          emit((state as ProgramDetailData).copyWith(
            isLoading: false,
            error: failure.message,
          ));
        } else {
          emit(ProgramDetailData(
            isLoading: false,
            error: failure.message,
          ));
        }
      },
      (logs) {
        if (state is ProgramDetailData) {
          emit((state as ProgramDetailData).copyWith(
            logs: logs,
            isLoading: false,
            error: null,
          ));
        } else {
          emit(ProgramDetailData(
            logs: logs,
            isLoading: false,
          ));
        }
      },
    );
  }

  Future<void> _onLoadExerciseById(
    LoadExerciseById event,
    Emitter<ProgramsState> emit,
  ) async {
    emit(ExerciseLoading());
    final result = await _repository.getExerciseById(event.exerciseId);
    result.fold(
      (failure) => emit(ProgramsError(_getKoreanErrorMessage(failure))),
      (exercise) => emit(ExerciseLoaded(exercise)),
    );
  }

  Future<void> _onCheckProgramDuplicate(
    CheckProgramDuplicate event,
    Emitter<ProgramsState> emit,
  ) async {
    final result = await _repository.checkProgramDuplicate(event.programId);
    
    result.fold(
      (failure) => emit(ProgramAddError(_getKoreanErrorMessage(failure))),
      (duplicateInfo) {
        if (duplicateInfo == null) {
          // 중복 없음, 바로 추가
          add(AddProgramToUser(event.programId));
        } else {
          // 중복 발견, 팝업 표시
          emit(ProgramDuplicateFound(
            programId: event.programId,
            programName: duplicateInfo['programName'] as String,
            currentWeek: duplicateInfo['currentWeek'] as int,
            currentDay: duplicateInfo['currentDay'] as int,
            totalWeeks: duplicateInfo['totalWeeks'] as int,
            progressPercent: duplicateInfo['progressPercent'] as double,
            isCompleted: duplicateInfo['isCompleted'] as bool,
          ));
        }
      },
    );
  }

  Future<void> _onRestartProgram(
    RestartProgram event,
    Emitter<ProgramsState> emit,
  ) async {
    final result = await _repository.restartProgram(event.programId);
    
    result.fold(
      (failure) => emit(ProgramAddError(_getKoreanErrorMessage(failure))),
      (_) => emit(const ProgramRestarted('프로그램을 처음부터 다시 시작합니다!')),
    );
  }

  Future<void> _onContinueProgram(
    ContinueProgram event,
    Emitter<ProgramsState> emit,
  ) async {
    final result = await _repository.continueProgram(event.programId);
    
    result.fold(
      (failure) => emit(ProgramAddError(_getKoreanErrorMessage(failure))),
      (_) => emit(const ProgramContinued('프로그램을 이어서 진행합니다!')),
    );
  }

  Future<void> _onResolveDuplicateProgram(
    ResolveDuplicateProgram event,
    Emitter<ProgramsState> emit,
  ) async {
    switch (event.option) {
      case ResolutionOption.continueExisting:
        // 기존 프로그램 계속하기
        final result = await _repository.continueProgram(event.templateProgramId);
        result.fold(
          (failure) => emit(RoutineSaveError(_getKoreanErrorMessage(failure))),
          (_) => emit(const RoutineSaved('기존 프로그램을 계속 진행합니다!')),
        );
        break;
        
      case ResolutionOption.restartProgram:
        // 프로그램 다시 시작하기
        final result = await _repository.restartProgram(event.templateProgramId);
        result.fold(
          (failure) => emit(RoutineSaveError(_getKoreanErrorMessage(failure))),
          (_) => emit(const RoutineSaved('프로그램을 처음부터 다시 시작합니다!')),
        );
        break;
        
      case ResolutionOption.createNewInstance:
        // 새로운 인스턴스 생성 - 기존 프로그램을 비활성화하고 새로 저장
        // 먼저 기존 프로그램을 비활성화
        await _repository.continueProgram(event.templateProgramId); // 임시로 활성화
        
        // 그 다음 새로운 프로그램으로 저장 시도
        final saveResult = await _repository.saveAsMyRoutine(event.templateProgramId);
        saveResult.fold(
          (failure) => emit(RoutineSaveError(_getKoreanErrorMessage(failure))),
          (duplicateCheckResult) {
            if (!duplicateCheckResult.isDuplicate) {
              emit(const RoutineSaved('새로운 프로그램으로 저장되었습니다!'));
            } else {
              emit(const RoutineSaveError('새로운 프로그램 생성에 실패했습니다.'));
            }
          },
        );
        break;
        
      case ResolutionOption.cancel:
        // 취소 - 아무것도 하지 않음
        emit(const RoutineSaveError('프로그램 저장이 취소되었습니다.'));
        break;
    }
  }

  Future<void> _onCancelDuplicateResolution(
    CancelDuplicateResolution event,
    Emitter<ProgramsState> emit,
  ) async {
    // 중복 해결 다이얼로그를 닫고 이전 상태로 돌아감
    if (state is ProgramsLoaded) {
      // 기존 상태 유지
      return;
    } else {
      emit(ProgramsInitial());
    }
  }

  /// Enhanced error handling for Programs BLoC
  /// Converts failures to user-friendly Korean messages and provides retry mechanisms
  void _handleProgramsError(
    Emitter<ProgramsState> emit,
    dynamic failure,
    VoidCallback? retryAction,
  ) {
    String userMessage;
    bool isRetryable = true;
    
    // Handle specific WorkoutProgramFailure types
    if (failure is WorkoutProgramFailure) {
      userMessage = failure.userMessage;
      isRetryable = _isFailureRetryable(failure.type);
    } else {
      // Handle generic failures with Korean messages
      final technicalMessage = failure.toString().toLowerCase();
      
      if (technicalMessage.contains('network') || technicalMessage.contains('connection')) {
        userMessage = '네트워크 연결을 확인해주세요.';
        isRetryable = true;
      } else if (technicalMessage.contains('server') || technicalMessage.contains('http')) {
        userMessage = '서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요.';
        isRetryable = true;
      } else if (technicalMessage.contains('timeout')) {
        userMessage = '연결 시간이 초과되었습니다. 다시 시도해주세요.';
        isRetryable = true;
      } else if (technicalMessage.contains('permission') || technicalMessage.contains('unauthorized')) {
        userMessage = '해당 작업을 수행할 권한이 없습니다.';
        isRetryable = false;
      } else if (technicalMessage.contains('not found')) {
        userMessage = '요청한 프로그램을 찾을 수 없습니다.';
        isRetryable = true;
      } else if (technicalMessage.contains('duplicate')) {
        userMessage = '이미 저장된 프로그램입니다.';
        isRetryable = false;
      } else {
        userMessage = '프로그램을 불러오는 중 오류가 발생했습니다.';
        isRetryable = true;
      }
    }

    // Emit enhanced error state
    if (isRetryable && retryAction != null) {
      emit(ProgramsErrorWithRetry(
        message: userMessage,
        retryAction: retryAction,
      ));
    } else {
      emit(ProgramsError(userMessage));
    }
  }

  /// Determine if a WorkoutProgramFailure is retryable
  bool _isFailureRetryable(WorkoutProgramErrorType type) {
    switch (type) {
      case WorkoutProgramErrorType.networkError:
      case WorkoutProgramErrorType.serverError:
      case WorkoutProgramErrorType.dataParsingError:
      case WorkoutProgramErrorType.repositoryNotInitialized:
      case WorkoutProgramErrorType.unknown:
        return true;
      case WorkoutProgramErrorType.duplicate:
      case WorkoutProgramErrorType.permissionDenied:
      case WorkoutProgramErrorType.validationError:
      case WorkoutProgramErrorType.programNotFound:
      case WorkoutProgramErrorType.exerciseDataEmpty:
        return false;
    }
  }

  /// Convert generic failure to user-friendly Korean message
  String _getKoreanErrorMessage(dynamic failure) {
    if (failure is WorkoutProgramFailure) {
      return failure.userMessage;
    }

    final message = failure.toString().toLowerCase();
    
    if (message.contains('network') || message.contains('connection')) {
      return '네트워크 연결을 확인해주세요.';
    } else if (message.contains('server') || message.contains('http')) {
      return '서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요.';
    } else if (message.contains('timeout')) {
      return '연결 시간이 초과되었습니다. 다시 시도해주세요.';
    } else if (message.contains('permission') || message.contains('unauthorized')) {
      return '해당 작업을 수행할 권한이 없습니다.';
    } else if (message.contains('not found')) {
      return '요청한 데이터를 찾을 수 없습니다.';
    } else if (message.contains('duplicate')) {
      return '이미 저장된 프로그램입니다.';
    } else if (message.contains('validation')) {
      return '입력한 정보를 다시 확인해주세요.';
    } else {
      return '오류가 발생했습니다. 다시 시도해주세요.';
    }
  }
} 