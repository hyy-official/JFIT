import 'package:equatable/equatable.dart';
import 'package:jfit/core/error/bloc_errors.dart';
import 'package:jfit/features/records/data/models/meal_record_model.dart';

abstract class MealState extends Equatable {
  const MealState();

  @override
  List<Object?> get props => [];
}

class MealInitial extends MealState {}

class MealLoading extends MealState {}

class MealRecordsLoaded extends MealState {
  final List<MealRecord> mealRecords;

  const MealRecordsLoaded({required this.mealRecords});

  @override
  List<Object> get props => [mealRecords];
}

class MealRecordAdded extends MealState {
  final MealRecord mealRecord;

  const MealRecordAdded({required this.mealRecord});

  @override
  List<Object> get props => [mealRecord];
}

class MealRecordUpdated extends MealState {
  final MealRecord mealRecord;

  const MealRecordUpdated({required this.mealRecord});

  @override
  List<Object> get props => [mealRecord];
}

class MealRecordDeleted extends MealState {
  final String recordId;

  const MealRecordDeleted({required this.recordId});

  @override
  List<Object> get props => [recordId];
}

class MealErrorState extends MealState {
  final MealError failure;

  const MealErrorState({required this.failure});

  @override
  List<Object> get props => [failure];
}