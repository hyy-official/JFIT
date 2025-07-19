import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/features/group_workout_community/domain/entities/user_workout_score.dart';
import 'package:jfit/features/group_workout_community/domain/entities/body_part_mapping.dart';

void main() {
  group('UserWorkoutScore', () {
    final testScore = UserWorkoutScore(
      id: 'score-id',
      userId: 'user-id',
      groupId: 'group-id',
      scoreDate: DateTime(2024, 1, 1),
      totalScore: 85.5,
      bodyBalanceScore: 88.0,
      volumeScore: 92.5,
      progressScore: 78.2,
      consistencyScore: 83.8,
      bodyPartScores: {
        BodyPart.chest: 85.0,
        BodyPart.back: 90.0,
        BodyPart.legs: 88.5,
        BodyPart.shoulders: 82.0,
        BodyPart.arms: 87.5,
        BodyPart.core: 89.0,
      },
      createdAt: DateTime(2024, 1, 1),
    );

    group('Entity Creation', () {
      test('should create UserWorkoutScore with required fields', () {
        expect(testScore.id, 'score-id');
        expect(testScore.userId, 'user-id');
        expect(testScore.groupId, 'group-id');
        expect(testScore.scoreDate, DateTime(2024, 1, 1));
        expect(testScore.totalScore, 85.5);
        expect(testScore.bodyBalanceScore, 88.0);
        expect(testScore.volumeScore, 92.5);
        expect(testScore.progressScore, 78.2);
        expect(testScore.consistencyScore, 83.8);
        expect(testScore.bodyPartScores.length, 6);
        expect(testScore.createdAt, DateTime(2024, 1, 1));
      });

      test('should create UserWorkoutScore with empty body part scores', () {
        final scoreWithEmptyBodyParts = UserWorkoutScore(
          id: 'score-id-2',
          userId: 'user-id-2',
          groupId: 'group-id-2',
          scoreDate: DateTime(2024, 1, 2),
          totalScore: 75.0,
          bodyBalanceScore: 80.0,
          volumeScore: 85.0,
          progressScore: 70.0,
          consistencyScore: 75.0,
          bodyPartScores: {},
          createdAt: DateTime(2024, 1, 2),
        );

        expect(scoreWithEmptyBodyParts.bodyPartScores.isEmpty, true);
      });
    });

    group('Equality', () {
      test('should be equal when all properties are the same', () {
        final score1 = UserWorkoutScore(
          id: 'score-id',
          userId: 'user-id',
          groupId: 'group-id',
          scoreDate: DateTime(2024, 1, 1),
          totalScore: 85.5,
          bodyBalanceScore: 88.0,
          volumeScore: 92.5,
          progressScore: 78.2,
          consistencyScore: 83.8,
          bodyPartScores: {
            BodyPart.chest: 85.0,
            BodyPart.back: 90.0,
          },
          createdAt: DateTime(2024, 1, 1),
        );

        final score2 = UserWorkoutScore(
          id: 'score-id',
          userId: 'user-id',
          groupId: 'group-id',
          scoreDate: DateTime(2024, 1, 1),
          totalScore: 85.5,
          bodyBalanceScore: 88.0,
          volumeScore: 92.5,
          progressScore: 78.2,
          consistencyScore: 83.8,
          bodyPartScores: {
            BodyPart.chest: 85.0,
            BodyPart.back: 90.0,
          },
          createdAt: DateTime(2024, 1, 1),
        );

        expect(score1, equals(score2));
        expect(score1.hashCode, equals(score2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final score1 = testScore;
        final score2 = testScore.copyWith(totalScore: 90.0);

        expect(score1, isNot(equals(score2)));
        expect(score1.hashCode, isNot(equals(score2.hashCode)));
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final updatedScore = testScore.copyWith(
          totalScore: 90.0,
          bodyBalanceScore: 95.0,
          bodyPartScores: {
            BodyPart.chest: 90.0,
            BodyPart.back: 95.0,
            BodyPart.legs: 92.0,
          },
        );

        expect(updatedScore.id, testScore.id);
        expect(updatedScore.userId, testScore.userId);
        expect(updatedScore.groupId, testScore.groupId);
        expect(updatedScore.totalScore, 90.0);
        expect(updatedScore.bodyBalanceScore, 95.0);
        expect(updatedScore.volumeScore, testScore.volumeScore);
        expect(updatedScore.bodyPartScores.length, 3);
        expect(updatedScore.bodyPartScores[BodyPart.chest], 90.0);
      });

      test('should create copy with same values when no changes', () {
        final copiedScore = testScore.copyWith();

        expect(copiedScore, equals(testScore));
        expect(copiedScore.hashCode, equals(testScore.hashCode));
      });
    });

    group('Business Logic Properties', () {
      test('isExcellent should return true for high scores', () {
        final excellentScore = testScore.copyWith(totalScore: 85.0);
        expect(excellentScore.isExcellent, true);

        final goodScore = testScore.copyWith(totalScore: 75.0);
        expect(goodScore.isExcellent, false);

        final averageScore = testScore.copyWith(totalScore: 55.0);
        expect(averageScore.isExcellent, false);
      });

      test('isGood should return true for good scores', () {
        final excellentScore = testScore.copyWith(totalScore: 85.0);
        expect(excellentScore.isGood, true);

        final goodScore = testScore.copyWith(totalScore: 65.0);
        expect(goodScore.isGood, true);

        final averageScore = testScore.copyWith(totalScore: 55.0);
        expect(averageScore.isGood, false);

        final poorScore = testScore.copyWith(totalScore: 45.0);
        expect(poorScore.isGood, false);
      });

      test('scoreGrade should return correct grade', () {
        final sScore = testScore.copyWith(totalScore: 95.0);
        expect(sScore.scoreGrade, 'S');

        final aScore = testScore.copyWith(totalScore: 85.0);
        expect(aScore.scoreGrade, 'A');

        final bScore = testScore.copyWith(totalScore: 75.0);
        expect(bScore.scoreGrade, 'B');

        final cScore = testScore.copyWith(totalScore: 65.0);
        expect(cScore.scoreGrade, 'C');

        final dScore = testScore.copyWith(totalScore: 55.0);
        expect(dScore.scoreGrade, 'D');

        final fScore = testScore.copyWith(totalScore: 45.0);
        expect(fScore.scoreGrade, 'F');
      });

      test('strongestBodyPart should return body part with highest score', () {
        final score = testScore.copyWith(
          bodyPartScores: {
            BodyPart.chest: 85.0,
            BodyPart.back: 95.0, // Highest
            BodyPart.legs: 88.5,
            BodyPart.shoulders: 82.0,
            BodyPart.arms: 87.5,
            BodyPart.core: 89.0,
          },
        );

        expect(score.strongestBodyPart, BodyPart.back);
      });

      test('weakestBodyPart should return body part with lowest score', () {
        final score = testScore.copyWith(
          bodyPartScores: {
            BodyPart.chest: 85.0,
            BodyPart.back: 90.0,
            BodyPart.legs: 88.5,
            BodyPart.shoulders: 75.0, // Lowest
            BodyPart.arms: 87.5,
            BodyPart.core: 89.0,
          },
        );

        expect(score.weakestBodyPart, BodyPart.shoulders);
      });

      test('strongestBodyPart should return null for empty body part scores', () {
        final score = testScore.copyWith(bodyPartScores: {});
        expect(score.strongestBodyPart, null);
      });

      test('weakestBodyPart should return null for empty body part scores', () {
        final score = testScore.copyWith(bodyPartScores: {});
        expect(score.weakestBodyPart, null);
      });

      test('isBalanced should return true for balanced scores', () {
        // Test with high balance score (>= 80% of 100)
        final balancedScore = testScore.copyWith(bodyBalanceScore: 85.0);
        expect(balancedScore.isBalanced, true);

        // Test with low balance score (< 80% of 100)
        final unbalancedScore = testScore.copyWith(bodyBalanceScore: 75.0);
        expect(unbalancedScore.isBalanced, false);
      });

      test('getBodyPartScore should return correct score for body part', () {
        expect(testScore.getBodyPartScore(BodyPart.chest), 85.0);
        expect(testScore.getBodyPartScore(BodyPart.back), 90.0);
        expect(testScore.getBodyPartScore(BodyPart.legs), 88.5);
        
        // Test for non-existent body part
        final emptyScore = testScore.copyWith(bodyPartScores: {});
        expect(emptyScore.getBodyPartScore(BodyPart.chest), 0.0);
      });

      test('bodyPartScoreStandardDeviation should calculate correctly', () {
        final score = testScore.copyWith(
          bodyPartScores: {
            BodyPart.chest: 80.0,
            BodyPart.back: 90.0,
            BodyPart.legs: 85.0,
          },
        );

        // Standard deviation calculation for [80, 90, 85]
        // Mean = 85, variance = ((80-85)² + (90-85)² + (85-85)²) / 3 = (25 + 25 + 0) / 3 = 16.67
        // StdDev = sqrt(16.67) ≈ 4.08
        expect(score.bodyPartScoreStandardDeviation, closeTo(4.08, 0.1));

        // Empty scores should return 0
        final emptyScore = testScore.copyWith(bodyPartScores: {});
        expect(emptyScore.bodyPartScoreStandardDeviation, 0.0);
      });

      test('bodyPartsNeedingImprovement should return correct body parts', () {
        final score = testScore.copyWith(
          bodyPartScores: {
            BodyPart.chest: 85.0,
            BodyPart.back: 90.0,
            BodyPart.legs: 88.0,
            BodyPart.shoulders: 60.0, // This should need improvement (< 80% of average)
            BodyPart.arms: 87.0,
            BodyPart.core: 89.0,
          },
        );

        final improvementNeeded = score.bodyPartsNeedingImprovement;
        expect(improvementNeeded, contains(BodyPart.shoulders));
        
        // Empty scores should return empty list
        final emptyScore = testScore.copyWith(bodyPartScores: {});
        expect(emptyScore.bodyPartsNeedingImprovement, isEmpty);
      });

      test('scoreSummary should return comprehensive summary', () {
        final summary = testScore.scoreSummary;

        expect(summary['total'], 85.5);
        expect(summary['balance'], 88.0);
        expect(summary['volume'], 92.5);
        expect(summary['progress'], 78.2);
        expect(summary['consistency'], 83.8);
        expect(summary['grade'], 'A');
        expect(summary['isBalanced'], true);
        expect(summary['strongestBodyPart'], BodyPart.back.name);
        expect(summary['weakestBodyPart'], BodyPart.shoulders.name);
        expect(summary['improvementNeeded'], isA<List>());
      });
    });

    group('Validation Logic', () {
      test('should handle negative scores', () {
        expect(() => testScore.copyWith(totalScore: -10.0), returnsNormally);
        expect(() => testScore.copyWith(bodyBalanceScore: -5.0), returnsNormally);
        expect(() => testScore.copyWith(volumeScore: -15.0), returnsNormally);
      });

      test('should handle scores above 100', () {
        expect(() => testScore.copyWith(totalScore: 110.0), returnsNormally);
        expect(() => testScore.copyWith(bodyBalanceScore: 105.0), returnsNormally);
        expect(() => testScore.copyWith(volumeScore: 120.0), returnsNormally);
      });

      test('should handle extreme body part scores', () {
        final extremeScores = {
          BodyPart.chest: -10.0,
          BodyPart.back: 150.0,
          BodyPart.legs: 0.0,
          BodyPart.shoulders: 100.0,
        };
        
        expect(() => testScore.copyWith(bodyPartScores: extremeScores), returnsNormally);
      });
    });

    group('Edge Cases and Error Conditions', () {
      test('should handle null and empty values appropriately', () {
        final minimalScore = UserWorkoutScore(
          id: '',
          userId: '',
          groupId: '',
          scoreDate: DateTime(1970, 1, 1),
          totalScore: 0.0,
          bodyBalanceScore: 0.0,
          volumeScore: 0.0,
          progressScore: 0.0,
          consistencyScore: 0.0,
          bodyPartScores: {},
          createdAt: DateTime(1970, 1, 1),
        );

        expect(minimalScore.id, '');
        expect(minimalScore.userId, '');
        expect(minimalScore.groupId, '');
        expect(minimalScore.totalScore, 0.0);
        expect(minimalScore.bodyPartScores.isEmpty, true);
        expect(minimalScore.scoreGrade, 'F');
        expect(minimalScore.strongestBodyPart, null);
        expect(minimalScore.weakestBodyPart, null);
      });

      test('should handle extreme date values', () {
        final extremeScore = testScore.copyWith(
          scoreDate: DateTime(1900, 1, 1),
          createdAt: DateTime(2100, 12, 31),
        );

        expect(extremeScore.scoreDate.year, 1900);
        expect(extremeScore.createdAt.year, 2100);
      });

      test('should handle single body part score', () {
        final singleBodyPartScore = testScore.copyWith(
          bodyPartScores: {BodyPart.chest: 85.0},
        );

        expect(singleBodyPartScore.strongestBodyPart, BodyPart.chest);
        expect(singleBodyPartScore.weakestBodyPart, BodyPart.chest);
        expect(singleBodyPartScore.bodyPartScoreStandardDeviation, 0.0);
      });
    });

    group('Comparison and Sorting', () {
      test('should support comparison by total score', () {
        final score1 = testScore.copyWith(totalScore: 80.0);
        final score2 = testScore.copyWith(totalScore: 90.0);
        final score3 = testScore.copyWith(totalScore: 85.0);

        final scores = [score1, score2, score3];
        scores.sort((a, b) => b.totalScore.compareTo(a.totalScore)); // Descending

        expect(scores[0].totalScore, 90.0);
        expect(scores[1].totalScore, 85.0);
        expect(scores[2].totalScore, 80.0);
      });

      test('should support comparison by score date', () {
        final score1 = testScore.copyWith(scoreDate: DateTime(2024, 1, 1));
        final score2 = testScore.copyWith(scoreDate: DateTime(2024, 1, 3));
        final score3 = testScore.copyWith(scoreDate: DateTime(2024, 1, 2));

        final scores = [score1, score2, score3];
        scores.sort((a, b) => a.scoreDate.compareTo(b.scoreDate)); // Ascending

        expect(scores[0].scoreDate, DateTime(2024, 1, 1));
        expect(scores[1].scoreDate, DateTime(2024, 1, 2));
        expect(scores[2].scoreDate, DateTime(2024, 1, 3));
      });

      test('should support comparison by specific component scores', () {
        final score1 = testScore.copyWith(volumeScore: 80.0);
        final score2 = testScore.copyWith(volumeScore: 95.0);
        final score3 = testScore.copyWith(volumeScore: 87.5);

        final scores = [score1, score2, score3];
        scores.sort((a, b) => b.volumeScore.compareTo(a.volumeScore)); // Descending

        expect(scores[0].volumeScore, 95.0);
        expect(scores[1].volumeScore, 87.5);
        expect(scores[2].volumeScore, 80.0);
      });
    });
  });
}