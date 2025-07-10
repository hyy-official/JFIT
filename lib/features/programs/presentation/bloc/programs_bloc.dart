import 'package:flutter_bloc/flutter_bloc.dart';
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
    on<LoadUserPrograms>(_onLoadUserPrograms);
    on<SearchPrograms>(_onSearchPrograms);
    on<RefreshPrograms>(_onRefreshPrograms);
    on<ClearSearch>(_onClearSearch);
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
} 