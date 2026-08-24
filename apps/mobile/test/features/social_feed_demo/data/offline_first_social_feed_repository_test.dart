import 'dart:async';

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

  test('sync lease can be re-acquired after close', () async {
    final SocialFeedSyncLease first = await repository.acquireSync(
      viewer: SocialFeedViewer.alex,
    );
    await first.close();
    final SocialFeedSyncLease second = await repository.acquireSync(
      viewer: SocialFeedViewer.alex,
    );
    final List<SocialFeedSyncSummary> summaries = <SocialFeedSyncSummary>[];
    final StreamSubscription<SocialFeedSyncSummary> sub = second.summaries
        .listen(summaries.add);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await second.close();
    await sub.cancel();
    expect(summaries, isNotEmpty);
  });
}
