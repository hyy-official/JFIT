import 'package:equatable/equatable.dart';
import 'package:jfit/features/records/data/models/meal_record_model.dart';

abstract class MealEvent extends Equatable {
  const MealEvent();

  @override
  List<Object?> get props => [];
}

class LoadMealRecords extends MealEvent {
  final String userId;
  final DateTime? date;

  const LoadMealRecords({
    required this.userId,
    this.date,
  });

  @override
  List<Object?> get props => [userId, date];
}

class AddMealRecord extends MealEvent {
  final MealRecord mealRecord;

  const AddMealRecord({required this.mealRecord});

  @override
  List<Object> get props => [mealRecord];
}

class UpdateMealRecord extends MealEvent {
  final MealRecord mealRecord;

  const UpdateMealRecord({required this.mealRecord});

  @override
  List<Object> get props => [mealRecord];
}

class DeleteMealRecord extends MealEvent {
  final String recordId;
  final String userId;
  final DateTime date;

  const DeleteMealRecord({
    required this.recordId,
    required this.userId,
    required this.date,
  });

  @override
  List<Object> get props => [recordId, userId, date];
}