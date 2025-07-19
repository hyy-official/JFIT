import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/widgets/responsive_layout.dart';
import 'package:jfit/core/utils/breakpoint_utils.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group/group_bloc.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group/group_event.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group/group_state.dart';
import 'package:jfit/features/group_workout_community/domain/entities/workout_group.dart';
import 'package:jfit/features/group_workout_community/domain/repositories/group_repository.dart';

/// 그룹 생성 화면
class GroupCreatePage extends StatefulWidget {
  const GroupCreatePage({super.key});

  @override
  State<GroupCreatePage> createState() => _GroupCreatePageState();
}

class _GroupCreatePageState extends State<GroupCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxMembersController = TextEditingController(text: '20');
  
  GroupPrivacyType _privacyType = GroupPrivacyType.public;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupBlocListener();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _maxMembersController.dispose();
    super.dispose();
  }

  void _setupBlocListener() {
    // Listen to GroupBloc state changes
    context.read<GroupBloc>().stream.listen((state) {
      if (mounted) {
        if (state is GroupCreated) {
          _handleGroupCreated(state);
        } else if (state is GroupErrorState) {
          _handleError(state);
        } else if (state is GroupLoading && state.operationType == 'creating_group') {
          setState(() {
            _isLoading = true;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  void _handleGroupCreated(GroupCreated state) {
    setState(() {
      _isLoading = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${state.group.name} 그룹이 생성되었습니다!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
    
    // Navigate back or to group detail
    Navigator.of(context).pop(state.group);
  }

  void _handleError(GroupErrorState state) {
    setState(() {
      _isLoading = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.userMessage),
        backgroundColor: Theme.of(context).colorScheme.error,
        action: state.isRetryable && state.retryAction != null
            ? SnackBarAction(
                label: state.actionButtonText,
                onPressed: state.retryAction!,
              )
            : null,
      ),
    );
  }

  void _createGroup() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = CreateGroupRequest(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty 
          ? '' 
          : _descriptionController.text.trim(),
      privacyType: _privacyType,
      maxMembers: int.parse(_maxMembersController.text),
    );

    final creatorId = 'current_user_id'; // TODO: Get from auth service
    
    context.read<GroupBloc>().add(CreateGroup(
      request: request,
      creatorId: creatorId,
    ));
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
        title: const Text('그룹 생성'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createGroup,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('생성'),
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
        title: const Text('그룹 생성'),
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
                    '새 운동 그룹 만들기',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildForm(),
                  const SizedBox(height: 24),
                  _buildCreateButton(),
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
        title: const Text('그룹 생성'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
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
                          '새 운동 그룹 만들기',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 32),
                        Expanded(child: _buildForm()),
                        const SizedBox(height: 24),
                        _buildCreateButton(),
                      ],
                    ),
                  ),
                ),
              ),
              // Right side - Preview/Tips
              Expanded(
                child: Card(
                  margin: const EdgeInsets.fromLTRB(0, 24, 24, 24),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _buildTipsSection(),
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
          // Group name
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '그룹 이름',
              hintText: '예: 헬스 초보 모임',
              prefixIcon: Icon(Icons.group),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '그룹 이름을 입력해주세요';
              }
              if (value.trim().length < 2) {
                return '그룹 이름은 2글자 이상이어야 합니다';
              }
              if (value.trim().length > 50) {
                return '그룹 이름은 50글자 이하여야 합니다';
              }
              return null;
            },
            maxLength: 50,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          
          // Description
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: '그룹 설명 (선택사항)',
              hintText: '그룹에 대한 간단한 설명을 작성해주세요',
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
            maxLength: 200,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          
          // Privacy type
          Text(
            '공개 설정',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _buildPrivacyOptions(),
          const SizedBox(height: 16),
          
          // Max members
          TextFormField(
            controller: _maxMembersController,
            decoration: const InputDecoration(
              labelText: '최대 멤버 수',
              hintText: '5-100',
              prefixIcon: Icon(Icons.people),
              suffixText: '명',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '최대 멤버 수를 입력해주세요';
              }
              final number = int.tryParse(value);
              if (number == null) {
                return '올바른 숫자를 입력해주세요';
              }
              if (number < 5) {
                return '최소 5명 이상이어야 합니다';
              }
              if (number > 100) {
                return '최대 100명까지 가능합니다';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyOptions() {
    return Column(
      children: [
        RadioListTile<GroupPrivacyType>(
          title: const Text('공개'),
          subtitle: const Text('누구나 그룹을 찾아서 가입할 수 있습니다'),
          value: GroupPrivacyType.public,
          groupValue: _privacyType,
          onChanged: (value) {
            setState(() {
              _privacyType = value!;
            });
          },
          secondary: const Icon(Icons.public),
        ),
        RadioListTile<GroupPrivacyType>(
          title: const Text('비공개'),
          subtitle: const Text('초대 코드가 있는 사람만 가입할 수 있습니다'),
          value: GroupPrivacyType.private,
          groupValue: _privacyType,
          onChanged: (value) {
            setState(() {
              _privacyType = value!;
            });
          },
          secondary: const Icon(Icons.lock),
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _createGroup,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
      child: _isLoading
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('그룹 생성 중...'),
              ],
            )
          : const Text('그룹 생성하기'),
    );
  }

  Widget _buildTipsSection() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '그룹 생성 팁',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildTipItem(
          Icons.lightbulb_outline,
          '명확한 그룹 이름',
          '그룹의 목적이나 특성을 잘 나타내는 이름을 사용하세요.',
        ),
        const SizedBox(height: 12),
        _buildTipItem(
          Icons.description_outlined,
          '상세한 설명',
          '그룹의 목표, 운동 스타일, 참여 방법 등을 설명해주세요.',
        ),
        const SizedBox(height: 12),
        _buildTipItem(
          Icons.people_outline,
          '적절한 인원',
          '활발한 소통을 위해 10-30명 정도가 적당합니다.',
        ),
        const SizedBox(height: 12),
        _buildTipItem(
          Icons.security_outlined,
          '공개 설정',
          '공개 그룹은 더 많은 사람들이 찾을 수 있습니다.',
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                Icons.group_add,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                '함께 운동하며\n목표를 달성해보세요!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipItem(IconData icon, String title, String description) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}