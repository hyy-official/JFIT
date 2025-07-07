import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardSummary extends DashboardEvent {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadDashboardSummary({required this.userId, this.startDate, this.endDate});

  @override
  List<Object?> get props => [userId, startDate, endDate];
}
