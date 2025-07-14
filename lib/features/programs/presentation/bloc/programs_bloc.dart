import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/program_repository.dart';
import 'programs_event.dart';
import 'programs_state.dart';
import 'package:flutter/material.dart';

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
      (failure) => emit(ProgramsError(failure.message)),
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
      (failure) => emit(ProgramsError(failure.message)),
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
      (failure) => emit(ProgramDetailError(failure.message)),
      (program) => emit(ProgramDetailLoaded(program)),
    );
  }

  Future<void> _onAddProgramToUser(
    AddProgramToUser event,
    Emitter<ProgramsState> emit,
  ) async {
    final result = await _repository.addProgramToUser(event.programId);
    
    result.fold(
      (failure) => emit(ProgramAddError(failure.message)),
      (_) => emit(const ProgramAddedToUser('프로그램이 내 루틴에 추가되었습니다!')),
    );
  }

  Future<void> _onSaveAsMyRoutine(
    SaveAsMyRoutine event,
    Emitter<ProgramsState> emit,
  ) async {
    final result = await _repository.saveAsMyRoutine(event.templateProgramId);
    
    result.fold(
      (failure) => emit(RoutineSaveError(failure.message)),
      (_) => emit(const RoutineSaved('프로그램이 내 루틴으로 저장되었습니다!')),
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
      (failure) => emit(ProgramsError(failure.message)),
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
      (failure) => emit(ProgramsError(failure.message)),
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
      (failure) => emit(ExerciseError(failure.message)),
      (exercise) => emit(ExerciseLoaded(exercise)),
    );
  }

  Future<void> _onCheckProgramDuplicate(
    CheckProgramDuplicate event,
    Emitter<ProgramsState> emit,
  ) async {
    final result = await _repository.checkProgramDuplicate(event.programId);
    
    result.fold(
      (failure) => emit(ProgramAddError(failure.message)),
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
      (failure) => emit(ProgramAddError(failure.message)),
      (_) => emit(const ProgramRestarted('프로그램을 처음부터 다시 시작합니다!')),
    );
  }

  Future<void> _onContinueProgram(
    ContinueProgram event,
    Emitter<ProgramsState> emit,
  ) async {
    final result = await _repository.continueProgram(event.programId);
    
    result.fold(
      (failure) => emit(ProgramAddError(failure.message)),
      (_) => emit(const ProgramContinued('프로그램을 이어서 진행합니다!')),
    );
  }
} 