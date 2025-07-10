import 'package:dartz/dartz.dart';
import 'package:jfit/core/error/failures.dart';
import '../entities/workout_program.dart';

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
  Future<Either<Failure, List<WorkoutProgram>>> getUserPrograms();
  Future<Either<Failure, List<WorkoutProgram>>> searchPrograms(String query);
} 