import 'package:dartz/dartz.dart';
import 'package:jfit/core/error/failures.dart';
import 'package:jfit/core/interfaces/base_repository.dart';
import '../entities/pt_group_diet_summary.dart';
import '../entities/diet_feedback.dart';
import '../entities/pt_group_diet_permission.dart';

/// Request models for PT diet operations
class CreateDietFeedbackRequest {
  final String groupId;
  final String memberId;
  final String trainerId;
  final String mealEntryId;
  final String feedbackText;
  final FeedbackType feedbackType;

  const CreateDietFeedbackRequest({
    required this.groupId,
    required this.memberId,
    required this.trainerId,
    required this.mealEntryId,
    required this.feedbackText,
    required this.feedbackType,
  });
}

class DietPermissionRequest {
  final String groupId;
  final String memberId;
  final String trainerId;
  final bool canViewMeals;
  final bool canViewPhotos;
  final bool canViewNutrition;

  const DietPermissionRequest({
    required this.groupId,
    required this.memberId,
    required this.trainerId,
    required this.canViewMeals,
    required this.canViewPhotos,
    required this.canViewNutrition,
  });
}

class DietAnalyticsRequest {
  final String groupId;
  final DateTime startDate;
  final DateTime endDate;
  final String? memberId; // null for all members

  const DietAnalyticsRequest({
    required this.groupId,
    required this.startDate,
    required this.endDate,
    this.memberId,
  });
}

/// Repository interface for PT diet sharing operations
/// Handles diet monitoring, feedback, and analytics for personal training groups
abstract class PTDietRepository extends BaseRepository {
  /// Get diet summaries for all members in a PT group for a specific date
  /// Returns comprehensive nutrition overview for trainer dashboard
  Future<Either<Failure, List<PTGroupDietSummary>>> getGroupDietSummaries(
    String groupId,
    DateTime date,
  );

  /// Get detailed diet summary for a specific member on a specific date
  /// Includes all meals, nutrition breakdown, and goals comparison
  Future<Either<Failure, PTGroupDietSummary?>> getMemberDietSummary(
    String groupId,
    String memberId,
    DateTime date,
  );

  /// Get member's meal entries for a date range
  /// Returns detailed meal data with nutrition information
  Future<Either<Failure, List<Map<String, dynamic>>>> getMemberMealEntries(
    String memberId,
    DateTime startDate,
    DateTime endDate, {
    bool includePhotos = true,
  });

  /// Add diet feedback from trainer to member
  /// Creates feedback record and notifies member
  Future<Either<Failure, DietFeedback>> addDietFeedback(
    CreateDietFeedbackRequest request,
  );

  /// Get diet feedbacks for a specific member
  /// Returns feedback history ordered by most recent
  Future<Either<Failure, List<DietFeedback>>> getDietFeedbacks(
    String groupId,
    String memberId, {
    int limit = 20,
    int offset = 0,
    FeedbackType? feedbackType,
  });

  /// Get all diet feedbacks in a group
  /// For trainer overview of all feedback activity
  Future<Either<Failure, List<DietFeedback>>> getGroupDietFeedbacks(
    String groupId, {
    int limit = 50,
    int offset = 0,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Mark diet feedback as read
  /// Updates read status for member notifications
  Future<Either<Failure, void>> markFeedbackAsRead(String feedbackId);

  /// Mark multiple feedbacks as read
  /// Bulk operation for notification management
  Future<Either<Failure, void>> markMultipleFeedbacksAsRead(
    List<String> feedbackIds,
  );

  /// Get diet analytics for the group or specific member
  /// Returns comprehensive nutrition statistics and trends
  Future<Either<Failure, Map<String, dynamic>>> getDietAnalytics(
    DietAnalyticsRequest request,
  );

  /// Get member's diet goal achievement rates
  /// Compares actual intake vs goals over time period
  Future<Either<Failure, Map<String, dynamic>>> getMemberGoalAchievement(
    String memberId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get group diet compliance overview
  /// Shows how well all members are following their diet plans
  Future<Either<Failure, Map<String, dynamic>>> getGroupDietCompliance(
    String groupId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Set or update diet sharing permissions for a member
  /// Controls what diet data trainer can access
  Future<Either<Failure, PTGroupDietPermission>> setDietPermissions(
    DietPermissionRequest request,
  );

  /// Get diet sharing permissions for a member
  /// Returns current permission settings
  Future<Either<Failure, PTGroupDietPermission?>> getDietPermissions(
    String groupId,
    String memberId,
    String trainerId,
  );

  /// Get all members' diet permissions in a group
  /// For trainer to see who has granted access
  Future<Either<Failure, List<PTGroupDietPermission>>> getGroupDietPermissions(
    String groupId,
    String trainerId,
  );

  /// Revoke diet sharing permissions
  /// Member can withdraw access to their diet data
  Future<Either<Failure, void>> revokeDietPermissions(
    String groupId,
    String memberId,
    String trainerId,
  );

  /// Get member's diet trends over time
  /// Shows nutrition patterns and changes
  Future<Either<Failure, Map<String, dynamic>>> getMemberDietTrends(
    String memberId,
    DateTime startDate,
    DateTime endDate, {
    String? groupId,
  });

  /// Get group diet comparison
  /// Compares nutrition metrics across all group members
  Future<Either<Failure, Map<String, dynamic>>> getGroupDietComparison(
    String groupId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get diet recommendations based on member's data
  /// AI-powered suggestions for diet improvements
  Future<Either<Failure, List<Map<String, dynamic>>>> getDietRecommendations(
    String memberId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get member's meal timing analysis
  /// Analyzes meal frequency and timing patterns
  Future<Either<Failure, Map<String, dynamic>>> getMealTimingAnalysis(
    String memberId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get nutrition deficiency alerts
  /// Identifies potential nutritional gaps
  Future<Either<Failure, List<Map<String, dynamic>>>> getNutritionAlerts(
    String groupId, {
    String? memberId,
    DateTime? date,
  });

  /// Get diet photo analysis
  /// Analyzes meal photos for portion sizes and food types
  Future<Either<Failure, Map<String, dynamic>>> getDietPhotoAnalysis(
    String mealEntryId,
  );

  /// Create diet summary for a member on a specific date
  /// Aggregates all meal data into summary format
  Future<Either<Failure, PTGroupDietSummary>> createDietSummary(
    String groupId,
    String memberId,
    DateTime date,
  );

  /// Update trainer notes for a member's diet summary
  /// Allows trainer to add observations and recommendations
  Future<Either<Failure, void>> updateTrainerNotes(
    String summaryId,
    String trainerNotes,
  );

  /// Get unread feedback count for a member
  /// For notification badges
  Future<Either<Failure, int>> getUnreadFeedbackCount(String memberId);

  /// Get recent diet activity for group dashboard
  /// Shows latest meals, feedback, and member activity
  Future<Either<Failure, Map<String, dynamic>>> getRecentDietActivity(
    String groupId, {
    int hours = 24,
  });

  /// Export member's diet data
  /// Generates comprehensive diet report for external use
  Future<Either<Failure, Map<String, dynamic>>> exportMemberDietData(
    String memberId,
    DateTime startDate,
    DateTime endDate, {
    String format = 'json', // json, csv, pdf
  });

  /// Get diet coaching insights
  /// Advanced analytics for trainers to provide better guidance
  Future<Either<Failure, Map<String, dynamic>>> getDietCoachingInsights(
    String groupId,
    String memberId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Schedule diet check-in reminder
  /// Automated reminders for members to log meals
  Future<Either<Failure, void>> scheduleDietReminder(
    String groupId,
    String memberId,
    DateTime reminderTime,
    String message,
  );

  /// Get diet adherence score
  /// Calculates how well member follows their diet plan
  Future<Either<Failure, double>> getDietAdherenceScore(
    String memberId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get macro distribution analysis
  /// Detailed breakdown of carbs, protein, fat intake patterns
  Future<Either<Failure, Map<String, dynamic>>> getMacroDistributionAnalysis(
    String memberId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get hydration tracking data
  /// Water intake monitoring for PT groups
  Future<Either<Failure, Map<String, dynamic>>> getHydrationData(
    String memberId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Update member's diet goals
  /// Allows trainer to adjust calorie and macro targets
  Future<Either<Failure, void>> updateMemberDietGoals(
    String memberId,
    double calorieGoal,
    double proteinGoal,
    double carbGoal,
    double fatGoal,
  );
}