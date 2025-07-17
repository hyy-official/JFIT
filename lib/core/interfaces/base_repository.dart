import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:jfit/core/error/failures.dart';

/// Base repository interface that all domain repositories should implement
/// Provides common patterns for error handling and data operations
abstract class BaseRepository {
  /// Common method signature for operations that might fail
  /// Returns Either&lt;Failure, T&gt; for consistent error handling
  Future<Either<Failure, T>> safeCall<T>(Future<T> Function() operation);
}

/// Base implementation of common repository functionality
mixin BaseRepositoryMixin implements BaseRepository {
  @override
  Future<Either<Failure, T>> safeCall<T>(Future<T> Function() operation) async {
    try {
      debugPrint('🔧 BaseRepository: Starting safeCall operation');
      final result = await operation();
      debugPrint('✅ BaseRepository: Operation completed successfully');
      return Right(result);
    } catch (e, stackTrace) {
      debugPrint('❌ BaseRepository: Exception caught: $e');
      debugPrint('❌ BaseRepository: Stack trace: $stackTrace');
      final failure = _handleException(e);
      debugPrint('❌ BaseRepository: Converted to failure: ${failure.runtimeType} - ${failure.message}');
      return Left(failure);
    }
  }

  /// Convert exceptions to appropriate Failure types
  Failure _handleException(dynamic exception) {
    if (exception is Failure) {
      return exception;
    }
    
    // Handle common exception types
    final message = exception.toString();
    
    if (message.contains('network') || message.contains('connection')) {
      return NetworkFailure(message);
    }
    
    if (message.contains('server') || message.contains('http')) {
      return ServerFailure(message);
    }
    
    if (message.contains('database') || message.contains('sql')) {
      return DatabaseFailure(message);
    }
    
    if (message.contains('auth') || message.contains('permission')) {
      return AuthFailure(message);
    }
    
    return GeneralFailure(message);
  }
}

/// Common interface for repositories that handle user-specific data
abstract class UserDataRepository extends BaseRepository {
  /// Get current user ID
  String? getCurrentUserId();
  
  /// Validate user access to data
  Future<bool> validateUserAccess(String userId);
}

/// Common interface for repositories that handle date-based data
abstract class DateBasedRepository extends BaseRepository {
  /// Get data for a specific date range
  Future<Either<Failure, List<T>>> getDataForDateRange<T>(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
  
  /// Get data for a specific date
  Future<Either<Failure, List<T>>> getDataForDate<T>(
    String userId,
    DateTime date,
  );
}

/// Common interface for repositories that support CRUD operations
abstract class CrudRepository<T, ID> extends BaseRepository {
  Future<Either<Failure, List<T>>> getAll(String userId);
  Future<Either<Failure, T?>> getById(ID id);
  Future<Either<Failure, T>> create(T entity);
  Future<Either<Failure, T>> update(T entity);
  Future<Either<Failure, void>> delete(ID id);
}

/// Common interface for repositories that support search functionality
abstract class SearchableRepository<T> extends BaseRepository {
  Future<Either<Failure, List<T>>> search(String query, {int? limit});
  Future<Either<Failure, List<T>>> searchWithFilters(
    String query,
    Map<String, dynamic> filters, {
    int? limit,
  });
}