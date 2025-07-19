import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/widgets/responsive_layout.dart';
import 'package:jfit/core/utils/breakpoint_utils.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group_activity/group_activity_bloc.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group_activity/group_activity_event.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group_activity/group_activity_state.dart';
import 'package:jfit/features/group_workout_community/domain/repositories/group_activity_repository.dart';

/// 루틴 공유 화면 - 현재 프로그램 선택, 설명 추가
class RoutineSharePage extends StatefulWidget {
  final String groupId;

  const RoutineSharePage({
    super.key,
    required this.groupId,
  });

  @override
  State<RoutineSharePage> createState() => _RoutineSharePageState();
}

class _RoutineSharePageState extends State<RoutineSharePage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  
  String? _selectedProgramId;
  String? _selectedProgramName;
  List<Map<String, dynamic>> _userPrograms = [];
  bool _isLoading = false;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _loadUserPrograms();
    _setupBlocListener();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _setupBlocListener() {
    context.read<GroupActivityBloc>().stream.listen((state) {
      if (mounted) {
        if (state is RoutineShared) {
          _handleRoutineShared(state);
        } else if (state is GroupActivityErrorState) {
          _handleError(state);
        } else if (state is GroupActivityLoading) {
          setState(() {
            _isSharing = state.operationType == 'sharing_routine';
          });
        }
      }
    });
  }

  void _loadUserPrograms() {
    setState(() {
      _isLoading = true;
    });

    // TODO: Load user's current programs from repository
    // For now, using mock data
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _userPrograms = [
            {
              'id': '1',
              'name': '상체 집중 루틴',
              'exercise_count': 8,
              'duration': 45,
              'description': '가슴, 어깨, 팔 중심의 운동',
            },
            {
              'id': '2',
              'name': '하체 강화 프로그램',
              'exercise_count': 6,
              'duration': 60,
              'description': '스쿼트, 데드리프트 중심',
            },
            {
              'id': '3',
              'name': '전신 운동 루틴',
              'exercise_count': 10,
              'duration': 75,
              'description': '전신 근육을 골고루 발달',
            },
          ];
          _isLoading = false;
        });
      }
    });
  }

  void _handleRoutineShared(RoutineShared state) {
    setState(() {
      _isSharing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selectedProgramName ?? '루틴'}이 공유되었습니다!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );

    Navigator.of(context).pop();
  }

  void _handleError(GroupActivityErrorState state) {
    setState(() {
      _isSharing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.userMessage),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _shareRoutine() {
    if (!_formKey.currentState!.validate() || _selectedProgramId == null) {
      return;
    }

    final request = ShareRoutineRequest(
      groupId: widget.groupId,
      userId: 'current_user_id', // TODO: Get from auth service
      userProgramId: _selectedProgramId!,
      routineName: _selectedProgramName!,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      exerciseIds: const [], // TODO: Get exercise IDs from selected program
    );

    context.read<GroupActivityBloc>().add(ShareRoutine(request));
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('루틴 공유'),
        actions: [
          TextButton(
            onPressed: _isSharing || _selectedProgramId == null ? null : _shareRoutine,
            child: _isSharing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('공유'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildForm(),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('루틴 공유'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '운동 루틴 공유하기',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildForm(),
                  const SizedBox(height: 24),
                  _buildShareButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('루틴 공유'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Row(
            children: [
              // Left side - Form
              Expanded(
                flex: 2,
                child: Card(
                  margin: const EdgeInsets.all(24),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '운동 루틴 공유하기',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 32),
                        Expanded(child: _buildForm()),
                        const SizedBox(height: 24),
                        _buildShareButton(),
                      ],
                    ),
                  ),
                ),
              ),
              // Right side - Preview
              Expanded(
                child: Card(
                  margin: const EdgeInsets.fromLTRB(0, 24, 24, 24),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _buildPreviewSection(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Program selection
          Text(
            '공유할 루틴 선택',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_userPrograms.isEmpty)
            _buildEmptyPrograms()
          else
            _buildProgramList(),
          
          const SizedBox(height: 24),
          
          // Description
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: '설명 (선택사항)',
              hintText: '이 루틴에 대한 설명이나 팁을 공유해주세요',
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
            maxLength: 200,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  Widget _buildProgramList() {
    return Column(
      children: _userPrograms.map((program) {
        final isSelected = _selectedProgramId == program['id'];
        
        return Card(
          elevation: isSelected ? 2 : 0,
          color: isSelected 
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
              : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceVariant,
              child: Icon(
                Icons.fitness_center,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            title: Text(
              program['name'],
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(program['description']),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 14,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${program['duration']}분',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.fitness_center,
                      size: 14,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${program['exercise_count']}개 운동',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            onTap: () {
              setState(() {
                _selectedProgramId = program['id'];
                _selectedProgramName = program['name'];
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyPrograms() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.fitness_center,
            size: 48,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            '운동 프로그램이 없습니다',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '먼저 운동 프로그램을 생성해주세요',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to program creation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('프로그램 생성 기능 구현 예정')),
              );
            },
            child: const Text('프로그램 만들기'),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton() {
    return ElevatedButton(
      onPressed: _isSharing || _selectedProgramId == null ? null : _shareRoutine,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
      child: _isSharing
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('공유 중...'),
              ],
            )
          : const Text('루틴 공유하기'),
    );
  }

  Widget _buildPreviewSection() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '공유 미리보기',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        
        if (_selectedProgramId != null) ...[
          _buildPreviewCard(),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.preview,
                  size: 48,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(height: 12),
                Text(
                  '루틴을 선택하면\n미리보기가 표시됩니다',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
        
        const Spacer(),
        
        // Tips section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '공유 팁',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• 루틴의 목적과 특징을 설명해주세요\n'
                '• 초보자를 위한 팁이 있다면 공유해주세요\n'
                '• 운동 강도나 주의사항을 알려주세요',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewCard() {
    final theme = Theme.of(context);
    final selectedProgram = _userPrograms.firstWhere(
      (program) => program['id'] == _selectedProgramId,
    );
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.share,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '사용자님이 루틴을 공유했습니다',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      '방금 전',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedProgram['name'],
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  selectedProgram['description'],
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 14,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${selectedProgram['duration']}분',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.fitness_center,
                      size: 14,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${selectedProgram['exercise_count']}개 운동',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          if (_descriptionController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _descriptionController.text,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}