import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/post_interaction/post_interaction_bloc.dart';
import '../bloc/post_interaction/post_interaction_event.dart';
import '../bloc/post_interaction/post_interaction_state.dart';
import '../../domain/entities/post_comment.dart';
import 'infinite_scroll_list.dart';

/// Widget for displaying paginated comments with infinite scroll
class PaginatedCommentList extends StatefulWidget {
  final String postId;
  final EdgeInsetsGeometry? padding;
  final bool enableReplies;
  final Function(PostComment)? onReply;
  final Function(PostComment)? onEdit;
  final Function(PostComment)? onDelete;
  final Function(PostComment)? onLike;

  const PaginatedCommentList({
    Key? key,
    required this.postId,
    this.padding,
    this.enableReplies = true,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.onLike,
  }) : super(key: key);

  @override
  State<PaginatedCommentList> createState() => _PaginatedCommentListState();
}

class _PaginatedCommentListState extends State<PaginatedCommentList> {
  @override
  void initState() {
    super.initState();
    // Load initial comments
    context.read<PostInteractionBloc>().add(
      LoadComments(postId: widget.postId),
    );
  }

  void _loadMoreComments() {
    context.read<PostInteractionBloc>().add(
      LoadMoreComments(postId: widget.postId),
    );
  }

  void _refreshComments() {
    context.read<PostInteractionBloc>().add(
      LoadComments(postId: widget.postId, forceRefresh: true),
    );
  }

  Widget _buildCommentItem(BuildContext context, PostComment comment, int index) {
    return CommentListItem(
      comment: comment,
      enableReplies: widget.enableReplies,
      onReply: widget.onReply,
      onEdit: widget.onEdit,
      onDelete: widget.onDelete,
      onLike: widget.onLike,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostInteractionBloc, PostInteractionState>(
      builder: (context, state) {
        if (state is CommentsLoaded && state.postId == widget.postId) {
          return InfiniteScrollList<PostComment>(
            items: state.comments,
            hasMore: state.hasMore,
            isLoading: false,
            itemBuilder: _buildCommentItem,
            onLoadMore: _loadMoreComments,
            onRefresh: _refreshComments,
            padding: widget.padding,
            separator: const Divider(height: 1),
            emptyWidget: const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '아직 댓글이 없습니다',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '첫 번째 댓글을 작성해보세요!',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is PostInteractionLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is PostInteractionErrorState) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshComments,
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// Individual comment list item widget
class CommentListItem extends StatelessWidget {
  final PostComment comment;
  final bool enableReplies;
  final Function(PostComment)? onReply;
  final Function(PostComment)? onEdit;
  final Function(PostComment)? onDelete;
  final Function(PostComment)? onLike;

  const CommentListItem({
    Key? key,
    required this.comment,
    this.enableReplies = true,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.onLike,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isReply = comment.parentCommentId != null;

    return Container(
      margin: EdgeInsets.only(
        left: isReply ? 32.0 : 0.0,
        top: 8.0,
        bottom: 8.0,
      ),
      child: Card(
        elevation: isReply ? 1 : 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author and timestamp
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: comment.authorProfileImage != null
                        ? NetworkImage(comment.authorProfileImage!)
                        : null,
                    child: comment.authorProfileImage == null
                        ? Text(
                            comment.authorUsername.isNotEmpty
                                ? comment.authorUsername[0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontSize: 12),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment.authorUsername,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _formatTimestamp(comment.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (comment.isEdited)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '수정됨',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Comment content
              if (!comment.isDeleted)
                Text(
                  comment.content,
                  style: theme.textTheme.bodyMedium,
                )
              else
                Text(
                  '삭제된 댓글입니다',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              
              const SizedBox(height: 8),
              
              // Action buttons
              if (!comment.isDeleted)
                Row(
                  children: [
                    // Like button
                    TextButton.icon(
                      onPressed: () => onLike?.call(comment),
                      icon: Icon(
                        comment.isLikedByCurrentUser
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 16,
                        color: comment.isLikedByCurrentUser
                            ? Colors.red
                            : Colors.grey,
                      ),
                      label: Text(
                        comment.likesCount.toString(),
                        style: TextStyle(
                          color: comment.isLikedByCurrentUser
                              ? Colors.red
                              : Colors.grey,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    
                    // Reply button
                    if (enableReplies && !isReply)
                      TextButton.icon(
                        onPressed: () => onReply?.call(comment),
                        icon: const Icon(Icons.reply, size: 16),
                        label: const Text('답글'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    
                    const Spacer(),
                    
                    // Edit/Delete buttons (for comment author)
                    if (comment.canEdit)
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              onEdit?.call(comment);
                              break;
                            case 'delete':
                              onDelete?.call(comment);
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
                                Icon(Icons.delete, size: 16, color: Colors.red),
                                SizedBox(width: 8),
                                Text('삭제', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        child: const Icon(
                          Icons.more_vert,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${timestamp.year}.${timestamp.month.toString().padLeft(2, '0')}.${timestamp.day.toString().padLeft(2, '0')}';
    }
  }
}

/// Nested comment list for replies
class NestedCommentList extends StatelessWidget {
  final List<PostComment> replies;
  final Function(PostComment)? onReply;
  final Function(PostComment)? onEdit;
  final Function(PostComment)? onDelete;
  final Function(PostComment)? onLike;

  const NestedCommentList({
    Key? key,
    required this.replies,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.onLike,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (replies.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(left: 16, top: 8),
      child: Column(
        children: replies.map((reply) => CommentListItem(
          comment: reply,
          enableReplies: false, // Disable nested replies for now
          onEdit: onEdit,
          onDelete: onDelete,
          onLike: onLike,
        )).toList(),
      ),
    );
  }
}