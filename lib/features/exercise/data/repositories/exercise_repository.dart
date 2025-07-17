import 'package:dartz/dartz.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/core/interfaces/base_repository.dart';
import 'package:jfit/core/models/exercise.dart';

/// Repository interface for exercise-related data operations
/// Handles exercise search, details loading, and caching
abstract class ExerciseRepository extends BaseRepository {
  
  /// Search exercises by query string
  /// Returns a list of exercises matching the search criteria
  Future<Either<Failure, List<Exercise>>> search(
    String query, {
    int? limit,
  });

  /// Search exercises with additional filters
  /// Filters can include: difficulty, type, equipment, muscle groups, etc.
  Future<Either<Failure, List<Exercise>>> searchWithFilters(
    String query,
    Map<String, dynamic> filters, {
    int? limit,
  });

  /// Get detailed information for a specific exercise by ID
  Future<Either<Failure, Exercise?>> getExerciseById(String exerciseId);

  /// Get detailed information for multiple exercises by their IDs
  Future<Either<Failure, List<Exercise>>> getExercisesByIds(
    List<String> exerciseIds,
  );

  /// Get popular exercises based on popularity score
  Future<Either<Failure, List<Exercise>>> getPopularExercises({
    int? limit,
  });

  /// Get exercises by category
  Future<Either<Failure, List<Exercise>>> getExercisesByCategory(
    String category, {
    int? limit,
  });

  /// Get exercises by muscle group
  Future<Either<Failure, List<Exercise>>> getExercisesByMuscleGroup(
    String muscleGroup, {
    int? limit,
  });

  /// Get exercises by equipment type
  Future<Either<Failure, List<Exercise>>> getExercisesByEquipment(
    String equipment, {
    int? limit,
  });

  /// Get exercises by difficulty level
  Future<Either<Failure, List<Exercise>>> getExercisesByDifficulty(
    String difficulty, {
    int? limit,
  });

  /// Get all available exercise categories
  Future<Either<Failure, List<String>>> getExerciseCategories();

  /// Get all available muscle groups
  Future<Either<Failure, List<String>>> getMuscleGroups();

  /// Get all available equipment types
  Future<Either<Failure, List<String>>> getEquipmentTypes();

  /// Get all available difficulty levels
  Future<Either<Failure, List<String>>> getDifficultyLevels();

  /// Clear exercise cache
  Future<Either<Failure, void>> clearCache();

  /// Refresh exercise cache
  Future<Either<Failure, void>> refreshCache();
}