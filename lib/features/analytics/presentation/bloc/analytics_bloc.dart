import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:jfit/features/analytics/domain/entities/diet_score_data.dart';
import 'package:jfit/features/analytics/domain/entities/nutrition_data.dart';
import 'package:jfit/features/analytics/domain/entities/workout_composition_data.dart';
import 'package:jfit/features/analytics/domain/entities/workout_time_data.dart';
import 'package:jfit/features/analytics/domain/entities/body_data.dart';
import 'package:jfit/features/analytics/domain/repositories/analytics_repository.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepository _analyticsRepository;

  AnalyticsBloc({required AnalyticsRepository analyticsRepository})
      : _analyticsRepository = analyticsRepository,
        super(AnalyticsInitial()) {
    on<FetchAnalyticsData>(_onFetchAnalyticsData);
  }

  Future<void> _onFetchAnalyticsData(
    FetchAnalyticsData event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());
    try {
      final dietScoreData = await _analyticsRepository.getDietScoreData(event.period);
      final nutritionData = await _analyticsRepository.getNutritionData(event.period);
      final workoutTimeData = await _analyticsRepository.getWorkoutTimeData(event.period);
      final workoutCompositionData = await _analyticsRepository.getWorkoutCompositionData(event.period);
      final bodyData = await _analyticsRepository.getBodyData(event.period);

      emit(AnalyticsLoaded(
        period: event.period,
        dietScoreData: dietScoreData,
        nutritionData: nutritionData,
        workoutTimeData: workoutTimeData,
        workoutCompositionData: workoutCompositionData,
        bodyData: bodyData,
      ));
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }
}
