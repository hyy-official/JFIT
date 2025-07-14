import 'package:equatable/equatable.dart';
import 'package:jfit/features/records/data/models/meal_record_model.dart';
import 'package:jfit/features/records/data/models/user_daily_summary_model.dart';

abstract class RecordState extends Equatable {
  const RecordState();

  @override
  List<Object?> get props => [];
}

class RecordInitial extends RecordState {}

class RecordLoading extends RecordState {}

class MealRecordsLoaded extends RecordState {
  final List<MealRecord> mealRecords;

  const MealRecordsLoaded({this.mealRecords = const []});

  @override
  List<Object?> get props => [mealRecords];
}

class DailySummaryLoaded extends RecordState {
  final UserDailySummary dailySummary;

  const DailySummaryLoaded({required this.dailySummary});

  @override
  List<Object?> get props => [dailySummary];
}

class RecordError extends RecordState {
  final String message;

  const RecordError({required this.message});

  @override
  List<Object?> get props => [message];
}

// 운동 프로그램 관련 상태들
class UserProgramsLoaded extends RecordState {
  final List<Map<String, dynamic>> userPrograms;

  const UserProgramsLoaded({required this.userPrograms});

  @override
  List<Object?> get props => [userPrograms];
}

class UserProgramDetailsLoaded extends RecordState {
  final Map<String, dynamic> programDetails;

  const UserProgramDetailsLoaded({required this.programDetails});

  @override
  List<Object?> get props => [programDetails];
}

class UserProgramDaysLoaded extends RecordState {
  final List<Map<String, dynamic>> programDays;

  const UserProgramDaysLoaded({required this.programDays});

  @override
  List<Object?> get props => [programDays];
}

class UserProgramDayCompleted extends RecordState {
  final String message;

  const UserProgramDayCompleted({required this.message});

  @override
  List<Object?> get props => [message];
}

class UserProgramProgressUpdated extends RecordState {
  final String message;

  const UserProgramProgressUpdated({required this.message});

  @override
  List<Object?> get props => [message];
}

class WorkoutSessionCreated extends RecordState {
  final String sessionId;

  const WorkoutSessionCreated({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

class WorkoutSessionCompleted extends RecordState {
  final String message;

  const WorkoutSessionCompleted({required this.message});

  @override
  List<Object?> get props => [message];
}

class ExerciseDetailsLoaded extends RecordState {
  final List<Map<String, dynamic>> exerciseDetails;

  const ExerciseDetailsLoaded({required this.exerciseDetails});

  @override
  List<Object?> get props => [exerciseDetails];
}

class ExerciseSearchResults extends RecordState {
  final List<Map<String, dynamic>> searchResults;

  const ExerciseSearchResults({required this.searchResults});

  @override
  List<Object?> get props => [searchResults];
}

// 복합 상태: 운동 프로그램과 일차 정보를 함께 관리
class WorkoutProgramData extends RecordState {
  final List<Map<String, dynamic>> userPrograms;
  final Map<String, dynamic>? currentProgramDetails;
  final List<Map<String, dynamic>> currentProgramDays;

  const WorkoutProgramData({
    required this.userPrograms,
    this.currentProgramDetails,
    this.currentProgramDays = const [],
  });

  @override
  List<Object?> get props => [userPrograms, currentProgramDetails, currentProgramDays];

  WorkoutProgramData copyWith({
    List<Map<String, dynamic>>? userPrograms,
    Map<String, dynamic>? currentProgramDetails,
    List<Map<String, dynamic>>? currentProgramDays,
  }) {
    return WorkoutProgramData(
      userPrograms: userPrograms ?? this.userPrograms,
      currentProgramDetails: currentProgramDetails ?? this.currentProgramDetails,
      currentProgramDays: currentProgramDays ?? this.currentProgramDays,
    );
  }
}

class UserProgramDeleted extends RecordState {
  final String message;

  const UserProgramDeleted({required this.message});

  @override
  List<Object?> get props => [message];
}

// 워크아웃 세션 관련 상태들
class WorkoutSessionLoaded extends RecordState {
  final Map<String, dynamic> session;

  const WorkoutSessionLoaded({required this.session});

  @override
  List<Object?> get props => [session];
}

class WorkoutSessionUpdated extends RecordState {
  final String message;

  const WorkoutSessionUpdated({required this.message});

  @override
  List<Object?> get props => [message];
}

class WorkoutSetLogged extends RecordState {
  final String message;

  const WorkoutSetLogged({required this.message});

  @override
  List<Object?> get props => [message];
}
