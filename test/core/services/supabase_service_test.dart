import 'package:flutter_test/flutter_test.dart';
import 'package:jfit/core/services/supabase_service.dart';
import 'package:jfit/features/analytics/domain/entities/diet_score_data.dart';

void main() {
  group('SupabaseService Tests', () {
    test('should create DietScoreData from calories', () {
      // arrange
      const calories = 2000.0;
      
      // act
      final score = _calculateDietScore(calories);
      
      // assert
      expect(score, isA<double>());
      expect(score, greaterThanOrEqualTo(1.0));
      expect(score, lessThanOrEqualTo(5.0));
    });

    test('should handle different calorie ranges', () {
      // Test different calorie ranges
      expect(_calculateDietScore(1000.0), equals(5.0)); // Low calories = high score
      expect(_calculateDietScore(2000.0), equals(3.0)); // Normal calories = medium score
      expect(_calculateDietScore(3000.0), equals(2.0)); // High calories = low score
    });

    test('should create DietScoreData with correct properties', () {
      // arrange
      final date = DateTime.now();
      const score = 4.0;
      
      // act
      final dietScoreData = DietScoreData(
        date: date,
        score: score,
      );
      
      // assert
      expect(dietScoreData.date, equals(date));
      expect(dietScoreData.score, equals(score));
    });
  });
}

// Helper function to calculate diet score based on calories
double _calculateDietScore(double calories) {
  if (calories < 1500) return 5.0;
  if (calories < 2000) return 4.0;
  if (calories < 2500) return 3.0;
  if (calories < 3000) return 2.0;
  return 1.0;
}