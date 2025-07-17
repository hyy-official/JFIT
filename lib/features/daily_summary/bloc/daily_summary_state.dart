import 'package:flutter/foundation.dart';
import 'package:jfit/core/bloc/base_bloc.dart';
import 'package:jfit/features/records/data/models/user_daily_summary_model.dart';

/// Base class for all DailySummary states
abstract class DailySummaryState extends BaseState {
  const DailySummaryState();
}

/// Initial state when DailySummaryBloc is first created
class DailySummaryInitial extends DailySummaryState {
  const DailySummaryInitial();
}

/// Loading state when fetching or calculating daily summary
class DailySummaryLoading extends DailySummaryState {
  final String? message;
  final DateTime? date;

  const DailySummaryLoading({
    this.message,
    this.date,
  });

  @override
  List<Object?> get props => [message, date];
}

/// State when daily summary is successfully loaded
class DailySummaryLoaded extends DailySummaryState {
  final UserDailySummary summary;
  final DateTime loadedAt;

  const DailySummaryLoaded({
    required this.summary,
    required this.loadedAt,
  });

  @override
  List<Object> get props => [summary, loadedAt];
}

/// State when no daily summary exists for the requested date
class DailySummaryEmpty extends DailySummaryState {
  final String userId;
  final DateTime date;
  final String message;

  const DailySummaryEmpty({
    required this.userId,
    required this.date,
    this.message = 'No data available for this date',
  });

  @override
  List<Object> get props => [userId, date, message];
}

/// State when multiple daily summaries are loaded (for date ranges)
class DailySummariesLoaded extends DailySummaryState {
  final List<UserDailySummary> summaries;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime loadedAt;

  const DailySummariesLoaded({
    required this.summaries,
    required this.startDate,
    required this.endDate,
    required this.loadedAt,
  });

  @override
  List<Object> get props => [summaries, startDate, endDate, loadedAt];
}

/// State when daily summary is successfully updated
class DailySummaryUpdated extends DailySummaryState {
  final UserDailySummary summary;
  final DateTime updatedAt;
  final String updateReason;

  const DailySummaryUpdated({
    required this.summary,
    required this.updatedAt,
    required this.updateReason,
  });

  @override
  List<Object> get props => [summary, updatedAt, updateReason];
}

/// State when daily summary is successfully deleted
class DailySummaryDeleted extends DailySummaryState {
  final String userId;
  final DateTime date;
  final DateTime deletedAt;

  const DailySummaryDeleted({
    required this.userId,
    required this.date,
    required this.deletedAt,
  });

  @override
  List<Object> get props => [userId, date, deletedAt];
}

/// State when daily summary cache is cleared
class DailySummaryCacheCleared extends DailySummaryState {
  final DateTime clearedAt;

  const DailySummaryCacheCleared({
    required this.clearedAt,
  });

  @override
  List<Object> get props => [clearedAt];
}

/// Error state for daily summary operations
class DailySummaryError extends DailySummaryState {
  final String message;
  final String? code;
  final DateTime? date;
  final String? operation;
  final bool isRetryable;
  final VoidCallback? retryAction;
  final String? recoverySuggestion;

  const DailySummaryError(
    this.message, {
    this.code,
    this.date,
    this.operation,
    this.isRetryable = false,
    this.retryAction,
    this.recoverySuggestion,
  });

  @override
  List<Object?> get props => [message, code, date, operation, isRetryable, retryAction, recoverySuggestion];

  /// Get user-friendly Korean error message
  String get userMessage {
    switch (code) {
      case 'summary_not_found':
        return '일일 요약 데이터를 찾을 수 없습니다.';
      case 'summary_update_failed':
        return '일일 요약 업데이트에 실패했습니다.';
      case 'summary_calculation_failed':
        return '일일 요약 계산에 실패했습니다.';
      case 'network_error':
        return '네트워크 연결을 확인해주세요.';
      case 'server_error':
        return '서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요.';
      default:
        if (message.toLowerCase().contains('network') || message.toLowerCase().contains('connection')) {
          return '네트워크 연결을 확인해주세요.';
        } else if (message.toLowerCase().contains('server') || message.toLowerCase().contains('http')) {
          return '서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요.';
        } else if (message.toLowerCase().contains('timeout')) {
          return '연결 시간이 초과되었습니다. 다시 시도해주세요.';
        } else {
          return '일일 요약을 불러오는 중 오류가 발생했습니다.';
        }
    }
  }

  /// Get action button text based on error type
  String get actionButtonText {
    if (!isRetryable) {
      return '확인';
    }
    
    switch (code) {
      case 'network_error':
      case 'connection_timeout':
        return '다시 시도';
      case 'server_error':
        return '새로고침';
      case 'summary_update_failed':
      case 'summary_calculation_failed':
        return '다시 계산';
      default:
        return '다시 시도';
    }
  }

  /// Get recovery suggestion message
  String get recoveryMessage {
    if (recoverySuggestion != null) {
      return recoverySuggestion!;
    }

    switch (code) {
      case 'summary_not_found':
        return '데이터를 새로고침하거나 다른 날짜를 선택해주세요.';
      case 'summary_update_failed':
        return '잠시 후 다시 시도하거나 앱을 재시작해주세요.';
      case 'summary_calculation_failed':
        return '식사 및 운동 기록을 확인하고 다시 시도해주세요.';
      case 'network_error':
        return '네트워크 연결을 확인하고 다시 시도해주세요.';
      case 'server_error':
        return '잠시 후 다시 시도해주세요.';
      default:
        return '문제가 지속되면 고객센터에 문의해주세요.';
    }
  }

  /// Create retryable error state
  factory DailySummaryError.withRetry({
    required String message,
    required VoidCallback retryAction,
    String? code,
    DateTime? date,
    String? operation,
    String? recoverySuggestion,
  }) {
    return DailySummaryError(
      message,
      code: code,
      date: date,
      operation: operation,
      isRetryable: true,
      retryAction: retryAction,
      recoverySuggestion: recoverySuggestion,
    );
  }

  /// Create non-retryable error state
  factory DailySummaryError.nonRetryable({
    required String message,
    String? code,
    DateTime? date,
    String? operation,
    String? recoverySuggestion,
  }) {
    return DailySummaryError(
      message,
      code: code,
      date: date,
      operation: operation,
      isRetryable: false,
      recoverySuggestion: recoverySuggestion,
    );
  }
}

/// State when daily summary is being refreshed/recalculated
class DailySummaryRefreshing extends DailySummaryState {
  final String userId;
  final DateTime date;
  final UserDailySummary? currentSummary;

  const DailySummaryRefreshing({
    required this.userId,
    required this.date,
    this.currentSummary,
  });

  @override
  List<Object?> get props => [userId, date, currentSummary];
}