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