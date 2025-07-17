import 'package:equatable/equatable.dart';
import 'package:jfit/features/todo/data/models/todo_model.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodos extends TodoEvent {
  final String userId;
  final DateTime? date;

  const LoadTodos({
    required this.userId,
    this.date,
  });

  @override
  List<Object?> get props => [userId, date];
}

class CreateTodo extends TodoEvent {
  final TodoModel todo;

  const CreateTodo({required this.todo});

  @override
  List<Object?> get props => [todo];
}

class UpdateTodo extends TodoEvent {
  final TodoModel todo;

  const UpdateTodo({required this.todo});

  @override
  List<Object?> get props => [todo];
}

class DeleteTodo extends TodoEvent {
  final String todoId;

  const DeleteTodo({required this.todoId});

  @override
  List<Object?> get props => [todoId];
}

class ToggleTodoComplete extends TodoEvent {
  final String todoId;

  const ToggleTodoComplete({required this.todoId});

  @override
  List<Object?> get props => [todoId];
}

class LoadTodosByCategory extends TodoEvent {
  final String userId;
  final String category;

  const LoadTodosByCategory({
    required this.userId,
    required this.category,
  });

  @override
  List<Object?> get props => [userId, category];
}

class LoadTodoStats extends TodoEvent {
  final String userId;
  final DateTime? date;

  const LoadTodoStats({
    required this.userId,
    this.date,
  });

  @override
  List<Object?> get props => [userId, date];
}