import 'package:equatable/equatable.dart';
import '../../domain/entities/workout_program.dart';

abstract class ProgramsState extends Equatable {
  const ProgramsState();

  @override
  List<Object?> get props => [];
}

class ProgramsInitial extends ProgramsState {}

class ProgramsLoading extends ProgramsState {}

class ProgramsLoaded extends ProgramsState {
  final List<WorkoutProgram> popularPrograms;
  final List<WorkoutProgram> programs;
  final List<WorkoutProgram> userPrograms;
  final List<WorkoutProgram> searchResults;
  final bool isSearching;
  final String? searchQuery;

  const ProgramsLoaded({
    this.popularPrograms = const [],
    this.programs = const [],
    this.userPrograms = const [],
    this.searchResults = const [],
    this.isSearching = false,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [
        popularPrograms,
        programs,
        userPrograms,
        searchResults,
        isSearching,
        searchQuery,
      ];

  ProgramsLoaded copyWith({
    List<WorkoutProgram>? popularPrograms,
    List<WorkoutProgram>? programs,
    List<WorkoutProgram>? userPrograms,
    List<WorkoutProgram>? searchResults,
    bool? isSearching,
    String? searchQuery,
  }) {
    return ProgramsLoaded(
      popularPrograms: popularPrograms ?? this.popularPrograms,
      programs: programs ?? this.programs,
      userPrograms: userPrograms ?? this.userPrograms,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class ProgramsError extends ProgramsState {
  final String message;

  const ProgramsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProgramDetailLoading extends ProgramsState {}

class ProgramDetailLoaded extends ProgramsState {
  final WorkoutProgram program;

  const ProgramDetailLoaded(this.program);

  @override
  List<Object?> get props => [program];
}

class ProgramDetailError extends ProgramsState {
  final String message;

  const ProgramDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProgramAddedToUser extends ProgramsState {
  final String message;

  const ProgramAddedToUser(this.message);

  @override
  List<Object?> get props => [message];
}

class ProgramAddError extends ProgramsState {
  final String message;

  const ProgramAddError(this.message);

  @override
  List<Object?> get props => [message];
} 