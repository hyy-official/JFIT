import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:jfit/features/auth/bloc/auth_bloc.dart';
import 'package:jfit/features/auth/bloc/auth_state.dart';
import 'package:jfit/features/todo/bloc/todo_bloc.dart';
import 'package:jfit/features/todo/bloc/todo_event.dart';
import 'package:jfit/features/todo/bloc/todo_state.dart';
import 'package:jfit/features/todo/data/models/todo_model.dart';
import 'package:uuid/uuid.dart';

class TodoAddSheetContent extends StatefulWidget {
  final DateTime selectedDate;
  final TodoModel? editTodo; // 수정할 때 사용

  const TodoAddSheetContent({
    super.key,
    required this.selectedDate,
    this.editTodo,
  });

  @override
  State<TodoAddSheetContent> createState() => _TodoAddSheetContentState();
}

class _TodoAddSheetContentState extends State<TodoAddSheetContent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _uuid = const Uuid();
  
  String _selectedPriority = 'medium';
  String _selectedCategory = 'general';
  DateTime? _selectedDueDate;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _priorities = [
    {'value': 'low', 'label': '낮음', 'color': Colors.green},
    {'value': 'medium', 'label': '보통', 'color': Colors.orange},
    {'value': 'high', 'label': '높음', 'color': Colors.red},
  ];

  final List<Map<String, dynamic>> _categories = [
    {'value': 'general', 'label': '일반', 'icon': Icons.task_alt},
    {'value': 'fitness', 'label': '운동', 'icon': Icons.fitness_center},
    {'value': 'diet', 'label': '식단', 'icon': Icons.restaurant},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editTodo != null) {
      _titleController.text = widget.editTodo!.title;
      _descriptionController.text = widget.editTodo!.description ?? '';
      _selectedPriority = widget.editTodo!.priority;
      _selectedCategory = widget.editTodo!.category;
      _selectedDueDate = widget.editTodo!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() => _isLoading = true);

    final todo = TodoModel(
      id: widget.editTodo?.id ?? _uuid.v4(),
      userId: authState.user.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      isCompleted: widget.editTodo?.isCompleted ?? false,
      dueDate: _selectedDueDate,
      priority: _selectedPriority,
      category: _selectedCategory,
      createdAt: widget.editTodo?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.editTodo != null) {
      context.read<TodoBloc>().add(UpdateTodo(todo: todo));
    } else {
      context.read<TodoBloc>().add(CreateTodo(todo: todo));
    }
  }

  void _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() => _selectedDueDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TodoBloc, TodoState>(
      listener: (context, state) {
        if (state is TodoOperationSuccess) {
          setState(() => _isLoading = false);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is TodoError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: context.colors.error,
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.colors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.add_task,
                    color: context.colors.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.editTodo != null ? '할 일 수정' : '새 할 일 추가',
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: context.colors.textSecondary),
                  ),
                ],
              ),
            ),
            
            // 폼 내용
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목
                      Text(
                        '제목',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: '할 일을 입력하세요',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '제목을 입력해주세요';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // 설명
                      Text(
                        '설명 (선택사항)',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: '상세 설명을 입력하세요',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.description),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // 우선순위
                      Text(
                        '우선순위',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: _priorities.map((priority) {
                          final isSelected = _selectedPriority == priority['value'];
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedPriority = priority['value']),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? priority['color'].withOpacity(0.2)
                                      : context.colors.surface,
                                  border: Border.all(
                                    color: isSelected 
                                        ? priority['color']
                                        : context.colors.border,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  priority['label'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected 
                                        ? priority['color']
                                        : context.colors.textSecondary,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // 카테고리
                      Text(
                        '카테고리',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: _categories.map((category) {
                          final isSelected = _selectedCategory == category['value'];
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedCategory = category['value']),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? context.colors.primary.withOpacity(0.2)
                                      : context.colors.surface,
                                  border: Border.all(
                                    color: isSelected 
                                        ? context.colors.primary
                                        : context.colors.border,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      category['icon'],
                                      color: isSelected 
                                          ? context.colors.primary
                                          : context.colors.textSecondary,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      category['label'],
                                      style: TextStyle(
                                        color: isSelected 
                                            ? context.colors.primary
                                            : context.colors.textSecondary,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // 마감일
                      Text(
                        '마감일 (선택사항)',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _selectDueDate,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: context.colors.border),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: context.colors.textSecondary),
                              const SizedBox(width: 12),
                              Text(
                                _selectedDueDate != null
                                    ? '${_selectedDueDate!.year}년 ${_selectedDueDate!.month}월 ${_selectedDueDate!.day}일'
                                    : '마감일 선택',
                                style: TextStyle(
                                  color: _selectedDueDate != null
                                      ? context.colors.textPrimary
                                      : context.colors.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              if (_selectedDueDate != null)
                                GestureDetector(
                                  onTap: () => setState(() => _selectedDueDate = null),
                                  child: Icon(Icons.clear, color: context.colors.textSecondary),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // 버튼
            Container(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          widget.editTodo != null ? '수정하기' : '추가하기',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}