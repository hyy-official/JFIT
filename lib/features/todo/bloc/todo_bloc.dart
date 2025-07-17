import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/features/todo/bloc/todo_event.dart';
import 'package:jfit/features/todo/bloc/todo_state.dart';
import 'package:jfit/features/todo/data/repositories/todo_repository.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository _repository;

  TodoBloc({required TodoRepository repository})
      : _repository = repository,
        super(TodoInitial()) {
    on<LoadTodos>(_onLoadTodos);
    on<CreateTodo>(_onCreateTodo);
    on<UpdateTodo>(_onUpdateTodo);
    on<DeleteTodo>(_onDeleteTodo);
    on<ToggleTodoComplete>(_onToggleTodoComplete);
    on<LoadTodosByCategory>(_onLoadTodosByCategory);
    on<LoadTodoStats>(_onLoadTodoStats);
  }

  Future<void> _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    try {
      final todos = await _repository.getTodos(event.userId, date: event.date);
      final totalCount = todos.length;
      final completedCount = todos.where((todo) => todo.isCompleted).length;

      emit(TodoLoaded(
        todos: todos,
        totalCount: totalCount,
        completedCount: completedCount,
      ));
    } catch (e) {
      emit(TodoError(message: '할 일 목록을 불러오는데 실패했습니다: $e'));
    }
  }

  Future<void> _onCreateTodo(CreateTodo event, Emitter<TodoState> emit) async {
    try {
      final createdTodo = await _repository.createTodo(event.todo);
      emit(TodoOperationSuccess(
        message: '할 일이 추가되었습니다',
        todo: createdTodo,
      ));
      
      // 목록 새로고침
      add(LoadTodos(userId: event.todo.userId));
    } catch (e) {
      emit(TodoError(message: '할 일 추가에 실패했습니다: $e'));
    }
  }

  Future<void> _onUpdateTodo(UpdateTodo event, Emitter<TodoState> emit) async {
    try {
      final updatedTodo = await _repository.updateTodo(event.todo);
      emit(TodoOperationSuccess(
        message: '할 일이 수정되었습니다',
        todo: updatedTodo,
      ));
      
      // 목록 새로고침
      add(LoadTodos(userId: event.todo.userId));
    } catch (e) {
      emit(TodoError(message: '할 일 수정에 실패했습니다: $e'));
    }
  }

  Future<void> _onDeleteTodo(DeleteTodo event, Emitter<TodoState> emit) async {
    try {
      await _repository.deleteTodo(event.todoId);
      emit(const TodoOperationSuccess(message: '할 일이 삭제되었습니다'));
      
      // 현재 상태에서 사용자 ID를 가져와서 목록 새로고침
      if (state is TodoLoaded) {
        final currentState = state as TodoLoaded;
        if (currentState.todos.isNotEmpty) {
          add(LoadTodos(userId: currentState.todos.first.userId));
        }
      }
    } catch (e) {
      emit(TodoError(message: '할 일 삭제에 실패했습니다: $e'));
    }
  }

  Future<void> _onToggleTodoComplete(ToggleTodoComplete event, Emitter<TodoState> emit) async {
    try {
      final updatedTodo = await _repository.toggleTodoComplete(event.todoId);
      emit(TodoOperationSuccess(
        message: updatedTodo.isCompleted ? '할 일을 완료했습니다' : '할 일을 미완료로 변경했습니다',
        todo: updatedTodo,
      ));
      
      // 현재 상태에서 사용자 ID를 가져와서 목록 새로고침
      if (state is TodoLoaded) {
        final currentState = state as TodoLoaded;
        if (currentState.todos.isNotEmpty) {
          add(LoadTodos(userId: currentState.todos.first.userId));
        }
      }
    } catch (e) {
      emit(TodoError(message: '할 일 상태 변경에 실패했습니다: $e'));
    }
  }

  Future<void> _onLoadTodosByCategory(LoadTodosByCategory event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    try {
      final todos = await _repository.getTodosByCategory(event.userId, event.category);
      final totalCount = todos.length;
      final completedCount = todos.where((todo) => todo.isCompleted).length;

      emit(TodoLoaded(
        todos: todos,
        totalCount: totalCount,
        completedCount: completedCount,
      ));
    } catch (e) {
      emit(TodoError(message: '카테고리별 할 일 목록을 불러오는데 실패했습니다: $e'));
    }
  }

  Future<void> _onLoadTodoStats(LoadTodoStats event, Emitter<TodoState> emit) async {
    try {
      final todayCount = await _repository.getTodayTodoCount(event.userId);
      final completedCount = await _repository.getCompletedTodoCount(
        event.userId,
        date: event.date,
      );
      
      final completionRate = todayCount > 0 ? (completedCount / todayCount) * 100 : 0.0;

      emit(TodoStatsLoaded(
        todayCount: todayCount,
        completedCount: completedCount,
        completionRate: completionRate,
      ));
    } catch (e) {
      emit(TodoError(message: '할 일 통계를 불러오는데 실패했습니다: $e'));
    }
  }
}