import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:jfit/features/todo/data/models/todo_model.dart';
import 'package:jfit/features/todo/data/repositories/todo_repository.dart';

class TodoRepositoryImpl implements TodoRepository {
  final SupabaseClient _supabaseClient;
  final _uuid = const Uuid();

  TodoRepositoryImpl({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  @override
  Future<List<TodoModel>> getTodos(String userId, {DateTime? date}) async {
    try {
      var query = _supabaseClient
          .from('todos')
          .select('*')
          .eq('user_id', userId);

      if (date != null) {
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        query = query
            .gte('created_at', startOfDay.toIso8601String())
            .lt('created_at', endOfDay.toIso8601String());
      }

      final response = await query.order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => TodoModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get todos: $e');
    }
  }

  @override
  Future<TodoModel> createTodo(TodoModel todo) async {
    try {
      final todoData = todo.copyWith(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final response = await _supabaseClient
          .from('todos')
          .insert(todoData.toJson())
          .select()
          .single();

      return TodoModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create todo: $e');
    }
  }

  @override
  Future<TodoModel> updateTodo(TodoModel todo) async {
    try {
      final updatedTodo = todo.copyWith(updatedAt: DateTime.now());
      
      final response = await _supabaseClient
          .from('todos')
          .update(updatedTodo.toJson())
          .eq('id', todo.id)
          .select()
          .single();

      return TodoModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update todo: $e');
    }
  }

  @override
  Future<void> deleteTodo(String todoId) async {
    try {
      await _supabaseClient
          .from('todos')
          .delete()
          .eq('id', todoId);
    } catch (e) {
      throw Exception('Failed to delete todo: $e');
    }
  }

  @override
  Future<TodoModel> toggleTodoComplete(String todoId) async {
    try {
      // 먼저 현재 상태를 가져옴
      final current = await _supabaseClient
          .from('todos')
          .select('is_completed')
          .eq('id', todoId)
          .single();

      final newStatus = !(current['is_completed'] as bool);

      final response = await _supabaseClient
          .from('todos')
          .update({
            'is_completed': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', todoId)
          .select()
          .single();

      return TodoModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to toggle todo: $e');
    }
  }

  @override
  Future<List<TodoModel>> getTodosByCategory(String userId, String category) async {
    try {
      final response = await _supabaseClient
          .from('todos')
          .select('*')
          .eq('user_id', userId)
          .eq('category', category)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => TodoModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get todos by category: $e');
    }
  }

  @override
  Future<int> getTodayTodoCount(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabaseClient
          .from('todos')
          .select('id')
          .eq('user_id', userId)
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String());

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<int> getCompletedTodoCount(String userId, {DateTime? date}) async {
    try {
      final targetDate = date ?? DateTime.now();
      final startOfDay = DateTime(targetDate.year, targetDate.month, targetDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _supabaseClient
          .from('todos')
          .select('id')
          .eq('user_id', userId)
          .eq('is_completed', true)
          .gte('created_at', startOfDay.toIso8601String())
          .lt('created_at', endOfDay.toIso8601String());

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }
}