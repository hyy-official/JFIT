import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/features/dashboard/bloc/dashboard_event.dart';
import 'package:jfit/features/dashboard/bloc/dashboard_state.dart';
import 'package:jfit/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:jfit/features/records/data/models/user_daily_summary_model.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository _dashboardRepository;

  DashboardBloc({required DashboardRepository dashboardRepository})
      : _dashboardRepository = dashboardRepository,
        super(DashboardInitial()) {
    on<LoadDashboardSummary>(_onLoadDashboardSummary);
  }

  Future<void> _onLoadDashboardSummary(LoadDashboardSummary event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final summaries = await _dashboardRepository.getDailySummaries(
        event.userId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(DashboardLoaded(dailySummaries: summaries));
    } catch (e) {
      emit(DashboardError(message: e.toString()));
    }
  }
}
