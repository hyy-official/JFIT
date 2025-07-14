import 'package:jfit/core/services/supabase_service.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/programs/data/datasources/program_remote_datasource.dart';
import '../../features/programs/data/repositories/program_repository_impl.dart';
import '../../features/programs/domain/repositories/program_repository.dart';
import '../../features/programs/presentation/bloc/programs_bloc.dart';



final getIt = GetIt.instance;

void setupDependencies() {
  // Supabase Client
  getIt.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );

  // Services
  getIt.registerLazySingleton<SupabaseService>(
    () => SupabaseService(getIt()),
  );

  // Data Sources
  getIt.registerLazySingleton<ProgramRemoteDataSource>(
    () => ProgramRemoteDataSourceImpl(supabaseClient: getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<ProgramRepository>(
    () => ProgramRepositoryImpl(
      remoteDataSource: getIt(),
      supabaseClient: getIt(),
    ),
  );

  // BLoCs
  getIt.registerFactory<ProgramsBloc>(
    () => ProgramsBloc(repository: getIt()),
  );
} 