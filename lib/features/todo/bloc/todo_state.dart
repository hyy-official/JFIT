import 'package:equatable/equatable.dart';
import 'package:jfit/features/todo/data/models/todo_model.dart';

abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object?> get props => [];
}

class TodoInitial extends TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<TodoModel> todos;
  final int totalCount;
  final int completedCount;

  const TodoLoaded({
    required this.todos,
    required this.totalCount,
    required this.completedCount,
  });

  @override
  List<Object?> get props => [todos, totalCount, completedCount];

  TodoLoaded copyWith({
    List<TodoModel>? todos,
    int? totalCount,
    int? completedCount,
  }) {
    return TodoLoaded(
      todos: todos ?? this.todos,
      totalCount: totalCount ?? this.totalCount,
      completedCount: completedCount ?? this.completedCount,
    );
  }
}

class TodoError extends TodoState {
  final String message;

  const TodoError({required this.message});

  @override
  List<Object?> get props => [message];
}

class TodoOperationSuccess extends TodoState {
  final String message;
  final TodoModel? todo;

  const TodoOperationSuccess({
    required this.message,
    this.todo,
  });

  @override
  List<Object?> get props => [message, todo];
}

class TodoStatsLoaded extends TodoState {
  final int todayCount;
  final int completedCount;
  final double completionRate;

  const TodoStatsLoaded({
    required this.todayCount,
    required this.completedCount,
    required this.completionRate,
  });

  @override
  List<Object?> get props => [todayCount, completedCount, completionRate];
}