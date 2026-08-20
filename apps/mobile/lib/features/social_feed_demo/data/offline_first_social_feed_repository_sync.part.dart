part of 'offline_first_social_feed_repository.dart';

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
  if (!repo._scenario.isSimulatedOnline) {
    final List<SocialFeedMutationDto> q = await repo._queue.readQueue(viewer);
    final List<SocialFeedMutationDto> a = await repo._queue.readNeedsAttention(
      viewer,
    );
    return SocialFeedSyncSummary(
      pendingCount: q.length,
      needsAttentionCount: a.length,
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
  while (queue.isNotEmpty) {
    final SocialFeedMutationDto head = queue.first;
    final String? nextAttemptAt = head.nextAttemptAt;
    if (nextAttemptAt != null) {
      final DateTime next = DateTime.parse(nextAttemptAt).toUtc();
      if (next.isAfter(now)) {
        break;
      }
    }
    try {
      if (head.type == 'like') {
        await repo._remote.applyLike(
          viewer: viewer,
          postId: head.postId,
          desiredLiked: head.desiredLiked ?? false,
          mutationId: head.idempotencyKey,
        );
      } else if (head.type == 'comment') {
        await repo._remote.applyComment(
          viewer: viewer,
          postId: head.postId,
          body: head.commentBody ?? '',
          mutationId: head.idempotencyKey,
        );
      }
      await repo._queue.removeFromQueue(
        viewer: viewer,
        mutationId: head.mutationId,
      );
    } on SocialFeedRemoteRejection catch (e) {
      await repo._queue.removeFromQueue(
        viewer: viewer,
        mutationId: head.mutationId,
      );
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
        queue = await repo._queue.readQueue(viewer);
        final int idx = queue.indexWhere(
          (e) => e.mutationId == head.mutationId,
        );
        if (idx >= 0) {
          queue[idx] = SocialFeedMutationDto(
            mutationId: head.mutationId,
            viewerId: head.viewerId,
            type: head.type,
            postId: head.postId,
            sequence: head.sequence,
            idempotencyKey: head.idempotencyKey,
            attemptCount: attempts,
            nextAttemptAt: now.add(backoff).toIso8601String(),
            desiredLiked: head.desiredLiked,
            commentBody: head.commentBody,
            status: 'pending',
            dispatched: false,
          );
          await repo._queue.replaceQueue(viewer, queue);
        }
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
    attentionMutations: <SocialFeedAttentionMutation>[
      for (final SocialFeedMutationDto item in attention)
        SocialFeedAttentionMutation(
          mutationId: item.mutationId,
          postId: item.postId,
        ),
    ],
    rejections: rejections,
  );
}
