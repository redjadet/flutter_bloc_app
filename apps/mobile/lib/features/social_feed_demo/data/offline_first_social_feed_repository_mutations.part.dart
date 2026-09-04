part of 'offline_first_social_feed_repository.dart';

Future<SocialFeedLikeResult> _setLikedImpl(
  OfflineFirstSocialFeedRepository repo, {
  required SocialFeedViewer viewer,
  required String postId,
  required bool desiredLiked,
  required String mutationId,
}) async {
  if (!repo._scenario.isSimulatedOnline) {
    try {
      await repo._queue.enqueueLike(
        viewer: viewer,
        postId: postId,
        desiredLiked: desiredLiked,
        mutationId: mutationId,
      );
    } on Object {
      throw const SocialFeedNotQueuedFailure();
    }
    final SocialFeedPost optimistic = await repo._optimisticPost(
      viewer,
      postId,
    );
    return SocialFeedLikeQueued(optimistic);
  }

  try {
    final SocialFeedPost post = await repo.withLikeApplyLock(viewer, () async {
      return repo._remote.applyLike(
        viewer: viewer,
        postId: postId,
        desiredLiked: desiredLiked,
        mutationId: mutationId,
      );
    });
    final bool persisted = await repo._persistViewerLikes();
    await repo._patchCachedPost(viewer, post);
    if (!persisted) {
      try {
        await repo._queue.enqueueLike(
          viewer: viewer,
          postId: postId,
          desiredLiked: desiredLiked,
          mutationId: mutationId,
        );
      } on Object {
        throw const SocialFeedNotQueuedFailure();
      }
      final SocialFeedPost optimistic = await repo._optimisticPost(
        viewer,
        postId,
      );
      return SocialFeedLikeQueued(optimistic);
    }
    await repo._queue.removeAllLikesForPost(viewer: viewer, postId: postId);
    return SocialFeedLikeSynced(post);
  } on SocialFeedRemoteRejection catch (e) {
    await repo._queue.removeFromQueue(viewer: viewer, mutationId: mutationId);
    return SocialFeedLikeRejected(e.canonical);
  } on SocialFeedFailure catch (failure) {
    if (failure is SocialFeedNotQueuedFailure) {
      rethrow;
    }
    try {
      await repo._queue.enqueueLike(
        viewer: viewer,
        postId: postId,
        desiredLiked: desiredLiked,
        mutationId: mutationId,
      );
    } on Object {
      throw const SocialFeedNotQueuedFailure();
    }
    final SocialFeedPost optimistic = await repo._optimisticPost(
      viewer,
      postId,
    );
    return SocialFeedLikeQueued(optimistic);
  }
}

Future<SocialFeedCommentResult> _addCommentImpl(
  OfflineFirstSocialFeedRepository repo, {
  required SocialFeedViewer viewer,
  required String postId,
  required String body,
  required String mutationId,
}) async {
  await repo._ensureCommentsHydrated();
  if (!repo._scenario.isSimulatedOnline) {
    try {
      await repo._queue.enqueueComment(
        viewer: viewer,
        postId: postId,
        body: body,
        mutationId: mutationId,
      );
    } on Object {
      throw const SocialFeedNotQueuedFailure();
    }
    final SocialFeedPost optimistic = await repo._optimisticPost(
      viewer,
      postId,
    );
    return SocialFeedCommentQueued(post: optimistic, mutationId: mutationId);
  }

  try {
    final SocialFeedPost post = await repo._remote.applyComment(
      viewer: viewer,
      postId: postId,
      body: body,
      mutationId: mutationId,
    );
    final bool persisted = await repo._persistCommentThreads();
    if (!persisted) {
      try {
        await repo._queue.enqueueComment(
          viewer: viewer,
          postId: postId,
          body: body,
          mutationId: mutationId,
        );
      } on Object {
        throw const SocialFeedNotQueuedFailure();
      }
      final SocialFeedPost optimistic = await repo._optimisticPost(
        viewer,
        postId,
      );
      return SocialFeedCommentQueued(post: optimistic, mutationId: mutationId);
    }
    await repo._queue.removeFromQueue(viewer: viewer, mutationId: mutationId);
    return SocialFeedCommentSynced(post: post, mutationId: mutationId);
  } on SocialFeedRemoteRejection catch (e) {
    await repo._queue.removeFromQueue(viewer: viewer, mutationId: mutationId);
    return SocialFeedCommentRejected(e.canonical);
  } on SocialFeedFailure catch (failure) {
    if (failure is SocialFeedNotQueuedFailure) {
      rethrow;
    }
    try {
      await repo._queue.enqueueComment(
        viewer: viewer,
        postId: postId,
        body: body,
        mutationId: mutationId,
      );
    } on Object {
      throw const SocialFeedNotQueuedFailure();
    }
    final SocialFeedPost optimistic = await repo._optimisticPost(
      viewer,
      postId,
    );
    return SocialFeedCommentQueued(post: optimistic, mutationId: mutationId);
  }
}
