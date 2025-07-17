import 'package:equatable/equatable.dart';
import '../../../../core/error/workout_program_failures.dart';

abstract class ProgramsEvent extends Equatable {
  const ProgramsEvent();

  @override
  List<Object?> get props => [];
}

class LoadPopularPrograms extends ProgramsEvent {}

class LoadPrograms extends ProgramsEvent {
  final String? searchQuery;
  final String? difficultyLevel;
  final String? programType;
  final int? workoutsPerWeek;
  final List<String>? tags;

  const LoadPrograms({
    this.searchQuery,
    this.difficultyLevel,
    this.programType,
    this.workoutsPerWeek,
    this.tags,
  });

  @override
  List<Object?> get props => [
        searchQuery,
        difficultyLevel,
        programType,
        workoutsPerWeek,
        tags,
      ];
}

class LoadProgramById extends ProgramsEvent {
  final String id;

  const LoadProgramById(this.id);

  @override
  List<Object?> get props => [id];
}

class AddProgramToUser extends ProgramsEvent {
  final String programId;

  const AddProgramToUser(this.programId);

  @override
  List<Object?> get props => [programId];
}

class SaveAsMyRoutine extends ProgramsEvent {
  final String templateProgramId;

  const SaveAsMyRoutine(this.templateProgramId);

  @override
  List<Object?> get props => [templateProgramId];
}

class LoadUserPrograms extends ProgramsEvent {}

class SearchPrograms extends ProgramsEvent {
  final String query;

  const SearchPrograms(this.query);

  @override
  List<Object?> get props => [query];
}

class RefreshPrograms extends ProgramsEvent {}

class ClearSearch extends ProgramsEvent {} 

// Day별 상태/운동 루틴 관련 이벤트
class LoadUserProgramDays extends ProgramsEvent {
  final String userProgramId;
  const LoadUserProgramDays(this.userProgramId);
  @override
  List<Object?> get props => [userProgramId];
}

class LoadWorkoutSessionsByUserProgram extends ProgramsEvent {
  final String userProgramId;
  const LoadWorkoutSessionsByUserProgram(this.userProgramId);
  @override
  List<Object?> get props => [userProgramId];
}

class LoadWorkoutLogsBySession extends ProgramsEvent {
  final String sessionId;
  const LoadWorkoutLogsBySession(this.sessionId);
  @override
  List<Object?> get props => [sessionId];
}

class LoadExerciseById extends ProgramsEvent {
  final String exerciseId;
  const LoadExerciseById(this.exerciseId);
  @override
  List<Object?> get props => [exerciseId];
}

// 프로그램 중복 체크 및 관리 이벤트들
class CheckProgramDuplicate extends ProgramsEvent {
  final String programId;
  const CheckProgramDuplicate(this.programId);
  @override
  List<Object?> get props => [programId];
}

class RestartProgram extends ProgramsEvent {
  final String programId;
  const RestartProgram(this.programId);
  @override
  List<Object?> get props => [programId];
}

class ContinueProgram extends ProgramsEvent {
  final String programId;
  const ContinueProgram(this.programId);
  @override
  List<Object?> get props => [programId];
}

// 중복 해결 관련 이벤트들
class ResolveDuplicateProgram extends ProgramsEvent {
  final String templateProgramId;
  final String userProgramId;
  final ResolutionOption option;

  const ResolveDuplicateProgram({
    required this.templateProgramId,
    required this.userProgramId,
    required this.option,
  });

  @override
  List<Object?> get props => [templateProgramId, userProgramId, option];
}

class CancelDuplicateResolution extends ProgramsEvent {
  const CancelDuplicateResolution();
} 