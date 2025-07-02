part of 'analytics_bloc.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object> get props => [];
}

class FetchAnalyticsData extends AnalyticsEvent {
  final String period;

  const FetchAnalyticsData({required this.period});

  @override
  List<Object> get props => [period];
}
