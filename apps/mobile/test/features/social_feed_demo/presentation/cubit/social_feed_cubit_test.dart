import 'dart:async';

import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_comment.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_mutation_status.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_page.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_realtime_source.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_repository.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_scenario_controller.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_viewer.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/cubit/social_feed_cubit.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/cubit/social_feed_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SocialFeedPost post({
    required String id,
    bool liked = false,
    int likes = 0,
    int comments = 0,
  }) {
    return SocialFeedPost(
      id: id,
      authorId: 'a1',
      authorDisplayName: 'Author',
      body: 'body',
      createdAt: DateTime.utc(2026, 8, 1),
      isLikedByMe: liked,
      likeCount: likes,
      commentCount: comments,
      serverRevision: 1,
    );
  }

  test('load emits cache then remote ready', () async {
    final _FakeRepo repo = _FakeRepo(
      cached: SocialFeedPage(
        posts: <SocialFeedPost>[post(id: 'c1')],
        nextCursor: 'c1',
        hasMore: true,
        source: SocialFeedDataSource.cache,
        fetchedAt: DateTime.utc(2026, 8, 20),
      ),
      remote: SocialFeedPage(
        posts: <SocialFeedPost>[post(id: 'r1')],
        nextCursor: 'r1',
        hasMore: true,
        source: SocialFeedDataSource.remote,
        fetchedAt: DateTime.utc(2026, 8, 20),
      ),
    );
    final SocialFeedCubit cubit = SocialFeedCubit(
      repository: repo,
      realtimeSource: _FakeRealtime(),
      scenario: _FakeScenario(),
      clock: () => DateTime.utc(2026, 8, 20, 12),
    );

    final Future<void> load = cubit.load();
    await Future<void>.delayed(Duration.zero);
    // Cache may flash before remote; wait for completion.
    await load;
    expect(cubit.state, isA<SocialFeedReady>());
    expect((cubit.state as SocialFeedReady).data.posts.first.id, 'r1');
    expect((cubit.state as SocialFeedReady).data.isShowingCachedData, isFalse);

    await cubit.close();
    expect(repo.lease.closed, isTrue);
  });

  test('toggleLike optimistic then synced', () async {
    final SocialFeedPost base = post(id: 'p1', likes: 1);
    final _FakeRepo repo = _FakeRepo(
      remote: SocialFeedPage(
        posts: <SocialFeedPost>[base],
        nextCursor: null,
        hasMore: false,
        source: SocialFeedDataSource.remote,
        fetchedAt: DateTime.utc(2026, 8, 20),
      ),
      likeResult: SocialFeedLikeSynced(
        base.copyWith(isLikedByMe: true, likeCount: 2, serverRevision: 2),
      ),
    );
    final SocialFeedCubit cubit = SocialFeedCubit(
      repository: repo,
      realtimeSource: _FakeRealtime(),
      scenario: _FakeScenario(),
      clock: () => DateTime.utc(2026, 8, 20, 12),
    );
    await cubit.load();
    await cubit.toggleLike('p1');
    final SocialFeedReady ready = cubit.state as SocialFeedReady;
    expect(ready.data.posts.first.isLikedByMe, isTrue);
    expect(ready.data.posts.first.likeCount, 2);
    await cubit.close();
  });

  test('toggleLike rejected restores canonical and emits effect', () async {
    final SocialFeedPost base = post(id: 'p1', likes: 1);
    final _FakeRepo repo = _FakeRepo(
      remote: SocialFeedPage(
        posts: <SocialFeedPost>[base],
        nextCursor: null,
        hasMore: false,
        source: SocialFeedDataSource.remote,
        fetchedAt: DateTime.utc(2026, 8, 20),
      ),
      likeResult: SocialFeedLikeRejected(base),
    );
    final SocialFeedCubit cubit = SocialFeedCubit(
      repository: repo,
      realtimeSource: _FakeRealtime(),
      scenario: _FakeScenario(),
      clock: () => DateTime.utc(2026, 8, 20, 12),
    );
    await cubit.load();
    await cubit.toggleLike('p1');
    final SocialFeedReady ready = cubit.state as SocialFeedReady;
    expect(ready.data.posts.first.isLikedByMe, isFalse);
    expect(ready.data.effect, isA<SocialFeedMutationRejectedEffect>());
    await cubit.close();
  });

  test('submitComment bumps commentCount and keeps it after sync', () async {
    final SocialFeedPost base = post(id: 'p1', comments: 2);
    final _FakeRepo repo = _FakeRepo(
      remote: SocialFeedPage(
        posts: <SocialFeedPost>[base],
        nextCursor: null,
        hasMore: false,
        source: SocialFeedDataSource.remote,
        fetchedAt: DateTime.utc(2026, 8, 20),
      ),
      commentResult: SocialFeedCommentSynced(
        // Simulate a stale remote projection that forgot the bump.
        post: base.copyWith(serverRevision: 2),
        mutationId: 'will-be-ignored',
      ),
    );
    final SocialFeedCubit cubit = SocialFeedCubit(
      repository: repo,
      realtimeSource: _FakeRealtime(),
      scenario: _FakeScenario(),
      clock: () => DateTime.utc(2026, 8, 20, 12),
    );
    await cubit.load();
    final bool accepted = await cubit.submitComment(
      postId: 'p1',
      body: 'Hello thread',
    );
    expect(accepted, isTrue);
    final SocialFeedReady ready = cubit.state as SocialFeedReady;
    expect(ready.data.posts.first.commentCount, 3);
    expect(ready.data.commentsByPostId['p1'], hasLength(3));
    expect(ready.data.pendingCommentsByPostId['p1'], isNull);
    await cubit.close();
  });

  test('submitComment ignores invalid body', () async {
    final _FakeRepo repo = _FakeRepo(
      remote: SocialFeedPage(
        posts: <SocialFeedPost>[post(id: 'p1')],
        nextCursor: null,
        hasMore: false,
        source: SocialFeedDataSource.remote,
        fetchedAt: DateTime.utc(2026, 8, 20),
      ),
    );
    final SocialFeedCubit cubit = SocialFeedCubit(
      repository: repo,
      realtimeSource: _FakeRealtime(),
      scenario: _FakeScenario(),
      clock: () => DateTime.utc(2026, 8, 20, 12),
    );
    await cubit.load();
    await cubit.submitComment(postId: 'p1', body: '   ');
    expect(repo.commentCalls, 0);
    await cubit.close();
  });

  test('load hydrates queued comments from pending snapshot', () async {
    final SocialFeedPost base = post(id: 'p1', comments: 1);
    final SocialFeedComment queued = SocialFeedComment(
      id: 'comment-p1-1',
      postId: 'p1',
      viewerId: SocialFeedViewer.alex.id,
      body: 'Queued offline',
      createdAt: DateTime.utc(2026, 8, 20, 12),
      syncStatus: SocialFeedMutationStatus.pending,
    );
    final _FakeRepo repo = _FakeRepo(
      cached: SocialFeedPage(
        posts: <SocialFeedPost>[base],
        nextCursor: null,
        hasMore: false,
        source: SocialFeedDataSource.cache,
        fetchedAt: DateTime.utc(2026, 8, 20),
      ),
      remote: SocialFeedPage(
        posts: <SocialFeedPost>[base],
        nextCursor: null,
        hasMore: false,
        source: SocialFeedDataSource.remote,
        fetchedAt: DateTime.utc(2026, 8, 20),
      ),
      pendingSnapshot: SocialFeedPendingSnapshot(
        pendingCommentsByPostId: <String, List<SocialFeedComment>>{
          'p1': <SocialFeedComment>[queued],
        },
        pendingPostIds: <String>{'p1'},
      ),
    );
    final _FakeScenario scenario = _FakeScenario()..online = false;
    final SocialFeedCubit cubit = SocialFeedCubit(
      repository: repo,
      realtimeSource: _FakeRealtime(),
      scenario: scenario,
      clock: () => DateTime.utc(2026, 8, 20, 12),
    );
    await cubit.load();
    final SocialFeedReady ready = cubit.state as SocialFeedReady;
    expect(ready.data.pendingCommentsByPostId['p1'], hasLength(1));
    expect(
      ready.data.pendingCommentsByPostId['p1']!.first.body,
      'Queued offline',
    );
    expect(ready.data.pendingPostIds, contains('p1'));
    await cubit.close();
  });

  test('background sync promotes queued comment without manual refresh', () async {
    final SocialFeedPost base = post(id: 'p1', comments: 1);
    final _FakeScenario scenario = _FakeScenario();
    final DateTime fixedNow = DateTime.utc(2026, 8, 20, 12);
    final _FakeRepo repo = _FakeRepo(
      remote: SocialFeedPage(
        posts: <SocialFeedPost>[base],
        nextCursor: null,
        hasMore: false,
        source: SocialFeedDataSource.remote,
        fetchedAt: DateTime.utc(2026, 8, 20),
      ),
      commentResult: SocialFeedCommentQueued(
        post: base.copyWith(commentCount: 2),
        mutationId: 'comment-p1-${fixedNow.microsecondsSinceEpoch}',
      ),
    );
    final SocialFeedCubit cubit = SocialFeedCubit(
      repository: repo,
      realtimeSource: _FakeRealtime(),
      scenario: scenario,
      clock: () => fixedNow,
    );
    await cubit.load();
    scenario.setSimulatedOnline(online: false);
    await cubit.submitComment(postId: 'p1', body: 'Queued offline');
    final SocialFeedReady queued = cubit.state as SocialFeedReady;
    final String mutationId =
        queued.data.pendingCommentsByPostId['p1']!.first.id;
    expect(queued.data.pendingPostIds, contains('p1'));

    repo.commentsByPostId['p1'] = <SocialFeedComment>[
      ...?repo.commentsByPostId['p1'],
      SocialFeedComment(
        id: mutationId,
        postId: 'p1',
        viewerId: SocialFeedViewer.alex.id,
        body: 'Queued offline',
        createdAt: fixedNow,
        syncStatus: SocialFeedMutationStatus.synced,
      ),
    ];
    repo.lease.emitSummary(
      SocialFeedSyncSummary(
        pendingCount: 0,
        needsAttentionCount: 0,
        dispatchedMutations: <SocialFeedDispatchedMutation>[
          SocialFeedDispatchedMutation(
            mutationId: mutationId,
            postId: 'p1',
            wasComment: true,
          ),
        ],
      ),
    );
    await Future<void>.delayed(Duration.zero);

    final SocialFeedReady synced = cubit.state as SocialFeedReady;
    expect(synced.data.pendingCommentsByPostId['p1'], isNull);
    expect(synced.data.pendingPostIds, isEmpty);
    expect(synced.data.commentsByPostId['p1'], hasLength(2));
    await cubit.close();
  });

  test('switchViewer reloads new viewer', () async {
    final _FakeRepo repo = _FakeRepo(
      remote: SocialFeedPage(
        posts: <SocialFeedPost>[post(id: 'alex')],
        nextCursor: null,
        hasMore: false,
        source: SocialFeedDataSource.remote,
        fetchedAt: DateTime.utc(2026, 8, 20),
      ),
    );
    final SocialFeedCubit cubit = SocialFeedCubit(
      repository: repo,
      realtimeSource: _FakeRealtime(),
      scenario: _FakeScenario(),
      clock: () => DateTime.utc(2026, 8, 20, 12),
    );
    await cubit.load();
    repo.remote = SocialFeedPage(
      posts: <SocialFeedPost>[post(id: 'sam')],
      nextCursor: null,
      hasMore: false,
      source: SocialFeedDataSource.remote,
      fetchedAt: DateTime.utc(2026, 8, 20),
    );
    await cubit.switchViewer(SocialFeedViewer.sam);
    expect((cubit.state as SocialFeedReady).data.viewer, SocialFeedViewer.sam);
    expect((cubit.state as SocialFeedReady).data.posts.first.id, 'sam');
    await cubit.close();
  });
}

class _FakeScenario implements SocialFeedScenarioController {
  bool online = true;

  @override
  bool get isSimulatedOnline => online;

  @override
  void setSimulatedOnline({required bool online}) => this.online = online;

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

class _FakeLease implements SocialFeedSyncLease {
  final StreamController<SocialFeedSyncSummary> _controller =
      StreamController<SocialFeedSyncSummary>.broadcast();
  bool closed = false;

  @override
  Stream<SocialFeedSyncSummary> get summaries => _controller.stream;

  void emitSummary(SocialFeedSyncSummary summary) {
    _controller.add(summary);
  }

  @override
  Future<void> close() async {
    if (closed) {
      return;
    }
    closed = true;
    await _controller.close();
  }
}

class _FakeRealtimeLease implements SocialFeedRealtimeLease {
  final StreamController<SocialFeedConnectionStatus> statusController =
      StreamController<SocialFeedConnectionStatus>.broadcast();
  final StreamController<SocialFeedPost> postsController =
      StreamController<SocialFeedPost>.broadcast();
  bool closed = false;

  @override
  Stream<SocialFeedConnectionStatus> get connectionStatus =>
      statusController.stream;

  @override
  Stream<SocialFeedPost> get posts => postsController.stream;

  @override
  Future<void> close() async {
    closed = true;
    await statusController.close();
    await postsController.close();
  }
}

class _FakeRealtime implements SocialFeedRealtimeSource {
  final _FakeRealtimeLease lease = _FakeRealtimeLease();

  @override
  Future<SocialFeedRealtimeLease> acquire(SocialFeedViewer viewer) async =>
      lease;

  @override
  void flushPendingPosts(SocialFeedViewer viewer) {}
}

class _FakeRepo implements SocialFeedRepository {
  _FakeRepo({
    this.cached,
    required this.remote,
    this.likeResult,
    this.commentResult,
    this.pendingSnapshot = const SocialFeedPendingSnapshot(
      pendingCommentsByPostId: <String, List<SocialFeedComment>>{},
      pendingPostIds: <String>{},
    ),
  });

  SocialFeedPage? cached;
  SocialFeedPage remote;
  SocialFeedLikeResult? likeResult;
  SocialFeedCommentResult? commentResult;
  SocialFeedPendingSnapshot pendingSnapshot;
  int commentCalls = 0;
  final Map<String, List<SocialFeedComment>> commentsByPostId =
      <String, List<SocialFeedComment>>{};
  final _FakeLease lease = _FakeLease();

  @override
  Future<SocialFeedPage?> readCachedPage({
    required SocialFeedViewer viewer,
  }) async => cached;

  @override
  Future<SocialFeedPage> refresh({required SocialFeedViewer viewer}) async =>
      remote;

  @override
  Future<SocialFeedPage> loadMore({
    required SocialFeedViewer viewer,
    required String cursor,
  }) async => remote;

  @override
  Future<SocialFeedLikeResult> setLiked({
    required SocialFeedViewer viewer,
    required String postId,
    required bool desiredLiked,
    required String mutationId,
  }) async {
    return likeResult ??
        SocialFeedLikeSynced(
          remote.posts.first.copyWith(
            isLikedByMe: desiredLiked,
            likeCount: remote.posts.first.likeCount + (desiredLiked ? 1 : -1),
          ),
        );
  }

  @override
  Future<SocialFeedCommentResult> addComment({
    required SocialFeedViewer viewer,
    required String postId,
    required String body,
    required String mutationId,
  }) async {
    commentCalls += 1;
    return commentResult ??
        SocialFeedCommentSynced(
          post: remote.posts.first.copyWith(
            commentCount: remote.posts.first.commentCount + 1,
          ),
          mutationId: mutationId,
        );
  }

  @override
  Future<Map<String, List<SocialFeedComment>>> commentsForPostIds({
    required Iterable<String> postIds,
  }) async {
    return <String, List<SocialFeedComment>>{
      for (final String postId in postIds)
        postId:
            commentsByPostId[postId] ??
            <SocialFeedComment>[
              for (int i = 0; i < _seedCommentCountFor(postId); i++)
                SocialFeedComment(
                  id: '$postId-seed-$i',
                  postId: postId,
                  viewerId: 'author-a',
                  body: 'Seed $i',
                  createdAt: DateTime.utc(2026, 8, 1, 0, i + 1),
                  syncStatus: SocialFeedMutationStatus.synced,
                ),
            ],
    };
  }

  int _seedCommentCountFor(String postId) {
    for (final SocialFeedPost post in remote.posts) {
      if (post.id == postId) {
        return post.commentCount;
      }
    }
    return 0;
  }

  @override
  Future<SocialFeedSyncLease> acquireSync({
    required SocialFeedViewer viewer,
  }) async => lease;

  @override
  Future<void> retryNeedsAttention({
    required SocialFeedViewer viewer,
    required String mutationId,
  }) async {}

  @override
  Future<int> pendingMutationCount({required SocialFeedViewer viewer}) async =>
      0;

  @override
  Future<SocialFeedPendingSnapshot> readPendingSnapshot({
    required SocialFeedViewer viewer,
  }) async => pendingSnapshot;

  @override
  Future<void> resetViewerData({required SocialFeedViewer viewer}) async {}
}
