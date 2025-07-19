import 'package:equatable/equatable.dart';
import '../../../domain/entities/pt_group_diet_summary.dart';
import '../../../domain/entities/diet_feedback.dart';
import '../../../domain/entities/pt_group_diet_permission.dart';

extension _ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

/// Base class for all PT diet states
abstract class PTDietState extends Equatable {
  const PTDietState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class PTDietInitial extends PTDietState {
  const PTDietInitial();
}

/// Loading state
class PTDietLoading extends PTDietState {
  const PTDietLoading();
}

/// Loaded state with PT diet data
class PTDietLoaded extends PTDietState {
  final List<PTGroupDietSummary> groupDietSummaries;
  final PTGroupDietSummary? selectedMemberSummary;
  final List<Map<String, dynamic>> memberMealEntries;
  final List<DietFeedback> dietFeedbacks;
  final List<DietFeedback> groupDietFeedbacks;
  final Map<String, dynamic>? dietAnalytics;
  final Map<String, dynamic>? memberGoalAchievement;
  final Map<String, dynamic>? groupDietCompliance;
  final List<PTGroupDietPermission> groupDietPermissions;
  final PTGroupDietPermission? memberDietPermissions;
  final Map<String, dynamic>? memberDietTrends;
  final Map<String, dynamic>? groupDietComparison;
  final List<Map<String, dynamic>> dietRecommendations;
  final Map<String, dynamic>? mealTimingAnalysis;
  final List<Map<String, dynamic>> nutritionAlerts;
  final double? dietAdherenceScore;
  final Map<String, dynamic>? macroDistributionAnalysis;
  final Map<String, dynamic>? dietCoachingInsights;
  final Map<String, dynamic>? recentDietActivity;
  final int unreadFeedbackCount;
  final DateTime selectedDate;
  final String? selectedMemberId;
  final DateTime lastUpdated;

  const PTDietLoaded({
    this.groupDietSummaries = const [],
    this.selectedMemberSummary,
    this.memberMealEntries = const [],
    this.dietFeedbacks = const [],
    this.groupDietFeedbacks = const [],
    this.dietAnalytics,
    this.memberGoalAchievement,
    this.groupDietCompliance,
    this.groupDietPermissions = const [],
    this.memberDietPermissions,
    this.memberDietTrends,
    this.groupDietComparison,
    this.dietRecommendations = const [],
    this.mealTimingAnalysis,
    this.nutritionAlerts = const [],
    this.dietAdherenceScore,
    this.macroDistributionAnalysis,
    this.dietCoachingInsights,
    this.recentDietActivity,
    this.unreadFeedbackCount = 0,
    required this.selectedDate,
    this.selectedMemberId,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        groupDietSummaries,
        selectedMemberSummary,
        memberMealEntries,
        dietFeedbacks,
        groupDietFeedbacks,
        dietAnalytics,
        memberGoalAchievement,
        groupDietCompliance,
        groupDietPermissions,
        memberDietPermissions,
        memberDietTrends,
        groupDietComparison,
        dietRecommendations,
        mealTimingAnalysis,
        nutritionAlerts,
        dietAdherenceScore,
        macroDistributionAnalysis,
        dietCoachingInsights,
        recentDietActivity,
        unreadFeedbackCount,
        selectedDate,
        selectedMemberId,
        lastUpdated,
      ];

  PTDietLoaded copyWith({
    List<PTGroupDietSummary>? groupDietSummaries,
    PTGroupDietSummary? selectedMemberSummary,
    List<Map<String, dynamic>>? memberMealEntries,
    List<DietFeedback>? dietFeedbacks,
    List<DietFeedback>? groupDietFeedbacks,
    Map<String, dynamic>? dietAnalytics,
    Map<String, dynamic>? memberGoalAchievement,
    Map<String, dynamic>? groupDietCompliance,
    List<PTGroupDietPermission>? groupDietPermissions,
    PTGroupDietPermission? memberDietPermissions,
    Map<String, dynamic>? memberDietTrends,
    Map<String, dynamic>? groupDietComparison,
    List<Map<String, dynamic>>? dietRecommendations,
    Map<String, dynamic>? mealTimingAnalysis,
    List<Map<String, dynamic>>? nutritionAlerts,
    double? dietAdherenceScore,
    Map<String, dynamic>? macroDistributionAnalysis,
    Map<String, dynamic>? dietCoachingInsights,
    Map<String, dynamic>? recentDietActivity,
    int? unreadFeedbackCount,
    DateTime? selectedDate,
    String? selectedMemberId,
    DateTime? lastUpdated,
  }) {
    return PTDietLoaded(
      groupDietSummaries: groupDietSummaries ?? this.groupDietSummaries,
      selectedMemberSummary: selectedMemberSummary ?? this.selectedMemberSummary,
      memberMealEntries: memberMealEntries ?? this.memberMealEntries,
      dietFeedbacks: dietFeedbacks ?? this.dietFeedbacks,
      groupDietFeedbacks: groupDietFeedbacks ?? this.groupDietFeedbacks,
      dietAnalytics: dietAnalytics ?? this.dietAnalytics,
      memberGoalAchievement: memberGoalAchievement ?? this.memberGoalAchievement,
      groupDietCompliance: groupDietCompliance ?? this.groupDietCompliance,
      groupDietPermissions: groupDietPermissions ?? this.groupDietPermissions,
      memberDietPermissions: memberDietPermissions ?? this.memberDietPermissions,
      memberDietTrends: memberDietTrends ?? this.memberDietTrends,
      groupDietComparison: groupDietComparison ?? this.groupDietComparison,
      dietRecommendations: dietRecommendations ?? this.dietRecommendations,
      mealTimingAnalysis: mealTimingAnalysis ?? this.mealTimingAnalysis,
      nutritionAlerts: nutritionAlerts ?? this.nutritionAlerts,
      dietAdherenceScore: dietAdherenceScore ?? this.dietAdherenceScore,
      macroDistributionAnalysis: macroDistributionAnalysis ?? this.macroDistributionAnalysis,
      dietCoachingInsights: dietCoachingInsights ?? this.dietCoachingInsights,
      recentDietActivity: recentDietActivity ?? this.recentDietActivity,
      unreadFeedbackCount: unreadFeedbackCount ?? this.unreadFeedbackCount,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedMemberId: selectedMemberId ?? this.selectedMemberId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Check if group diet summaries are available
  bool get hasGroupDietSummaries => groupDietSummaries.isNotEmpty;

  /// Check if selected member summary is available
  bool get hasSelectedMemberSummary => selectedMemberSummary != null;

  /// Check if member meal entries are available
  bool get hasMemberMealEntries => memberMealEntries.isNotEmpty;

  /// Check if diet feedbacks are available
  bool get hasDietFeedbacks => dietFeedbacks.isNotEmpty;

  /// Check if group diet feedbacks are available
  bool get hasGroupDietFeedbacks => groupDietFeedbacks.isNotEmpty;

  /// Check if diet analytics are available
  bool get hasDietAnalytics => dietAnalytics != null;

  /// Check if member goal achievement is available
  bool get hasMemberGoalAchievement => memberGoalAchievement != null;

  /// Check if group diet compliance is available
  bool get hasGroupDietCompliance => groupDietCompliance != null;

  /// Check if diet permissions are available
  bool get hasDietPermissions => groupDietPermissions.isNotEmpty;

  /// Check if member diet trends are available
  bool get hasMemberDietTrends => memberDietTrends != null;

  /// Check if group diet comparison is available
  bool get hasGroupDietComparison => groupDietComparison != null;

  /// Check if diet recommendations are available
  bool get hasDietRecommendations => dietRecommendations.isNotEmpty;

  /// Check if meal timing analysis is available
  bool get hasMealTimingAnalysis => mealTimingAnalysis != null;

  /// Check if nutrition alerts are available
  bool get hasNutritionAlerts => nutritionAlerts.isNotEmpty;

  /// Check if diet adherence score is available
  bool get hasDietAdherenceScore => dietAdherenceScore != null;

  /// Check if macro distribution analysis is available
  bool get hasMacroDistributionAnalysis => macroDistributionAnalysis != null;

  /// Check if diet coaching insights are available
  bool get hasDietCoachingInsights => dietCoachingInsights != null;

  /// Check if recent diet activity is available
  bool get hasRecentDietActivity => recentDietActivity != null;

  /// Check if there are unread feedbacks
  bool get hasUnreadFeedbacks => unreadFeedbackCount > 0;

  /// Get selected member's summary
  PTGroupDietSummary? get selectedSummary {
    if (selectedMemberId == null) return null;
    
    try {
      return groupDietSummaries.firstWhere(
        (summary) => summary.memberId == selectedMemberId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get total calories for selected date across all members
  double get totalGroupCalories {
    return groupDietSummaries.fold<double>(
      0.0,
      (sum, summary) => sum + summary.totalCalories,
    );
  }

  /// Get average calories per member for selected date
  double get averageCaloriesPerMember {
    if (groupDietSummaries.isEmpty) return 0.0;
    return totalGroupCalories / groupDietSummaries.length;
  }

  /// Get total protein for selected date across all members
  double get totalGroupProtein {
    return groupDietSummaries.fold<double>(
      0.0,
      (sum, summary) => sum + summary.totalProtein,
    );
  }

  /// Get average protein per member for selected date
  double get averageProteinPerMember {
    if (groupDietSummaries.isEmpty) return 0.0;
    return totalGroupProtein / groupDietSummaries.length;
  }

  /// Get members who haven't logged meals today
  List<PTGroupDietSummary> get membersWithoutMeals {
    return groupDietSummaries.where((summary) => summary.mealCount == 0).toList();
  }

  /// Get members who exceeded their calorie goals
  List<PTGroupDietSummary> get membersOverCalorieGoal {
    return groupDietSummaries
        .where((summary) => summary.totalCalories > summary.calorieGoal)
        .toList();
  }

  /// Get members who are under their calorie goals
  List<PTGroupDietSummary> get membersUnderCalorieGoal {
    return groupDietSummaries
        .where((summary) => summary.totalCalories < summary.calorieGoal * 0.8)
        .toList();
  }

  /// Get group calorie goal achievement rate
  double get groupCalorieGoalAchievementRate {
    if (groupDietSummaries.isEmpty) return 0.0;
    
    final achievedCount = groupDietSummaries
        .where((summary) => 
            summary.totalCalories >= summary.calorieGoal * 0.8 &&
            summary.totalCalories <= summary.calorieGoal * 1.2)
        .length;
    
    return (achievedCount / groupDietSummaries.length) * 100;
  }

  /// Get group protein goal achievement rate
  double get groupProteinGoalAchievementRate {
    if (groupDietSummaries.isEmpty) return 0.0;
    
    final achievedCount = groupDietSummaries
        .where((summary) => summary.totalProtein >= summary.proteinGoal * 0.8)
        .length;
    
    return (achievedCount / groupDietSummaries.length) * 100;
  }

  /// Get selected date formatted string
  String get selectedDateString {
    return '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
  }

  /// Check if data is stale (older than 30 minutes)
  bool get isDataStale {
    final now = DateTime.now();
    return now.difference(lastUpdated).inMinutes > 30;
  }

  /// Get summary statistics
  Map<String, dynamic> get summaryStats {
    return {
      'totalMembers': groupDietSummaries.length,
      'totalCalories': totalGroupCalories,
      'averageCalories': averageCaloriesPerMember,
      'totalProtein': totalGroupProtein,
      'averageProtein': averageProteinPerMember,
      'membersWithoutMeals': membersWithoutMeals.length,
      'membersOverGoal': membersOverCalorieGoal.length,
      'membersUnderGoal': membersUnderCalorieGoal.length,
      'calorieGoalAchievementRate': groupCalorieGoalAchievementRate,
      'proteinGoalAchievementRate': groupProteinGoalAchievementRate,
      'unreadFeedbacks': unreadFeedbackCount,
      'selectedDate': selectedDateString,
      'lastUpdated': lastUpdated,
    };
  }

  /// Get recent feedbacks (last 5)
  List<DietFeedback> get recentFeedbacks {
    final allFeedbacks = [...dietFeedbacks, ...groupDietFeedbacks];
    allFeedbacks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allFeedbacks.take(5).toList();
  }

  /// Get unread feedbacks
  List<DietFeedback> get unreadFeedbacks {
    final allFeedbacks = [...dietFeedbacks, ...groupDietFeedbacks];
    return allFeedbacks.where((feedback) => !feedback.isRead).toList();
  }

  /// Get feedbacks by type
  List<DietFeedback> getFeedbacksByType(FeedbackType type) {
    final allFeedbacks = [...dietFeedbacks, ...groupDietFeedbacks];
    return allFeedbacks.where((feedback) => feedback.feedbackType == type).toList();
  }

  /// Get member's latest meal time
  DateTime? getMemberLatestMealTime(String memberId) {
    final summary = groupDietSummaries
        .where((s) => s.memberId == memberId)
        .firstOrNull;
    return summary?.lastMealTime;
  }

  /// Check if member has meal photos
  bool memberHasMealPhotos(String memberId) {
    final summary = groupDietSummaries
        .where((s) => s.memberId == memberId)
        .firstOrNull;
    return summary?.mealPhotoUrls.isNotEmpty ?? false;
  }

  /// Get member's calorie achievement percentage
  double getMemberCalorieAchievement(String memberId) {
    final summary = groupDietSummaries
        .where((s) => s.memberId == memberId)
        .firstOrNull;
    
    if (summary == null || summary.calorieGoal == 0) return 0.0;
    return (summary.totalCalories / summary.calorieGoal) * 100;
  }

  /// Get member's protein achievement percentage
  double getMemberProteinAchievement(String memberId) {
    final summary = groupDietSummaries
        .where((s) => s.memberId == memberId)
        .firstOrNull;
    
    if (summary == null || summary.proteinGoal == 0) return 0.0;
    return (summary.totalProtein / summary.proteinGoal) * 100;
  }
}

/// Error state
class PTDietError extends PTDietState {
  final String message;
  final String? errorCode;

  const PTDietError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

/// Loading specific data state
class PTDietPartialLoading extends PTDietState {
  final PTDietLoaded currentState;
  final String loadingType; // 'summaries', 'feedbacks', 'analytics', etc.

  const PTDietPartialLoading({
    required this.currentState,
    required this.loadingType,
  });

  @override
  List<Object?> get props => [currentState, loadingType];
}

/// Feedback operation in progress
class PTDietFeedbackOperating extends PTDietState {
  final String operationType; // 'adding', 'marking_read', etc.

  const PTDietFeedbackOperating({required this.operationType});

  @override
  List<Object?> get props => [operationType];
}

/// Permission operation in progress
class PTDietPermissionOperating extends PTDietState {
  final String operationType; // 'setting', 'revoking', etc.

  const PTDietPermissionOperating({required this.operationType});

  @override
  List<Object?> get props => [operationType];
}

/// Data export in progress
class PTDietExporting extends PTDietState {
  final String memberId;
  final String format;

  const PTDietExporting({
    required this.memberId,
    required this.format,
  });

  @override
  List<Object?> get props => [memberId, format];
}

/// Success state for operations
class PTDietOperationSuccess extends PTDietState {
  final String message;
  final String operationType;

  const PTDietOperationSuccess({
    required this.message,
    required this.operationType,
  });

  @override
  List<Object?> get props => [message, operationType];
}