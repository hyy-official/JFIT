import 'package:dartz/dartz.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/core/interfaces/base_repository.dart';
import 'package:jfit/features/records/data/models/meal_record_model.dart';

abstract class MealRepository extends BaseRepository {
  /// Get meal records for a specific user and optional date
  Future<Either<Failure, List<MealRecord>>> getMealRecords(
    String userId, {
    DateTime? date,
  });

  /// Add a new meal record
  Future<Either<Failure, void>> addMealRecord(MealRecord record);

  /// Update an existing meal record
  Future<Either<Failure, void>> updateMealRecord(MealRecord record);

  /// Delete a meal record by ID
  Future<Either<Failure, void>> deleteMealRecord(String recordId);
}