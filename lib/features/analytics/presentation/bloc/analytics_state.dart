part of 'analytics_bloc.dart';

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object> get props => [];
}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final String period;
  final List<DietScoreData> dietScoreData;
  final List<NutritionData> nutritionData;
  final List<WorkoutTimeData> workoutTimeData;
  final List<WorkoutCompositionData> workoutCompositionData;
  final List<BodyData> bodyData;

  const AnalyticsLoaded({
    required this.period,
    required this.dietScoreData,
    required this.nutritionData,
    required this.workoutTimeData,
    required this.workoutCompositionData,
    required this.bodyData,
  });

  @override
  List<Object> get props => [
        period,
        dietScoreData,
        nutritionData,
        workoutTimeData,
        workoutCompositionData,
        bodyData,
      ];
}

class AnalyticsError extends AnalyticsState {
  final String message;

  const AnalyticsError(this.message);

  @override
  List<Object> get props => [message];
}
