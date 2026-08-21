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
      return d.copyWith(
        posts: d.posts.map((p) => p.id == post.id ? post : p).toList(),
        pendingPostIds: pending,
      );
    });
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
        final int idx = list.indexWhere(
          (c) => c.id == mutationId,
        );
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

  Future<void> _acquireLeases(
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
      return;
    }
    _syncLease = syncLease;
    _syncSub = registerSubscription(
      syncLease.summaries.listen(
        (summary) {
          if (!_isCurrentLease(leaseGeneration, current)) {
            return;
          }
          _emitReadyPatch((d) {
            final Map<String, String> attentionByPost = <String, String>{
              for (final SocialFeedAttentionMutation item
                  in summary.attentionMutations)
                item.postId: item.mutationId,
            };
            final Set<String> pending = Set<String>.from(d.pendingPostIds)
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
                      (p) => p.id == rejection.postId
                          ? rejection.canonicalPost
                          : p,
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
                final List<SocialFeedComment>? list =
                    comments[rejection.postId];
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
        },
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
      return;
    }
    _realtimeLease = realtimeLease;
    _realtimeStatusSub = registerSubscription(
      realtimeLease.connectionStatus.listen(
        (status) {
          if (!_isCurrentLease(leaseGeneration, current)) {
            return;
          }
          _emitReadyPatch(
            (d) => d.copyWith(connectionStatus: status),
          );
        },
        onError: (Object error, StackTrace stackTrace) {},
      ),
    );
    _realtimePostsSub = registerSubscription(
      realtimeLease.posts.listen(
        (post) {
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
        },
        onError: (Object error, StackTrace stackTrace) {},
      ),
    );
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
