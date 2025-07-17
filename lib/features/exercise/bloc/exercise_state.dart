import 'package:flutter/foundation.dart';
import 'package:jfit/core/bloc/base_bloc.dart';
import 'package:jfit/core/error/bloc_errors.dart';
import 'package:jfit/core/models/exercise.dart';

/// Base class for all Exercise-related states
abstract class ExerciseState extends BaseState {
  const ExerciseState();
}

/// Initial state when ExerciseBloc is first created
class ExerciseInitial extends ExerciseState {
  const ExerciseInitial();

  @override
  List<Object?> get props => [];
}

/// State when exercise operations are in progress
class ExerciseLoading extends ExerciseState {
  final String? message;

  const ExerciseLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// State when exercise search results are loaded
class ExerciseSearchResults extends ExerciseState {
  final List<Exercise> exercises;
  final String query;
  final bool hasMore;
  final int totalCount;

  const ExerciseSearchResults({
    required this.exercises,
    required this.query,
    this.hasMore = false,
    this.totalCount = 0,
  });

  @override
  List<Object?> get props => [exercises, query, hasMore, totalCount];

  /// Create a copy with updated values
  ExerciseSearchResults copyWith({
    List<Exercise>? exercises,
    String? query,
    bool? hasMore,
    int? totalCount,
  }) {
    return ExerciseSearchResults(
      exercises: exercises ?? this.exercises,
      query: query ?? this.query,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

/// State when exercise details are loaded
class ExerciseDetailsLoaded extends ExerciseState {
  final Exercise exercise;

  const ExerciseDetailsLoaded(this.exercise);

  @override
  List<Object?> get props => [exercise];
}

/// State when multiple exercise details are loaded
class MultipleExerciseDetailsLoaded extends ExerciseState {
  final List<Exercise> exercises;
  final List<String> requestedIds;

  const MultipleExerciseDetailsLoaded({
    required this.exercises,
    required this.requestedIds,
  });

  @override
  List<Object?> get props => [exercises, requestedIds];
}

/// State when popular exercises are loaded
class PopularExercisesLoaded extends ExerciseState {
  final List<Exercise> exercises;

  const PopularExercisesLoaded(this.exercises);

  @override
  List<Object?> get props => [exercises];
}

/// State when exercises by category are loaded
class ExercisesByCategoryLoaded extends ExerciseState {
  final List<Exercise> exercises;
  final String category;

  const ExercisesByCategoryLoaded({
    required this.exercises,
    required this.category,
  });

  @override
  List<Object?> get props => [exercises, category];
}

/// State when exercises by muscle group are loaded
class ExercisesByMuscleGroupLoaded extends ExerciseState {
  final List<Exercise> exercises;
  final String muscleGroup;

  const ExercisesByMuscleGroupLoaded({
    required this.exercises,
    required this.muscleGroup,
  });

  @override
  List<Object?> get props => [exercises, muscleGroup];
}

/// State when search results are cleared
class ExerciseSearchCleared extends ExerciseState {
  const ExerciseSearchCleared();

  @override
  List<Object?> get props => [];
}

/// State when exercise cache is refreshed
class ExerciseCacheRefreshed extends ExerciseState {
  final DateTime refreshedAt;

  const ExerciseCacheRefreshed(this.refreshedAt);

  @override
  List<Object?> get props => [refreshedAt];
}

/// State when an exercise-related error occurs
class ExerciseErrorState extends ExerciseState {
  final BlocError error;
  final bool isRetryable;
  final VoidCallback? retryAction;
  final String? recoverySuggestion;
  
  const ExerciseErrorState(
    this.error, {
    this.isRetryable = false,
    this.retryAction,
    this.recoverySuggestion,
  });

  @override
  List<Object?> get props => [error, isRetryable, retryAction, recoverySuggestion];

  /// Get user-friendly Korean error message
  String get userMessage {
    switch (error.code) {
      case BlocErrorCodes.exerciseNotFound:
        return '운동 정보를 찾을 수 없습니다.';
      case BlocErrorCodes.exerciseSearchFailed:
        return '운동 검색에 실패했습니다.';
      case BlocErrorCodes.networkError:
        return '네트워크 연결을 확인해주세요.';
      case BlocErrorCodes.serverError:
        return '서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요.';
      case BlocErrorCodes.connectionTimeout:
        return '연결 시간이 초과되었습니다. 다시 시도해주세요.';
      default:
        final message = error.message.toLowerCase();
        if (message.contains('network') || message.contains('connection')) {
          return '네트워크 연결을 확인해주세요.';
        } else if (message.contains('server') || message.contains('http')) {
          return '서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요.';
        } else if (message.contains('timeout')) {
          return '연결 시간이 초과되었습니다. 다시 시도해주세요.';
        } else if (message.contains('search')) {
          return '운동 검색에 실패했습니다.';
        } else if (message.contains('not found')) {
          return '운동 정보를 찾을 수 없습니다.';
        } else {
          return '운동 정보를 불러오는 중 오류가 발생했습니다.';
        }
    }
  }

  /// Get action button text based on error type
  String get actionButtonText {
    if (!isRetryable) {
      return '확인';
    }
    
    switch (error.code) {
      case BlocErrorCodes.networkError:
      case BlocErrorCodes.connectionTimeout:
        return '다시 시도';
      case BlocErrorCodes.serverError:
        return '새로고침';
      case BlocErrorCodes.exerciseSearchFailed:
        return '다시 검색';
      case BlocErrorCodes.exerciseNotFound:
        return '새로고침';
      default:
        return '다시 시도';
    }
  }

  /// Get recovery suggestion message
  String get recoveryMessage {
    if (recoverySuggestion != null) {
      return recoverySuggestion!;
    }

    switch (error.code) {
      case BlocErrorCodes.exerciseNotFound:
        return '다른 운동을 검색하거나 목록을 새로고침해주세요.';
      case BlocErrorCodes.exerciseSearchFailed:
        return '검색어를 다시 입력하거나 필터를 조정해주세요.';
      case BlocErrorCodes.networkError:
        return '네트워크 연결을 확인하고 다시 시도해주세요.';
      case BlocErrorCodes.serverError:
        return '잠시 후 다시 시도해주세요.';
      case BlocErrorCodes.connectionTimeout:
        return '연결 시간이 초과되었습니다. 다시 시도해주세요.';
      default:
        return '문제가 지속되면 고객센터에 문의해주세요.';
    }
  }

  /// Create an ExerciseErrorState from a generic error
  factory ExerciseErrorState.fromError(dynamic error, {String? code}) {
    if (error is BlocError) {
      return ExerciseErrorState(error);
    }
    
    final exerciseError = ExerciseError(
      error.toString(),
      code: code ?? BlocErrorCodes.unknown,
    );
    
    return ExerciseErrorState(exerciseError);
  }

  /// Create an ExerciseErrorState with a specific message and code
  factory ExerciseErrorState.withCode(String message, String code) {
    return ExerciseErrorState(
      ExerciseError(message, code: code),
    );
  }

  /// Create retryable error state
  factory ExerciseErrorState.withRetry({
    required BlocError error,
    required VoidCallback retryAction,
    String? recoverySuggestion,
  }) {
    return ExerciseErrorState(
      error,
      isRetryable: true,
      retryAction: retryAction,
      recoverySuggestion: recoverySuggestion,
    );
  }

  /// Create non-retryable error state
  factory ExerciseErrorState.nonRetryable({
    required BlocError error,
    String? recoverySuggestion,
  }) {
    return ExerciseErrorState(
      error,
      isRetryable: false,
      recoverySuggestion: recoverySuggestion,
    );
  }

  /// Create search failed error
  factory ExerciseErrorState.searchFailed(String query, [String? details]) {
    return ExerciseErrorState.withCode(
      '운동 검색에 실패했습니다: "$query"',
      BlocErrorCodes.exerciseSearchFailed,
    );
  }

  /// Create not found error
  factory ExerciseErrorState.notFound(String exerciseId) {
    return ExerciseErrorState.withCode(
      '운동 정보를 찾을 수 없습니다: "$exerciseId"',
      BlocErrorCodes.exerciseNotFound,
    );
  }

  /// Create load failed error
  factory ExerciseErrorState.loadFailed(String exerciseId, [String? details]) {
    return ExerciseErrorState.withCode(
      '운동 정보 로드에 실패했습니다: "$exerciseId"',
      BlocErrorCodes.unknown,
    );
  }
}