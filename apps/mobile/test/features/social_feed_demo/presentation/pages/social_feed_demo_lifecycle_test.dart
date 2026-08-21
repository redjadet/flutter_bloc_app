import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_comment.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_page.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_realtime_source.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_repository.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_scenario_controller.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_viewer.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/cubit/social_feed_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lifecycle pause closes realtime lease; resume reacquires', () async {
    final _Realtime realtime = _Realtime();
    final SocialFeedCubit cubit = SocialFeedCubit(
      repository: _Repo(),
      realtimeSource: realtime,
      scenario: _Scenario(),
      clock: () => DateTime.utc(2026, 8, 20),
    );
    await cubit.load();
    expect(realtime.acquireCount, greaterThanOrEqualTo(1));
    final int afterLoad = realtime.acquireCount;

    cubit.onAppLifecycle(AppLifecycleState.paused);
    await Future<void>.delayed(Duration.zero);
    expect(realtime.lastLease.closed, isTrue);

    cubit.onAppLifecycle(AppLifecycleState.resumed);
    await Future<void>.delayed(Duration.zero);
    expect(realtime.acquireCount, greaterThan(afterLoad));

    await cubit.close();
  });
}

class _Scenario implements SocialFeedScenarioController {
  @override
  bool get isSimulatedOnline => true;

  @override
  void setSimulatedOnline({required bool online}) {}

  @override
  void emitThreeNewPosts({required SocialFeedViewer viewer}) {}

  @override
  void failNextInitialOrRefresh({required SocialFeedViewer viewer}) {}

  @override
  void failNextLoadMore({required SocialFeedViewer viewer}) {}

  @override
  void disconnectRealtimeAndFailNextReconnect({
    required SocialFeedViewer viewer,
  }) {}

  @override
  void failNextFiveQueuedDispatchesRetryably({
    required SocialFeedViewer viewer,
  }) {}

  @override
  void rejectNextLikePermanently({required SocialFeedViewer viewer}) {}

  @override
  void rejectNextCommentPermanently({required SocialFeedViewer viewer}) {}

  @override
  void returnMalformedNextPayload({required SocialFeedViewer viewer}) {}

  @override
  void resetViewerSimulatorFaults({required SocialFeedViewer viewer}) {}
}

class _SyncLease implements SocialFeedSyncLease {
  final StreamController<SocialFeedSyncSummary> c =
      StreamController<SocialFeedSyncSummary>.broadcast();

  @override
  Stream<SocialFeedSyncSummary> get summaries => c.stream;

  @override
  Future<void> close() async {
    if (!c.isClosed) {
      await c.close();
    }
  }
}

class _RtLease implements SocialFeedRealtimeLease {
  final StreamController<SocialFeedConnectionStatus> status =
      StreamController<SocialFeedConnectionStatus>.broadcast();
  final StreamController<SocialFeedPost> postsController =
      StreamController<SocialFeedPost>.broadcast();
  bool closed = false;

  @override
  Stream<SocialFeedConnectionStatus> get connectionStatus => status.stream;

  @override
  Stream<SocialFeedPost> get posts => postsController.stream;

  @override
  Future<void> close() async {
    closed = true;
    if (!status.isClosed) {
      await status.close();
    }
    if (!postsController.isClosed) {
      await postsController.close();
    }
  }
}

class _Realtime implements SocialFeedRealtimeSource {
  int acquireCount = 0;
  _RtLease lastLease = _RtLease();

  @override
  Future<SocialFeedRealtimeLease> acquire(SocialFeedViewer viewer) async {
    acquireCount += 1;
    lastLease = _RtLease();
    return lastLease;
  }

  @override
  void flushPendingPosts(SocialFeedViewer viewer) {}
}

class _Repo implements SocialFeedRepository {
  @override
  Future<SocialFeedPage?> readCachedPage({
    required SocialFeedViewer viewer,
  }) async => null;

  @override
  Future<SocialFeedPage> refresh({required SocialFeedViewer viewer}) async =>
      SocialFeedPage(
        posts: <SocialFeedPost>[
          SocialFeedPost(
            id: 'p1',
            authorId: 'a1',
            authorDisplayName: 'Author',
            body: 'Hello',
            createdAt: DateTime.utc(2026, 8, 1),
            isLikedByMe: false,
            likeCount: 0,
            commentCount: 0,
            serverRevision: 1,
          ),
        ],
        nextCursor: null,
        hasMore: false,
        source: SocialFeedDataSource.remote,
        fetchedAt: DateTime.utc(2026, 8, 20),
      );

  @override
  Future<SocialFeedPage> loadMore({
    required SocialFeedViewer viewer,
    required String cursor,
  }) async => refresh(viewer: viewer);

  @override
  Future<SocialFeedLikeResult> setLiked({
    required SocialFeedViewer viewer,
    required String postId,
    required bool desiredLiked,
    required String mutationId,
  }) async => SocialFeedLikeSynced((await refresh(viewer: viewer)).posts.first);

  @override
  Future<SocialFeedCommentResult> addComment({
    required SocialFeedViewer viewer,
    required String postId,
    required String body,
    required String mutationId,
  }) async => SocialFeedCommentSynced(
    post: (await refresh(viewer: viewer)).posts.first,
    mutationId: mutationId,
  );

  @override
  Future<Map<String, List<SocialFeedComment>>> commentsForPostIds({
    required Iterable<String> postIds,
  }) async => <String, List<SocialFeedComment>>{};

  @override
  Future<SocialFeedSyncLease> acquireSync({
    required SocialFeedViewer viewer,
  }) async => _SyncLease();

  @override
  Future<void> retryNeedsAttention({
    required SocialFeedViewer viewer,
    required String mutationId,
  }) async {}

  @override
  Future<int> pendingMutationCount({required SocialFeedViewer viewer}) async =>
      0;

  @override
  Future<void> resetViewerData({required SocialFeedViewer viewer}) async {}
}
