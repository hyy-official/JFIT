import 'package:jfit/core/bloc/base_bloc.dart';
import 'package:jfit/features/group_workout_community/domain/entities/community_post.dart';
import 'package:jfit/features/group_workout_community/domain/repositories/post_interaction_repository.dart';

/// Base class for all PostInteraction-related events
abstract class PostInteractionEvent extends BaseEvent {
  const PostInteractionEvent();
}

/// Event to load comments for a post
class LoadComments extends PostInteractionEvent {
  final String postId;
  final int limit;
  final int offset;

  const LoadComments({
    required this.postId,
    this.limit = 50,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [postId, limit, offset];
}

/// Event to load more comments (pagination)
class LoadMoreComments extends PostInteractionEvent {
  final String postId;

  const LoadMoreComments(this.postId);

  @override
  List<Object?> get props => [postId];
}

/// Event to add a comment
class AddComment extends PostInteractionEvent {
  final AddCommentRequest request;

  const AddComment(this.request);

  @override
  List<Object?> get props => [request];
}

/// Event to update a comment
class UpdateComment extends PostInteractionEvent {
  final String commentId;
  final String content;

  const UpdateComment({
    required this.commentId,
    required this.content,
  });

  @override
  List<Object?> get props => [commentId, content];
}

/// Event to delete a comment
class DeleteComment extends PostInteractionEvent {
  final String commentId;
  final String userId;

  const DeleteComment({
    required this.commentId,
    required this.userId,
  });

  @override
  List<Object?> get props => [commentId, userId];
}

/// Event to toggle like on post or comment
class ToggleLike extends PostInteractionEvent {
  final String postId;
  final String? commentId;
  final String userId;
  final LikeType likeType;

  const ToggleLike({
    required this.postId,
    this.commentId,
    required this.userId,
    required this.likeType,
  });

  @override
  List<Object?> get props => [postId, commentId, userId, likeType];
}

/// Event to check if user liked a post/comment
class CheckLikeStatus extends PostInteractionEvent {
  final String postId;
  final String? commentId;
  final String userId;

  const CheckLikeStatus({
    required this.postId,
    this.commentId,
    required this.userId,
  });

  @override
  List<Object?> get props => [postId, commentId, userId];
}

/// Event to increment view count
class IncrementViewCount extends PostInteractionEvent {
  final String postId;

  const IncrementViewCount(this.postId);

  @override
  List<Object?> get props => [postId];
}

/// Event to handle real-time comment update
class HandleCommentUpdate extends PostInteractionEvent {
  final String postId;
  final Map<String, dynamic> commentData;

  const HandleCommentUpdate({
    required this.postId,
    required this.commentData,
  });

  @override
  List<Object?> get props => [postId, commentData];
}

/// Event to refresh comments
class RefreshComments extends PostInteractionEvent {
  final String postId;

  const RefreshComments(this.postId);

  @override
  List<Object?> get props => [postId];
}