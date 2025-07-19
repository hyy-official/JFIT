import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/widgets/responsive_layout.dart';
import 'package:jfit/core/utils/breakpoint_utils.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/community/community_bloc.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/community/community_event.dart';
import 'package:jfit/features/group_workout_community/presentation/bloc/community/community_state.dart';
import 'package:jfit/features/group_workout_community/domain/entities/post_category.dart';
import 'package:jfit/features/group_workout_community/domain/entities/community_post.dart';
import 'package:jfit/features/group_workout_community/domain/repositories/community_repository.dart';

/// 게시글 작성 화면 - 제목, 내용, 이미지/동영상 업로드, 태그
class PostCreatePage extends StatefulWidget {
  final String? groupId; // null이면 전체 커뮤니티

  const PostCreatePage({
    super.key,
    this.groupId,
  });

  @override
  State<PostCreatePage> createState() => _PostCreatePageState();
}

class _PostCreatePageState extends State<PostCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  
  List<PostCategory> _categories = [];
  String? _selectedCategoryId;
  PostType _postType = PostType.text;
  List<String> _mediaUrls = [];
  List<String> _tags = [];
  bool _isLoading = false;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _setupBlocListener();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _setupBlocListener() {
    context.read<CommunityBloc>().stream.listen((state) {
      if (mounted) {
        if (state is CategoriesLoaded) {
          setState(() {
            _categories = state.categories;
            _isLoading = false;
          });
        } else if (state is PostCreated) {
          _handlePostCreated(state);
        } else if (state is CommunityErrorState) {
          _handleError(state);
        } else if (state is CommunityLoading) {
          setState(() {
            if (state.operationType == 'loading_categories') {
              _isLoading = true;
            } else if (state.operationType == 'creating_post') {
              _isCreating = true;
            }
          });
        }
      }
    });
  }

  void _loadCategories() {
    context.read<CommunityBloc>().add(LoadCategories());
  }

  void _handlePostCreated(PostCreated state) {
    setState(() {
      _isCreating = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('게시글이 작성되었습니다!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );

    Navigator.of(context).pop(state.post);
  }

  void _handleError(CommunityErrorState state) {
    setState(() {
      _isLoading = false;
      _isCreating = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.userMessage),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _createPost() {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null) {
      return;
    }

    // Parse tags
    _parseTags();

    final request = CreatePostRequest(
      authorId: 'current_user_id', // TODO: Get from auth service
      groupId: widget.groupId,
      categoryId: _selectedCategoryId!,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      postType: _postType,
      mediaUrls: _mediaUrls,
      tags: _tags,
    );

    context.read<CommunityBloc>().add(CreatePost(request));
  }

  void _parseTags() {
    final tagsText = _tagsController.text.trim();
    if (tagsText.isNotEmpty) {
      _tags = tagsText
          .split(RegExp(r'[,\s]+'))
          .where((tag) => tag.isNotEmpty)
          .map((tag) => tag.replaceAll('#', ''))
          .toList();
    }
  }

  void _addMedia() {
    // TODO: Implement media picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('미디어 업로드 기능 구현 예정')),
    );
  }

  void _removeMedia(int index) {
    setState(() {
      _mediaUrls.removeAt(index);
      if (_mediaUrls.isEmpty) {
        _postType = PostType.text;
      }
    });
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
        title: const Text('게시글 작성'),
        actions: [
          TextButton(
            onPressed: _isCreating || _selectedCategoryId == null ? null : _createPost,
            child: _isCreating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('작성'),
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
        title: const Text('게시글 작성'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '새 게시글 작성',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Expanded(child: _buildForm()),
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
        title: const Text('게시글 작성'),
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
                          '새 게시글 작성',
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
              // Right side - Tips and preview
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
          // Category selection
          Text(
            '카테고리 선택',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else
            _buildCategoryDropdown(),
          
          const SizedBox(height: 24),
          
          // Title
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: '제목',
              hintText: '게시글 제목을 입력하세요',
              prefixIcon: Icon(Icons.title),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '제목을 입력해주세요';
              }
              if (value.trim().length < 2) {
                return '제목은 2글자 이상이어야 합니다';
              }
              if (value.trim().length > 100) {
                return '제목은 100글자 이하여야 합니다';
              }
              return null;
            },
            maxLength: 100,
            textInputAction: TextInputAction.next,
          ),
          
          const SizedBox(height: 16),
          
          // Content
          TextFormField(
            controller: _contentController,
            decoration: const InputDecoration(
              labelText: '내용',
              hintText: '게시글 내용을 입력하세요',
              prefixIcon: Icon(Icons.description),
              alignLabelWithHint: true,
            ),
            maxLines: 8,
            maxLength: 2000,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '내용을 입력해주세요';
              }
              if (value.trim().length < 10) {
                return '내용은 10글자 이상이어야 합니다';
              }
              return null;
            },
            textInputAction: TextInputAction.newline,
          ),
          
          const SizedBox(height: 16),
          
          // Media section
          _buildMediaSection(),
          
          const SizedBox(height: 16),
          
          // Tags
          TextFormField(
            controller: _tagsController,
            decoration: const InputDecoration(
              labelText: '태그 (선택사항)',
              hintText: '태그를 쉼표로 구분하여 입력하세요 (예: 운동, 헬스, 팁)',
              prefixIcon: Icon(Icons.tag),
            ),
            maxLength: 100,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategoryId,
      decoration: const InputDecoration(
        labelText: '카테고리',
        prefixIcon: Icon(Icons.category),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '카테고리를 선택해주세요';
        }
        return null;
      },
      items: _categories.map((category) {
        return DropdownMenuItem(
          value: category.id,
          child: Row(
            children: [
              Icon(
                _getCategoryIcon(category.name),
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(category.name),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategoryId = value;
        });
      },
    );
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '미디어',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _addMedia,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('추가'),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        if (_mediaUrls.isEmpty)
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 32,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '이미지나 동영상을 추가해보세요',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          _buildMediaPreview(),
      ],
    );
  }

  Widget _buildMediaPreview() {
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _mediaUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                Container(
                  width: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '미디어 ${index + 1}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removeMedia(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Theme.of(context).colorScheme.onError,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreateButton() {
    return ElevatedButton(
      onPressed: _isCreating || _selectedCategoryId == null ? null : _createPost,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
      child: _isCreating
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('작성 중...'),
              ],
            )
          : const Text('게시글 작성하기'),
    );
  }

  Widget _buildTipsSection() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '게시글 작성 팁',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        
        _buildTipItem(
          Icons.title,
          '명확한 제목',
          '게시글의 내용을 잘 나타내는 제목을 작성하세요.',
        ),
        const SizedBox(height: 12),
        
        _buildTipItem(
          Icons.description,
          '상세한 내용',
          '다른 사용자들이 이해하기 쉽도록 자세히 작성해주세요.',
        ),
        const SizedBox(height: 12),
        
        _buildTipItem(
          Icons.category,
          '적절한 카테고리',
          '게시글 내용에 맞는 카테고리를 선택해주세요.',
        ),
        const SizedBox(height: 12),
        
        _buildTipItem(
          Icons.tag,
          '관련 태그',
          '검색하기 쉽도록 관련 태그를 추가해보세요.',
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
                Icons.forum,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                '좋은 게시글로\n커뮤니티를 활성화해요!',
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

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case '운동':
      case 'workout':
        return Icons.fitness_center;
      case '식단':
      case 'diet':
        return Icons.restaurant;
      case '질문':
      case 'question':
        return Icons.help_outline;
      case '팁':
      case 'tip':
        return Icons.lightbulb_outline;
      case '자유':
      case 'free':
        return Icons.chat_bubble_outline;
      case '후기':
      case 'review':
        return Icons.rate_review;
      case '공지':
      case 'notice':
        return Icons.campaign;
      default:
        return Icons.article;
    }
  }
}