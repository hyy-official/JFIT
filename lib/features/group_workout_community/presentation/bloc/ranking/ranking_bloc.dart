import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/group_ranking.dart';
import '../../../domain/repositories/ranking_repository.dart';
import 'ranking_event.dart';
import 'ranking_state.dart';

@injectable
class RankingBloc extends Bloc<RankingEvent, RankingState> {
  final RankingRepository _rankingRepository;

  RankingBloc(this._rankingRepository) : super(const RankingInitial()) {
    on<LoadGroupRankings>(_onLoadGroupRankings);
    on<LoadUserScores>(_onLoadUserScores);
    on<LoadGroupMemberScores>(_onLoadGroupMemberScores);
    on<CalculateUserScore>(_onCalculateUserScore);
    on<LoadScoreBreakdown>(_onLoadScoreBreakdown);
    on<LoadUserGroupRankings>(_onLoadUserGroupRankings);
    on<LoadGroupTopPerformers>(_onLoadGroupTopPerformers);
    on<LoadGroupRankingTrends>(_onLoadGroupRankingTrends);
    on<LoadUserScoreTrends>(_onLoadUserScoreTrends);
    on<LoadGroupPerformanceStats>(_onLoadGroupPerformanceStats);
    on<CompareUsers>(_onCompareUsers);
    on<RefreshRankings>(_onRefreshRankings);
    on<ChangeRankingPeriod>(_onChangeRankingPeriod);
    on<UpdateGroupRankings>(_onUpdateGroupRankings);
    on<LoadWorkoutAnalysis>(_onLoadWorkoutAnalysis);
    on<LoadBodyPartDistribution>(_onLoadBodyPartDistribution);
    on<ResetRankingState>(_onResetRankingState);
  }

  Future<void> _onLoadGroupRankings(
    LoadGroupRankings event,
    Emitter<RankingState> emit,
  ) async {
    if (state is! RankingLoaded) {
      emit(const RankingLoading());
    } else {
      emit(RankingPartialLoading(
        currentState: state as RankingLoaded,
        loadingType: 'rankings',
      ));
    }

    final result = await _rankingRepository.getGroupRankings(
      event.request,
      limit: event.limit,
      offset: event.offset,
    );

    result.fold(
      (failure) => emit(RankingError(message: failure.message)),
      (rankings) {
        final currentState = state is RankingLoaded ? state as RankingLoaded : null;
        emit(RankingLoaded(
          groupRankings: rankings,
          userScores: currentState?.userScores ?? [],
          groupMemberScores: currentState?.groupMemberScores ?? [],
          scoreBreakdown: currentState?.scoreBreakdown,
          userGroupRankings: currentState?.userGroupRankings ?? [],
          groupTopPerformers: currentState?.groupTopPerformers ?? [],
          groupRankingTrends: currentState?.groupRankingTrends ?? [],
          userScoreTrends: currentState?.userScoreTrends ?? [],
          groupPerformanceStats: currentState?.groupPerformanceStats,
          userComparison: currentState?.userComparison,
          workoutAnalysis: currentState?.workoutAnalysis,
          bodyPartDistribution: currentState?.bodyPartDistribution,
          currentPeriod: event.request.period,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onLoadUserScores(
    LoadUserScores event,
    Emitter<RankingState> emit,
  ) async {
    if (state is! RankingLoaded) {
      emit(const RankingLoading());
    } else {
      emit(RankingPartialLoading(
        currentState: state as RankingLoaded,
        loadingType: 'user_scores',
      ));
    }

    try {
      final result = await _rankingRepository.getUserScores(
        event.userId,
        groupId: event.groupId,
        period: event.period,
        limit: event.limit,
      );

      result.fold(
        (failure) => emit(RankingError(message: failure.message)),
        (scores) {
          final currentState = state is RankingLoaded ? state as RankingLoaded : null;
          emit(RankingLoaded(
            groupRankings: currentState?.groupRankings ?? [],
            userScores: scores,
            groupMemberScores: currentState?.groupMemberScores ?? [],
            scoreBreakdown: currentState?.scoreBreakdown,
            userGroupRankings: currentState?.userGroupRankings ?? [],
            groupTopPerformers: currentState?.groupTopPerformers ?? [],
            groupRankingTrends: currentState?.groupRankingTrends ?? [],
            userScoreTrends: currentState?.userScoreTrends ?? [],
            groupPerformanceStats: currentState?.groupPerformanceStats,
            userComparison: currentState?.userComparison,
            workoutAnalysis: currentState?.workoutAnalysis,
            bodyPartDistribution: currentState?.bodyPartDistribution,
            currentPeriod: event.period?.period ?? RankingPeriod.weekly,
            lastUpdated: DateTime.now(),
          ));
        },
      );
    } catch (e) {
      emit(RankingError(message: e.toString()));
    }
  }

  Future<void> _onLoadGroupMemberScores(
    LoadGroupMemberScores event,
    Emitter<RankingState> emit,
  ) async {
    if (state is! RankingLoaded) {
      emit(const RankingLoading());
    } else {
      emit(RankingPartialLoading(
        currentState: state as RankingLoaded,
        loadingType: 'member_scores',
      ));
    }

    final result = await _rankingRepository.getGroupMemberScores(
      event.groupId,
      event.request,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(RankingError(message: failure.message)),
      (memberScores) {
        final currentState = state is RankingLoaded ? state as RankingLoaded : null;
        emit(RankingLoaded(
          groupRankings: currentState?.groupRankings ?? [],
          userScores: memberScores,
          groupMemberScores: currentState?.groupMemberScores ?? [],
          scoreBreakdown: currentState?.scoreBreakdown,
          userGroupRankings: currentState?.userGroupRankings ?? [],
          groupTopPerformers: currentState?.groupTopPerformers ?? [],
          groupRankingTrends: currentState?.groupRankingTrends ?? [],
          userScoreTrends: currentState?.userScoreTrends ?? [],
          groupPerformanceStats: currentState?.groupPerformanceStats,
          userComparison: currentState?.userComparison,
          workoutAnalysis: currentState?.workoutAnalysis,
          bodyPartDistribution: currentState?.bodyPartDistribution,
          currentPeriod: event.request.period,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onCalculateUserScore(
    CalculateUserScore event,
    Emitter<RankingState> emit,
  ) async {
    emit(RankingCalculating(
      userId: event.request.userId,
      scoreDate: event.request.scoreDate,
    ));

    final result = await _rankingRepository.calculateUserScore(event.request);

    result.fold(
      (failure) => emit(RankingError(message: failure.message)),
      (score) {
        emit(const RankingOperationSuccess(
          message: '점수 계산이 완료되었습니다',
          operationType: 'calculate_score',
        ));
        
        // Reload user scores to include the new calculation
        add(LoadUserScores(
          userId: event.request.userId,
          groupId: event.request.groupId,
        ));
      },
    );
  }

  Future<void> _onLoadScoreBreakdown(
    LoadScoreBreakdown event,
    Emitter<RankingState> emit,
  ) async {
    if (state is! RankingLoaded) {
      emit(const RankingLoading());
    } else {
      emit(RankingPartialLoading(
        currentState: state as RankingLoaded,
        loadingType: 'score_breakdown',
      ));
    }

    final result = await _rankingRepository.getScoreBreakdown(
      event.userId,
      event.startDate,
      event.endDate,
    );

    result.fold(
      (failure) => emit(RankingError(message: failure.message)),
      (breakdown) {
        if (state is RankingLoaded) {
          final currentState = state as RankingLoaded;
          emit(currentState.copyWith(
            scoreBreakdown: breakdown,
            lastUpdated: DateTime.now(),
          ));
        } else {
          emit(RankingLoaded(
            scoreBreakdown: breakdown,
            lastUpdated: DateTime.now(),
          ));
        }
      },
    );
  }

  Future<void> _onLoadUserGroupRankings(
    LoadUserGroupRankings event,
    Emitter<RankingState> emit,
  ) async {
    if (state is! RankingLoaded) {
      emit(const RankingLoading());
    } else {
      emit(RankingPartialLoading(
        currentState: state as RankingLoaded,
        loadingType: 'user_rankings',
      ));
    }

    final result = await _rankingRepository.getUserGroupRankings(
      event.userId,
      event.request,
    );

    result.fold(
      (failure) => emit(RankingError(message: failure.message)),
      (rankings) {
        final currentState = state as RankingLoaded;
        emit(currentState.copyWith(
          userGroupRankings: rankings,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onLoadGroupTopPerformers(
    LoadGroupTopPerformers event,
    Emitter<RankingState> emit,
  ) async {
    if (state is! RankingLoaded) {
      emit(const RankingLoading());
    } else {
      emit(RankingPartialLoading(
        currentState: state as RankingLoaded,
        loadingType: 'top_performers',
      ));
    }

    final result = await _rankingRepository.getGroupTopPerformers(
      event.groupId,
      event.request,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(RankingError(message: failure.message)),
      (performers) {
        final currentState = state as RankingLoaded;
        emit(currentState.copyWith(
          groupTopPerformers: performers,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onLoadGroupRankingTrends(
    LoadGroupRankingTrends event,
    Emitter<RankingState> emit,
  ) async {
    if (state is! RankingLoaded) {
      emit(const RankingLoading());
    } else {
      emit(RankingPartialLoading(
        currentState: state as RankingLoaded,
        loadingType: 'ranking_trends',
      ));
    }

    final result = await _rankingRepository.getGroupRankingTrends(
      event.groupId,
      period: event.period,
      periodCount: event.periodCount,
    );

    result.fold(
      (failure) => emit(RankingError(message: failure.message)),
      (trends) {
        final currentState = state as RankingLoaded;
        emit(currentState.copyWith(
          groupRankingTrends: trends,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onLoadUserScoreTrends(
    LoadUserScoreTrends event,
    Emitter<RankingState> emit,
  ) async {
    if (state is! RankingLoaded) {
      emit(const RankingLoading());
    } else {
      emit(RankingPartialLoading(
        currentState: state as RankingLoaded,
        loadingType: 'score_trends',
      ));
    }

    final result = await _rankingRepository.getUserScoreTrends(
      event.userId,
      groupId: event.groupId,
      period: event.period,
      periodCount: event.periodCount,
    );

    result.fold(
      (failure) => emit(RankingError(message: failure.message)),
      (trends) {
        final currentState = state as RankingLoaded;
        emit(currentState.copyWith(
          userScoreTrends: trends,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onLoadGroupPerformanceStats(
    LoadGroupPerformanceStats event,
    Emitter<RankingState> emit,
  ) async {
    if (state is! RankingLoaded) {
      emit(const RankingLoading());
    } else {
      emit(RankingPartialLoading(
        currentState: state as RankingLoaded,
        loadingType: 'performance_stats',
      ));
    }

    final result = await _rankingRepository.getGroupPerformanceStats(
      event.groupId,
      event.request,
    );

    result.fold(
      (failure) => emit(RankingError(message: failure.message)),
      (stats) {
        final currentState = state as RankingLoaded;
        emit(currentState.copyWith(
          groupPerformanceStats: stats,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onCompareUsers(
    CompareUsers event,
    Emitter<RankingState> emit,
  ) async {
    if (state is! RankingLoaded) {
      emit(const RankingLoading());
    } else {
      emit(RankingPartialLoading(
        currentState: state as RankingLoaded,
        loadingType: 'user_comparison',
      ));
    }

    final result = await _rankingRepository.compareUsers(
      event.userId1,
      event.userId2,
      event.startDate,
      event.endDate,
    );

    result.fold(
      (failure) => emit(RankingError(message: failure.message)),
      (comparison) {
        final currentState = state as RankingLoaded;
        emit(currentState.copyWith(
          userComparison: comparison,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onRefreshRankings(
    RefreshRankings event,
    Emitter<RankingState> emit,
  ) async {
    if (state is RankingLoaded) {
      final currentState = state as RankingLoaded;
      
      // Reload current data
      add(LoadGroupRankings(
        request: RankingPeriodRequest(period: currentState.currentPeriod),
      ));
    } else {
      // Load default weekly rankings
      add(const LoadGroupRankings(
        request: RankingPeriodRequest(period: RankingPeriod.weekly),
      ));
    }
  }

  Future<void> _onChangeRankingPeriod(
    ChangeRankingPeriod event,
    Emitter<RankingState> emit,
  ) async {
    // Load rankings for the new period
    add(LoadGroupRankings(
      request: RankingPeriodRequest(period: event.period),
    ));
  }

  Future<void> _onUpdateGroupRankings(
    UpdateGroupRankings event,
    Emitter<RankingState> emit,
  ) async {
    emit(RankingUpdating(period: event.request.period));

    final result = await _rankingRepository.updateGroupRankings(event.request);

    result.fold(
      (failure) => emit(RankingError(message: failure.message)),
      (_) {
        emit(const RankingOperationSuccess(
          message: '랭킹이 업데이트되었습니다',
          operationType: 'update_rankings',
        ));
        
        // Reload rankings after update
        add(LoadGroupRankings(request: event.request));
      },
    );
  }

  Future<void> _onLoadWorkoutAnalysis(
    LoadWorkoutAnalysis event,
    Emitter<RankingState> emit,
  ) async {
    if (state is! RankingLoaded) {
      emit(const RankingLoading());
    } else {
      emit(RankingPartialLoading(
        currentState: state as RankingLoaded,
        loadingType: 'workout_analysis',
      ));
    }

    final result = await _rankingRepository.getWorkoutAnalysis(
      event.userId,
      event.startDate,
      event.endDate,
    );

    result.fold(
      (failure) => emit(RankingError(message: failure.message)),
      (analysis) {
        final currentState = state as RankingLoaded;
        emit(currentState.copyWith(
          workoutAnalysis: analysis,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onLoadBodyPartDistribution(
    LoadBodyPartDistribution event,
    Emitter<RankingState> emit,
  ) async {
    if (state is! RankingLoaded) {
      emit(const RankingLoading());
    } else {
      emit(RankingPartialLoading(
        currentState: state as RankingLoaded,
        loadingType: 'body_part_distribution',
      ));
    }

    final result = await _rankingRepository.getBodyPartDistribution(
      event.userId,
      event.startDate,
      event.endDate,
    );

    result.fold(
      (failure) => emit(RankingError(message: failure.message)),
      (distribution) {
        final currentState = state as RankingLoaded;
        emit(currentState.copyWith(
          bodyPartDistribution: distribution,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onResetRankingState(
    ResetRankingState event,
    Emitter<RankingState> emit,
  ) async {
    emit(const RankingInitial());
  }
}