import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jfit/core/navigation/main_navigation_page.dart';
import 'package:jfit/core/widgets/auth_gate.dart';
import 'package:jfit/features/analytics/presentation/pages/analytics_page.dart';
import 'package:jfit/features/records/presentation/pages/record_page.dart';
import 'package:jfit/features/workout_session/presentation/pages/workout_session_page.dart';
import 'package:jfit/features/programs/presentation/pages/programs_page.dart';

// Group Workout Community Pages
import 'package:jfit/features/group_workout_community/presentation/pages/group_list_page.dart';
import 'package:jfit/features/group_workout_community/presentation/pages/group_create_page.dart';
import 'package:jfit/features/group_workout_community/presentation/pages/group_detail_page.dart';
import 'package:jfit/features/group_workout_community/presentation/pages/group_join_page.dart';
import 'package:jfit/features/group_workout_community/presentation/pages/group_chat_page.dart';
import 'package:jfit/features/group_workout_community/presentation/pages/community_board_page.dart';
import 'package:jfit/features/group_workout_community/presentation/pages/post_create_page.dart';
import 'package:jfit/features/group_workout_community/presentation/pages/routine_share_page.dart';
import 'package:jfit/features/group_workout_community/presentation/pages/shared_routine_detail_page.dart';
import 'package:jfit/features/group_workout_community/presentation/pages/encouragement_message_page.dart';
import 'package:jfit/features/group_workout_community/presentation/pages/group_ranking_leaderboard_page.dart';
import 'package:jfit/features/group_workout_community/presentation/pages/user_workout_score_dashboard_page.dart';
import 'package:jfit/features/group_workout_community/presentation/pages/group_member_score_comparison_page.dart';
import 'package:jfit/features/group_workout_community/presentation/pages/score_detailed_analysis_page.dart';
import 'package:jfit/features/group_workout_community/presentation/pages/ranking_history_trends_page.dart';
import 'package:jfit/features/group_workout_community/presentation/pages/pt_group_diet_dashboard_page.dart';
import 'package:jfit/features/group_workout_community/presentation/pages/member_diet_detail_page.dart';
import 'package:jfit/features/group_workout_community/presentation/pages/diet_feedback_create_page.dart';
import 'package:jfit/features/group_workout_community/presentation/pages/diet_analysis_report_page.dart';
import 'package:jfit/features/group_workout_community/presentation/pages/diet_permissions_settings_page.dart';

/// App routing configuration using GoRouter
class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      // Main shell route with bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          return AuthGate(
            child: MainNavigationPage(
              initialIndex: _getInitialIndexFromPath(state.fullPath ?? '/'),
              child: child,
            ),
          );
        },
        routes: [
          // Home route
          GoRoute(
            path: '/',
            builder: (context, state) => const RecordPage(),
          ),
          
          // Workout route
          GoRoute(
            path: '/workout',
            name: 'workout',
            builder: (context, state) => WorkoutSessionPage(
              sessionId: state.uri.queryParameters['sessionId'],
              programId: state.uri.queryParameters['programId'],
              programDay: int.tryParse(state.uri.queryParameters['programDay'] ?? ''),
              targetWeek: int.tryParse(state.uri.queryParameters['targetWeek'] ?? ''),
              targetDay: int.tryParse(state.uri.queryParameters['targetDay'] ?? ''),
              showNavigation: state.uri.queryParameters['showNavigation'] == 'true',
            ),
          ),
          
          // Programs route
          GoRoute(
            path: '/programs',
            name: 'programs',
            builder: (context, state) => const ProgramsPage(),
          ),
          
          // Groups route
          GoRoute(
            path: '/groups',
            name: 'groups',
            builder: (context, state) => const GroupListPage(),
          ),
          
          // Community route
          GoRoute(
            path: '/community',
            name: 'community',
            builder: (context, state) => const CommunityBoardPage(),
          ),
          
          // Analytics route
          GoRoute(
            path: '/analytics',
            name: 'analytics',
            builder: (context, state) => const AnalyticsPage(),
          ),
        ],
      ),
      
      // Standalone Group Workout Community Routes (outside shell)
      GoRoute(
        path: '/group-create',
        name: 'group-create-standalone',
        builder: (context, state) => const AuthGate(child: GroupCreatePage()),
      ),
      
      GoRoute(
        path: '/group-join',
        name: 'group-join-standalone',
        builder: (context, state) {
          final inviteCode = state.uri.queryParameters['invite'];
          return AuthGate(child: GroupJoinPage(inviteCode: inviteCode));
        },
      ),
      
      GoRoute(
        path: '/group/:groupId',
        name: 'group-detail-standalone',
        builder: (context, state) {
          final groupId = state.pathParameters['groupId']!;
          return AuthGate(child: GroupDetailPage(groupId: groupId));
        },
        routes: [
          // Group chat
          GoRoute(
            path: '/chat',
            name: 'group-chat-standalone',
            builder: (context, state) {
              final groupId = state.pathParameters['groupId']!;
              return AuthGate(child: GroupChatPage(groupId: groupId, groupName: 'Group Chat'));
            },
          ),
          
          // Routine sharing
          GoRoute(
            path: '/share-routine',
            name: 'routine-share-standalone',
            builder: (context, state) {
              final groupId = state.pathParameters['groupId']!;
              return AuthGate(child: RoutineSharePage(groupId: groupId));
            },
          ),
          
          // Shared routine detail
          GoRoute(
            path: '/routines/:routineId',
            name: 'shared-routine-detail-standalone',
            builder: (context, state) {
              final routineId = state.pathParameters['routineId']!;
              return AuthGate(child: SharedRoutineDetailPage(sharedRoutineId: routineId));
            },
          ),
          
          // Encouragement message
          GoRoute(
            path: '/encourage/:targetUserId',
            name: 'encouragement-message-standalone',
            builder: (context, state) {
              final groupId = state.pathParameters['groupId']!;
              final targetUserId = state.pathParameters['targetUserId']!;
              return AuthGate(
                child: EncouragementMessagePage(
                  groupId: groupId,
                  groupMembers: const [], // TODO: Load group members
                ),
              );
            },
          ),
          
          // Group ranking
          GoRoute(
            path: '/ranking',
            name: 'group-ranking-standalone',
            builder: (context, state) {
              final groupId = state.pathParameters['groupId']!;
              return AuthGate(child: GroupRankingLeaderboardPage(groupId: groupId));
            },
            routes: [
              // Member score comparison
              GoRoute(
                path: '/comparison',
                name: 'member-score-comparison-standalone',
                builder: (context, state) {
                  final groupId = state.pathParameters['groupId']!;
                  return AuthGate(child: GroupMemberScoreComparisonPage(
                groupId: groupId,
                groupName: 'Group', // TODO: Load group name
              ));
                },
              ),
              
              // Ranking history
              GoRoute(
                path: '/history',
                name: 'ranking-history-standalone',
                builder: (context, state) {
                  final groupId = state.pathParameters['groupId']!;
                  return AuthGate(child: RankingHistoryTrendsPage(groupId: groupId));
                },
              ),
            ],
          ),
          
          // PT Diet Dashboard (for PT groups)
          GoRoute(
            path: '/diet-dashboard',
            name: 'pt-diet-dashboard-standalone',
            builder: (context, state) {
              final groupId = state.pathParameters['groupId']!;
              return AuthGate(child: PTGroupDietDashboardPage(
                groupId: groupId,
                trainerId: 'current_trainer_id', // TODO: Get current trainer ID
              ));
            },
            routes: [
              // Member diet detail
              GoRoute(
                path: '/member/:memberId',
                name: 'member-diet-detail-standalone',
                builder: (context, state) {
                  final groupId = state.pathParameters['groupId']!;
                  final memberId = state.pathParameters['memberId']!;
                  return AuthGate(
                    child: MemberDietDetailPage(
                      groupId: groupId,
                      memberId: memberId,
                      memberName: 'Member', // TODO: Get member name
                    ),
                  );
                },
                routes: [
                  // Diet feedback creation
                  GoRoute(
                    path: '/feedback',
                    name: 'diet-feedback-create-standalone',
                    builder: (context, state) {
                      final groupId = state.pathParameters['groupId']!;
                      final memberId = state.pathParameters['memberId']!;
                      final mealEntryId = state.uri.queryParameters['mealEntryId'];
                      return AuthGate(
                        child: DietFeedbackCreatePage(
                          groupId: groupId,
                          memberId: memberId,
                          trainerId: 'current_trainer_id', // TODO: Get current trainer ID
                          mealEntryId: mealEntryId,
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              // Diet analysis report
              GoRoute(
                path: '/analysis',
                name: 'diet-analysis-report-standalone',
                builder: (context, state) {
                  final groupId = state.pathParameters['groupId']!;
                  return AuthGate(child: DietAnalysisReportPage(
                groupId: groupId,
                startDate: DateTime.now().subtract(const Duration(days: 30)),
                endDate: DateTime.now(),
              ));
                },
              ),
              
              // Diet permissions settings
              GoRoute(
                path: '/permissions',
                name: 'diet-permissions-settings-standalone',
                builder: (context, state) {
                  final groupId = state.pathParameters['groupId']!;
                  return AuthGate(child: DietPermissionsSettingsPage(
                groupId: groupId,
                memberId: 'current_member_id', // TODO: Get current member ID
                trainerId: 'current_trainer_id', // TODO: Get current trainer ID
              ));
                },
              ),
            ],
          ),
        ],
      ),
      
      // Community Board Routes (standalone)
      GoRoute(
        path: '/post-create',
        name: 'post-create-standalone',
        builder: (context, state) {
          final groupId = state.uri.queryParameters['groupId'];
          return AuthGate(child: PostCreatePage(groupId: groupId));
        },
      ),
      
      GoRoute(
        path: '/post/:postId',
        name: 'post-detail-standalone',
        builder: (context, state) {
          final postId = state.pathParameters['postId']!;
          // Navigate back to community board with post highlighted
          return AuthGate(child: CommunityBoardPage());
        },
      ),
      
      // User Workout Score Dashboard
      GoRoute(
        path: '/my-score',
        name: 'user-workout-score',
        builder: (context, state) => AuthGate(child: UserWorkoutScoreDashboardPage(
          userId: 'current_user_id', // TODO: Get current user ID
        )),
        routes: [
          // Detailed score analysis
          GoRoute(
            path: '/analysis',
            name: 'score-detailed-analysis',
            builder: (context, state) {
              final userId = state.uri.queryParameters['userId'];
              final period = state.uri.queryParameters['period'];
              return AuthGate(
                child: ScoreDetailedAnalysisPage(
                  userId: userId ?? 'current_user_id',
                ),
              );
            },
          ),
        ],
      ),
      
      // Deep link routes for sharing
      GoRoute(
        path: '/invite/:inviteCode',
        name: 'group-invite-deeplink',
        redirect: (context, state) {
          final inviteCode = state.pathParameters['inviteCode']!;
          return '/group-join?invite=$inviteCode';
        },
      ),
      
      GoRoute(
        path: '/share/post/:postId',
        name: 'post-share-deeplink',
        redirect: (context, state) {
          final postId = state.pathParameters['postId']!;
          return '/post/$postId';
        },
      ),
      
      GoRoute(
        path: '/share/group/:groupId',
        name: 'group-share-deeplink',
        redirect: (context, state) {
          final groupId = state.pathParameters['groupId']!;
          return '/group/$groupId';
        },
      ),
      
      GoRoute(
        path: '/share/routine/:routineId',
        name: 'routine-share-deeplink',
        redirect: (context, state) {
          final routineId = state.pathParameters['routineId']!;
          final groupId = state.uri.queryParameters['groupId'];
          if (groupId != null) {
            return '/group/$groupId/routines/$routineId';
          }
          return '/group/shared-routine/$routineId';
        },
      ),
      
      // Standalone shared routine detail (when no group context)
      GoRoute(
        path: '/group/shared-routine/:routineId',
        name: 'shared-routine-standalone',
        builder: (context, state) {
          final routineId = state.pathParameters['routineId']!;
          return AuthGate(child: SharedRoutineDetailPage(sharedRoutineId: routineId));
        },
      ),
    ],
    
    // Error handling
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('페이지를 찾을 수 없습니다'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '요청하신 페이지를 찾을 수 없습니다.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Path: ${state.fullPath}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('홈으로 돌아가기'),
            ),
          ],
        ),
      ),
    ),
    
    // Deep link handling
    redirect: (context, state) {
      // Handle deep links for group invites
      if (state.fullPath?.startsWith('/invite/') == true) {
        final inviteCode = state.fullPath?.split('/invite/').last;
        return '/group-join?invite=$inviteCode';
      }
      
      // Handle deep links for post sharing
      if (state.fullPath?.startsWith('/share/post/') == true) {
        final postId = state.fullPath?.split('/share/post/').last;
        return '/post/$postId';
      }
      
      // Handle deep links for group sharing
      if (state.fullPath?.startsWith('/share/group/') == true) {
        final groupId = state.fullPath?.split('/share/group/').last;
        return '/group/$groupId';
      }
      
      // Handle deep links for routine sharing
      if (state.fullPath?.startsWith('/share/routine/') == true) {
        final routineId = state.fullPath?.split('/share/routine/').last;
        // Extract group ID from query parameters if available
        final groupId = state.uri.queryParameters['groupId'];
        if (groupId != null) {
          return '/group/$groupId/routines/$routineId';
        }
        return '/group/shared-routine/$routineId';
      }
      
      return null; // No redirect needed
    },
  );

  static GoRouter get router => _router;

  /// Get initial navigation index based on path
  static int _getInitialIndexFromPath(String path) {
    if (path.startsWith('/workout') || path.startsWith('/session')) {
      return 1; // Workout tab
    } else if (path.startsWith('/programs') || path.startsWith('/routines')) {
      return 2; // Programs tab
    }
    return 0; // Home tab (default)
  }
}

/// Extension methods for easy navigation
extension AppRouterExtension on BuildContext {
  // === Group Navigation ===
  
  /// Navigate to group list
  void goToGroups() => go('/groups');
  
  /// Navigate to create new group
  void goToCreateGroup() => go('/group-create');
  
  /// Navigate to join group with optional invite code
  void goToJoinGroup({String? inviteCode}) {
    final query = inviteCode != null ? '?invite=$inviteCode' : '';
    go('/group-join$query');
  }
  
  /// Navigate to group detail
  void goToGroupDetail(String groupId) => go('/group/$groupId');
  
  /// Navigate to group chat
  void goToGroupChat(String groupId) => go('/group/$groupId/chat');
  
  /// Navigate to share routine in group
  void goToShareRoutine(String groupId) => go('/group/$groupId/share-routine');
  
  /// Navigate to shared routine detail
  void goToSharedRoutineDetail(String groupId, String routineId) => 
      go('/group/$groupId/routines/$routineId');
  
  /// Navigate to encouragement message
  void goToEncouragementMessage(String groupId, String targetUserId) => 
      go('/group/$groupId/encourage/$targetUserId');
  
  // === Community Navigation ===
  
  /// Navigate to community board
  void goToCommunity() => go('/community');
  
  /// Navigate to create post
  void goToCreatePost({String? groupId}) {
    final query = groupId != null ? '?groupId=$groupId' : '';
    go('/post-create$query');
  }
  
  /// Navigate to post detail
  void goToPostDetail(String postId) => go('/post/$postId');
  
  // === Ranking Navigation ===
  
  /// Navigate to user score dashboard
  void goToMyScore() => go('/my-score');
  
  /// Navigate to group ranking
  void goToGroupRanking(String groupId) => go('/group/$groupId/ranking');
  
  /// Navigate to member score comparison
  void goToMemberScoreComparison(String groupId) => 
      go('/group/$groupId/ranking/comparison');
  
  /// Navigate to ranking history
  void goToRankingHistory(String groupId) => 
      go('/group/$groupId/ranking/history');
  
  /// Navigate to detailed score analysis
  void goToScoreAnalysis({String? userId, String? period}) {
    final params = <String, String>{};
    if (userId != null) params['userId'] = userId;
    if (period != null) params['period'] = period;
    
    final query = params.isNotEmpty 
        ? '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}'
        : '';
    go('/my-score/analysis$query');
  }
  
  // === PT Diet Navigation ===
  
  /// Navigate to PT diet dashboard
  void goToPTDietDashboard(String groupId) => go('/group/$groupId/diet-dashboard');
  
  /// Navigate to member diet detail
  void goToMemberDietDetail(String groupId, String memberId) => 
      go('/group/$groupId/diet-dashboard/member/$memberId');
  
  /// Navigate to diet feedback creation
  void goToDietFeedbackCreate(String groupId, String memberId, {String? mealEntryId}) {
    final query = mealEntryId != null ? '?mealEntryId=$mealEntryId' : '';
    go('/group/$groupId/diet-dashboard/member/$memberId/feedback$query');
  }
  
  /// Navigate to diet analysis report
  void goToDietAnalysisReport(String groupId) => 
      go('/group/$groupId/diet-dashboard/analysis');
  
  /// Navigate to diet permissions settings
  void goToDietPermissionsSettings(String groupId) => 
      go('/group/$groupId/diet-dashboard/permissions');
  
  // === Sharing & Deep Links ===
  
  /// Generate and share group invite link
  String generateGroupInviteLink(String inviteCode) {
    return '/invite/$inviteCode';
  }
  
  /// Generate and share post link
  String generatePostShareLink(String postId) {
    return '/share/post/$postId';
  }
  
  /// Generate and share group link
  String generateGroupShareLink(String groupId) {
    return '/share/group/$groupId';
  }
  
  /// Generate and share routine link
  String generateRoutineShareLink(String routineId, {String? groupId}) {
    final query = groupId != null ? '?groupId=$groupId' : '';
    return '/share/routine/$routineId$query';
  }
  
  /// Share group invite (navigate to join page)
  void shareGroupInvite(String inviteCode) {
    goToJoinGroup(inviteCode: inviteCode);
  }
  
  /// Share post (navigate to post detail)
  void sharePost(String postId) {
    goToPostDetail(postId);
  }
  
  /// Share group (navigate to group detail)
  void shareGroup(String groupId) {
    goToGroupDetail(groupId);
  }
  
  /// Share routine (navigate to routine detail)
  void shareRoutine(String routineId, {String? groupId}) {
    if (groupId != null) {
      goToSharedRoutineDetail(groupId, routineId);
    } else {
      go('/group/shared-routine/$routineId');
    }
  }
  
  // === Navigation Helpers ===
  
  /// Check if current route is in groups section
  bool get isInGroupsSection {
    final location = GoRouterState.of(this).fullPath;
    return location?.startsWith('/groups') == true || 
           location?.startsWith('/group') == true;
  }
  
  /// Check if current route is in community section
  bool get isInCommunitySection {
    final location = GoRouterState.of(this).fullPath;
    return location?.startsWith('/community') == true || 
           location?.startsWith('/post') == true;
  }
  
  /// Get current group ID from route if available
  String? get currentGroupId {
    final state = GoRouterState.of(this);
    return state.pathParameters['groupId'];
  }
  
  /// Get current post ID from route if available
  String? get currentPostId {
    final state = GoRouterState.of(this);
    return state.pathParameters['postId'];
  }
}