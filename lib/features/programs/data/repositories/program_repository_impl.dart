import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../../../workout_program/data/models/duplicate_check_result_model.dart';
import '../../domain/entities/workout_program.dart';
import '../../domain/repositories/program_repository.dart';
import '../datasources/program_remote_datasource.dart';
import '../models/user_program_day_model.dart';
import '../models/workout_session_model.dart';
import '../models/workout_log_model.dart';
import '../models/exercise_model.dart';

class ProgramRepositoryImpl implements ProgramRepository {
  final ProgramRemoteDataSource remoteDataSource;
  final SupabaseClient supabaseClient;

  ProgramRepositoryImpl({
    required this.remoteDataSource,
    required this.supabaseClient,
  });

  @override
  Future<Either<Failure, List<WorkoutProgram>>> getPopularPrograms() async {
    try {
      final programs = await remoteDataSource.getPopularPrograms();
      return Right(programs.map((model) => model.toEntity()).toList());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WorkoutProgram>>> getPrograms({
    String? searchQuery,
    String? difficultyLevel,
    String? programType,
    int? workoutsPerWeek,
    List<String>? tags,
  }) async {
    try {
      final programs = await remoteDataSource.getPrograms(
        searchQuery: searchQuery,
        difficultyLevel: difficultyLevel,
        programType: programType,
        workoutsPerWeek: workoutsPerWeek,
        tags: tags,
      );
      return Right(programs.map((model) => model.toEntity()).toList());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkoutProgram>> getProgramById(String id) async {
    try {
      final program = await remoteDataSource.getProgramById(id);
      return Right(program.toEntity());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addProgramToUser(String programId) async {
    try {
      final user = supabaseClient.auth.currentUser;
      print('현재 로그인된 사용자 UID: ${user?.id}');
      if (user == null) {
        return const Left(AuthFailure('사용자가 로그인되지 않았습니다.'));
      }

      await remoteDataSource.addProgramToUser(programId, user.id);
      return const Right(null);
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DuplicateCheckResult>> saveAsMyRoutine(String templateProgramId) async {
    final user = supabaseClient.auth.currentUser;
    print('현재 로그인된 사용자 UID: ${user?.id}');
    if (user == null) {
      return const Left(AuthFailure('사용자가 로그인되지 않았습니다.'));
    }

    final result = await remoteDataSource.saveAsMyRoutine(templateProgramId, user.id);
    return result;
  }

  @override
  Future<Either<Failure, List<WorkoutProgram>>> getUserPrograms() async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('사용자가 로그인되지 않았습니다.'));
      }

      final programs = await remoteDataSource.getUserPrograms(user.id);
      return Right(programs.map((model) => model.toEntity()).toList());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WorkoutProgram>>> searchPrograms(String query) async {
    try {
      final programs = await remoteDataSource.searchPrograms(query);
      return Right(programs.map((model) => model.toEntity()).toList());
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserProgramDayModel>>> getUserProgramDays(String userProgramId) async {
    try {
      final days = await remoteDataSource.getUserProgramDays(userProgramId);
      return Right(days);
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WorkoutSessionModel>>> getWorkoutSessionsByUserProgram(String userProgramId) async {
    try {
      final sessions = await remoteDataSource.getWorkoutSessionsByUserProgram(userProgramId);
      return Right(sessions);
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WorkoutLogModel>>> getWorkoutLogsBySession(String sessionId) async {
    try {
      final logs = await remoteDataSource.getWorkoutLogsBySession(sessionId);
      return Right(logs);
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExerciseModel>> getExerciseById(String exerciseId) async {
    try {
      final exercise = await remoteDataSource.getExerciseById(exerciseId);
      return Right(exercise);
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>?>> checkProgramDuplicate(String programId) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('사용자가 로그인되지 않았습니다.'));
      }

      final duplicate = await remoteDataSource.checkProgramDuplicate(programId, user.id);
      return Right(duplicate);
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> restartProgram(String programId) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('사용자가 로그인되지 않았습니다.'));
      }

      await remoteDataSource.restartProgram(programId, user.id);
      return const Right(null);
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> continueProgram(String programId) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('사용자가 로그인되지 않았습니다.'));
      }

      await remoteDataSource.continueProgram(programId, user.id);
      return const Right(null);
    } on Exception catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
} 