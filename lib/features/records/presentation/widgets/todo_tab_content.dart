import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:jfit/core/widgets/enhanced_error_feedback.dart';
import 'package:jfit/features/auth/bloc/auth_bloc.dart';
import 'package:jfit/features/auth/bloc/auth_state.dart';
import 'package:jfit/features/todo/bloc/todo_bloc.dart';
import 'package:jfit/features/todo/bloc/todo_event.dart';
import 'package:jfit/features/todo/bloc/todo_state.dart';
import 'package:jfit/features/todo/data/models/todo_model.dart';
import 'package:jfit/features/todo/presentation/widgets/todo_add_sheet.dart';
import 'package:get_it/get_it.dart';

class TodoTabContent extends StatefulWidget {
  final DateTime selectedDate;

  const TodoTabContent({
    super.key,
    required this.selectedDate,
  });

  @override
  State<TodoTabContent> createState() => _TodoTabContentState();
}

class _TodoTabContentState extends State<TodoTabContent> 
    with AutomaticKeepAliveClientMixin {
  
  late TodoBloc _todoBloc;

  @override
  void initState() {
    super.initState();
    _todoBloc = GetIt.instance<TodoBloc>();
    _loadTodos();
  }

  @override
  void dispose() {
    _todoBloc.close();
    super.dispose();
  }

  void _loadTodos() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _todoBloc.add(LoadTodos(
        userId: authState.user.id,
        date: widget.selectedDate,
      ));
    }
  }

  @override
  void didUpdateWidget(TodoTabContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _loadTodos();
    }
  }

  void _showAddTodoSheet({TodoModel? editTodo}) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    if (isDesktop) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => BlocProvider.value(
          value: _todoBloc,
          child: Dialog(
            insetPadding: const EdgeInsets.all(32),
            backgroundColor: Colors.transparent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: TodoAddSheetContent(
                  selectedDate: widget.selectedDate,
                  editTodo: editTodo,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => BlocProvider.value(
          value: _todoBloc,
          child: FractionallySizedBox(
            heightFactor: 0.9,
            child: TodoAddSheetContent(
              selectedDate: widget.selectedDate,
              editTodo: editTodo,
            ),
          ),
        ),
      );
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return BlocProvider.value(
      value: _todoBloc,
      child: BlocConsumer<TodoBloc, TodoState>(
        listener: (context, state) {
          if (state is TodoOperationSuccess) {
            EnhancedErrorFeedback.showSuccessSnackBar(
              context,
              message: state.message,
            );
            _loadTodos(); // 목록 새로고침
          } else if (state is TodoError) {
            EnhancedErrorFeedback.showErrorSnackBar(
              context,
              message: state.message,
              isRetryable: false,
            );
          }
        },
        builder: (context, state) {
          if (state is TodoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TodoLoaded) {
            if (state.todos.isEmpty) {
              return _buildEmptyState();
            } else {
              return _buildTodoList(state.todos, state.completedCount, state.totalCount);
            }
          } else if (state is TodoError) {
            return _buildErrorState(state.message);
          } else {
            // 초기 상태이면 할 일 로드
            _loadTodos();
            return _buildEmptyState();
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.colors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.task_alt,
              size: 48,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '할 일이 없습니다',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '새로운 할 일을 추가해보세요',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddTodoSheet(),
            icon: const Icon(Icons.add),
            label: const Text('할 일 추가'),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList(List<TodoModel> todos, int completedCount, int totalCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더 섹션
        _buildHeader(completedCount, totalCount),
        const SizedBox(height: 16),
        
        // 할 일 목록
        Expanded(
          child: ListView.separated(
            itemCount: todos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final todo = todos[index];
              return _buildTodoCard(todo);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(int completedCount, int totalCount) {
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.selectedDate.month}월 ${widget.selectedDate.day}일 할 일',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completedCount/$totalCount 완료',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: context.colors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          FloatingActionButton.small(
            onPressed: () => _showAddTodoSheet(),
            backgroundColor: context.colors.primary,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoCard(TodoModel todo) {
    final priorityColor = _getPriorityColor(todo.priority);
    final categoryIcon = _getCategoryIcon(todo.category);
    final dueDateInfo = _getDueDateInfo(todo.dueDate);
    
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: todo.isCompleted 
              ? context.colors.success.withOpacity(0.3)
              : dueDateInfo.isOverdue
                  ? Colors.red.withOpacity(0.3)
                  : context.colors.border,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: GestureDetector(
              onTap: () => _todoBloc.add(ToggleTodoComplete(todoId: todo.id)),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: todo.isCompleted 
                      ? context.colors.success
                      : Colors.transparent,
                  border: Border.all(
                    color: todo.isCompleted 
                        ? context.colors.success
                        : dueDateInfo.isOverdue
                            ? Colors.red
                            : context.colors.border,
                    width: 2,
                  ),
                ),
                child: todo.isCompleted
                    ? Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            title: Text(
              todo.title,
              style: context.textTheme.bodyLarge?.copyWith(
                decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                color: todo.isCompleted 
                    ? context.colors.textSecondary
                    : context.colors.textPrimary,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (todo.description != null) ...[
                  Text(
                    todo.description!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                ],
                // 마감기한 표시
                if (todo.dueDate != null)
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: dueDateInfo.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dueDateInfo.text,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: dueDateInfo.color,
                          fontWeight: dueDateInfo.isOverdue || dueDateInfo.isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (todo.isCompleted) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: context.colors.success,
                        ),
                        Text(
                          ' 완료됨',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 카테고리 아이콘
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    categoryIcon,
                    size: 16,
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                // 우선순위 표시
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                // 더보기 메뉴
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showAddTodoSheet(editTodo: todo);
                        break;
                      case 'delete':
                        _todoBloc.add(DeleteTodo(todoId: todo.id));
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('수정'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16),
                          SizedBox(width: 8),
                          Text('삭제'),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(
                    Icons.more_vert,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // 완료된 할 일에 대한 성취감 표시
          if (todo.isCompleted && todo.dueDate != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: context.colors.success.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.celebration,
                    size: 16,
                    color: context.colors.success,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dueDateInfo.isOverdue 
                        ? '늦었지만 완료했습니다! 👏'
                        : dueDateInfo.isToday
                            ? '오늘 완료했습니다! 🎉'
                            : '일찍 완료했습니다! ⭐',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: context.colors.error, size: 48),
          const SizedBox(height: 16),
          Text(
            '할 일을 불러오는 중 오류가 발생했습니다',
            style: TextStyle(color: context.colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: context.colors.textMuted, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadTodos,
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'fitness':
        return Icons.fitness_center;
      case 'diet':
        return Icons.restaurant;
      case 'general':
      default:
        return Icons.task_alt;
    }
  }

  DueDateInfo _getDueDateInfo(DateTime? dueDate) {
    if (dueDate == null) {
      return DueDateInfo(
        text: '',
        color: Colors.grey,
        isOverdue: false,
        isToday: false,
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = dueDateOnly.difference(today).inDays;

    if (difference < 0) {
      // 마감일이 지남
      return DueDateInfo(
        text: '${-difference}일 지남',
        color: Colors.red,
        isOverdue: true,
        isToday: false,
      );
    } else if (difference == 0) {
      // 오늘이 마감일
      return DueDateInfo(
        text: '오늘 마감',
        color: Colors.orange,
        isOverdue: false,
        isToday: true,
      );
    } else if (difference == 1) {
      // 내일이 마감일
      return DueDateInfo(
        text: '내일 마감',
        color: Colors.orange,
        isOverdue: false,
        isToday: false,
      );
    } else if (difference <= 3) {
      // 3일 이내
      return DueDateInfo(
        text: '${difference}일 후',
        color: Colors.orange,
        isOverdue: false,
        isToday: false,
      );
    } else if (difference <= 7) {
      // 일주일 이내
      return DueDateInfo(
        text: '${difference}일 후',
        color: Colors.blue,
        isOverdue: false,
        isToday: false,
      );
    } else {
      // 일주일 이후
      return DueDateInfo(
        text: '${dueDate.month}/${dueDate.day}',
        color: Colors.grey,
        isOverdue: false,
        isToday: false,
      );
    }
  }
}

class DueDateInfo {
  final String text;
  final Color color;
  final bool isOverdue;
  final bool isToday;

  DueDateInfo({
    required this.text,
    required this.color,
    required this.isOverdue,
    required this.isToday,
  });
}