import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/data/hive_social_feed_local_data_source.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/data/hive_social_feed_mutation_queue.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/data/simulated_social_feed_remote_data_source.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/data/simulated_social_feed_scenario_controller.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/data/social_feed_mutation_dto.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_comment.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_failure.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_merge_policy.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_mutation_status.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_page.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_repository.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_viewer.dart';

part 'offline_first_social_feed_repository_comments.part.dart';
part 'offline_first_social_feed_repository_likes.part.dart';
part 'offline_first_social_feed_repository_mutations.part.dart';
part 'offline_first_social_feed_repository_replay.part.dart';
part 'offline_first_social_feed_repository_sync.part.dart';

class OfflineFirstSocialFeedRepository implements SocialFeedRepository {
  OfflineFirstSocialFeedRepository({
    required this._local,
    required this._queue,
    required this._remote,
    required this._scenario,
    required this._timerService,
    this._mergePolicy = const SocialFeedMergePolicy(),
  });

  final HiveSocialFeedLocalDataSource _local;
  final HiveSocialFeedMutationQueue _queue;
  final SimulatedSocialFeedRemoteDataSource _remote;
  final SimulatedSocialFeedScenarioController _scenario;
  final TimerService _timerService;
  final SocialFeedMergePolicy _mergePolicy;

  final Map<String, _ViewerReplay> _replays = <String, _ViewerReplay>{};
  final Map<String, Completer<void>> _likeApplyLocks =
      <String, Completer<void>>{};
  bool _commentsHydrated = false;
  Future<void>? _commentsHydrateInFlight;

  /// Serializes remote like applies per viewer (dispatch + online setLiked).
  Future<T> withLikeApplyLock<T>(
    SocialFeedViewer viewer,
    Future<T> Function() action,
  ) async {
    final Completer<void>? previous = _likeApplyLocks[viewer.id];
    final Completer<void> gate = Completer<void>();
    _likeApplyLocks[viewer.id] = gate;
    if (previous != null) {
      try {
        await previous.future;
      } on Object {
        // Prior critical section failed; continue safely.
      }
    }
    try {
      return await action();
    } finally {
      if (!gate.isCompleted) {
        gate.complete();
      }
      if (identical(_likeApplyLocks[viewer.id], gate)) {
        _likeApplyLocks.remove(viewer.id);
      }
    }
  }

  Future<void> _ensureCommentsHydrated() => _ensureCommentsHydratedImpl(this);

  Future<bool> _persistCommentThreads() => _persistCommentThreadsImpl(this);

  Future<bool> _persistViewerLikes() => _persistViewerLikesImpl(this);

  Future<void> _patchCachedPost(
    SocialFeedViewer viewer,
    SocialFeedPost updated,
  ) => _patchCachedPostImpl(this, viewer, updated);

  @override
  Future<SocialFeedPage?> readCachedPage({
    required SocialFeedViewer viewer,
  }) async {
    await _ensureCommentsHydrated();
    final SocialFeedPage? cached = await _local.readPage(viewer);
    if (cached == null) {
      return null;
    }
    return _overlayPending(viewer, cached);
  }

  @override
  Future<SocialFeedPage> refresh({required SocialFeedViewer viewer}) =>
      _refreshImpl(this, viewer: viewer);

  @override
  Future<SocialFeedPage> loadMore({
    required SocialFeedViewer viewer,
    required String cursor,
  }) async {
    await _ensureCommentsHydrated();
    final SocialFeedPage remotePage = await _remote.fetchPage(
      viewer: viewer,
      cursor: cursor,
      isRefresh: false,
    );
    return _overlayPending(viewer, remotePage);
  }

  @override
  Future<SocialFeedLikeResult> setLiked({
    required SocialFeedViewer viewer,
    required String postId,
    required bool desiredLiked,
    required String mutationId,
  }) => _setLikedImpl(
    this,
    viewer: viewer,
    postId: postId,
    desiredLiked: desiredLiked,
    mutationId: mutationId,
  );

  @override
  Future<SocialFeedCommentResult> addComment({
    required SocialFeedViewer viewer,
    required String postId,
    required String body,
    required String mutationId,
  }) => _addCommentImpl(
    this,
    viewer: viewer,
    postId: postId,
    body: body,
    mutationId: mutationId,
  );

  @override
  Future<Map<String, List<SocialFeedComment>>> commentsForPostIds({
    required Iterable<String> postIds,
  }) async {
    await _ensureCommentsHydrated();
    return _remote.commentsForPostIds(postIds);
  }

  @override
  Future<SocialFeedSyncLease> acquireSync({
    required SocialFeedViewer viewer,
  }) async {
    final _ViewerReplay replay = _replays.putIfAbsent(
      viewer.id,
      () => _ViewerReplay(
        viewer: viewer,
        repository: this,
        timerService: _timerService,
        onZero: () => _replays.remove(viewer.id),
      ),
    );
    return replay.addLease();
  }

  @override
  Future<void> retryNeedsAttention({
    required SocialFeedViewer viewer,
    required String mutationId,
  }) => _queue.manualRetry(viewer: viewer, mutationId: mutationId);

  @override
  Future<int> pendingMutationCount({required SocialFeedViewer viewer}) async {
    final List<SocialFeedMutationDto> queue = await _queue.readQueue(viewer);
    return queue.length;
  }

  @override
  Future<SocialFeedPendingSnapshot> readPendingSnapshot({
    required SocialFeedViewer viewer,
  }) => _readPendingSnapshotImpl(this, viewer);

  @override
  Future<void> resetViewerData({required SocialFeedViewer viewer}) async {
    await _local.clearViewer(viewer);
    await _local.removeViewerLikes(viewer);
    await _queue.clearViewer(viewer);
    _remote.resetViewerPersonalization(viewer);
    _scenario.resetViewerSimulatorFaults(viewer: viewer);
  }

  Future<void> dispose() async {
    for (final _ViewerReplay replay in List<_ViewerReplay>.from(
      _replays.values,
    )) {
      await replay.forceClose();
    }
    _replays.clear();
  }

  Future<SocialFeedPage> _overlayPending(
    SocialFeedViewer viewer,
    SocialFeedPage page,
  ) => _overlayPendingImpl(this, viewer, page);

  /// Post after queue overlay (no second delta apply).
  Future<SocialFeedPost> _optimisticPost(
    SocialFeedViewer viewer,
    String postId,
  ) => _optimisticPostImpl(this, viewer, postId);

  Future<SocialFeedSyncSummary> _dispatchQueue(SocialFeedViewer viewer) =>
      _dispatchQueueImpl(this, viewer);
}
