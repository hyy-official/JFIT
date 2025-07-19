import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jfit/core/bloc/base_bloc.dart';
import 'package:jfit/core/bloc/bloc_event_bus.dart' as event_bus;
import 'package:jfit/features/group_workout_community/domain/entities/community_post.dart';
import 'package:jfit/features/group_workout_community/domain/repositories/post_interaction_repository.dart';
import 'post_interaction_event.dart';
import 'post_interaction_state.dart';

/// BLoC for managing post interactions (comments, likes, views)
class PostInteractionBloc extends BaseBloc<PostInteractionEvent, PostInteractionState> {
  final PostInteractionRepository _repository;

  PostInteractionBloc({
    required PostInteractionRepository repository,
  })  : _repository = repository,
        super(const PostInteractionInitial()) {
    
    on<LoadComments>(_onLoadComments);
    on<LoadMoreComments>(_onLoadMoreComments);
    on<AddComment>(_onAddComment);
    on<UpdateComment>(_onUpdateComment);
    on<DeleteComment>(_onDeleteComment);
    on<ToggleLike>(_onToggleLike);
    on<CheckLikeStatus>(_onCheckLikeStatus);
    on<IncrementViewCount>(_onIncrementViewCount);
    on<HandleCommentUpdate>(_onHandleCommentUpdate);
    on<RefreshComments>(_onRefreshComments);
  }

  Future<void> _onLoadComments(
    LoadComments event,
    Emitter<PostInteractionState> emit,
  ) async {
    emit(const PostInteractionLoading(
      message: '댓글을 불러오고 있습니다...',
      operationType: 'loading_comments',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getComments(
          event.postId,
          limit: event.limit,
          offset: event.offset,
        );
        
        result.fold(
          (failure) => emit(PostInteractionErrorState.fromError(
            failure,
            operationType: 'loading_comments',
          )),
          (comments) => emit(CommentsLoaded(
            postId: event.postId,
            comments: comments,
            hasMore: comments.length == event.limit,
            totalCount: comments.length,
            loadedAt: DateTime.now(),
          )),
        );
      },
      (error) => emit(PostInteractionErrorState.fromError(
        error,
        operationType: 'loading_comments',
      )),
    );
  }

  Future<void> _onLoadMoreComments(
    LoadMoreComments event,
    Emitter<PostInteractionState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CommentsLoaded || !currentState.hasMore) return;

    emit(const PostInteractionLoading(
      message: '더 많은 댓글을 불러오고 있습니다...',
      operationType: 'loading_more_comments',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.getComments(
          event.postId,
          limit: 20,
          offset: currentState.comments.length,
        );
        
        result.fold(
          (failure) => emit(PostInteractionErrorState.fromError(failure)),
          (newComments) => emit(currentState.addMoreComments(newComments)),
        );
      },
      (error) => emit(PostInteractionErrorState.fromError(error)),
    );
  }

  Future<void> _onAddComment(
    AddComment event,
    Emitter<PostInteractionState> emit,
  ) async {
    emit(const PostInteractionLoading(
      message: '댓글을 작성하고 있습니다...',
      operationType: 'adding_comment',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.addComment(event.request);
        
        result.fold(
          (failure) => emit(PostInteractionErrorState.fromError(failure)),
          (comment) {
            emit(CommentAdded(
              comment: comment,
              addedAt: DateTime.now(),
            ));

            emitCommunicationEvent(event_bus.PostCommentAddedEvent(
              postId: event.request.postId,
              commentId: comment.id,
              authorId: comment.authorId,
              groupId: null, // Will be set if this is a group post
            ));
          },
        );
      },
      (error) => emit(PostInteractionErrorState.fromError(error)),
    );
  }

  Future<void> _onUpdateComment(
    UpdateComment event,
    Emitter<PostInteractionState> emit,
  ) async {
    emit(const PostInteractionLoading(
      message: '댓글을 수정하고 있습니다...',
      operationType: 'updating_comment',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.updateComment(
          event.commentId,
          UpdateCommentRequest(
          content: event.content,
        ),
          'current_user_id', // TODO: Get from auth service
        );
        
        result.fold(
          (failure) => emit(PostInteractionErrorState.fromError(failure)),
          (comment) => emit(CommentUpdated(
            comment: comment,
            updatedAt: DateTime.now(),
          )),
        );
      },
      (error) => emit(PostInteractionErrorState.fromError(error)),
    );
  }

  Future<void> _onDeleteComment(
    DeleteComment event,
    Emitter<PostInteractionState> emit,
  ) async {
    emit(const PostInteractionLoading(
      message: '댓글을 삭제하고 있습니다...',
      operationType: 'deleting_comment',
    ));

    await safeAsyncOperation(
      () async {
        final result = await _repository.deleteComment(
          event.commentId,
          event.userId,
        );
        
        result.fold(
          (failure) => emit(PostInteractionErrorState.fromError(failure)),
          (_) => emit(CommentDeleted(
            commentId: event.commentId,
            deletedAt: DateTime.now(),
          )),
        );
      },
      (error) => emit(PostInteractionErrorState.fromError(error)),
    );
  }

  Future<void> _onToggleLike(
    ToggleLike event,
    Emitter<PostInteractionState> emit,
  ) async {
    await safeAsyncOperation(
      () async {
        final result = await _repository.toggleLike(
          ToggleLikeRequest(
            postId: event.postId,
            userId: event.userId,
            commentId: event.commentId,
            likeType: event.likeType,
          ),
        );
        
        result.fold(
          (failure) => emit(PostInteractionErrorState.fromError(failure)),
          (_) async {
            // Check new like status
            final likeResult = await _repository.getUserLikeStatus(
              event.userId,
              postId: event.postId,
            );
            
            likeResult.fold(
              (failure) => emit(PostInteractionErrorState.fromError(failure)),
              (likeType) => emit(LikeToggled(
                postId: event.postId,
                commentId: event.commentId,
                userId: event.userId,
                isLiked: likeType != null,
                likeType: event.likeType,
                toggledAt: DateTime.now(),
              )),
            );
          },
        );
      },
      (error) => emit(PostInteractionErrorState.fromError(error)),
    );
  }

  Future<void> _onCheckLikeStatus(
    CheckLikeStatus event,
    Emitter<PostInteractionState> emit,
  ) async {
    await safeAsyncOperation(
      () async {
        final result = await _repository.getUserLikeStatus(
          event.userId,
          postId: event.postId,
        );
        
        result.fold(
          (failure) => emit(PostInteractionErrorState.fromError(failure)),
          (likeType) => emit(LikeStatusChecked(
            postId: event.postId,
            commentId: event.commentId,
            userId: event.userId,
            isLiked: likeType != null,
            checkedAt: DateTime.now(),
          )),
        );
      },
      (error) => emit(PostInteractionErrorState.fromError(error)),
    );
  }

  Future<void> _onIncrementViewCount(
    IncrementViewCount event,
    Emitter<PostInteractionState> emit,
  ) async {
    await safeAsyncOperation(
      () async {
        final result = await _repository.incrementViewCount(event.postId);
        
        result.fold(
          (failure) => emit(PostInteractionErrorState.fromError(failure)),
          (_) => emit(ViewCountIncremented(
            postId: event.postId,
            incrementedAt: DateTime.now(),
          )),
        );
      },
      (error) => emit(PostInteractionErrorState.fromError(error)),
    );
  }

  Future<void> _onHandleCommentUpdate(
    HandleCommentUpdate event,
    Emitter<PostInteractionState> emit,
  ) async {
    emit(CommentUpdatedRealtime(
      postId: event.postId,
      commentData: event.commentData,
      updatedAt: DateTime.now(),
    ));
  }

  Future<void> _onRefreshComments(
    RefreshComments event,
    Emitter<PostInteractionState> emit,
  ) async {
    add(LoadComments(postId: event.postId));
    emit(CommentsRefreshed(
      postId: event.postId,
      refreshedAt: DateTime.now(),
    ));
  }

  // Convenience methods
  void loadComments(String postId) {
    add(LoadComments(postId: postId));
  }

  void addComment(AddCommentRequest request) {
    add(AddComment(request));
  }

  void toggleLike(String postId, String userId, {String? commentId, LikeType likeType = LikeType.like}) {
    add(ToggleLike(
      postId: postId,
      commentId: commentId,
      userId: userId,
      likeType: likeType,
    ));
  }

  void incrementViewCount(String postId) {
    add(IncrementViewCount(postId));
  }
}