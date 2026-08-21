part of 'offline_first_social_feed_repository.dart';

Future<void> _ensureCommentsHydratedImpl(
  OfflineFirstSocialFeedRepository repo,
) async {
  if (repo._commentsHydrated) {
    return;
  }
  final Future<void>? inFlight = repo._commentsHydrateInFlight;
  if (inFlight != null) {
    await inFlight;
    return;
  }
  final Future<void> pending = () async {
    try {
      final Map<String, List<SocialFeedComment>>? stored = await repo._local
          .readCommentThreads();
      if (stored != null && stored.isNotEmpty) {
        repo._remote.replaceCommentThreads(stored);
      }
    } on Object {
      // Degraded: keep in-memory seed threads.
    } finally {
      repo
        .._commentsHydrated = true
        .._commentsHydrateInFlight = null;
    }
  }();
  repo._commentsHydrateInFlight = pending;
  await pending;
}

Future<void> _persistCommentThreadsImpl(
  OfflineFirstSocialFeedRepository repo,
) async {
  try {
    await repo._local.saveCommentThreads(repo._remote.exportCommentThreads());
  } on Object {
    // Persistence degraded; in-memory threads remain for this session.
  }
}

Future<SocialFeedPage> _refreshImpl(
  OfflineFirstSocialFeedRepository repo, {
  required SocialFeedViewer viewer,
}) async {
  await repo._ensureCommentsHydrated();
  final SocialFeedPage remotePage = await repo._remote.fetchPage(
    viewer: viewer,
    isRefresh: true,
  );
  // TOCTOU: final local re-read before persistence.
  final SocialFeedPage? existing = await repo._local.readPage(viewer);
  // Current remote page is source of truth for shared seed content. Keep only
  // cached posts that are not on this page (older pages) so seed edits and
  // thread projections apply after hot restart.
  final Set<String> remoteIds = <String>{
    for (final SocialFeedPost post in remotePage.posts) post.id,
  };
  final List<SocialFeedPost> merged = repo._mergePolicy.dedupeById(
    <SocialFeedPost>[
      ...remotePage.posts,
      if (existing != null)
        ...existing.posts.where(
          (post) => !remoteIds.contains(post.id),
        ),
    ],
  );
  final SocialFeedPage page = SocialFeedPage(
    posts: merged.take(repo._local.maxCachedPosts).toList(),
    nextCursor:
        remotePage.nextCursor ?? (merged.isNotEmpty ? merged.last.id : null),
    hasMore: true,
    source: SocialFeedDataSource.remote,
    fetchedAt: remotePage.fetchedAt,
  );
  try {
    await repo._local.savePage(viewer, page);
  } on Object {
    // Keep in-memory result; persistence degraded is surfaced by Cubit.
  }
  return repo._overlayPending(viewer, page);
}
