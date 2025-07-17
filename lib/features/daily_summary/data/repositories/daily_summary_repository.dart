import 'package:dartz/dartz.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/core/interfaces/base_repository.dart';
import 'package:jfit/features/records/data/models/user_daily_summary_model.dart';

/// Repository interface for daily summary operations
/// Handles CRUD operations for user daily summaries
abstract class DailySummaryRepository implements BaseRepository, UserDataRepository, DateBasedRepository {
  
  /// Get daily summary for a specific user and date
  /// Returns null if no summary exists for the given date
  Future<Either<Failure, UserDailySummary?>> getDailySummary(
    String userId, 
    DateTime date,
  );

  /// Create or update daily summary
  /// Uses upsert operation to handle both create and update scenarios
  Future<Either<Failure, UserDailySummary>> upsertDailySummary(
    UserDailySummary summary,
  );

  /// Get daily summaries for a date range
  /// Useful for analytics and trend analysis
  Future<Either<Failure, List<UserDailySummary>>> getDailySummariesForRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Calculate and update daily summary based on current data
  /// This method aggregates data from meal records and workout sessions
  Future<Either<Failure, UserDailySummary>> calculateAndUpdateDailySummary(
    String userId,
    DateTime date,
  );

  /// Delete daily summary for a specific date
  Future<Either<Failure, void>> deleteDailySummary(
    String userId,
    DateTime date,
  );
}