import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/workout_program.dart';
import '../../domain/repositories/program_repository.dart';
import '../datasources/program_remote_datasource.dart';

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
} 