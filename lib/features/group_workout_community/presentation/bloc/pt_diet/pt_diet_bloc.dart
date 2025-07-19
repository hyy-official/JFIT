import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/repositories/pt_diet_repository.dart';
import 'pt_diet_event.dart';
import 'pt_diet_state.dart';

@injectable
class PTDietBloc extends Bloc<PTDietEvent, PTDietState> {
  final PTDietRepository _ptDietRepository;

  PTDietBloc(this._ptDietRepository) : super(const PTDietInitial()) {
    on<LoadGroupDietSummaries>(_onLoadGroupDietSummaries);
    on<LoadMemberDietSummary>(_onLoadMemberDietSummary);
    on<LoadMemberMealEntries>(_onLoadMemberMealEntries);
    on<AddDietFeedback>(_onAddDietFeedback);
    on<LoadDietFeedbacks>(_onLoadDietFeedbacks);
    on<LoadGroupDietFeedbacks>(_onLoadGroupDietFeedbacks);
    on<MarkFeedbackAsRead>(_onMarkFeedbackAsRead);
    on<MarkMultipleFeedbacksAsRead>(_onMarkMultipleFeedbacksAsRead);
    on<LoadDietAnalytics>(_onLoadDietAnalytics);
    on<LoadMemberGoalAchievement>(_onLoadMemberGoalAchievement);
    on<LoadGroupDietCompliance>(_onLoadGroupDietCompliance);
    on<SetDietPermissions>(_onSetDietPermissions);
    on<LoadDietPermissions>(_onLoadDietPermissions);
    on<LoadGroupDietPermissions>(_onLoadGroupDietPermissions);
    on<RevokeDietPermissions>(_onRevokeDietPermissions);
    on<LoadMemberDietTrends>(_onLoadMemberDietTrends);
    on<LoadGroupDietComparison>(_onLoadGroupDietComparison);
    on<LoadDietRecommendations>(_onLoadDietRecommendations);
    on<LoadUnreadFeedbackCount>(_onLoadUnreadFeedbackCount);
    on<UpdateTrainerNotes>(_onUpdateTrainerNotes);
    on<LoadRecentDietActivity>(_onLoadRecentDietActivity);
    on<LoadMealTimingAnalysis>(_onLoadMealTimingAnalysis);
    on<LoadNutritionAlerts>(_onLoadNutritionAlerts);
    on<LoadDietAdherenceScore>(_onLoadDietAdherenceScore);
    on<LoadMacroDistributionAnalysis>(_onLoadMacroDistributionAnalysis);
    on<UpdateMemberDietGoals>(_onUpdateMemberDietGoals);
    on<RefreshPTDietData>(_onRefreshPTDietData);
    on<ResetPTDietState>(_onResetPTDietState);
    on<ChangeSelectedDate>(_onChangeSelectedDate);
    on<ChangeSelectedMember>(_onChangeSelectedMember);
    on<LoadDietCoachingInsights>(_onLoadDietCoachingInsights);
    on<ExportMemberDietData>(_onExportMemberDietData);
  }

  Future<void> _onLoadGroupDietSummaries(
    LoadGroupDietSummaries event,
    Emitter<PTDietState> emit,
  ) async {
    if (state is! PTDietLoaded) {
      emit(const PTDietLoading());
    } else {
      emit(PTDietPartialLoading(
        currentState: state as PTDietLoaded,
        loadingType: 'summaries',
      ));
    }

    final result = await _ptDietRepository.getGroupDietSummaries(
      event.groupId,
      event.date,
    );

    result.fold(
      (failure) => emit(PTDietError(message: failure.message)),
      (summaries) {
        final currentState = state is PTDietLoaded ? state as PTDietLoaded : null;
        emit(PTDietLoaded(
          groupDietSummaries: summaries,
          selectedMemberSummary: currentState?.selectedMemberSummary,
          memberMealEntries: currentState?.memberMealEntries ?? [],
          dietFeedbacks: currentState?.dietFeedbacks ?? [],
          groupDietFeedbacks: currentState?.groupDietFeedbacks ?? [],
          dietAnalytics: currentState?.dietAnalytics,
          memberGoalAchievement: currentState?.memberGoalAchievement,
          groupDietCompliance: currentState?.groupDietCompliance,
          groupDietPermissions: currentState?.groupDietPermissions ?? [],
          memberDietPermissions: currentState?.memberDietPermissions,
          memberDietTrends: currentState?.memberDietTrends,
          groupDietComparison: currentState?.groupDietComparison,
          dietRecommendations: currentState?.dietRecommendations ?? [],
          mealTimingAnalysis: currentState?.mealTimingAnalysis,
          nutritionAlerts: currentState?.nutritionAlerts ?? [],
          dietAdherenceScore: currentState?.dietAdherenceScore,
          macroDistributionAnalysis: currentState?.macroDistributionAnalysis,
          dietCoachingInsights: currentState?.dietCoachingInsights,
          recentDietActivity: currentState?.recentDietActivity,
          unreadFeedbackCount: currentState?.unreadFeedbackCount ?? 0,
          selectedDate: event.date,
          selectedMemberId: currentState?.selectedMemberId,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onLoadMemberDietSummary(
    LoadMemberDietSummary event,
    Emitter<PTDietState> emit,
  ) async {
    if (state is! PTDietLoaded) {
      emit(const PTDietLoading());
    } else {
      emit(PTDietPartialLoading(
        currentState: state as PTDietLoaded,
        loadingType: 'member_summary',
      ));
    }

    final result = await _ptDietRepository.getMemberDietSummary(
      event.groupId,
      event.memberId,
      event.date,
    );

    result.fold(
      (failure) => emit(PTDietError(message: failure.message)),
      (summary) {
        final currentState = state as PTDietLoaded;
        emit(currentState.copyWith(
          selectedMemberSummary: summary,
          selectedMemberId: event.memberId,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onLoadMemberMealEntries(
    LoadMemberMealEntries event,
    Emitter<PTDietState> emit,
  ) async {
    if (state is! PTDietLoaded) {
      emit(const PTDietLoading());
    } else {
      emit(PTDietPartialLoading(
        currentState: state as PTDietLoaded,
        loadingType: 'meal_entries',
      ));
    }

    final result = await _ptDietRepository.getMemberMealEntries(
      event.memberId,
      event.startDate,
      event.endDate,
      includePhotos: event.includePhotos,
    );

    result.fold(
      (failure) => emit(PTDietError(message: failure.message)),
      (mealEntries) {
        final currentState = state as PTDietLoaded;
        emit(currentState.copyWith(
          memberMealEntries: mealEntries,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onAddDietFeedback(
    AddDietFeedback event,
    Emitter<PTDietState> emit,
  ) async {
    emit(const PTDietFeedbackOperating(operationType: 'adding'));

    final result = await _ptDietRepository.addDietFeedback(event.request);

    result.fold(
      (failure) => emit(PTDietError(message: failure.message)),
      (feedback) {
        emit(const PTDietOperationSuccess(
          message: '피드백이 성공적으로 추가되었습니다',
          operationType: 'add_feedback',
        ));
        
        // Reload feedbacks to include the new one
        add(LoadDietFeedbacks(
          groupId: event.request.groupId,
          memberId: event.request.memberId,
        ));
      },
    );
  }

  Future<void> _onLoadDietFeedbacks(
    LoadDietFeedbacks event,
    Emitter<PTDietState> emit,
  ) async {
    if (state is! PTDietLoaded) {
      emit(const PTDietLoading());
    } else {
      emit(PTDietPartialLoading(
        currentState: state as PTDietLoaded,
        loadingType: 'feedbacks',
      ));
    }

    final result = await _ptDietRepository.getDietFeedbacks(
      event.groupId,
      event.memberId,
      limit: event.limit,
      offset: event.offset,
      feedbackType: event.feedbackType,
    );

    result.fold(
      (failure) => emit(PTDietError(message: failure.message)),
      (feedbacks) {
        final currentState = state as PTDietLoaded;
        emit(currentState.copyWith(
          dietFeedbacks: feedbacks,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onLoadGroupDietFeedbacks(
    LoadGroupDietFeedbacks event,
    Emitter<PTDietState> emit,
  ) async {
    if (state is! PTDietLoaded) {
      emit(const PTDietLoading());
    } else {
      emit(PTDietPartialLoading(
        currentState: state as PTDietLoaded,
        loadingType: 'group_feedbacks',
      ));
    }

    final result = await _ptDietRepository.getGroupDietFeedbacks(
      event.groupId,
      limit: event.limit,
      offset: event.offset,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(PTDietError(message: failure.message)),
      (feedbacks) {
        final currentState = state as PTDietLoaded;
        emit(currentState.copyWith(
          groupDietFeedbacks: feedbacks,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onMarkFeedbackAsRead(
    MarkFeedbackAsRead event,
    Emitter<PTDietState> emit,
  ) async {
    emit(const PTDietFeedbackOperating(operationType: 'marking_read'));

    final result = await _ptDietRepository.markFeedbackAsRead(event.feedbackId);

    result.fold(
      (failure) => emit(PTDietError(message: failure.message)),
      (_) {
        emit(const PTDietOperationSuccess(
          message: '피드백이 읽음으로 표시되었습니다',
          operationType: 'mark_read',
        ));
        
        // Update the feedback in current state
        if (state is PTDietLoaded) {
          final currentState = state as PTDietLoaded;
          final updatedFeedbacks = currentState.dietFeedbacks.map((feedback) {
            if (feedback.id == event.feedbackId) {
              return feedback.copyWith(isRead: true);
            }
            return feedback;
          }).toList();
          
          final updatedGroupFeedbacks = currentState.groupDietFeedbacks.map((feedback) {
            if (feedback.id == event.feedbackId) {
              return feedback.copyWith(isRead: true);
            }
            return feedback;
          }).toList();
          
          emit(currentState.copyWith(
            dietFeedbacks: updatedFeedbacks,
            groupDietFeedbacks: updatedGroupFeedbacks,
            unreadFeedbackCount: currentState.unreadFeedbackCount > 0 
                ? currentState.unreadFeedbackCount - 1 
                : 0,
            lastUpdated: DateTime.now(),
          ));
        }
      },
    );
  }

  Future<void> _onMarkMultipleFeedbacksAsRead(
    MarkMultipleFeedbacksAsRead event,
    Emitter<PTDietState> emit,
  ) async {
    emit(const PTDietFeedbackOperating(operationType: 'marking_multiple_read'));

    final result = await _ptDietRepository.markMultipleFeedbacksAsRead(event.feedbackIds);

    result.fold(
      (failure) => emit(PTDietError(message: failure.message)),
      (_) {
        emit(const PTDietOperationSuccess(
          message: '선택된 피드백들이 읽음으로 표시되었습니다',
          operationType: 'mark_multiple_read',
        ));
        
        // Update the feedbacks in current state
        if (state is PTDietLoaded) {
          final currentState = state as PTDietLoaded;
          final updatedFeedbacks = currentState.dietFeedbacks.map((feedback) {
            if (event.feedbackIds.contains(feedback.id)) {
              return feedback.copyWith(isRead: true);
            }
            return feedback;
          }).toList();
          
          final updatedGroupFeedbacks = currentState.groupDietFeedbacks.map((feedback) {
            if (event.feedbackIds.contains(feedback.id)) {
              return feedback.copyWith(isRead: true);
            }
            return feedback;
          }).toList();
          
          emit(currentState.copyWith(
            dietFeedbacks: updatedFeedbacks,
            groupDietFeedbacks: updatedGroupFeedbacks,
            unreadFeedbackCount: (currentState.unreadFeedbackCount - event.feedbackIds.length).clamp(0, double.infinity).toInt(),
            lastUpdated: DateTime.now(),
          ));
        }
      },
    );
  }

  Future<void> _onLoadDietAnalytics(
    LoadDietAnalytics event,
    Emitter<PTDietState> emit,
  ) async {
    if (state is! PTDietLoaded) {
      emit(const PTDietLoading());
    } else {
      emit(PTDietPartialLoading(
        currentState: state as PTDietLoaded,
        loadingType: 'analytics',
      ));
    }

    final result = await _ptDietRepository.getDietAnalytics(event.request);

    result.fold(
      (failure) => emit(PTDietError(message: failure.message)),
      (analytics) {
        final currentState = state as PTDietLoaded;
        emit(currentState.copyWith(
          dietAnalytics: analytics,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onLoadMemberGoalAchievement(
    LoadMemberGoalAchievement event,
    Emitter<PTDietState> emit,
  ) async {
    if (state is! PTDietLoaded) {
      emit(const PTDietLoading());
    } else {
      emit(PTDietPartialLoading(
        currentState: state as PTDietLoaded,
        loadingType: 'goal_achievement',
      ));
    }

    final result = await _ptDietRepository.getMemberGoalAchievement(
      event.memberId,
      event.startDate,
      event.endDate,
    );

    result.fold(
      (failure) => emit(PTDietError(message: failure.message)),
      (achievement) {
        final currentState = state as PTDietLoaded;
        emit(currentState.copyWith(
          memberGoalAchievement: achievement,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onLoadGroupDietCompliance(
    LoadGroupDietCompliance event,
    Emitter<PTDietState> emit,
  ) async {
    if (state is! PTDietLoaded) {
      emit(const PTDietLoading());
    } else {
      emit(PTDietPartialLoading(
        currentState: state as PTDietLoaded,
        loadingType: 'compliance',
      ));
    }

    final result = await _ptDietRepository.getGroupDietCompliance(
      event.groupId,
      event.startDate,
      event.endDate,
    );

    result.fold(
      (failure) => emit(PTDietError(message: failure.message)),
      (compliance) {
        final currentState = state as PTDietLoaded;
        emit(currentState.copyWith(
          groupDietCompliance: compliance,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onSetDietPermissions(
    SetDietPermissions event,
    Emitter<PTDietState> emit,
  ) async {
    emit(const PTDietPermissionOperating(operationType: 'setting'));

    final result = await _ptDietRepository.setDietPermissions(event.request);

    result.fold(
      (failure) => emit(PTDietError(message: failure.message)),
      (permission) {
        emit(const PTDietOperationSuccess(
          message: '식단 공유 권한이 설정되었습니다',
          operationType: 'set_permissions',
        ));
        
        // Reload permissions
        add(LoadGroupDietPermissions(
          groupId: event.request.groupId,
          trainerId: event.request.trainerId,
        ));
      },
    );
  }

  Future<void> _onLoadDietPermissions(
    LoadDietPermissions event,
    Emitter<PTDietState> emit,
  ) async {
    if (state is! PTDietLoaded) {
      emit(const PTDietLoading());
    } else {
      emit(PTDietPartialLoading(
        currentState: state as PTDietLoaded,
        loadingType: 'permissions',
      ));
    }

    final result = await _ptDietRepository.getDietPermissions(
      event.groupId,
      event.memberId,
      event.trainerId,
    );

    result.fold(
      (failure) => emit(PTDietError(message: failure.message)),
      (permissions) {
        final currentState = state as PTDietLoaded;
        emit(currentState.copyWith(
          memberDietPermissions: permissions,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onLoadGroupDietPermissions(
    LoadGroupDietPermissions event,
    Emitter<PTDietState> emit,
  ) async {
    if (state is! PTDietLoaded) {
      emit(const PTDietLoading());
    } else {
      emit(PTDietPartialLoading(
        currentState: state as PTDietLoaded,
        loadingType: 'group_permissions',
      ));
    }

    final result = await _ptDietRepository.getGroupDietPermissions(
      event.groupId,
      event.trainerId,
    );

    result.fold(
      (failure) => emit(PTDietError(message: failure.message)),
      (permissions) {
        final currentState = state as PTDietLoaded;
        emit(currentState.copyWith(
          groupDietPermissions: permissions,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onRevokeDietPermissions(
    RevokeDietPermissions event,
    Emitter<PTDietState> emit,
  ) async {
    emit(const PTDietPermissionOperating(operationType: 'revoking'));

    final result = await _ptDietRepository.revokeDietPermissions(
      event.groupId,
      event.memberId,
      event.trainerId,
    );

    result.fold(
      (failure) => emit(PTDietError(message: failure.message)),
      (_) {
        emit(const PTDietOperationSuccess(
          message: '식단 공유 권한이 철회되었습니다',
          operationType: 'revoke_permissions',
        ));
        
        // Reload permissions
        add(LoadGroupDietPermissions(
          groupId: event.groupId,
          trainerId: event.trainerId,
        ));
      },
    );
  }

  Future<void> _onLoadMemberDietTrends(
    LoadMemberDietTrends event,
    Emitter<PTDietState> emit,
  ) async {
    if (state is! PTDietLoaded) {
      emit(const PTDietLoading());
    } else {
      emit(PTDietPartialLoading(
        currentState: state as PTDietLoaded,
        loadingType: 'diet_trends',
      ));
    }

    final result = await _ptDietRepository.getMemberDietTrends(
      event.memberId,
      event.startDate,
      event.endDate,
      groupId: event.groupId,
    );

    result.fold(
      (failure) => emit(PTDietError(message: failure.message)),
      (trends) {
        final currentState = state as PTDietLoaded;
        emit(currentState.copyWith(
          memberDietTrends: trends,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onLoadGroupDietComparison(
    LoadGroupDietComparison event,
    Emitter<PTDietState> emit,
  ) async {
    if (state is! PTDietLoaded) {
      emit(const PTDietLoading());
    } else {
      emit(PTDietPartialLoading(
        currentState: state as PTDietLoaded,
        loadingType: 'diet_comparison',
      ));
    }

    final result = await _ptDietRepository.getGroupDietComparison(
      event.groupId,
      event.startDate,
      event.endDate,
    );

    result.fold(
      (failure) => emit(PTDietError(message: failure.message)),
      (comparison) {
        final currentState = state as PTDietLoaded;
        emit(currentState.copyWith(
          groupDietComparison: comparison,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onLoadDietRecommendations(
    LoadDietRecommendations event,
    Emitter<PTDietState> emit,
  ) async {
    if (state is! PTDietLoaded) {
      emit(const PTDietLoading());
    } else {
      emit(PTDietPartialLoading(
        currentState: state as PTDietLoaded,
        loadingType: 'recommendations',
      ));
    }

    final result = await _ptDietRepository.getDietRecommendations(
      event.memberId,
      event.startDate,
      event.endDate,
    );

    result.fold(
      (failure) => emit(PTDietError(message: failure.message)),
      (recommendations) {
        final currentState = state as PTDietLoaded;
        emit(currentState.copyWith(
          dietRecommendations: recommendations,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onLoadUnreadFeedbackCount(
    LoadUnreadFeedbackCount event,
    Emitter<PTDietState> emit,
  ) async {
    final result = await _ptDietRepository.getUnreadFeedbackCount(event.memberId);

    result.fold(
      (failure) => emit(PTDietError(message: failure.message)),
      (count) {
        if (state is PTDietLoaded) {
          final currentState = state as PTDietLoaded;
          emit(currentState.copyWith(
            unreadFeedbackCount: count,
            lastUpdated: DateTime.now(),
          ));
        }
      },
    );
  }

  Future<void> _onUpdateTrainerNotes(
    UpdateTrainerNotes event,
    Emitter<PTDietState> emit,
  ) async {
    final result = await _ptDietRepository.updateTrainerNotes(
      event.summaryId,
      event.trainerNotes,
    );

    result.fold(
      (failure) => emit(PTDietError(message: failure.message)),
      (_) {
        emit(const PTDietOperationSuccess(
          message: '트레이너 노트가 업데이트되었습니다',
          operationType: 'update_notes',
        ));
      },
    );
  }

  Future<void> _onLoadRecentDietActivity(
    LoadRecentDietActivity event,
    Emitter<PTDietState> emit,
  ) async {
    if (state is! PTDietLoaded) {
      emit(const PTDietLoading());
    } else {
      emit(PTDietPartialLoading(
        currentState: state as PTDietLoaded,
        loadingType: 'recent_activity',
      ));
    }

    final result = await _ptDietRepository.getRecentDietActivity(
      event.groupId,
      hours: event.hours,
    );

    result.fold(
      (failure) => emit(PTDietError(message: failure.message)),
      (activity) {
        final currentState = state as PTDietLoaded;
        emit(currentState.copyWith(
          recentDietActivity: activity,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onLoadMealTimingAnalysis(
    LoadMealTimingAnalysis event,
    Emitter<PTDietState> emit,
  ) async {
    if (state is! PTDietLoaded) {
      emit(const PTDietLoading());
    } else {
      emit(PTDietPartialLoading(
        currentState: state as PTDietLoaded,
        loadingType: 'meal_timing',
      ));
    }

    final result = await _ptDietRepository.getMealTimingAnalysis(
      event.memberId,
      event.startDate,
      event.endDate,
    );

    result.fold(
      (failure) => emit(PTDietError(message: failure.message)),
      (analysis) {
        final currentState = state as PTDietLoaded;
        emit(currentState.copyWith(
          mealTimingAnalysis: analysis,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onLoadNutritionAlerts(
    LoadNutritionAlerts event,
    Emitter<PTDietState> emit,
  ) async {
    if (state is! PTDietLoaded) {
      emit(const PTDietLoading());
    } else {
      emit(PTDietPartialLoading(
        currentState: state as PTDietLoaded,
        loadingType: 'nutrition_alerts',
      ));
    }

    final result = await _ptDietRepository.getNutritionAlerts(
      event.groupId,
      memberId: event.memberId,
      date: event.date,
    );

    result.fold(
      (failure) => emit(PTDietError(message: failure.message)),
      (alerts) {
        final currentState = state as PTDietLoaded;
        emit(currentState.copyWith(
          nutritionAlerts: alerts,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onLoadDietAdherenceScore(
    LoadDietAdherenceScore event,
    Emitter<PTDietState> emit,
  ) async {
    if (state is! PTDietLoaded) {
      emit(const PTDietLoading());
    } else {
      emit(PTDietPartialLoading(
        currentState: state as PTDietLoaded,
        loadingType: 'adherence_score',
      ));
    }

    final result = await _ptDietRepository.getDietAdherenceScore(
      event.memberId,
      event.startDate,
      event.endDate,
    );

    result.fold(
      (failure) => emit(PTDietError(message: failure.message)),
      (score) {
        final currentState = state as PTDietLoaded;
        emit(currentState.copyWith(
          dietAdherenceScore: score,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onLoadMacroDistributionAnalysis(
    LoadMacroDistributionAnalysis event,
    Emitter<PTDietState> emit,
  ) async {
    if (state is! PTDietLoaded) {
      emit(const PTDietLoading());
    } else {
      emit(PTDietPartialLoading(
        currentState: state as PTDietLoaded,
        loadingType: 'macro_analysis',
      ));
    }

    final result = await _ptDietRepository.getMacroDistributionAnalysis(
      event.memberId,
      event.startDate,
      event.endDate,
    );

    result.fold(
      (failure) => emit(PTDietError(message: failure.message)),
      (analysis) {
        final currentState = state as PTDietLoaded;
        emit(currentState.copyWith(
          macroDistributionAnalysis: analysis,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onUpdateMemberDietGoals(
    UpdateMemberDietGoals event,
    Emitter<PTDietState> emit,
  ) async {
    final result = await _ptDietRepository.updateMemberDietGoals(
      event.memberId,
      event.calorieGoal,
      event.proteinGoal,
      event.carbGoal,
      event.fatGoal,
    );

    result.fold(
      (failure) => emit(PTDietError(message: failure.message)),
      (_) {
        emit(const PTDietOperationSuccess(
          message: '회원의 식단 목표가 업데이트되었습니다',
          operationType: 'update_goals',
        ));
      },
    );
  }

  Future<void> _onRefreshPTDietData(
    RefreshPTDietData event,
    Emitter<PTDietState> emit,
  ) async {
    if (state is PTDietLoaded) {
      final currentState = state as PTDietLoaded;
      
      // Reload current data based on selected date and member
      if (currentState.selectedMemberId != null) {
        add(LoadMemberDietSummary(
          groupId: '', // This would need to be stored in state
          memberId: currentState.selectedMemberId!,
          date: currentState.selectedDate,
        ));
      }
    }
  }

  Future<void> _onResetPTDietState(
    ResetPTDietState event,
    Emitter<PTDietState> emit,
  ) async {
    emit(const PTDietInitial());
  }

  Future<void> _onChangeSelectedDate(
    ChangeSelectedDate event,
    Emitter<PTDietState> emit,
  ) async {
    if (state is PTDietLoaded) {
      final currentState = state as PTDietLoaded;
      emit(currentState.copyWith(
        selectedDate: event.date,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onChangeSelectedMember(
    ChangeSelectedMember event,
    Emitter<PTDietState> emit,
  ) async {
    if (state is PTDietLoaded) {
      final currentState = state as PTDietLoaded;
      emit(currentState.copyWith(
        selectedMemberId: event.memberId,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  Future<void> _onLoadDietCoachingInsights(
    LoadDietCoachingInsights event,
    Emitter<PTDietState> emit,
  ) async {
    if (state is! PTDietLoaded) {
      emit(const PTDietLoading());
    } else {
      emit(PTDietPartialLoading(
        currentState: state as PTDietLoaded,
        loadingType: 'coaching_insights',
      ));
    }

    final result = await _ptDietRepository.getDietCoachingInsights(
      event.groupId,
      event.memberId,
      event.startDate,
      event.endDate,
    );

    result.fold(
      (failure) => emit(PTDietError(message: failure.message)),
      (insights) {
        final currentState = state as PTDietLoaded;
        emit(currentState.copyWith(
          dietCoachingInsights: insights,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onExportMemberDietData(
    ExportMemberDietData event,
    Emitter<PTDietState> emit,
  ) async {
    emit(PTDietExporting(
      memberId: event.memberId,
      format: event.format,
    ));

    final result = await _ptDietRepository.exportMemberDietData(
      event.memberId,
      event.startDate,
      event.endDate,
      format: event.format,
    );

    result.fold(
      (failure) => emit(PTDietError(message: failure.message)),
      (exportData) {
        emit(const PTDietOperationSuccess(
          message: '식단 데이터 내보내기가 완료되었습니다',
          operationType: 'export_data',
        ));
      },
    );
  }
}