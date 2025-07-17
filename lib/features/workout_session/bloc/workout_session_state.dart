import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:jfit/core/bloc/base_bloc.dart';
import 'package:jfit/core/error/bloc_errors.dart';
import 'package:jfit/features/programs/data/models/workout_session_model.dart';

/// Base class for all WorkoutSession states
abstract class WorkoutSessionState extends BaseState {
  const WorkoutSessionState();
}

/// Initial state when WorkoutSessionBloc is first created
class WorkoutSessionInitial extends WorkoutSessionState {
  const WorkoutSessionInitial();
}

/// Loading state for workout session operations
class WorkoutSessionLoading extends WorkoutSessionState {
  final String? message;

  const WorkoutSessionLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// State when a workout session is successfully created
class WorkoutSessionCreated extends WorkoutSessionState {
  final String sessionId;
  final WorkoutSessionModel session;

  const WorkoutSessionCreated({
    required this.sessionId,
    required this.session,
  });

  @override
  List<Object?> get props => [sessionId, session];
}

/// State when a workout session is successfully loaded
class WorkoutSessionLoaded extends WorkoutSessionState {
  final WorkoutSessionModel session;

  const WorkoutSessionLoaded(this.session);

  @override
  List<Object?> get props => [session];
}

/// State when multiple workout sessions are loaded
class WorkoutSessionsLoaded extends WorkoutSessionState {
  final List<WorkoutSessionModel> sessions;

  const WorkoutSessionsLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

/// State when active workout sessions are loaded
class ActiveSessionLoaded extends WorkoutSessionState {
  final List<WorkoutSessionModel> activeSessions;

  const ActiveSessionLoaded(this.activeSessions);

  @override
  List<Object?> get props => [activeSessions];
}

/// State when a workout session is successfully updated
class WorkoutSessionUpdated extends WorkoutSessionState {
  final WorkoutSessionModel session;

  const WorkoutSessionUpdated(this.session);

  @override
  List<Object?> get props => [session];
}

/// State when a workout set is successfully logged
class WorkoutSetLogged extends WorkoutSessionState {
  final String sessionId;
  final String exerciseId;
  final int setNumber;
  final int reps;
  final double weight;

  const WorkoutSetLogged({
    required this.sessionId,
    required this.exerciseId,
    required this.setNumber,
    required this.reps,
    required this.weight,
  });

  @override
  List<Object?> get props => [sessionId, exerciseId, setNumber, reps, weight];
}

/// State when a workout session is successfully completed
class WorkoutSessionCompleted extends WorkoutSessionState {
  final String sessionId;
  final WorkoutSessionModel session;

  const WorkoutSessionCompleted({
    required this.sessionId,
    required this.session,
  });

  @override
  List<Object?> get props => [sessionId, session];
}

/// State when exercise data validation fails
class WorkoutSessionExerciseValidationFailed extends WorkoutSessionState {
  final String message;
  final String? technicalMessage;
  final dynamic originalData;

  const WorkoutSessionExerciseValidationFailed({
    required this.message,
    this.technicalMessage,
    this.originalData,
  });

  @override
  List<Object?> get props => [message, technicalMessage, originalData];
}

/// State when no exercises are found for the workout session
class WorkoutSessionEmptyExerciseList extends WorkoutSessionState {
  final String userProgramId;
  final int? targetWeek;
  final int? targetDay;
  final String message;

  const WorkoutSessionEmptyExerciseList({
    required this.userProgramId,
    this.targetWeek,
    this.targetDay,
    required this.message,
  });

  @override
  List<Object?> get props => [userProgramId, targetWeek, targetDay, message];
}

/// State when exercise data is successfully validated and ready for session
class WorkoutSessionExerciseDataValidated extends WorkoutSessionState {
  final String userProgramId;
  final List<Map<String, dynamic>> validatedExercises;
  final int? targetWeek;
  final int? targetDay;

  const WorkoutSessionExerciseDataValidated({
    required this.userProgramId,
    required this.validatedExercises,
    this.targetWeek,
    this.targetDay,
  });

  @override
  List<Object?> get props => [userProgramId, validatedExercises, targetWeek, targetDay];
}

/// Error state for workout session operations
class WorkoutSessionErrorState extends WorkoutSessionState {
  final BlocError error;
  final bool isRetryable;
  final VoidCallback? retryAction;
  final String? recoverySuggestion;
  
  const WorkoutSessionErrorState(
    this.error, {
    this.isRetryable = false,
    this.retryAction,
    this.recoverySuggestion,
  });

  /// Create error state from exception
  factory WorkoutSessionErrorState.fromException(Exception exception) {
    final error = BlocErrorHandler.handleException(
      exception,
      BlocErrorType.workoutSession,
    );
    return WorkoutSessionErrorState(error);
  }

  /// Create error state with specific error code
  factory WorkoutSessionErrorState.withCode(String message, String code) {
    final error = WorkoutSessionError(
      message,
      code: code,
    );
    return WorkoutSessionErrorState(error);
  }

  /// Create retryable error state
  factory WorkoutSessionErrorState.withRetry({
    required BlocError error,
    required VoidCallback retryAction,
    String? recoverySuggestion,
  }) {
    return WorkoutSessionErrorState(
      error,
      isRetryable: true,
      retryAction: retryAction,
      recoverySuggestion: recoverySuggestion,
    );
  }

  /// Create non-retryable error state
  factory WorkoutSessionErrorState.nonRetryable({
    required BlocError error,
    String? recoverySuggestion,
  }) {
    return WorkoutSessionErrorState(
      error,
      isRetryable: false,
      recoverySuggestion: recoverySuggestion,
    );
  }

  @override
  List<Object?> get props => [error, isRetryable, retryAction, recoverySuggestion];
  
  /// Get user-friendly error message
  String get userMessage => BlocErrorHandler.getUserFriendlyMessage(error);

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
      case BlocErrorCodes.sessionCreateFailed:
      case BlocErrorCodes.sessionUpdateFailed:
        return '다시 시도';
      case BlocErrorCodes.dataParsingError:
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
      case BlocErrorCodes.networkError:
        return '네트워크 연결을 확인하고 다시 시도해주세요.';
      case BlocErrorCodes.serverError:
        return '잠시 후 다시 시도해주세요.';
      case BlocErrorCodes.sessionCreateFailed:
        return '운동 세션 생성을 다시 시도해주세요.';
      case BlocErrorCodes.sessionUpdateFailed:
        return '운동 세션 업데이트를 다시 시도해주세요.';
      case BlocErrorCodes.dataParsingError:
        return '운동 데이터를 다시 불러와주세요.';
      case BlocErrorCodes.validationError:
        return '입력한 정보를 확인하고 다시 시도해주세요.';
      case BlocErrorCodes.sessionNotFound:
        return '운동 세션을 다시 선택해주세요.';
      default:
        return '문제가 지속되면 고객센터에 문의해주세요.';
    }
  }
}