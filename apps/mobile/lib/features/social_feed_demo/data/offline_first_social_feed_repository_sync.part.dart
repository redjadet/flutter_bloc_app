part of 'offline_first_social_feed_repository.dart';

Future<SocialFeedPendingSnapshot> _readPendingSnapshotImpl(
  OfflineFirstSocialFeedRepository repo,
  SocialFeedViewer viewer,
) async {
  List<SocialFeedMutationDto> queue;
  try {
    queue = await repo._queue.readQueue(viewer);
  } on Object {
    queue = const <SocialFeedMutationDto>[];
  }
  final Map<String, List<SocialFeedComment>> pendingComments =
      <String, List<SocialFeedComment>>{};
  final Set<String> pendingPostIds = <String>{};
  final DateTime now = repo._queue.now();
  for (final SocialFeedMutationDto item in queue) {
    pendingPostIds.add(item.postId);
    if (item.type != 'comment') {
      continue;
    }
    final String? body = item.commentBody;
    if (body == null) {
      continue;
    }
    pendingComments
        .putIfAbsent(item.postId, () => <SocialFeedComment>[])
        .add(
          SocialFeedComment(
            id: item.mutationId,
            postId: item.postId,
            viewerId: item.viewerId,
            body: body,
            createdAt: now,
            syncStatus: SocialFeedMutationStatus.pending,
          ),
        );
  }
  return SocialFeedPendingSnapshot(
    pendingCommentsByPostId: pendingComments,
    pendingPostIds: pendingPostIds,
  );
}

Future<SocialFeedPage> _overlayPendingImpl(
  OfflineFirstSocialFeedRepository repo,
  SocialFeedViewer viewer,
  SocialFeedPage page,
) async {
  List<SocialFeedMutationDto> queue;
  try {
    queue = await repo._queue.readQueue(viewer);
  } on Object {
    // Degraded: cache/remote still usable without pending overlay.
    queue = const <SocialFeedMutationDto>[];
  }
  final Map<String, bool> pendingLikes = <String, bool>{};
  final Map<String, int> pendingComments = <String, int>{};
  for (final SocialFeedMutationDto item in queue) {
    if (item.type == 'like') {
      final bool? desiredLiked = item.desiredLiked;
      if (desiredLiked != null) {
        pendingLikes[item.postId] = desiredLiked;
      }
    } else if (item.type == 'comment') {
      pendingComments[item.postId] = (pendingComments[item.postId] ?? 0) + 1;
    }
  }
  final List<SocialFeedPost> posts = <SocialFeedPost>[
    for (final SocialFeedPost post in page.posts)
      repo._mergePolicy.applyPendingCommentCount(
        base: repo._mergePolicy.applyPendingLike(
          base: post,
          pendingLiked: pendingLikes[post.id],
        ),
        pendingCommentSubmissions: pendingComments[post.id] ?? 0,
      ),
  ];
  return SocialFeedPage(
    posts: posts,
    nextCursor: page.nextCursor,
    hasMore: page.hasMore,
    source: page.source,
    fetchedAt: page.fetchedAt,
  );
}

Future<SocialFeedPost> _optimisticPostImpl(
  OfflineFirstSocialFeedRepository repo,
  SocialFeedViewer viewer,
  String postId,
) async {
  final SocialFeedPage? cached = await repo.readCachedPage(viewer: viewer);
  if (cached != null) {
    for (final SocialFeedPost post in cached.posts) {
      if (post.id == postId) {
        return post;
      }
    }
  }
  final SocialFeedPost? remote = repo._remote.projectPost(
    viewer: viewer,
    postId: postId,
  );
  if (remote != null) {
    final SocialFeedPage overlaid = await repo._overlayPending(
      viewer,
      SocialFeedPage(
        posts: <SocialFeedPost>[remote],
        nextCursor: null,
        hasMore: false,
        source: SocialFeedDataSource.remote,
        fetchedAt: repo._queue.now(),
      ),
    );
    return overlaid.posts.first;
  }
  return SocialFeedPost(
    id: postId,
    authorId: 'unknown',
    authorDisplayName: 'Unknown',
    body: '',
    createdAt: DateTime.now().toUtc(),
    isLikedByMe: false,
    likeCount: 0,
    commentCount: 0,
    serverRevision: 0,
  );
}

Future<SocialFeedSyncSummary> _dispatchQueueImpl(
  OfflineFirstSocialFeedRepository repo,
  SocialFeedViewer viewer,
) async {
  await repo._ensureCommentsHydrated();
  if (!repo._scenario.isSimulatedOnline) {
    final List<SocialFeedMutationDto> q = await repo._queue.readQueue(viewer);
    final List<SocialFeedMutationDto> a = await repo._queue.readNeedsAttention(
      viewer,
    );
    return SocialFeedSyncSummary(
      pendingCount: q.length,
      needsAttentionCount: a.length,
      pendingPostIds: <String>{
        for (final SocialFeedMutationDto item in q) item.postId,
      },
      attentionMutations: <SocialFeedAttentionMutation>[
        for (final SocialFeedMutationDto item in a)
          SocialFeedAttentionMutation(
            mutationId: item.mutationId,
            postId: item.postId,
          ),
      ],
    );
  }

  List<SocialFeedMutationDto> queue = await repo._queue.readQueue(viewer);
  final DateTime now = repo._queue.now();
  final List<SocialFeedRejectedSync> rejections = <SocialFeedRejectedSync>[];
  final List<SocialFeedDispatchedMutation> dispatched =
      <SocialFeedDispatchedMutation>[];
  while (queue.isNotEmpty) {
    final SocialFeedMutationDto head = queue.first;
    final String? nextAttemptAt = head.nextAttemptAt;
    if (nextAttemptAt != null) {
      try {
        final DateTime next = DateTime.parse(nextAttemptAt).toUtc();
        if (next.isAfter(now)) {
          break;
        }
      } on FormatException {
        // Corrupt backoff timestamp; retry on the next tick.
      }
    }
    try {
      if (head.type == 'like') {
        var likeDispatchCompleted = false;
        await repo._queue.markLikeMutationDispatched(
          viewer: viewer,
          mutationId: head.mutationId,
        );
        await repo.withLikeApplyLock(viewer, () async {
          final List<SocialFeedMutationDto> currentQueue = await repo._queue
              .readQueue(viewer);
          final SocialFeedMutationDto? currentHead = currentQueue.isEmpty
              ? null
              : currentQueue.first;
          if (currentHead == null ||
              currentHead.mutationId != head.mutationId) {
            await repo._queue.removeFromQueue(
              viewer: viewer,
              mutationId: head.mutationId,
            );
            likeDispatchCompleted = true;
            return;
          }
          final SocialFeedPost updated = await repo._remote.applyLike(
            viewer: viewer,
            postId: head.postId,
            desiredLiked: currentHead.desiredLiked ?? false,
            mutationId: head.idempotencyKey,
          );
          final List<SocialFeedMutationDto> queueAfterApply = await repo._queue
              .readQueue(viewer);
          final bool headStillCurrent =
              queueAfterApply.isNotEmpty &&
              queueAfterApply.first.mutationId == head.mutationId;
          var persisted = true;
          if (headStillCurrent) {
            persisted = await repo._persistViewerLikes();
            await repo._patchCachedPost(viewer, updated);
          }
          if (persisted) {
            await repo._queue.removeFromQueue(
              viewer: viewer,
              mutationId: head.mutationId,
            );
            likeDispatchCompleted = true;
          }
        });
        if (likeDispatchCompleted) {
          dispatched.add(
            SocialFeedDispatchedMutation(
              mutationId: head.mutationId,
              postId: head.postId,
              wasComment: false,
            ),
          );
        } else {
          // Keep the head for the next scheduled retry after local persistence fails.
          break;
        }
      } else if (head.type == 'comment') {
        await repo._remote.applyComment(
          viewer: viewer,
          postId: head.postId,
          body: head.commentBody ?? '',
          mutationId: head.idempotencyKey,
        );
        final bool persisted = await repo._persistCommentThreads();
        if (persisted) {
          await repo._queue.removeFromQueue(
            viewer: viewer,
            mutationId: head.mutationId,
          );
          dispatched.add(
            SocialFeedDispatchedMutation(
              mutationId: head.mutationId,
              postId: head.postId,
              wasComment: true,
            ),
          );
        } else {
          // Keep the head for the next scheduled retry after local persistence fails.
          break;
        }
      }
    } on SocialFeedRemoteRejection catch (e) {
      if (head.type == 'like') {
        await repo._queue.removeFromQueue(
          viewer: viewer,
          mutationId: head.mutationId,
        );
      } else {
        await repo._queue.removeFromQueue(
          viewer: viewer,
          mutationId: head.mutationId,
        );
      }
      rejections.add(
        SocialFeedRejectedSync(
          postId: head.postId,
          canonicalPost: e.canonical,
          wasComment: head.type == 'comment',
          mutationId: head.mutationId,
        ),
      );
    } on Object {
      final int attempts = head.attemptCount + 1;
      if (attempts >= 5) {
        await repo._queue.moveToNeedsAttention(viewer, head);
      } else {
        final Duration backoff = repo._queue.backoffForAttempt(attempts);
        await repo._queue.updateMutationAfterFailure(
          viewer: viewer,
          mutationId: head.mutationId,
          head: head,
          attemptCount: attempts,
          nextAttemptAt: now.add(backoff),
        );
        break;
      }
    }
    queue = await repo._queue.readQueue(viewer);
  }

  final List<SocialFeedMutationDto> pending = await repo._queue.readQueue(
    viewer,
  );
  final List<SocialFeedMutationDto> attention = await repo._queue
      .readNeedsAttention(viewer);
  return SocialFeedSyncSummary(
    pendingCount: pending.length,
    needsAttentionCount: attention.length,
    pendingPostIds: <String>{
      for (final SocialFeedMutationDto item in pending) item.postId,
    },
    attentionMutations: <SocialFeedAttentionMutation>[
      for (final SocialFeedMutationDto item in attention)
        SocialFeedAttentionMutation(
          mutationId: item.mutationId,
          postId: item.postId,
        ),
    ],
    rejections: rejections,
    dispatchedMutations: dispatched,
  );
}
