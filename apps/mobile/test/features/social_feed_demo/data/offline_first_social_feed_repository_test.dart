import 'package:flutter_bloc_app/features/social_feed_demo/data/hive_social_feed_local_data_source.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/data/hive_social_feed_mutation_queue.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/data/offline_first_social_feed_repository.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/data/simulated_social_feed_remote_data_source.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/data/simulated_social_feed_scenario_controller.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_comment.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_page.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_repository.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_viewer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storage/storage.dart';

import '../../../test_helpers.dart' as test_helpers;

void main() {
  late HiveService hiveService;
  late SimulatedSocialFeedScenarioController scenario;
  late SimulatedSocialFeedRemoteDataSource remote;
  late HiveSocialFeedLocalDataSource local;
  late HiveSocialFeedMutationQueue queue;
  late OfflineFirstSocialFeedRepository repository;
  late test_helpers.FakeTimerService timer;
  DateTime now = DateTime.utc(2026, 8, 20, 12);

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await test_helpers.setupHiveForTesting();
  });

  setUp(() async {
    hiveService = await test_helpers.createHiveService();
    scenario = SimulatedSocialFeedScenarioController();
    remote = SimulatedSocialFeedRemoteDataSource(
      scenario: scenario,
      clock: () => now,
    );
    local = HiveSocialFeedLocalDataSource(
      hiveService: hiveService,
      clock: () => now,
    );
    queue = HiveSocialFeedMutationQueue(
      hiveService: hiveService,
      clock: () => now,
    );
    timer = test_helpers.FakeTimerService();
    repository = OfflineFirstSocialFeedRepository(
      local: local,
      queue: queue,
      remote: remote,
      scenario: scenario,
      timerService: timer,
    );
  });

  tearDown(() async {
    await repository.dispose();
    await test_helpers.cleanupHiveBoxes(<String>[
      HiveSocialFeedLocalDataSource.boxNameValue,
      HiveSocialFeedMutationQueue.boxNameValue,
    ]);
  });

  test('refresh caches first page', () async {
    final SocialFeedPage page = await repository.refresh(
      viewer: SocialFeedViewer.alex,
    );
    expect(page.posts, isNotEmpty);
    final SocialFeedPage? cached = await repository.readCachedPage(
      viewer: SocialFeedViewer.alex,
    );
    expect(cached?.posts.first.id, page.posts.first.id);
  });

  test(
    'offline like queues and overlays pending intent on cache read',
    () async {
      final SocialFeedPage page = await repository.refresh(
        viewer: SocialFeedViewer.alex,
      );
      final String postId = page.posts.first.id;
      scenario.setSimulatedOnline(online: false);

      final SocialFeedLikeResult result = await repository.setLiked(
        viewer: SocialFeedViewer.alex,
        postId: postId,
        desiredLiked: true,
        mutationId: 'like-1',
      );
      expect(result, isA<SocialFeedLikeQueued>());

      final SocialFeedPage? cached = await repository.readCachedPage(
        viewer: SocialFeedViewer.alex,
      );
      final SocialFeedPost overlaid = cached!.posts.firstWhere(
        (SocialFeedPost p) => p.id == postId,
      );
      expect(overlaid.isLikedByMe, isTrue);
    },
  );

  test('pending local like wins over remote unlike after refresh', () async {
    final SocialFeedPage page = await repository.refresh(
      viewer: SocialFeedViewer.alex,
    );
    final String postId = page.posts.first.id;
    scenario.setSimulatedOnline(online: false);
    await repository.setLiked(
      viewer: SocialFeedViewer.alex,
      postId: postId,
      desiredLiked: true,
      mutationId: 'like-pending',
    );

    // Force remote personalization unlike without clearing queue.
    remote.resetViewerPersonalization(SocialFeedViewer.alex);
    scenario.setSimulatedOnline(online: true);
    final SocialFeedPage refreshed = await repository.refresh(
      viewer: SocialFeedViewer.alex,
    );
    final SocialFeedPost matched = refreshed.posts.firstWhere(
      (SocialFeedPost p) => p.id == postId,
    );
    expect(matched.isLikedByMe, isTrue);
  });

  test('online setLiked syncs without queue residue', () async {
    final SocialFeedPage page = await repository.refresh(
      viewer: SocialFeedViewer.alex,
    );
    final String postId = page.posts.first.id;
    final SocialFeedLikeResult result = await repository.setLiked(
      viewer: SocialFeedViewer.alex,
      postId: postId,
      desiredLiked: true,
      mutationId: 'like-online',
    );
    expect(result, isA<SocialFeedLikeSynced>());
    expect(
      await repository.pendingMutationCount(viewer: SocialFeedViewer.alex),
      0,
    );
  });

  test('online unlike clears stale offline like queue for same post', () async {
    final SocialFeedPage page = await repository.refresh(
      viewer: SocialFeedViewer.alex,
    );
    final String postId = page.posts.first.id;
    scenario.setSimulatedOnline(online: false);
    await repository.setLiked(
      viewer: SocialFeedViewer.alex,
      postId: postId,
      desiredLiked: true,
      mutationId: 'offline-like',
    );
    scenario.setSimulatedOnline(online: true);
    final SocialFeedLikeResult result = await repository.setLiked(
      viewer: SocialFeedViewer.alex,
      postId: postId,
      desiredLiked: false,
      mutationId: 'online-unlike',
    );
    expect(result, isA<SocialFeedLikeSynced>());
    expect((result as SocialFeedLikeSynced).post.isLikedByMe, isFalse);
    expect(
      await repository.pendingMutationCount(viewer: SocialFeedViewer.alex),
      0,
    );
  });

  test(
    'offline like on load-more post returns projected optimistic post',
    () async {
      final SocialFeedPage first = await repository.refresh(
        viewer: SocialFeedViewer.alex,
      );
      expect(first.hasMore, isTrue);
      final SocialFeedPage page2 = await repository.loadMore(
        viewer: SocialFeedViewer.alex,
        cursor: first.nextCursor!,
      );
      final String postId = page2.posts.first.id;
      scenario.setSimulatedOnline(online: false);
      final SocialFeedLikeResult result = await repository.setLiked(
        viewer: SocialFeedViewer.alex,
        postId: postId,
        desiredLiked: true,
        mutationId: 'like-p2',
      );
      expect(result, isA<SocialFeedLikeQueued>());
      final SocialFeedLikeQueued queued = result as SocialFeedLikeQueued;
      expect(queued.post.isLikedByMe, isTrue);
      expect(queued.post.authorId, isNot('unknown'));
    },
  );

  test(
    'coalesced unlike after like ack applies final intent on dispatch',
    () async {
      final SocialFeedPage page = await repository.refresh(
        viewer: SocialFeedViewer.alex,
      );
      final String postId = page.posts.first.id;
      scenario.setSimulatedOnline(online: false);
      await repository.setLiked(
        viewer: SocialFeedViewer.alex,
        postId: postId,
        desiredLiked: true,
        mutationId: 'like-1',
      );
      await repository.setLiked(
        viewer: SocialFeedViewer.alex,
        postId: postId,
        desiredLiked: false,
        mutationId: 'like-2',
      );
      scenario.setSimulatedOnline(online: true);
      final SocialFeedSyncLease lease = await repository.acquireSync(
        viewer: SocialFeedViewer.alex,
      );
      for (int i = 0; i < 20; i++) {
        if (await repository.pendingMutationCount(
              viewer: SocialFeedViewer.alex,
            ) ==
            0) {
          break;
        }
        timer.tick();
        await pumpEventQueue();
      }
      await lease.close();
      final SocialFeedPage refreshed = await repository.refresh(
        viewer: SocialFeedViewer.alex,
      );
      final SocialFeedPost matched = refreshed.posts.firstWhere(
        (SocialFeedPost p) => p.id == postId,
      );
      expect(matched.isLikedByMe, isFalse);
    },
  );

  test('online unlike wins when queued like dispatch is in flight', () async {
    final SimulatedSocialFeedRemoteDataSource slowRemote =
        SimulatedSocialFeedRemoteDataSource(
          scenario: scenario,
          clock: () => now,
          latency: const Duration(milliseconds: 100),
        );
    final OfflineFirstSocialFeedRepository slowRepository =
        OfflineFirstSocialFeedRepository(
          local: local,
          queue: queue,
          remote: slowRemote,
          scenario: scenario,
          timerService: timer,
        );
    addTearDown(slowRepository.dispose);

    final SocialFeedPage page = await slowRepository.refresh(
      viewer: SocialFeedViewer.alex,
    );
    final String postId = page.posts.first.id;
    scenario.setSimulatedOnline(online: false);
    await slowRepository.setLiked(
      viewer: SocialFeedViewer.alex,
      postId: postId,
      desiredLiked: true,
      mutationId: 'queued-like',
    );
    scenario.setSimulatedOnline(online: true);
    final SocialFeedSyncLease lease = await slowRepository.acquireSync(
      viewer: SocialFeedViewer.alex,
    );
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final SocialFeedLikeResult unlikeResult = await slowRepository.setLiked(
      viewer: SocialFeedViewer.alex,
      postId: postId,
      desiredLiked: false,
      mutationId: 'online-unlike',
    );
    expect(unlikeResult, isA<SocialFeedLikeSynced>());
    for (int i = 0; i < 30; i++) {
      if (await slowRepository.pendingMutationCount(
            viewer: SocialFeedViewer.alex,
          ) ==
          0) {
        break;
      }
      timer.tick();
      await pumpEventQueue();
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    await lease.close();
    final SocialFeedPage refreshed = await slowRepository.refresh(
      viewer: SocialFeedViewer.alex,
    );
    final SocialFeedPost matched = refreshed.posts.firstWhere(
      (SocialFeedPost p) => p.id == postId,
    );
    expect(matched.isLikedByMe, isFalse);
    expect(
      await slowRepository.pendingMutationCount(viewer: SocialFeedViewer.alex),
      0,
    );
  });

  test(
    'refresh reconciles stale local commentCount to remote threads',
    () async {
      final SocialFeedPage first = await repository.refresh(
        viewer: SocialFeedViewer.alex,
      );
      final SocialFeedPost head = first.posts.first;
      final int remoteCount = head.commentCount;

      await local.savePage(
        SocialFeedViewer.alex,
        SocialFeedPage(
          posts: <SocialFeedPost>[
            head.copyWith(commentCount: remoteCount + 5, serverRevision: 99),
            ...first.posts.skip(1),
          ],
          nextCursor: first.nextCursor,
          hasMore: first.hasMore,
          source: SocialFeedDataSource.cache,
          fetchedAt: first.fetchedAt,
        ),
      );

      final SocialFeedPage refreshed = await repository.refresh(
        viewer: SocialFeedViewer.alex,
      );
      expect(refreshed.posts.first.id, head.id);
      expect(refreshed.posts.first.commentCount, remoteCount);
    },
  );

  test('offline comment overlays once (no double increment)', () async {
    final SocialFeedPage page = await repository.refresh(
      viewer: SocialFeedViewer.alex,
    );
    final String postId = page.posts.first.id;
    final int baseCount = page.posts.first.commentCount;
    scenario.setSimulatedOnline(online: false);

    final SocialFeedCommentResult result = await repository.addComment(
      viewer: SocialFeedViewer.alex,
      postId: postId,
      body: 'hello',
      mutationId: 'c-1',
    );
    expect(result, isA<SocialFeedCommentQueued>());
    final SocialFeedCommentQueued queued = result as SocialFeedCommentQueued;
    expect(queued.post.commentCount, baseCount + 1);

    final SocialFeedPage? cached = await repository.readCachedPage(
      viewer: SocialFeedViewer.alex,
    );
    final SocialFeedPost overlaid = cached!.posts.firstWhere(
      (SocialFeedPost p) => p.id == postId,
    );
    expect(overlaid.commentCount, baseCount + 1);
  });

  test('viewer cache and queue isolation', () async {
    await repository.refresh(viewer: SocialFeedViewer.alex);
    scenario.setSimulatedOnline(online: false);
    await repository.setLiked(
      viewer: SocialFeedViewer.alex,
      postId: 'post-060',
      desiredLiked: true,
      mutationId: 'alex-like',
    );
    expect(
      await repository.readCachedPage(viewer: SocialFeedViewer.sam),
      isNull,
    );
    expect(
      await repository.pendingMutationCount(viewer: SocialFeedViewer.sam),
      0,
    );
  });

  test('readPendingSnapshot hydrates queued comment bodies', () async {
    final SocialFeedPage page = await repository.refresh(
      viewer: SocialFeedViewer.alex,
    );
    final String postId = page.posts.first.id;
    scenario.setSimulatedOnline(online: false);
    await repository.addComment(
      viewer: SocialFeedViewer.alex,
      postId: postId,
      body: 'survives restart',
      mutationId: 'restart-comment',
    );

    final SocialFeedPendingSnapshot pending = await repository
        .readPendingSnapshot(viewer: SocialFeedViewer.alex);
    expect(pending.pendingPostIds, contains(postId));
    expect(pending.pendingCommentsByPostId[postId], hasLength(1));
    expect(
      pending.pendingCommentsByPostId[postId]!.first.body,
      'survives restart',
    );
  });

  test('submitted comments survive remote recreation (hot restart)', () async {
    final SocialFeedPage page = await repository.refresh(
      viewer: SocialFeedViewer.alex,
    );
    final String postId = page.posts.first.id;

    await repository.addComment(
      viewer: SocialFeedViewer.alex,
      postId: postId,
      body: 'Alex keeps this',
      mutationId: 'persist-alex',
    );
    await repository.addComment(
      viewer: SocialFeedViewer.sam,
      postId: postId,
      body: 'Sam keeps this',
      mutationId: 'persist-sam',
    );

    await repository.dispose();
    remote = SimulatedSocialFeedRemoteDataSource(
      scenario: scenario,
      clock: () => now,
    );
    repository = OfflineFirstSocialFeedRepository(
      local: local,
      queue: queue,
      remote: remote,
      scenario: scenario,
      timerService: timer,
    );

    final Map<String, List<SocialFeedComment>> threads = await repository
        .commentsForPostIds(postIds: <String>[postId]);
    final List<String> bodies = threads[postId]!
        .map((SocialFeedComment c) => c.body)
        .toList();
    expect(bodies, contains('Alex keeps this'));
    expect(bodies, contains('Sam keeps this'));
  });

  test('synced likes survive remote recreation (hot restart)', () async {
    final SocialFeedPage page = await repository.refresh(
      viewer: SocialFeedViewer.alex,
    );
    final String postId = page.posts.first.id;

    await repository.setLiked(
      viewer: SocialFeedViewer.alex,
      postId: postId,
      desiredLiked: true,
      mutationId: 'persist-like',
    );

    await repository.dispose();
    remote = SimulatedSocialFeedRemoteDataSource(
      scenario: scenario,
      clock: () => now,
    );
    repository = OfflineFirstSocialFeedRepository(
      local: local,
      queue: queue,
      remote: remote,
      scenario: scenario,
      timerService: timer,
    );

    final SocialFeedPage? cached = await repository.readCachedPage(
      viewer: SocialFeedViewer.alex,
    );
    final SocialFeedPost cachedPost = cached!.posts.firstWhere(
      (SocialFeedPost p) => p.id == postId,
    );
    expect(cachedPost.isLikedByMe, isTrue);

    final SocialFeedPage refreshed = await repository.refresh(
      viewer: SocialFeedViewer.alex,
    );
    final SocialFeedPost remotePost = refreshed.posts.firstWhere(
      (SocialFeedPost p) => p.id == postId,
    );
    expect(remotePost.isLikedByMe, isTrue);
  });

  test(
    'dispatched offline likes survive remote recreation (hot restart)',
    () async {
      final SocialFeedPage page = await repository.refresh(
        viewer: SocialFeedViewer.alex,
      );
      final String postId = page.posts.first.id;
      scenario.setSimulatedOnline(online: false);
      await repository.setLiked(
        viewer: SocialFeedViewer.alex,
        postId: postId,
        desiredLiked: true,
        mutationId: 'offline-like',
      );

      scenario.setSimulatedOnline(online: true);
      final SocialFeedSyncLease lease = await repository.acquireSync(
        viewer: SocialFeedViewer.alex,
      );
      expect(lease.seedSummary, isNotNull);
      expect(lease.seedSummary!.dispatchedMutations, isNotEmpty);
      expect(
        await repository.pendingMutationCount(viewer: SocialFeedViewer.alex),
        0,
      );
      await lease.close();
      expect(
        await repository.pendingMutationCount(viewer: SocialFeedViewer.alex),
        0,
      );

      await repository.dispose();
      remote = SimulatedSocialFeedRemoteDataSource(
        scenario: scenario,
        clock: () => now,
      );
      repository = OfflineFirstSocialFeedRepository(
        local: local,
        queue: queue,
        remote: remote,
        scenario: scenario,
        timerService: timer,
      );

      final SocialFeedPage refreshed = await repository.refresh(
        viewer: SocialFeedViewer.alex,
      );
      final SocialFeedPost remotePost = refreshed.posts.firstWhere(
        (SocialFeedPost p) => p.id == postId,
      );
      expect(remotePost.isLikedByMe, isTrue);
    },
  );

  test('acquireSync seedSummary captures queued comment dispatch', () async {
    final SocialFeedPage page = await repository.refresh(
      viewer: SocialFeedViewer.alex,
    );
    final String postId = page.posts.first.id;
    scenario.setSimulatedOnline(online: false);
    await repository.addComment(
      viewer: SocialFeedViewer.alex,
      postId: postId,
      body: 'Queued for seed',
      mutationId: 'seed-comment',
    );
    scenario.setSimulatedOnline(online: true);

    final SocialFeedSyncLease lease = await repository.acquireSync(
      viewer: SocialFeedViewer.alex,
    );
    expect(lease.seedSummary, isNotNull);
    expect(
      lease.seedSummary!.dispatchedMutations,
      contains(
        isA<SocialFeedDispatchedMutation>().having(
          (SocialFeedDispatchedMutation m) => m.mutationId,
          'mutationId',
          'seed-comment',
        ),
      ),
    );
    await lease.close();
  });

  test('sync lease can be re-acquired after close', () async {
    final SocialFeedSyncLease first = await repository.acquireSync(
      viewer: SocialFeedViewer.alex,
    );
    await first.close();
    final SocialFeedSyncLease second = await repository.acquireSync(
      viewer: SocialFeedViewer.alex,
    );
    await second.close();
    expect(second.seedSummary, isNotNull);
  });
}
