part of 'social_feed_cubit.dart';

mixin _SocialFeedCubitHelpers on _SocialFeedCubitBase {
  Duration _cacheAge(SocialFeedPage page) {
    final Duration age = _clock().toUtc().difference(page.fetchedAt);
    return age.isNegative ? Duration.zero : age;
  }

  SocialFeedPost? _findPost(SocialFeedReadyData data, String postId) {
    for (final SocialFeedPost post in data.posts) {
      if (post.id == postId) {
        return post;
      }
    }
    return null;
  }

  void _replacePost(SocialFeedPost post, {required bool clearPending}) {
    _emitReadyPatch((d) {
      final Set<String> pending = Set<String>.from(d.pendingPostIds);
      if (clearPending) {
        pending.remove(post.id);
      }
      // Keep badge in sync with known thread rows (stored + still-pending).
      final int knownCount = _knownCommentCount(d, post.id);
      final SocialFeedPost resolved = post.commentCount < knownCount
          ? post.copyWith(commentCount: knownCount)
          : post;
      return d.copyWith(
        posts: d.posts.map((p) => p.id == post.id ? resolved : p).toList(),
        pendingPostIds: pending,
      );
    });
  }

  int _knownCommentCount(SocialFeedReadyData data, String postId) {
    final Set<String> ids = <String>{
      for (final SocialFeedComment c
          in data.commentsByPostId[postId] ?? const <SocialFeedComment>[])
        c.id,
      for (final SocialFeedComment c
          in data.pendingCommentsByPostId[postId] ??
              const <SocialFeedComment>[])
        c.id,
    };
    return ids.length;
  }

  /// Badge/thread share one source of truth: stored (+ pending) comment rows.
  List<SocialFeedPost> _postsAlignedToComments({
    required List<SocialFeedPost> posts,
    required Map<String, List<SocialFeedComment>> commentsByPostId,
    Map<String, List<SocialFeedComment>> pendingCommentsByPostId =
        const <String, List<SocialFeedComment>>{},
  }) {
    return <SocialFeedPost>[
      for (final SocialFeedPost post in posts)
        _postAlignedToComments(
          post: post,
          stored: commentsByPostId[post.id] ?? const <SocialFeedComment>[],
          pending:
              pendingCommentsByPostId[post.id] ?? const <SocialFeedComment>[],
        ),
    ];
  }

  SocialFeedPost _postAlignedToComments({
    required SocialFeedPost post,
    required List<SocialFeedComment> stored,
    required List<SocialFeedComment> pending,
  }) {
    final Set<String> ids = <String>{
      for (final SocialFeedComment c in stored) c.id,
      for (final SocialFeedComment c in pending) c.id,
    };
    if (ids.length == post.commentCount) {
      return post;
    }
    return post.copyWith(commentCount: ids.length);
  }

  void _clearPendingComment(
    String postId,
    String mutationId, {
    required bool synced,
    bool remove = false,
  }) {
    _emitReadyPatch((d) {
      final Map<String, List<SocialFeedComment>> map =
          Map<String, List<SocialFeedComment>>.from(d.pendingCommentsByPostId);
      final List<SocialFeedComment> list = List<SocialFeedComment>.from(
        map[postId] ?? const <SocialFeedComment>[],
      );
      if (remove) {
        list.removeWhere((c) => c.id == mutationId);
      } else {
        final int idx = list.indexWhere((c) => c.id == mutationId);
        if (idx >= 0) {
          list[idx] = list[idx].copyWith(
            syncStatus: synced
                ? SocialFeedMutationStatus.synced
                : SocialFeedMutationStatus.pending,
          );
        }
      }
      if (list.isEmpty) {
        map.remove(postId);
      } else {
        map[postId] = list;
      }
      return d.copyWith(pendingCommentsByPostId: map);
    });
  }

  void _promotePendingComment(String postId, String mutationId) {
    _emitReadyPatch((d) {
      final Map<String, List<SocialFeedComment>> pendingMap =
          Map<String, List<SocialFeedComment>>.from(d.pendingCommentsByPostId);
      final List<SocialFeedComment> pendingList = List<SocialFeedComment>.from(
        pendingMap[postId] ?? const <SocialFeedComment>[],
      );
      SocialFeedComment? promoted;
      final int idx = pendingList.indexWhere((c) => c.id == mutationId);
      if (idx >= 0) {
        promoted = pendingList
            .removeAt(idx)
            .copyWith(syncStatus: SocialFeedMutationStatus.synced);
      }
      if (pendingList.isEmpty) {
        pendingMap.remove(postId);
      } else {
        pendingMap[postId] = pendingList;
      }
      final Map<String, List<SocialFeedComment>> storedMap =
          Map<String, List<SocialFeedComment>>.from(d.commentsByPostId);
      if (promoted != null) {
        final List<SocialFeedComment> stored = List<SocialFeedComment>.from(
          storedMap[postId] ?? const <SocialFeedComment>[],
        );
        if (!stored.any((c) => c.id == mutationId)) {
          stored.add(promoted);
        }
        storedMap[postId] = stored;
      }
      final int knownCount = () {
        final Set<String> ids = <String>{
          for (final SocialFeedComment c
              in storedMap[postId] ?? const <SocialFeedComment>[])
            c.id,
          for (final SocialFeedComment c
              in pendingMap[postId] ?? const <SocialFeedComment>[])
            c.id,
        };
        return ids.length;
      }();
      return d.copyWith(
        pendingCommentsByPostId: pendingMap,
        commentsByPostId: storedMap,
        posts: d.posts
            .map(
              (p) => p.id == postId && p.commentCount != knownCount
                  ? p.copyWith(commentCount: knownCount)
                  : p,
            )
            .toList(),
      );
    });
  }

  void _emitEffect(SocialFeedEffect effect) {
    _emitReadyPatch(
      (d) => d.copyWith(effect: effect, effectId: d.effectId + 1),
    );
  }

  void _emitReadyPatch(SocialFeedReadyData Function(SocialFeedReadyData) fn) {
    if (isClosed) {
      return;
    }
    final SocialFeedState current = state;
    if (current is! SocialFeedReady) {
      return;
    }
    emit(SocialFeedState.ready(fn(current.data)));
  }

  bool _isCurrentLease(int generation, SocialFeedViewer current) =>
      !isClosed && generation == _generation && current.id == viewer.id;

  Future<Map<String, List<SocialFeedComment>>> _commentsForPosts(
    Iterable<SocialFeedPost> posts,
  ) {
    return _repository.commentsForPostIds(
      postIds: posts.map((post) => post.id),
    );
  }

  Future<SocialFeedPendingSnapshot> _readPendingSnapshot(
    SocialFeedViewer viewer,
  ) {
    return _repository.readPendingSnapshot(viewer: viewer);
  }

  Map<String, List<SocialFeedComment>> _mergeCommentMaps(
    Map<String, List<SocialFeedComment>> existing,
    Map<String, List<SocialFeedComment>> incoming,
  ) {
    if (incoming.isEmpty) {
      return existing;
    }
    return <String, List<SocialFeedComment>>{...existing, ...incoming};
  }

  Future<SocialFeedSyncSummary?> _acquireLeases(
    SocialFeedViewer current, {
    int? generation,
  }) async {
    final int leaseGeneration = generation ?? _generation;
    await _closeLeases();
    final SocialFeedSyncLease syncLease = await _repository.acquireSync(
      viewer: current,
    );
    if (!_isCurrentLease(leaseGeneration, current)) {
      await syncLease.close();
      return null;
    }
    _syncLease = syncLease;
    void onSyncSummary(SocialFeedSyncSummary summary) {
      if (!_isCurrentLease(leaseGeneration, current)) {
        return;
      }
      _applySyncSummary(summary, current);
    }

    _syncSub = registerSubscription(
      syncLease.summaries.listen(
        onSyncSummary,
        onError: (Object error, StackTrace stackTrace) {},
      ),
    );
    final SocialFeedRealtimeLease realtimeLease = await _realtimeSource.acquire(
      current,
    );
    if (!_isCurrentLease(leaseGeneration, current)) {
      await realtimeLease.close();
      if (identical(_syncLease, syncLease)) {
        await _closeLeases();
      }
      return null;
    }
    _realtimeLease = realtimeLease;
    _realtimeStatusSub = registerSubscription(
      realtimeLease.connectionStatus.listen((status) {
        if (!_isCurrentLease(leaseGeneration, current)) {
          return;
        }
        _emitReadyPatch((d) => d.copyWith(connectionStatus: status));
      }, onError: (Object error, StackTrace stackTrace) {}),
    );
    _realtimePostsSub = registerSubscription(
      realtimeLease.posts.listen((post) {
        if (!_isCurrentLease(leaseGeneration, current)) {
          return;
        }
        _emitReadyPatch((d) {
          if (d.posts.any((p) => p.id == post.id) ||
              d.bufferedRealtimePosts.any((p) => p.id == post.id)) {
            return d;
          }
          return d.copyWith(
            bufferedRealtimePosts: <SocialFeedPost>[
              ...d.bufferedRealtimePosts,
              post,
            ],
          );
        });
      }, onError: (Object error, StackTrace stackTrace) {}),
    );
    return syncLease.seedSummary;
  }

  void _applySyncSummary(
    SocialFeedSyncSummary summary,
    SocialFeedViewer current,
  ) {
    _emitReadyPatch((d) {
      final Map<String, String> attentionByPost = <String, String>{
        for (final SocialFeedAttentionMutation item
            in summary.attentionMutations)
          item.postId: item.mutationId,
      };
      final Set<String> pending = Set<String>.from(summary.pendingPostIds)
        ..removeAll(attentionByPost.keys);
      SocialFeedReadyData next = d.copyWith(
        pendingMutationCount: summary.pendingCount,
        needsAttentionCount: summary.needsAttentionCount,
        needsAttentionByPostId: attentionByPost,
        pendingPostIds: pending,
      );
      for (final SocialFeedRejectedSync rejection in summary.rejections) {
        pending.remove(rejection.postId);
        next = next.copyWith(
          posts: next.posts
              .map(
                (p) => p.id == rejection.postId ? rejection.canonicalPost : p,
              )
              .toList(),
          pendingPostIds: pending,
          effect: const SocialFeedEffect.mutationRejected(),
          effectId: next.effectId + 1,
        );
        if (rejection.wasComment && rejection.mutationId != null) {
          final Map<String, List<SocialFeedComment>> comments =
              Map<String, List<SocialFeedComment>>.from(
                next.pendingCommentsByPostId,
              );
          final List<SocialFeedComment>? list = comments[rejection.postId];
          if (list != null) {
            final List<SocialFeedComment> remaining = list
                .where((c) => c.id != rejection.mutationId)
                .toList();
            if (remaining.isEmpty) {
              comments.remove(rejection.postId);
            } else {
              comments[rejection.postId] = remaining;
            }
          }
          next = next.copyWith(pendingCommentsByPostId: comments);
        }
      }
      return next;
    });
    if (summary.dispatchedMutations.isNotEmpty) {
      unawaited(
        _reconcileDispatchedComments(current, summary.dispatchedMutations),
      );
    }
  }

  Future<void> _reconcileDispatchedComments(
    SocialFeedViewer current,
    List<SocialFeedDispatchedMutation> dispatched,
  ) async {
    final List<SocialFeedDispatchedMutation> commentDispatches = dispatched
        .where((item) => item.wasComment)
        .toList();
    if (commentDispatches.isEmpty) {
      return;
    }
    final Set<String> postIds = <String>{
      for (final SocialFeedDispatchedMutation item in commentDispatches)
        item.postId,
    };
    final Map<String, List<SocialFeedComment>> stored = await _repository
        .commentsForPostIds(postIds: postIds);
    if (!_isCurrentLease(_generation, current)) {
      return;
    }
    _emitReadyPatch((d) {
      final Map<String, List<SocialFeedComment>> pendingComments =
          Map<String, List<SocialFeedComment>>.from(d.pendingCommentsByPostId);
      final Map<String, List<SocialFeedComment>> commentsByPostId =
          Map<String, List<SocialFeedComment>>.from(d.commentsByPostId);
      for (final SocialFeedDispatchedMutation item in dispatched) {
        if (!item.wasComment) {
          continue;
        }
        final List<SocialFeedComment> pendingList =
            List<SocialFeedComment>.from(
              pendingComments[item.postId] ?? const <SocialFeedComment>[],
            );
        final int idx = pendingList.indexWhere((c) => c.id == item.mutationId);
        SocialFeedComment? promoted;
        if (idx >= 0) {
          promoted = pendingList
              .removeAt(idx)
              .copyWith(syncStatus: SocialFeedMutationStatus.synced);
        }
        if (pendingList.isEmpty) {
          pendingComments.remove(item.postId);
        } else {
          pendingComments[item.postId] = pendingList;
        }
        final List<SocialFeedComment> storedList = List<SocialFeedComment>.from(
          commentsByPostId[item.postId] ??
              stored[item.postId] ??
              const <SocialFeedComment>[],
        );
        if (promoted != null &&
            !storedList.any((c) => c.id == item.mutationId)) {
          storedList.add(promoted);
        } else if (promoted == null) {
          for (final SocialFeedComment comment
              in stored[item.postId] ?? const <SocialFeedComment>[]) {
            if (comment.id == item.mutationId &&
                !storedList.any((c) => c.id == item.mutationId)) {
              storedList.add(comment);
            }
          }
        }
        commentsByPostId[item.postId] = storedList;
      }
      return d.copyWith(
        pendingCommentsByPostId: pendingComments,
        commentsByPostId: commentsByPostId,
        posts: _postsAlignedToComments(
          posts: d.posts,
          commentsByPostId: commentsByPostId,
          pendingCommentsByPostId: pendingComments,
        ),
      );
    });
  }

  Future<void> _closeLeases() async {
    await cancelRegisteredSubscription(_syncSub);
    await cancelRegisteredSubscription(_realtimePostsSub);
    await cancelRegisteredSubscription(_realtimeStatusSub);
    _syncSub = null;
    _realtimePostsSub = null;
    _realtimeStatusSub = null;
    await _syncLease?.close();
    await _realtimeLease?.close();
    _syncLease = null;
    _realtimeLease = null;
  }
}
