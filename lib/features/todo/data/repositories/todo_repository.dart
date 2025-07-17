import 'package:jfit/features/todo/data/models/todo_model.dart';

abstract class TodoRepository {
  Future<List<TodoModel>> getTodos(String userId, {DateTime? date});
  Future<TodoModel> createTodo(TodoModel todo);
  Future<TodoModel> updateTodo(TodoModel todo);
  Future<void> deleteTodo(String todoId);
  Future<TodoModel> toggleTodoComplete(String todoId);
  Future<List<TodoModel>> getTodosByCategory(String userId, String category);
  Future<int> getTodayTodoCount(String userId);
  Future<int> getCompletedTodoCount(String userId, {DateTime? date});
}