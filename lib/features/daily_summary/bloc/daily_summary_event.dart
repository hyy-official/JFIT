import 'package:jfit/core/bloc/base_bloc.dart';

/// Base class for all DailySummary events
abstract class DailySummaryEvent extends BaseEvent {
  const DailySummaryEvent();
}

/// Event to load daily summary for a specific date
class LoadDailySummary extends DailySummaryEvent {
  final String userId;
  final DateTime date;

  const LoadDailySummary({
    required this.userId,
    required this.date,
  });

  @override
  List<Object> get props => [userId, date];
}

/// Event to refresh daily summary (recalculate from source data)
class RefreshDailySummary extends DailySummaryEvent {
  final String userId;
  final DateTime date;
  final bool forceRecalculation;

  const RefreshDailySummary({
    required this.userId,
    required this.date,
    this.forceRecalculation = false,
  });

  @override
  List<Object> get props => [userId, date, forceRecalculation];
}

/// Event to update daily summary when meal data changes
class UpdateSummaryFromMeal extends DailySummaryEvent {
  final String userId;
  final DateTime date;
  final String? mealRecordId;

  const UpdateSummaryFromMeal({
    required this.userId,
    required this.date,
    this.mealRecordId,
  });

  @override
  List<Object?> get props => [userId, date, mealRecordId];
}

/// Event to update daily summary when workout data changes
class UpdateSummaryFromWorkout extends DailySummaryEvent {
  final String userId;
  final DateTime date;
  final String? sessionId;

  const UpdateSummaryFromWorkout({
    required this.userId,
    required this.date,
    this.sessionId,
  });

  @override
  List<Object?> get props => [userId, date, sessionId];
}

/// Event to load daily summaries for a date range
class LoadDailySummariesForRange extends DailySummaryEvent {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadDailySummariesForRange({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [userId, startDate, endDate];
}

/// Event to clear cached daily summary data
class ClearDailySummaryCache extends DailySummaryEvent {
  const ClearDailySummaryCache();

  @override
  List<Object> get props => [];
}

/// Event to delete daily summary for a specific date
class DeleteDailySummary extends DailySummaryEvent {
  final String userId;
  final DateTime date;

  const DeleteDailySummary({
    required this.userId,
    required this.date,
  });

  @override
  List<Object> get props => [userId, date];
}