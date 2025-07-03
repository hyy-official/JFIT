import 'package:equatable/equatable.dart';
import 'package:jfit/features/records/data/models/meal_record_model.dart';
import 'package:jfit/features/records/data/models/user_daily_summary_model.dart';

abstract class RecordState extends Equatable {
  const RecordState();

  @override
  List<Object> get props => [];
}

class RecordInitial extends RecordState {}

class RecordLoading extends RecordState {}

class MealRecordsLoaded extends RecordState {
  final List<MealRecord> mealRecords;

  const MealRecordsLoaded({this.mealRecords = const []});

  @override
  List<Object> get props => [mealRecords];
}

class DailySummaryLoaded extends RecordState {
  final UserDailySummary dailySummary;

  const DailySummaryLoaded({required this.dailySummary});

  @override
  List<Object> get props => [dailySummary];
}

class RecordError extends RecordState {
  final String message;

  const RecordError({required this.message});

  @override
  List<Object> get props => [message];
}
