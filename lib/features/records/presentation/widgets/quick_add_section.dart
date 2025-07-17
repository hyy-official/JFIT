import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/theme/theme_system.dart';
import 'package:jfit/features/records/presentation/widgets/diet_add_sheet.dart';
import 'package:jfit/features/records/presentation/widgets/body_add_sheet.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_bloc.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_event.dart';
import 'package:jfit/features/workout_program/bloc/workout_program_state.dart';
import 'package:jfit/features/workout_program/data/models/current_workout_info_model.dart';
import 'package:jfit/features/auth/bloc/auth_bloc.dart';
import 'package:jfit/features/auth/bloc/auth_state.dart';
import 'package:jfit/features/records/presentation/widgets/program_detail_sheet.dart';
import 'package:jfit/features/todo/presentation/widgets/todo_add_sheet.dart';
import 'package:jfit/features/todo/bloc/todo_bloc.dart';
import 'package:get_it/get_it.dart';

/// Quick Add Section with Workout card spanning 2 columns
class QuickAddSection extends StatelessWidget {
  const QuickAddSection({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = (MediaQuery.of(context).size.width >= 1024) ? 16.0 : 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 추가',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: spacing / 2),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardHeight = constraints.maxWidth >= 768 ? 120.0 : 100.0;

            return Column(
              children: [
                // 첫 번째 줄: 운동 카드와 할 일 카드
                Row(
                  children: [
                    Expanded(
                      flex: 2, // 운동 카드가 더 넓게
                      child: WorkoutCard(height: cardHeight),
                    ),
                    SizedBox(width: spacing),
                    Expanded(
                      flex: 1, // 할 일 카드는 좁게
                      child: QuickCard(icon: Icons.task_alt, label: '할 일', accent: context.colors.info),
                    ),
                  ],
                ),
                SizedBox(height: spacing),
                // 두 번째 줄: 식단과 신체 카드
                Row(
                  children: [
                    Expanded(child: QuickCard(icon: Icons.restaurant, label: '식단', accent: context.colors.success)),
                    SizedBox(width: spacing),
                    Expanded(child: QuickCard(icon: Icons.person, label: '신체', accent: context.colors.warning)),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class WorkoutCard extends StatefulWidget {
  final double height;
  const WorkoutCard({super.key, required this.height});

  @override
  State<WorkoutCard> createState() => _WorkoutCardState();
}

class _WorkoutCardState extends State<WorkoutCard> {
  bool _hovering = false;
  CurrentWorkoutInfoModel? _cachedWorkoutInfo;
  WorkoutProgramBloc? _workoutProgramBloc;

  @override
  void initState() {
    super.initState();
    print('🚀 [WorkoutCard] initState called');
    _workoutProgramBloc = GetIt.instance<WorkoutProgramBloc>();
    // 현재 운동 정보 로드
    _loadCurrentWorkoutInfo();
  }

  @override
  void dispose() {
    _workoutProgramBloc?.close();
    super.dispose();
  }

  void _loadCurrentWorkoutInfo() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      print('🎯 [QuickAdd] Loading current workout info for user: ${authState.user.id}');
      _workoutProgramBloc?.add(LoadCurrentWorkoutInfo(userId: authState.user.id));
    } else {
      print('❌ [QuickAdd] User not authenticated');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 의존성이 변경될 때마다 운동 정보 다시 로드
    if (_cachedWorkoutInfo == null) {
      _loadCurrentWorkoutInfo();
    }
  }

  void _handleTap(CurrentWorkoutInfoModel workoutInfo) {
    if (workoutInfo.hasActiveProgram && workoutInfo.activeProgram?.id != null) {
      _showProgramDetailSheet(
        context, 
        workoutInfo.activeProgram!.id,
        workoutInfo.activeProgram?.workoutProgram?.name ?? '운동 프로그램',
        workoutInfo.progressPercentage,
      );
    } else {
      // 운동 프로그램이 없으면 프로그램 선택 화면으로 이동
      // TODO: 프로그램 선택 화면 구현
    }
  }

  String _getProgressText(CurrentWorkoutInfoModel workoutInfo) {
    if (!workoutInfo.hasActiveProgram) return '운동 시작하기';
    
    final programName = workoutInfo.activeProgram?.workoutProgram?.name ?? '운동 프로그램';
    final currentWeek = workoutInfo.currentWeek ?? 1;
    final currentDay = workoutInfo.currentDay ?? 1;
    final completedDays = workoutInfo.totalCompletedDays;
    final totalDays = (workoutInfo.activeProgram?.workoutProgram?.durationWeeks ?? 1) * 
                     (workoutInfo.activeProgram?.workoutProgram?.workoutsPerWeek ?? 3);
    
    return '$programName\nWeek $currentWeek, Day $currentDay ($completedDays/$totalDays 완료)';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutProgramBloc, WorkoutProgramState>(
      bloc: _workoutProgramBloc,
      builder: (context, state) {
        print('🎨 [WorkoutCard] BlocBuilder rebuild - State: ${state.runtimeType}');
        
        // 🎯 현재 운동 정보 가져오기
        CurrentWorkoutInfoModel workoutInfo = _cachedWorkoutInfo ?? CurrentWorkoutInfoModel.empty();
        
        // 새로운 운동 정보가 로드되면 캐시 업데이트
        if (state is CurrentWorkoutInfoLoaded) {
          print('✅ [WorkoutCard] CurrentWorkoutInfoLoaded received!');
          print('📋 [WorkoutCard] Workout info: ${state.currentWorkoutInfo.activeProgram?.workoutProgram?.name}');
          workoutInfo = state.currentWorkoutInfo;
          _cachedWorkoutInfo = workoutInfo;
        } else {
          print('ℹ️ [WorkoutCard] Using cached or default workout info');
        }

        return GestureDetector(
          onTap: () => _handleTap(workoutInfo),
          child: MouseRegion(
            onEnter: (_) => setState(() => _hovering = true),
            onExit: (_) => setState(() => _hovering = false),
            child: AnimatedScale(
              scale: _hovering ? 1.02 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: widget.height,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.surface.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _hovering ? context.colors.primary : context.colors.border, 
                    width: 1
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.outline.withOpacity(_hovering ? 0.25 : 0.15),
                      blurRadius: _hovering ? 16 : 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: context.colors.gradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '운동',
                            style: context.textTheme.titleMedium?.copyWith(
                              color: context.colors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getProgressText(workoutInfo),
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colors.textSecondary,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      workoutInfo.hasActiveProgram ? Icons.arrow_forward_ios : Icons.add,
                      color: context.colors.textPrimary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class QuickCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color accent;
  const QuickCard({super.key, required this.icon, required this.label, required this.accent});

  @override
  State<QuickCard> createState() => _QuickCardState();
}

class _QuickCardState extends State<QuickCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    void handleTap() {
      if (widget.label == '식단') {
        _showAddDietSheet(context);
      } else if (widget.label == '신체') {
        _showAddBodySheet(context);
      } else if (widget.label == '할 일') {
        _showAddTodoSheet(context);
      }
    }

    return GestureDetector(
      onTap: handleTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: AnimatedScale(
          scale: _hovering ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.surface.withOpacity(0.75),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _hovering ? widget.accent : context.colors.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: context.colors.shadow.withOpacity(_hovering ? 0.25 : 0.15),
                  blurRadius: _hovering ? 16 : 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [widget.accent.withOpacity(0.8), widget.accent]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, color: context.colors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.label,
                  style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: context.colors.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showAddDietSheet(BuildContext context, {DateTime? date}) {
  final isDesktop = MediaQuery.of(context).size.width >= 1024;
  if (isDesktop) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(32),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: DietAddSheetContent(selectedDate: date ?? DateTime.now()),
          ),
        ),
      ),
    );
  } else {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.9,
        child: DietAddSheetContent(selectedDate: date ?? DateTime.now()),
      ),
    );
  }
}

void _showAddBodySheet(BuildContext context, {DateTime? date}) {
  final isDesktop = MediaQuery.of(context).size.width >= 1024;
  if (isDesktop) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(32),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BodyAddSheetContent(selectedDate: date ?? DateTime.now()),
          ),
        ),
      ),
    );
  } else {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.9,
        child: BodyAddSheetContent(selectedDate: date ?? DateTime.now()),
      ),
    );
  }
}

void _showAddTodoSheet(BuildContext context, {DateTime? date}) {
  final isDesktop = MediaQuery.of(context).size.width >= 1024;
  if (isDesktop) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => BlocProvider(
        create: (context) => GetIt.instance<TodoBloc>(),
        child: Dialog(
          insetPadding: const EdgeInsets.all(32),
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: TodoAddSheetContent(selectedDate: date ?? DateTime.now()),
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
      builder: (ctx) => BlocProvider(
        create: (context) => GetIt.instance<TodoBloc>(),
        child: FractionallySizedBox(
          heightFactor: 0.9,
          child: TodoAddSheetContent(selectedDate: date ?? DateTime.now()),
        ),
      ),
    );
  }
}

void _showProgramDetailSheet(
  BuildContext context, 
  String userProgramId, 
  String programName, 
  double progressPercent,
) {
  final isDesktop = MediaQuery.of(context).size.width >= 1024;
  if (isDesktop) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(32),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: ProgramDetailSheet(
              userProgramId: userProgramId,
              programName: programName,
              progressPercent: progressPercent,
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
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.9,
        child: ProgramDetailSheet(
          userProgramId: userProgramId,
          programName: programName,
          progressPercent: progressPercent,
        ),
      ),
    );
  }
} 