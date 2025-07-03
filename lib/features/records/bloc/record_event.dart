import 'package:equatable/equatable.dart';
import 'package:jfit/features/records/data/models/meal_record_model.dart';

abstract class RecordEvent extends Equatable {
  const RecordEvent();

  @override
  List<Object> get props => [];
}

class LoadMealRecords extends RecordEvent {
  final int userId;
  final DateTime? date;

  const LoadMealRecords({required this.userId, this.date});

  @override
  List<Object?> get props => [userId, date];
}

class AddMealRecord extends RecordEvent {
  final MealRecord mealRecord;

  const AddMealRecord({required this.mealRecord});

  @override
  List<Object> get props => [mealRecord];
}

class UpdateMealRecord extends RecordEvent {
  final MealRecord mealRecord;

  const UpdateMealRecord({required this.mealRecord});

  @override
  List<Object> get props => [mealRecord];
}

class DeleteMealRecord extends RecordEvent {
  final String recordId;

  const DeleteMealRecord({required this.recordId});

  @override
  List<Object> get props => [recordId];
}

class LoadDailySummary extends RecordEvent {
  final int userId;
  final DateTime date;

  const LoadDailySummary({required this.userId, required this.date});

  @override
  List<Object> get props => [userId, date];
}
