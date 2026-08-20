import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/data/hive_social_feed_local_data_source.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/data/hive_social_feed_mutation_queue.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/data/simulated_social_feed_remote_data_source.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/data/simulated_social_feed_scenario_controller.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/data/social_feed_mutation_dto.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_failure.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_merge_policy.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_page.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_repository.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_viewer.dart';

part 'offline_first_social_feed_repository_mutations.part.dart';
part 'offline_first_social_feed_repository_sync.part.dart';
part 'offline_first_social_feed_repository_replay.part.dart';

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

  @override
  Future<SocialFeedPage?> readCachedPage({
    required SocialFeedViewer viewer,
  }) async {
    final SocialFeedPage? cached = await _local.readPage(viewer);
    if (cached == null) {
      return null;
    }
    return _overlayPending(viewer, cached);
  }

  @override
  Future<SocialFeedPage> refresh({required SocialFeedViewer viewer}) async {
    final SocialFeedPage remotePage = await _remote.fetchPage(
      viewer: viewer,
      isRefresh: true,
    );
    // TOCTOU: final local re-read before persistence.
    final SocialFeedPage? existing = await _local.readPage(viewer);
    final List<SocialFeedPost> merged = _mergePolicy.dedupeById(
      <SocialFeedPost>[
        ...remotePage.posts,
        if (existing != null) ...existing.posts,
      ],
    );
    final SocialFeedPage page = SocialFeedPage(
      posts: merged.take(_local.maxCachedPosts).toList(),
      nextCursor:
          remotePage.nextCursor ?? (merged.isNotEmpty ? merged.last.id : null),
      hasMore: true,
      source: SocialFeedDataSource.remote,
      fetchedAt: remotePage.fetchedAt,
    );
    try {
      await _local.savePage(viewer, page);
    } on Object {
      // Keep in-memory result; persistence degraded is surfaced by Cubit.
    }
    return _overlayPending(viewer, page);
  }

  @override
  Future<SocialFeedPage> loadMore({
    required SocialFeedViewer viewer,
    required String cursor,
  }) async {
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
  Future<void> resetViewerData({required SocialFeedViewer viewer}) async {
    await _local.clearViewer(viewer);
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
