part of 'social_feed_cubit.dart';

mixin _SocialFeedCubitPaging on _SocialFeedCubitBase, _SocialFeedCubitHelpers {
  Future<void> activateBufferedPosts() async {
    final SocialFeedState currentState = state;
    if (currentState is! SocialFeedReady) {
      return;
    }
    final List<SocialFeedPost> buffered =
        currentState.data.bufferedRealtimePosts;
    if (buffered.isEmpty) {
      return;
    }
    final Map<String, SocialFeedPost> byId = <String, SocialFeedPost>{
      for (final SocialFeedPost p in buffered) p.id: p,
      for (final SocialFeedPost p in currentState.data.posts) p.id: p,
    };
    final List<SocialFeedPost> ordered = <SocialFeedPost>[
      ...buffered,
      ...currentState.data.posts.where(
        (p) => !buffered.any((b) => b.id == p.id),
      ),
    ];
    _emitReadyPatch(
      (d) => d.copyWith(
        posts: <SocialFeedPost>[
          for (final SocialFeedPost p in ordered)
            if (byId[p.id] case final SocialFeedPost latest) latest,
        ],
        bufferedRealtimePosts: const <SocialFeedPost>[],
        commentsByPostId: _mergeCommentMaps(
          d.commentsByPostId,
          // Realtime posts start with empty threads; keep any prior entries.
          <String, List<SocialFeedComment>>{
            for (final SocialFeedPost post in buffered)
              post.id:
                  d.commentsByPostId[post.id] ?? const <SocialFeedComment>[],
          },
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    final SocialFeedState currentState = state;
    if (currentState is! SocialFeedReady) {
      return;
    }
    final SocialFeedReadyData data = currentState.data;
    if (_loadMoreInFlight ||
        data.nextCursor == null ||
        data.pageStatus is SocialFeedPageLoading) {
      return;
    }
    _loadMoreInFlight = true;
    final int gen = _generation;
    _emitReadyPatch(
      (d) => d.copyWith(pageStatus: const SocialFeedPageStatus.loading()),
    );
    try {
      final String? cursor = data.nextCursor;
      if (cursor == null) {
        return;
      }
      final SocialFeedPage page = await _repository.loadMore(
        viewer: data.viewer,
        cursor: cursor,
      );
      if (gen != _generation || isClosed) {
        return;
      }
      final Map<String, SocialFeedPost> byId = <String, SocialFeedPost>{
        for (final SocialFeedPost p in data.posts) p.id: p,
      };
      for (final SocialFeedPost p in page.posts) {
        byId[p.id] = p;
      }
      final List<SocialFeedPost> merged = <SocialFeedPost>[
        for (final SocialFeedPost p in data.posts)
          if (byId[p.id] case final SocialFeedPost latest) latest,
        ...page.posts.where(
          (p) => !data.posts.any((e) => e.id == p.id),
        ),
      ];
      final Map<String, List<SocialFeedComment>> pageComments =
          await _commentsForPosts(page.posts);
      if (gen != _generation || isClosed) {
        return;
      }
      final Map<String, List<SocialFeedComment>> mergedComments =
          _mergeCommentMaps(
            data.commentsByPostId,
            pageComments,
          );
      _emitReadyPatch(
        (d) => d.copyWith(
          posts: _postsAlignedToComments(
            posts: merged,
            commentsByPostId: mergedComments,
            pendingCommentsByPostId: d.pendingCommentsByPostId,
          ),
          nextCursor: page.nextCursor,
          pageStatus: page.hasMore
              ? const SocialFeedPageStatus.idle()
              : const SocialFeedPageStatus.exhausted(),
          commentsByPostId: mergedComments,
        ),
      );
    } on SocialFeedFailure catch (failure) {
      if (gen != _generation || isClosed) {
        return;
      }
      _emitReadyPatch(
        (d) => d.copyWith(pageStatus: SocialFeedPageStatus.failure(failure)),
      );
    } finally {
      _loadMoreInFlight = false;
    }
  }
}
