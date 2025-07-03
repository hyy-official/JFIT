import 'package:equatable/equatable.dart';
import 'package:jfit/features/records/data/models/user_daily_summary_model.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<UserDailySummary> dailySummaries;
  // TODO: 필요에 따라 다른 요약 데이터 (예: 최근 운동 목록, 영양 차트 데이터) 추가

  const DashboardLoaded({this.dailySummaries = const []});

  @override
  List<Object> get props => [dailySummaries];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object> get props => [message];
}
