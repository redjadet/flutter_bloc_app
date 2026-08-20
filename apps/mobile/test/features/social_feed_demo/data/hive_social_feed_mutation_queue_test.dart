import 'package:flutter_bloc_app/features/social_feed_demo/data/hive_social_feed_mutation_queue.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/data/social_feed_mutation_dto.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_viewer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storage/storage.dart';

import '../../../test_helpers.dart' as test_helpers;

void main() {
  late HiveService hiveService;
  late HiveSocialFeedMutationQueue queue;
  final DateTime now = DateTime.utc(2026, 8, 20, 12);

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await test_helpers.setupHiveForTesting();
  });

  setUp(() async {
    hiveService = await test_helpers.createHiveService();
    queue = HiveSocialFeedMutationQueue(
      hiveService: hiveService,
      clock: () => now,
    );
  });

  tearDown(() async {
    await test_helpers.cleanupHiveBoxes(<String>[
      HiveSocialFeedMutationQueue.boxNameValue,
    ]);
  });

  test('enqueues like then comment in sequence order', () async {
    await queue.enqueueLike(
      viewer: SocialFeedViewer.alex,
      postId: 'p1',
      desiredLiked: true,
      mutationId: 'm1',
    );
    await queue.enqueueComment(
      viewer: SocialFeedViewer.alex,
      postId: 'p1',
      body: 'hi',
      mutationId: 'm2',
    );
    final List<SocialFeedMutationDto> items = await queue.readQueue(
      SocialFeedViewer.alex,
    );
    expect(items.map((SocialFeedMutationDto e) => e.mutationId), <String>[
      'm1',
      'm2',
    ]);
    expect(items.first.sequence < items.last.sequence, isTrue);
  });

  test('coalesces adjacent undispatched likes for same post', () async {
    await queue.enqueueLike(
      viewer: SocialFeedViewer.alex,
      postId: 'p1',
      desiredLiked: true,
      mutationId: 'm1',
    );
    await queue.enqueueLike(
      viewer: SocialFeedViewer.alex,
      postId: 'p1',
      desiredLiked: false,
      mutationId: 'm2',
    );
    final List<SocialFeedMutationDto> items = await queue.readQueue(
      SocialFeedViewer.alex,
    );
    expect(items, hasLength(1));
    expect(items.single.mutationId, 'm2');
    expect(items.single.desiredLiked, isFalse);
  });

  test('viewer queues are isolated and clearViewer wipes one viewer', () async {
    await queue.enqueueLike(
      viewer: SocialFeedViewer.alex,
      postId: 'p1',
      desiredLiked: true,
      mutationId: 'a1',
    );
    await queue.enqueueLike(
      viewer: SocialFeedViewer.sam,
      postId: 'p1',
      desiredLiked: true,
      mutationId: 's1',
    );
    await queue.clearViewer(SocialFeedViewer.alex);
    expect(await queue.readQueue(SocialFeedViewer.alex), isEmpty);
    expect(await queue.readQueue(SocialFeedViewer.sam), hasLength(1));
  });
}
