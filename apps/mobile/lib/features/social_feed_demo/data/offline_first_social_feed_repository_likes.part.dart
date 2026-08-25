part of 'offline_first_social_feed_repository.dart';

Future<void> _persistViewerLikesImpl(
  OfflineFirstSocialFeedRepository repo,
) async {
  try {
    await repo._local.saveViewerLikes(repo._remote.exportViewerLikes());
  } on Object {
    // Persistence degraded; in-memory likes remain for this session.
  }
}

Future<void> _patchCachedPostImpl(
  OfflineFirstSocialFeedRepository repo,
  SocialFeedViewer viewer,
  SocialFeedPost updated,
) async {
  try {
    final SocialFeedPage? existing = await repo._local.readPage(viewer);
    if (existing == null) {
      return;
    }
    final int index = existing.posts.indexWhere(
      (SocialFeedPost post) => post.id == updated.id,
    );
    if (index < 0) {
      return;
    }
    final List<SocialFeedPost> posts = List<SocialFeedPost>.from(
      existing.posts,
    );
    posts[index] = updated;
    await repo._local.savePage(
      viewer,
      SocialFeedPage(
        posts: posts,
        nextCursor: existing.nextCursor,
        hasMore: existing.hasMore,
        source: existing.source,
        fetchedAt: existing.fetchedAt,
      ),
    );
  } on Object {
    // Cache patch degraded; hydrated remote likes still apply on refresh.
  }
}
