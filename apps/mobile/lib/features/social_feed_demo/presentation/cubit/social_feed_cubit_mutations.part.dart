part of 'social_feed_cubit.dart';

mixin _SocialFeedCubitMutations
    on _SocialFeedCubitBase, _SocialFeedCubitHelpers {
  Future<void> toggleLike(String postId) async {
    final SocialFeedState currentState = state;
    if (currentState is! SocialFeedReady) {
      return;
    }
    final SocialFeedPost? post = _findPost(currentState.data, postId);
    if (post == null) {
      return;
    }
    final bool desired = !post.isLikedByMe;
    final String mutationId = 'like-$postId-${_clock().microsecondsSinceEpoch}';
    _emitReadyPatch((d) {
      final List<SocialFeedPost> posts = d.posts
          .map(
            (p) => p.id == postId
                ? p.copyWith(
                    isLikedByMe: desired,
                    likeCount: (p.likeCount + (desired ? 1 : -1)).clamp(
                      0,
                      1 << 30,
                    ),
                  )
                : p,
          )
          .toList();
      return d.copyWith(
        posts: posts,
        pendingPostIds: <String>{...d.pendingPostIds, postId},
      );
    });

    try {
      final SocialFeedLikeResult result = await _repository.setLiked(
        viewer: currentState.data.viewer,
        postId: postId,
        desiredLiked: desired,
        mutationId: mutationId,
      );
      switch (result) {
        case SocialFeedLikeSynced(:final post):
          _replacePost(post, clearPending: true);
        case SocialFeedLikeQueued(:final post):
          _replacePost(post, clearPending: false);
        case SocialFeedLikeRejected(:final canonicalPost):
          _replacePost(canonicalPost, clearPending: true);
          _emitEffect(const SocialFeedEffect.mutationRejected());
      }
    } on SocialFeedNotQueuedFailure {
      _replacePost(post, clearPending: true);
      _emitEffect(const SocialFeedEffect.mutationRejected());
    }
  }

  Future<bool> submitComment({
    required String postId,
    required String body,
  }) async {
    final String? validated = _commentPolicy.validate(body);
    if (validated == null) {
      return false;
    }
    final SocialFeedState currentState = state;
    if (currentState is! SocialFeedReady) {
      return false;
    }
    final SocialFeedPost? post = _findPost(currentState.data, postId);
    if (post == null) {
      return false;
    }
    final String mutationId =
        'comment-$postId-${_clock().microsecondsSinceEpoch}';
    final SocialFeedComment pending = SocialFeedComment(
      id: mutationId,
      postId: postId,
      viewerId: currentState.data.viewer.id,
      body: validated,
      createdAt: _clock().toUtc(),
      syncStatus: SocialFeedMutationStatus.pending,
    );
    _emitReadyPatch((d) {
      final List<SocialFeedPost> posts = d.posts
          .map(
            (p) => p.id == postId
                ? p.copyWith(commentCount: p.commentCount + 1)
                : p,
          )
          .toList();
      final Map<String, List<SocialFeedComment>> pendingMap =
          Map<String, List<SocialFeedComment>>.from(d.pendingCommentsByPostId);
      pendingMap[postId] = <SocialFeedComment>[
        ...?pendingMap[postId],
        pending,
      ];
      return d.copyWith(
        posts: posts,
        pendingCommentsByPostId: pendingMap,
        pendingPostIds: <String>{...d.pendingPostIds, postId},
      );
    });

    try {
      final SocialFeedCommentResult result = await _repository.addComment(
        viewer: currentState.data.viewer,
        postId: postId,
        body: validated,
        mutationId: mutationId,
      );
      switch (result) {
        case SocialFeedCommentSynced(:final post):
          _replacePost(post, clearPending: true);
          _clearPendingComment(postId, mutationId, synced: true);
          return true;
        case SocialFeedCommentQueued(:final post):
          _replacePost(post, clearPending: false);
          _clearPendingComment(postId, mutationId, synced: false);
          return true;
        case SocialFeedCommentRejected(:final canonicalPost):
          _replacePost(canonicalPost, clearPending: true);
          _clearPendingComment(postId, mutationId, synced: false, remove: true);
          _emitEffect(const SocialFeedEffect.mutationRejected());
          return false;
      }
    } on SocialFeedNotQueuedFailure {
      _replacePost(post, clearPending: true);
      _clearPendingComment(postId, mutationId, synced: false, remove: true);
      _emitEffect(const SocialFeedEffect.mutationRejected());
      return false;
    }
  }
}
