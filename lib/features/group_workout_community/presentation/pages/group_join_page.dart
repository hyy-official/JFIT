import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/widgets/responsive_layout.dart';
import 'package:jfit/core/utils/breakpoint_utils.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group/group_bloc.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group/group_event.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group/group_state.dart';
import 'package:jfit/features/group_workout_community/domain/entities/workout_group.dart';
import 'package:jfit/features/group_workout_community/domain/repositories/group_repository.dart';

/// 그룹 가입 화면 - 초대 코드 입력, 가입 요청
class GroupJoinPage extends StatefulWidget {
  final String? groupId;
  final String? inviteCode;

  const GroupJoinPage({
    super.key,
    this.groupId,
    this.inviteCode,
  });

  @override
  State<GroupJoinPage> createState() => _GroupJoinPageState();
}

class _GroupJoinPageState extends State<GroupJoinPage> {
  final _formKey = GlobalKey<FormState>();
  final _inviteCodeController = TextEditingController();
  
  WorkoutGroup? _targetGroup;
  bool _isLoading = false;
  bool _isValidatingCode = false;
  bool _isCodeValid = false;

  @override
  void initState() {
    super.initState();
    if (widget.inviteCode != null) {
      _inviteCodeController.text = widget.inviteCode!;
      _validateInviteCode();
    }
    _setupBlocListener();
  }

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  void _setupBlocListener() {
    context.read<GroupBloc>().stream.listen((state) {
      if (mounted) {
        if (state is InviteCodeValidated) {
          _handleCodeValidated(state);
        } else if (state is GroupDetailsLoaded) {
          _handleGroupLoaded(state);
        } else if (state is GroupJoined) {
          _handleGroupJoined(state);
        } else if (state is GroupErrorState) {
          _handleError(state);
        } else if (state is GroupLoading) {
          _handleLoading(state);
        }
      }
    });
  }

  void _handleCodeValidated(InviteCodeValidated state) {
    setState(() {
      _isValidatingCode = false;
      _isCodeValid = state.isValid;
    });

    if (state.isValid) {
      // Load group details
      context.read<GroupBloc>().add(LoadGroupDetails(state.groupId));
    }
  }

  void _handleGroupLoaded(GroupDetailsLoaded state) {
    setState(() {
      _targetGroup = state.group;
    });
  }

  void _handleGroupJoined(GroupJoined state) {
    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${state.groupName} 그룹에 가입되었습니다!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );

    // Navigate to group detail
    Navigator.of(context).pushReplacementNamed(
      '/group/detail',
      arguments: state.groupId,
    );
  }

  void _handleError(GroupErrorState state) {
    setState(() {
      _isLoading = false;
      _isValidatingCode = false;
      if (state.error.code == 'invalid_invite_code') {
        _isCodeValid = false;
        _targetGroup = null;
      }
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

  void _handleLoading(GroupLoading state) {
    setState(() {
      if (state.operationType == 'validating_invite_code') {
        _isValidatingCode = true;
      } else if (state.operationType == 'joining_group') {
        _isLoading = true;
      }
    });
  }

  void _validateInviteCode() {
    final code = _inviteCodeController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _isCodeValid = false;
        _targetGroup = null;
      });
      return;
    }

    if (widget.groupId != null) {
      context.read<GroupBloc>().add(ValidateInviteCode(
        groupId: widget.groupId!,
        inviteCode: code,
      ));
    } else {
      // TODO: Implement code validation without group ID
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('초대 코드 검증 기능 구현 예정')),
      );
    }
  }

  void _joinGroup() {
    if (!_formKey.currentState!.validate() || !_isCodeValid || _targetGroup == null) {
      return;
    }

    final request = JoinGroupRequest(
      groupId: _targetGroup!.id,
      userId: 'current_user_id', // TODO: Get from auth service
      inviteCode: _inviteCodeController.text.trim(),
    );

    context.read<GroupBloc>().add(JoinGroup(request));
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
        title: const Text('그룹 가입'),
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
        title: const Text('그룹 가입'),
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
                    '그룹 가입하기',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildForm(),
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
        title: const Text('그룹 가입'),
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
                          '그룹 가입하기',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 32),
                        Expanded(child: _buildForm()),
                      ],
                    ),
                  ),
                ),
              ),
              // Right side - Instructions
              Expanded(
                child: Card(
                  margin: const EdgeInsets.fromLTRB(0, 24, 24, 24),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _buildInstructionsSection(),
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
          // Invite code input
          TextFormField(
            controller: _inviteCodeController,
            decoration: InputDecoration(
              labelText: '초대 코드',
              hintText: '그룹 관리자로부터 받은 초대 코드를 입력하세요',
              prefixIcon: const Icon(Icons.vpn_key),
              suffixIcon: _isValidatingCode
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _isCodeValid
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : _inviteCodeController.text.isNotEmpty
                          ? Icon(
                              Icons.error,
                              color: Theme.of(context).colorScheme.error,
                            )
                          : null,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '초대 코드를 입력해주세요';
              }
              if (!_isCodeValid && value.trim().isNotEmpty) {
                return '유효하지 않은 초대 코드입니다';
              }
              return null;
            },
            onChanged: (value) {
              // Debounce validation
              Future.delayed(const Duration(milliseconds: 500), () {
                if (_inviteCodeController.text == value) {
                  _validateInviteCode();
                }
              });
            },
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _joinGroup(),
          ),
          
          const SizedBox(height: 24),
          
          // Group preview
          if (_targetGroup != null) ...[
            _buildGroupPreview(),
            const SizedBox(height: 24),
          ],
          
          // Join button
          ElevatedButton(
            onPressed: _isLoading || !_isCodeValid || _targetGroup == null
                ? null
                : _joinGroup,
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
                      Text('가입 중...'),
                    ],
                  )
                : const Text('그룹 가입하기'),
          ),
          
          const SizedBox(height: 16),
          
          // Help text
          Text(
            '초대 코드는 그룹 관리자로부터 받을 수 있습니다.\n코드를 입력하면 자동으로 그룹 정보가 표시됩니다.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupPreview() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  Icons.group,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _targetGroup!.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 16,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_targetGroup!.currentMemberCount}/${_targetGroup!.maxMembers}명',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          _targetGroup!.privacyType == GroupPrivacyType.public
                              ? Icons.public
                              : Icons.lock,
                          size: 16,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _targetGroup!.privacyType == GroupPrivacyType.public
                              ? '공개'
                              : '비공개',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_targetGroup!.description?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Text(
              _targetGroup!.description!,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInstructionsSection() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '그룹 가입 방법',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildInstructionStep(
          1,
          '초대 코드 받기',
          '그룹 관리자로부터 초대 코드를 받으세요.',
          Icons.mail_outline,
        ),
        const SizedBox(height: 12),
        _buildInstructionStep(
          2,
          '코드 입력',
          '받은 초대 코드를 위 입력란에 입력하세요.',
          Icons.keyboard,
        ),
        const SizedBox(height: 12),
        _buildInstructionStep(
          3,
          '그룹 확인',
          '그룹 정보를 확인하고 가입 버튼을 누르세요.',
          Icons.group_add,
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
                Icons.info_outline,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                '초대 코드가 없나요?',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '공개 그룹은 그룹 찾기에서\n바로 가입할 수 있습니다.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/group/list');
                },
                child: const Text('그룹 찾아보기'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionStep(
    int step,
    String title,
    String description,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
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