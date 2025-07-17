import 'package:dartz/dartz.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/core/interfaces/base_repository.dart';
import 'package:jfit/features/programs/data/models/workout_session_model.dart';

/// Repository interface for workout session operations
/// Handles all workout session-related data operations
abstract class WorkoutSessionRepository extends BaseRepository {
  /// Create a new workout session
  /// Returns the created session ID on success
  Future<Either<Failure, String>> createWorkoutSession({
    required String userProgramId,
    required Map<String, dynamic> exercisesJson,
  });

  /// Get a specific workout session by ID
  Future<Either<Failure, WorkoutSessionModel?>> getWorkoutSession(String sessionId);

  /// Get all workout sessions for a user
  Future<Either<Failure, List<WorkoutSessionModel>>> getWorkoutSessions(String userId);

  /// Get active (incomplete) workout sessions for a user
  Future<Either<Failure, List<WorkoutSessionModel>>> getActiveWorkoutSessions(String userId);

  /// Update a workout session
  Future<Either<Failure, WorkoutSessionModel>> updateWorkoutSession({
    required String sessionId,
    required Map<String, dynamic> updates,
  });

  /// Complete a workout session
  Future<Either<Failure, WorkoutSessionModel>> completeWorkoutSession(String sessionId);

  /// Log a workout set
  Future<Either<Failure, void>> logWorkoutSet({
    required String sessionId,
    required String exerciseId,
    required int setNumber,
    required int reps,
    required double weight,
  });

  /// Get the last workout log for a specific exercise and user
  Future<Either<Failure, Map<String, dynamic>?>> getLastWorkoutLogByExercise({
    required String exerciseId,
    required String userId,
  });

  /// Get or create exercise ID by name (for custom exercises)
  Future<Either<Failure, String>> getOrCreateExerciseId(String exerciseName);
}