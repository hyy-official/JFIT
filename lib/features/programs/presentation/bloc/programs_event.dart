import 'package:equatable/equatable.dart';

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