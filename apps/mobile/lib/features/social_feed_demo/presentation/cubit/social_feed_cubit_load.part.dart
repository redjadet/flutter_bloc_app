part of 'social_feed_cubit.dart';

mixin _SocialFeedCubitLoad on _SocialFeedCubitBase, _SocialFeedCubitHelpers {
  Future<void> load() async {
    final int gen = ++_generation;
    final SocialFeedViewer current = viewer;
    emit(SocialFeedState.loading(current));
    await _closeLeases();

    final SocialFeedPage? cached = await _repository.readCachedPage(
      viewer: current,
    );
    if (gen != _generation || isClosed) {
      return;
    }
    if (cached != null && cached.posts.isNotEmpty) {
      final Map<String, List<SocialFeedComment>> cachedComments =
          await _commentsForPosts(
            cached.posts,
          );
      final SocialFeedPendingSnapshot pendingSnapshot =
          await _readPendingSnapshot(current);
      if (gen != _generation || isClosed) {
        return;
      }
      emit(
        SocialFeedState.ready(
          SocialFeedReadyData(
            viewer: current,
            posts: _postsAlignedToComments(
              posts: cached.posts,
              commentsByPostId: cachedComments,
              pendingCommentsByPostId: pendingSnapshot.pendingCommentsByPostId,
            ),
            nextCursor: cached.nextCursor,
            refreshStatus: const SocialFeedRefreshStatus.loading(),
            pageStatus: const SocialFeedPageStatus.idle(),
            isShowingCachedData: true,
            cacheAge: _cacheAge(cached),
            connectionStatus: SocialFeedConnectionStatus.disconnected,
            isSimulatedOffline: !_scenario.isSimulatedOnline,
            bufferedRealtimePosts: const <SocialFeedPost>[],
            pendingMutationCount: await _repository.pendingMutationCount(
              viewer: current,
            ),
            needsAttentionCount: 0,
            pendingPostIds: pendingSnapshot.pendingPostIds,
            needsAttentionByPostId: const <String, String>{},
            pendingCommentsByPostId: pendingSnapshot.pendingCommentsByPostId,
            commentsByPostId: cachedComments,
          ),
        ),
      );
    }

    try {
      final SocialFeedSyncSummary? seedSummary = await _acquireLeases(
        current,
        generation: gen,
      );
      var seedApplied = false;
      void applySeedIfReady() {
        if (seedApplied || seedSummary == null || state is! SocialFeedReady) {
          return;
        }
        seedApplied = true;
        _applySyncSummary(seedSummary, current);
      }

      applySeedIfReady();
      if (!_scenario.isSimulatedOnline && cached == null) {
        if (gen != _generation || isClosed) {
          return;
        }
        emit(
          SocialFeedState.failure(
            viewer: current,
            failure: const SocialFeedOfflineFailure(),
          ),
        );
        return;
      }
      if (_scenario.isSimulatedOnline) {
        final SocialFeedPage page = await _repository.refresh(
          viewer: current,
        );
        if (gen != _generation || isClosed) {
          return;
        }
        final Map<String, List<SocialFeedComment>> pageComments =
            await _commentsForPosts(page.posts);
        final SocialFeedPendingSnapshot pendingSnapshot =
            await _readPendingSnapshot(current);
        if (gen != _generation || isClosed) {
          return;
        }
        emit(
          SocialFeedState.ready(
            SocialFeedReadyData(
              viewer: current,
              posts: _postsAlignedToComments(
                posts: page.posts,
                commentsByPostId: pageComments,
                pendingCommentsByPostId:
                    pendingSnapshot.pendingCommentsByPostId,
              ),
              nextCursor: page.nextCursor,
              refreshStatus: const SocialFeedRefreshStatus.idle(),
              pageStatus: page.hasMore
                  ? const SocialFeedPageStatus.idle()
                  : const SocialFeedPageStatus.exhausted(),
              isShowingCachedData: false,
              cacheAge: Duration.zero,
              connectionStatus: _realtimeLease == null
                  ? SocialFeedConnectionStatus.disconnected
                  : SocialFeedConnectionStatus.connected,
              isSimulatedOffline: false,
              bufferedRealtimePosts: const <SocialFeedPost>[],
              pendingMutationCount: await _repository.pendingMutationCount(
                viewer: current,
              ),
              needsAttentionCount: 0,
              pendingPostIds: pendingSnapshot.pendingPostIds,
              needsAttentionByPostId: const <String, String>{},
              pendingCommentsByPostId: pendingSnapshot.pendingCommentsByPostId,
              commentsByPostId: pageComments,
            ),
          ),
        );
        applySeedIfReady();
      }
    } on SocialFeedFailure catch (failure) {
      if (gen != _generation || isClosed) {
        return;
      }
      if (cached != null && cached.posts.isNotEmpty) {
        _emitReadyPatch(
          (d) => d.copyWith(
            refreshStatus: SocialFeedRefreshStatus.failure(failure),
            isSimulatedOffline: !_scenario.isSimulatedOnline,
          ),
        );
      } else {
        emit(SocialFeedState.failure(viewer: current, failure: failure));
      }
    } on Object {
      if (gen != _generation || isClosed) {
        return;
      }
      const SocialFeedFailure failure = SocialFeedUnknownFailure();
      if (cached != null && cached.posts.isNotEmpty) {
        _emitReadyPatch(
          (d) => d.copyWith(
            refreshStatus: const SocialFeedRefreshStatus.failure(failure),
          ),
        );
      } else {
        emit(SocialFeedState.failure(viewer: current, failure: failure));
      }
    }
  }

  Future<void> refresh() async {
    final SocialFeedState currentState = state;
    if (currentState is! SocialFeedReady) {
      return load();
    }
    final int gen = _generation;
    _emitReadyPatch(
      (d) => d.copyWith(
        refreshStatus: const SocialFeedRefreshStatus.loading(),
      ),
    );
    try {
      final SocialFeedPage page = await _repository.refresh(
        viewer: currentState.data.viewer,
      );
      if (gen != _generation || isClosed) {
        return;
      }
      final Map<String, List<SocialFeedComment>> pageComments =
          await _commentsForPosts(page.posts);
      if (gen != _generation || isClosed) {
        return;
      }
      _emitReadyPatch(
        (d) => d.copyWith(
          posts: _postsAlignedToComments(
            posts: page.posts,
            commentsByPostId: pageComments,
            pendingCommentsByPostId: d.pendingCommentsByPostId,
          ),
          nextCursor: page.nextCursor,
          refreshStatus: const SocialFeedRefreshStatus.idle(),
          isShowingCachedData: false,
          cacheAge: Duration.zero,
          isSimulatedOffline: !_scenario.isSimulatedOnline,
          pageStatus: page.hasMore
              ? const SocialFeedPageStatus.idle()
              : const SocialFeedPageStatus.exhausted(),
          commentsByPostId: pageComments,
        ),
      );
    } on SocialFeedFailure catch (failure) {
      if (gen != _generation || isClosed) {
        return;
      }
      _emitReadyPatch(
        (d) => d.copyWith(
          refreshStatus: SocialFeedRefreshStatus.failure(failure),
          isSimulatedOffline: !_scenario.isSimulatedOnline,
        ),
      );
    }
  }
}
