import 'package:dartz/dartz.dart';
import 'package:jfit/core/error/failures.dart';
import '../../../workout_program/data/models/duplicate_check_result_model.dart';
import '../entities/workout_program.dart';
import '../../data/models/user_program_day_model.dart';
import '../../data/models/workout_session_model.dart';
import '../../data/models/workout_log_model.dart';
import '../../data/models/exercise_model.dart';

abstract class ProgramRepository {
  Future<Either<Failure, List<WorkoutProgram>>> getPopularPrograms();
  Future<Either<Failure, List<WorkoutProgram>>> getPrograms({
    String? searchQuery,
    String? difficultyLevel,
    String? programType,
    int? workoutsPerWeek,
    List<String>? tags,
  });
  Future<Either<Failure, WorkoutProgram>> getProgramById(String id);
  Future<Either<Failure, void>> addProgramToUser(String programId);
  Future<Either<Failure, DuplicateCheckResult>> saveAsMyRoutine(String templateProgramId);
  Future<Either<Failure, List<WorkoutProgram>>> getUserPrograms();
  Future<Either<Failure, List<WorkoutProgram>>> searchPrograms(String query);
  Future<Either<Failure, List<UserProgramDayModel>>> getUserProgramDays(String userProgramId);
  Future<Either<Failure, List<WorkoutSessionModel>>> getWorkoutSessionsByUserProgram(String userProgramId);
  Future<Either<Failure, List<WorkoutLogModel>>> getWorkoutLogsBySession(String sessionId);
  Future<Either<Failure, ExerciseModel>> getExerciseById(String exerciseId);
  
  // 프로그램 중복 체크 및 관리
  Future<Either<Failure, Map<String, dynamic>?>> checkProgramDuplicate(String programId);
  Future<Either<Failure, void>> restartProgram(String programId);
  Future<Either<Failure, void>> continueProgram(String programId);
} 