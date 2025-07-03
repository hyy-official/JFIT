import 'package:equatable/equatable.dart';
import 'package:jfit/features/exercise/data/models/exercise_record.dart';

abstract class ExerciseState extends Equatable {
  const ExerciseState();

  @override
  List<Object> get props => [];
}

class ExerciseInitial extends ExerciseState {}

class ExerciseLoading extends ExerciseState {}

class ExerciseLoaded extends ExerciseState {
  final List<ExerciseRecord> records;

  const ExerciseLoaded({this.records = const []});

  @override
  List<Object> get props => [records];
}

class ExerciseError extends ExerciseState {
  final String message;

  const ExerciseError({required this.message});

  @override
  List<Object> get props => [message];
}
