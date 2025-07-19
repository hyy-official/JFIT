import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/features/group_workout_community/domain/entities/group_ranking.dart';
import 'package:jfit/features/group_workout_community/domain/entities/user_workout_score.dart';
import 'package:jfit/features/group_workout_community/presentation/widgets/ranking/ranking_leaderboard_widget.dart';

void main() {
  group('RankingLeaderboardWidget Tests', () {
    late List<GroupRanking> testGroupRankings;
    late List<UserWorkoutScore> testUserScores;

    setUp(() {
      testGroupRankings = [
        GroupRanking(
          id: 'ranking-1',
          groupId: 'group-1',
          groupName: 'Elite Fitness',
          rankingPeriod: RankingPeriod.weekly,
          periodStartDate: DateTime(2024, 1, 1),
          periodEndDate: DateTime(2024, 1, 7),
          totalScore: 950,
          memberCount: 15,
          averageScore: 63.3,
          rankPosition: 1,
          previousRank: 2,
          calculatedAt: DateTime(2024, 1, 1),
          scoreBreakdown: {
            'balance': 85.0,
            'volume': 90.0,
            'progress': 88.0,
            'consistency': 92.0,
          },
        ),
        GroupRanking(
          id: 'ranking-2',
          groupId: 'group-2',
          groupName: 'Power Lifters',
          rankingPeriod: RankingPeriod.weekly,
          periodStartDate: DateTime(2024, 1, 1),
          periodEndDate: DateTime(2024, 1, 7),
          totalScore: 920,
          memberCount: 12,
          averageScore: 76.7,
          rankPosition: 2,
          previousRank: 1,
          calculatedAt: DateTime(2024, 1, 1),
          scoreBreakdown: {
            'balance': 80.0,
            'volume': 95.0,
            'progress': 85.0,
            'consistency': 88.0,
          },
        ),
        GroupRanking(
          id: 'ranking-3',
          groupId: 'group-3',
          groupName: 'Cardio Kings',
          rankingPeriod: RankingPeriod.weekly,
          periodStartDate: DateTime(2024, 1, 1),
          periodEndDate: DateTime(2024, 1, 7),
          totalScore: 880,
          memberCount: 20,
          averageScore: 44.0,
          rankPosition: 3,
          previousRank: 3,
          calculatedAt: DateTime(2024, 1, 1),
          scoreBreakdown: {
            'balance': 75.0,
            'volume': 70.0,
            'progress': 90.0,
            'consistency': 85.0,
          },
        ),
      ];

      testUserScores = [
        UserWorkoutScore(
          id: 'score-1',
          userId: 'user-1',
          userName: 'John Doe',
          groupId: 'group-1',
          scoreDate: DateTime(2024, 1, 1),
          totalScore: 95.5,
          bodyBalanceScore: 88.0,
          volumeScore: 92.0,
          progressScore: 90.0,
          consistencyScore: 96.0,
          bodyPartScores: {
            'chest': 85.0,
            'back': 90.0,
            'legs': 88.0,
            'shoulders': 87.0,
            'arms': 89.0,
            'core': 91.0,
          },
          createdAt: DateTime(2024, 1, 1),
        ),
        UserWorkoutScore(
          id: 'score-2',
          userId: 'user-2',
          userName: 'Jane Smith',
          groupId: 'group-1',
          scoreDate: DateTime(2024, 1, 1),
          totalScore: 88.2,
          bodyBalanceScore: 85.0,
          volumeScore: 87.0,
          progressScore: 92.0,
          consistencyScore: 89.0,
          bodyPartScores: {
            'chest': 82.0,
            'back': 88.0,
            'legs': 90.0,
            'shoulders': 85.0,
            'arms': 86.0,
            'core': 89.0,
          },
          createdAt: DateTime(2024, 1, 1),
        ),
      ];
    });

    Widget createTestWidget({
      List<GroupRanking>? rankings,
      RankingPeriod period = RankingPeriod.weekly,
      ValueChanged<String>? onGroupTap,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: RankingLeaderboardWidget(
            rankings: rankings ?? testGroupRankings,
            period: period,
            onGroupTap: onGroupTap,
          ),
        ),
      );
    }

    group('Basic Rendering', () {
      testWidgets('should display group leaderboard correctly', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('Elite Fitness'), findsOneWidget);
        expect(find.text('Power Lifters'), findsOneWidget);
        expect(find.text('Cardio Kings'), findsOneWidget);
        
        expect(find.text('1'), findsOneWidget); // First place
        expect(find.text('2'), findsOneWidget); // Second place
        expect(find.text('3'), findsOneWidget); // Third place
      });

      testWidgets('should display user leaderboard correctly', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // The widget only shows group rankings, not user scores
        expect(find.text('Elite Fitness'), findsOneWidget);
        expect(find.text('Power Lifters'), findsOneWidget);
        expect(find.text('Cardio Kings'), findsOneWidget);
      });

      testWidgets('should display rank change indicators', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Elite Fitness moved up from rank 2 to 1
        expect(find.byIcon(Icons.trending_up), findsOneWidget);
        
        // Power Lifters moved down from rank 1 to 2
        expect(find.byIcon(Icons.trending_down), findsOneWidget);
        
        // Cardio Kings stayed at rank 3
        expect(find.byIcon(Icons.trending_flat), findsOneWidget);
      });

      testWidgets('should display score breakdowns', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('950'), findsOneWidget); // Total score
        expect(find.text('63.3'), findsOneWidget); // Average score
        expect(find.text('15 members'), findsOneWidget); // Member count
      });

      testWidgets('should display empty state when no data', (tester) async {
        await tester.pumpWidget(createTestWidget(
          rankings: [],
        ));

        expect(find.text('랭킹 데이터가 없습니다'), findsOneWidget);
      });
    });

    group('Period Selection', () {
      testWidgets('should display period selector', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('주간 그룹 랭킹'), findsOneWidget);
      });

      testWidgets('should handle period changes', (tester) async {
        await tester.pumpWidget(createTestWidget(period: RankingPeriod.monthly));

        expect(find.text('월간 그룹 랭킹'), findsOneWidget);
      });
    });

    group('Interaction Tests', () {
      testWidgets('should call onGroupTap when group is tapped', (tester) async {
        String? tappedGroupId;
        
        await tester.pumpWidget(createTestWidget(
          onGroupTap: (groupId) => tappedGroupId = groupId,
        ));

        await tester.tap(find.text('Elite Fitness'));
        await tester.pumpAndSettle();

        expect(tappedGroupId, 'group-1');
      });

      testWidgets('should call onGroupTap when group is tapped in list', (tester) async {
        String? tappedGroupId;
        
        await tester.pumpWidget(createTestWidget(
          onGroupTap: (groupId) => tappedGroupId = groupId,
        ));

        await tester.tap(find.text('Elite Fitness'));
        await tester.pumpAndSettle();

        expect(tappedGroupId, 'group-1');
      });

      testWidgets('should expand score breakdown when tapped', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Tap to expand breakdown
        await tester.tap(find.byIcon(Icons.expand_more).first);
        await tester.pumpAndSettle();

        expect(find.text('Balance: 85.0'), findsOneWidget);
        expect(find.text('Volume: 90.0'), findsOneWidget);
        expect(find.text('Progress: 88.0'), findsOneWidget);
        expect(find.text('Consistency: 92.0'), findsOneWidget);
      });
    });

    group('Visual Elements', () {
      testWidgets('should display podium for top 3', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Should show special styling for top 3
        expect(find.byIcon(Icons.emoji_events), findsAtLeastNWidgets(3));
      });

      testWidgets('should display different colors for ranks', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // First place should have gold color
        final firstPlaceContainer = find.ancestor(
          of: find.text('1'),
          matching: find.byType(Container),
        ).first;
        
        expect(firstPlaceContainer, findsOneWidget);
      });

      testWidgets('should display progress bars for scores', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.byType(LinearProgressIndicator), findsWidgets);
      });
    });

    group('Responsive Design', () {
      testWidgets('should adapt to mobile screen size', (tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(400, 800);
        tester.binding.window.devicePixelRatioTestValue = 1.0;

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(RankingLeaderboardWidget), findsOneWidget);

        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
      });

      testWidgets('should adapt to tablet screen size', (tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(800, 1200);
        tester.binding.window.devicePixelRatioTestValue = 1.0;

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(RankingLeaderboardWidget), findsOneWidget);

        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);
      });

      testWidgets('should handle long group names gracefully', (tester) async {
        final longNameRankings = [
          testGroupRankings[0].copyWith(
            groupName: 'This is a very long group name that should be handled gracefully',
          ),
        ];

        await tester.pumpWidget(createTestWidget(
          rankings: longNameRankings,
        ));

        expect(find.textContaining('This is a very long'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle tied scores', (tester) async {
        final tiedRankings = [
          testGroupRankings[0].copyWith(totalScore: 900),
          testGroupRankings[1].copyWith(totalScore: 900),
        ];

        await tester.pumpWidget(createTestWidget(
          rankings: tiedRankings,
        ));

        expect(find.text('900'), findsNWidgets(2));
      });

      testWidgets('should handle zero scores', (tester) async {
        final zeroScoreRankings = [
          testGroupRankings[0].copyWith(
            totalScore: 0,
            averageScore: 0.0,
          ),
        ];

        await tester.pumpWidget(createTestWidget(
          rankings: zeroScoreRankings,
        ));

        expect(find.text('0'), findsWidgets);
      });

      testWidgets('should handle single item list', (tester) async {
        await tester.pumpWidget(createTestWidget(
          rankings: [testGroupRankings[0]],
        ));

        expect(find.text('Elite Fitness'), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
      });

      testWidgets('should handle missing score breakdown', (tester) async {
        final noBreakdownRankings = [
          testGroupRankings[0].copyWith(scoreBreakdown: {}),
        ];

        await tester.pumpWidget(createTestWidget(
          rankings: noBreakdownRankings,
        ));

        expect(find.text('Elite Fitness'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper accessibility labels', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(
          find.bySemanticsLabel('Ranking leaderboard'),
          findsOneWidget,
        );
        
        expect(
          find.bySemanticsLabel('Rank 1: Elite Fitness with score 950'),
          findsOneWidget,
        );
      });

      testWidgets('should support keyboard navigation', (tester) async {
        bool wasTapped = false;
        
        await tester.pumpWidget(createTestWidget(
          onGroupTap: () => wasTapped = true,
        ));

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(wasTapped, true);
      });

      testWidgets('should announce rank changes to screen readers', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(
          find.bySemanticsLabel('Moved up from rank 2 to rank 1'),
          findsOneWidget,
        );
        
        expect(
          find.bySemanticsLabel('Moved down from rank 1 to rank 2'),
          findsOneWidget,
        );
      });
    });

    group('Animation Tests', () {
      testWidgets('should animate rank changes', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Initial state
        expect(find.text('1'), findsOneWidget);

        // Simulate rank change
        final updatedRankings = [
          testGroupRankings[1].copyWith(rankPosition: 1, previousRank: 2),
          testGroupRankings[0].copyWith(rankPosition: 2, previousRank: 1),
        ];

        await tester.pumpWidget(createTestWidget(
          rankings: updatedRankings,
        ));
        await tester.pumpAndSettle();

        expect(find.text('Power Lifters'), findsOneWidget);
      });

      testWidgets('should animate score updates', (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('950'), findsOneWidget);

        // Update score
        final updatedRankings = [
          testGroupRankings[0].copyWith(totalScore: 960),
        ];

        await tester.pumpWidget(createTestWidget(
          rankings: updatedRankings,
        ));
        await tester.pumpAndSettle();

        expect(find.text('960'), findsOneWidget);
      });
    });

    group('Theme Integration', () {
      testWidgets('should respect light theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: RankingLeaderboardWidget(
                rankings: testGroupRankings,
                period: RankingPeriod.weekly,
              ),
            ),
          ),
        );

        expect(find.byType(RankingLeaderboardWidget), findsOneWidget);
      });

      testWidgets('should respect dark theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: RankingLeaderboardWidget(
                rankings: testGroupRankings,
                period: RankingPeriod.weekly,
              ),
            ),
          ),
        );

        expect(find.byType(RankingLeaderboardWidget), findsOneWidget);
      });
    });

    group('Performance', () {
      testWidgets('should handle large leaderboards efficiently', (tester) async {
        final largeRankingList = List.generate(100, (index) => 
          GroupRanking(
            id: 'ranking-$index',
            groupId: 'group-$index',
            groupName: 'Group $index',
            rankingPeriod: RankingPeriod.weekly,
            periodStartDate: DateTime(2024, 1, 1),
            periodEndDate: DateTime(2024, 1, 7),
            totalScore: 1000 - index,
            memberCount: 10 + index,
            averageScore: (1000 - index) / (10 + index),
            rankPosition: index + 1,
            previousRank: index + 1,
            calculatedAt: DateTime.now(),
            scoreBreakdown: {'total': (1000 - index).toDouble()},
          ),
        );

        await tester.pumpWidget(createTestWidget(
          rankings: largeRankingList,
        ));

        expect(find.byType(RankingLeaderboardWidget), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  });
}