import 'package:jfit/core/bloc/base_bloc.dart';

/// Base class for all Exercise-related events
abstract class ExerciseEvent extends BaseEvent {
  const ExerciseEvent();
}

/// Event to search for exercises by query
class SearchExercises extends ExerciseEvent {
  final String query;
  final int? limit;
  final Map<String, dynamic>? filters;

  const SearchExercises({
    required this.query,
    this.limit,
    this.filters,
  });

  @override
  List<Object?> get props => [query, limit, filters];
}

/// Event to load detailed information for a specific exercise
class LoadExerciseDetails extends ExerciseEvent {
  final String exerciseId;

  const LoadExerciseDetails(this.exerciseId);

  @override
  List<Object?> get props => [exerciseId];
}

/// Event to load detailed information for multiple exercises
class LoadMultipleExerciseDetails extends ExerciseEvent {
  final List<String> exerciseIds;

  const LoadMultipleExerciseDetails(this.exerciseIds);

  @override
  List<Object?> get props => [exerciseIds];
}

/// Event to clear current search results
class ClearSearchResults extends ExerciseEvent {
  const ClearSearchResults();

  @override
  List<Object?> get props => [];
}

/// Event to load popular exercises
class LoadPopularExercises extends ExerciseEvent {
  final int? limit;

  const LoadPopularExercises({this.limit});

  @override
  List<Object?> get props => [limit];
}

/// Event to load exercises by category
class LoadExercisesByCategory extends ExerciseEvent {
  final String category;
  final int? limit;

  const LoadExercisesByCategory({
    required this.category,
    this.limit,
  });

  @override
  List<Object?> get props => [category, limit];
}

/// Event to load exercises by muscle group
class LoadExercisesByMuscleGroup extends ExerciseEvent {
  final String muscleGroup;
  final int? limit;

  const LoadExercisesByMuscleGroup({
    required this.muscleGroup,
    this.limit,
  });

  @override
  List<Object?> get props => [muscleGroup, limit];
}

/// Event to refresh exercise cache
class RefreshExerciseCache extends ExerciseEvent {
  const RefreshExerciseCache();

  @override
  List<Object?> get props => [];
}