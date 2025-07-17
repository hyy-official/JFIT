import 'package:dartz/dartz.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/core/interfaces/base_repository.dart';
import 'package:jfit/features/workout_program/data/models/user_program_model.dart';
import 'package:jfit/features/workout_program/data/models/current_workout_info_model.dart';
import 'package:jfit/features/programs/data/models/user_program_day_model.dart';

/// Repository interface for workout program operations
abstract class WorkoutProgramRepository extends BaseRepository {
  /// Get user's active workout programs
  Future<Either<Failure, List<UserProgramModel>>> getUserPrograms(String userId);

  /// Get specific user program details with joined workout program data
  Future<Either<Failure, UserProgramModel?>> getUserProgramDetails(String userProgramId);

  /// Get program days for a specific user program
  Future<Either<Failure, List<UserProgramDayModel>>> getUserProgramDays(String userProgramId);

  /// Update user program progress
  Future<Either<Failure, void>> updateUserProgramProgress(
    String userProgramId,
    int currentWeek,
    int currentDay,
  );

  /// Complete a program day
  Future<Either<Failure, void>> completeUserProgramDay(
    String userProgramId,
    int week,
    int day, {
    String? note,
  });

  /// Delete/deactivate a user program
  Future<Either<Failure, void>> deleteUserProgram(String userProgramId);

  /// Get current workout info for a user
  Future<Either<Failure, CurrentWorkoutInfoModel>> getCurrentWorkoutInfo(String userId);

  /// Get latest active user program
  Future<Either<Failure, UserProgramModel?>> getLatestActiveUserProgram(String userId);
}