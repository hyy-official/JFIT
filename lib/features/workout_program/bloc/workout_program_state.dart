import 'package:flutter/foundation.dart';
import 'package:jfit/core/bloc/base_bloc.dart';
import 'package:jfit/core/error/bloc_errors.dart';
import 'package:jfit/features/workout_program/data/models/user_program_model.dart';
import 'package:jfit/features/workout_program/data/models/current_workout_info_model.dart';
import 'package:jfit/features/programs/data/models/user_program_day_model.dart';

/// Base class for all WorkoutProgram states
abstract class WorkoutProgramState extends BaseState {
  const WorkoutProgramState();
}

/// Initial state
class WorkoutProgramInitial extends WorkoutProgramState {
  const WorkoutProgramInitial();
}

/// Loading state
class WorkoutProgramLoading extends WorkoutProgramState {
  final String? message;

  const WorkoutProgramLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// State when user programs are loaded
class UserProgramsLoaded extends WorkoutProgramState {
  final List<UserProgramModel> userPrograms;

  const UserProgramsLoaded({required this.userPrograms});

  @override
  List<Object?> get props => [userPrograms];
}

/// State when program details are loaded
class ProgramDetailsLoaded extends WorkoutProgramState {
  final UserProgramModel userProgram;

  const ProgramDetailsLoaded({required this.userProgram});

  @override
  List<Object?> get props => [userProgram];
}

/// State when program days are loaded
class ProgramDaysLoaded extends WorkoutProgramState {
  final List<UserProgramDayModel> programDays;
  final String userProgramId;

  const ProgramDaysLoaded({
    required this.programDays,
    required this.userProgramId,
  });

  @override
  List<Object?> get props => [programDays, userProgramId];
}

/// State when program progress is updated
class ProgramProgressUpdated extends WorkoutProgramState {
  final String userProgramId;
  final int currentWeek;
  final int currentDay;

  const ProgramProgressUpdated({
    required this.userProgramId,
    required this.currentWeek,
    required this.currentDay,
  });

  @override
  List<Object?> get props => [userProgramId, currentWeek, currentDay];
}

/// State when a program day is completed
class ProgramDayCompleted extends WorkoutProgramState {
  final String userProgramId;
  final int week;
  final int day;
  final String? note;

  const ProgramDayCompleted({
    required this.userProgramId,
    required this.week,
    required this.day,
    this.note,
  });

  @override
  List<Object?> get props => [userProgramId, week, day, note];
}

/// State when a user program is deleted
class UserProgramDeleted extends WorkoutProgramState {
  final String userProgramId;

  const UserProgramDeleted({required this.userProgramId});

  @override
  List<Object?> get props => [userProgramId];
}

/// State when current workout info is loaded
class CurrentWorkoutInfoLoaded extends WorkoutProgramState {
  final CurrentWorkoutInfoModel currentWorkoutInfo;

  const CurrentWorkoutInfoLoaded({required this.currentWorkoutInfo});

  @override
  List<Object?> get props => [currentWorkoutInfo];
}

/// Error state for workout program operations
class WorkoutProgramErrorState extends WorkoutProgramState {
  final BlocError failure;
  final bool isRetryable;
  final VoidCallback? retryAction;
  final String? recoverySuggestion;

  const WorkoutProgramErrorState({
    required this.failure,
    this.isRetryable = false,
    this.retryAction,
    this.recoverySuggestion,
  });

  @override
  List<Object?> get props => [failure, isRetryable, retryAction, recoverySuggestion];

  /// Get user-friendly error message
  String get userMessage => BlocErrorHandler.getUserFriendlyMessage(failure);

  /// Get action button text based on error type
  String get actionButtonText {
    if (!isRetryable) {
      return '확인';
    }
    
    switch (failure.code) {
      case BlocErrorCodes.networkError:
      case BlocErrorCodes.connectionTimeout:
        return '다시 시도';
      case BlocErrorCodes.serverError:
        return '새로고침';
      case BlocErrorCodes.repositoryNotInitialized:
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

    switch (failure.code) {
      case BlocErrorCodes.networkError:
        return '네트워크 연결을 확인하고 다시 시도해주세요.';
      case BlocErrorCodes.serverError:
        return '잠시 후 다시 시도해주세요.';
      case BlocErrorCodes.repositoryNotInitialized:
        return '앱을 다시 시작하거나 로그인을 다시 해주세요.';
      case BlocErrorCodes.dataParsingError:
        return '프로그램을 다시 불러오거나 앱을 재시작해주세요.';
      case BlocErrorCodes.programDuplicate:
        return '기존 프로그램을 계속하거나 새로 시작할 수 있습니다.';
      case BlocErrorCodes.permissionDenied:
        return '로그인 상태를 확인하고 다시 시도해주세요.';
      case BlocErrorCodes.validationError:
        return '입력한 정보를 확인하고 다시 시도해주세요.';
      default:
        return '문제가 지속되면 고객센터에 문의해주세요.';
    }
  }

  /// Create error state with retry capability
  factory WorkoutProgramErrorState.withRetry({
    required BlocError failure,
    required VoidCallback retryAction,
    String? recoverySuggestion,
  }) {
    return WorkoutProgramErrorState(
      failure: failure,
      isRetryable: true,
      retryAction: retryAction,
      recoverySuggestion: recoverySuggestion,
    );
  }

  /// Create non-retryable error state
  factory WorkoutProgramErrorState.nonRetryable({
    required BlocError failure,
    String? recoverySuggestion,
  }) {
    return WorkoutProgramErrorState(
      failure: failure,
      isRetryable: false,
      recoverySuggestion: recoverySuggestion,
    );
  }
}