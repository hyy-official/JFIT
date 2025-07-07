import 'package:jfit/core/services/supabase_service.dart';
import '../models/food_search_item.dart';

class FoodApiService {
  final _supabase = SupabaseService();

  Future<List<FoodSearchItem>> searchFoods(String query) async {
    if (query.isEmpty) return [];
    final rows = await _supabase.searchFoodItems(query);
    return rows.map((e) => FoodSearchItem.fromJson(e)).toList();
  }
} 