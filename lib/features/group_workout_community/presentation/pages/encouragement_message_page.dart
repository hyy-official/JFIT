import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/encouragement_request.dart';
import 'package:jfit/core/widgets/responsive_layout.dart';
import 'package:jfit/core/utils/breakpoint_utils.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group_activity/group_activity_bloc.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group_activity/group_activity_event.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/group_activity/group_activity_state.dart';
import 'package:jfit/features/group_workout_community/domain/entities/group_member.dart';
import 'package:jfit/features/group_workout_community/domain/repositories/group_activity_repository.dart';

/// 격려 메시지 작성 화면 - 키보드 대응 레이아웃
class EncouragementMessagePage extends StatefulWidget {
  final String groupId;
  final List<GroupMember> groupMembers;

  const EncouragementMessagePage({
    super.key,
    required this.groupId,
    required this.groupMembers,
  });

  @override
  State<EncouragementMessagePage> createState() => _EncouragementMessagePageState();
}

class _EncouragementMessagePageState extends State<EncouragementMessagePage> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _focusNode = FocusNode();
  
  String? _selectedMemberId;
  String? _selectedMemberName;
  bool _isSending = false;
  
  // Predefined encouragement messages
  final List<String> _quickMessages = [
    '오늘도 화이팅! 💪',
    '꾸준히 하고 계시네요! 👏',
    '정말 대단해요! 🔥',
    '함께 목표를 향해 달려봐요! 🏃‍♂️',
    '포기하지 말고 계속해요! ✨',
    '운동하는 모습이 멋져요! 😎',
    '오늘 하루도 수고하셨어요! 🌟',
    '계속 이런 식으로 해봐요! 👍',
  ];

  @override
  void initState() {
    super.initState();
    _setupBlocListener();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _setupBlocListener() {
    context.read<GroupActivityBloc>().stream.listen((state) {
      if (mounted) {
        if (state is EncouragementSent) {
          _handleEncouragementSent(state);
        } else if (state is GroupActivityErrorState) {
          _handleError(state);
        } else if (state is GroupActivityLoading) {
          setState(() {
            _isSending = state.operationType == 'sending_encouragement';
          });
        }
      }
    });
  }

  void _handleEncouragementSent(EncouragementSent state) {
    setState(() {
      _isSending = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selectedMemberName ?? '멤버'}님에게 격려 메시지를 보냈습니다!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );

    Navigator.of(context).pop();
  }

  void _handleError(GroupActivityErrorState state) {
    setState(() {
      _isSending = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.userMessage),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _sendEncouragement() {
    if (!_formKey.currentState!.validate() || _selectedMemberId == null) {
      return;
    }

    final request = EncouragementRequest(
      groupId: widget.groupId,
      fromUserId: 'current_user_id', // TODO: Get from auth service
      toUserId: _selectedMemberId!,
      message: _messageController.text.trim(),
    );

    context.read<GroupActivityBloc>().add(SendEncouragement(request));
  }

  void _selectQuickMessage(String message) {
    setState(() {
      _messageController.text = message;
    });
    _focusNode.requestFocus();
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
        title: const Text('격려 메시지'),
        actions: [
          TextButton(
            onPressed: _isSending || _selectedMemberId == null || _messageController.text.trim().isEmpty
                ? null
                : _sendEncouragement,
            child: _isSending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('전송'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildForm(),
            ),
          ),
          // Keyboard-aware bottom section
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('격려 메시지'),
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
                    '격려 메시지 보내기',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildForm(),
                  const SizedBox(height: 24),
                  _buildSendButton(),
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
        title: const Text('격려 메시지'),
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
                          '격려 메시지 보내기',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 32),
                        Expanded(child: _buildForm()),
                        const SizedBox(height: 24),
                        _buildSendButton(),
                      ],
                    ),
                  ),
                ),
              ),
              // Right side - Tips and quick messages
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
          // Member selection
          Text(
            '격려할 멤버 선택',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          
          _buildMemberSelection(),
          
          const SizedBox(height: 24),
          
          // Quick message selection
          Text(
            '빠른 메시지',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          
          _buildQuickMessageChips(),
          
          const SizedBox(height: 24),
          
          // Message input
          TextFormField(
            controller: _messageController,
            focusNode: _focusNode,
            decoration: const InputDecoration(
              labelText: '격려 메시지',
              hintText: '따뜻한 격려의 말을 전해주세요',
              prefixIcon: Icon(Icons.favorite),
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            maxLength: 200,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '메시지를 입력해주세요';
              }
              if (value.trim().length < 2) {
                return '메시지는 2글자 이상이어야 합니다';
              }
              return null;
            },
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _sendEncouragement(),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberSelection() {
    final availableMembers = widget.groupMembers
        .where((member) => member.userId != 'current_user_id') // TODO: Get actual current user ID
        .toList();

    if (availableMembers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          '격려할 수 있는 멤버가 없습니다',
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: availableMembers.length,
        itemBuilder: (context, index) {
          final member = availableMembers[index];
          final isSelected = _selectedMemberId == member.userId;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMemberId = member.userId;
                  _selectedMemberName = member.username;
                });
              },
              child: Container(
                width: 80,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                      child: Text(
                        member.username[0].toUpperCase(),
                        style: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.surface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      member.username,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : null,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickMessageChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _quickMessages.map((message) {
        return ActionChip(
          label: Text(message),
          onPressed: () => _selectQuickMessage(message),
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        );
      }).toList(),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: _buildSendButton(),
    );
  }

  Widget _buildSendButton() {
    return ElevatedButton(
      onPressed: _isSending || _selectedMemberId == null || _messageController.text.trim().isEmpty
          ? null
          : _sendEncouragement,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
      child: _isSending
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('전송 중...'),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.send),
                const SizedBox(width: 8),
                Text(_selectedMemberName != null
                    ? '$_selectedMemberName님에게 전송'
                    : '격려 메시지 전송'),
              ],
            ),
    );
  }

  Widget _buildTipsSection() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '격려 메시지 팁',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        
        _buildTipItem(
          Icons.favorite,
          '진심을 담아서',
          '진정성 있는 격려가 가장 큰 힘이 됩니다.',
        ),
        const SizedBox(height: 12),
        
        _buildTipItem(
          Icons.star,
          '구체적으로',
          '상대방의 노력이나 성과를 구체적으로 언급해보세요.',
        ),
        const SizedBox(height: 12),
        
        _buildTipItem(
          Icons.emoji_emotions,
          '긍정적으로',
          '밝고 긍정적인 메시지로 에너지를 전달하세요.',
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
                Icons.group,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                '함께 응원하며\n목표를 달성해요!',
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