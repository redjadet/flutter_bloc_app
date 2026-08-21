import 'package:flutter_bloc_app/features/social_feed_demo/data/hive_social_feed_local_data_source.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_comment.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_mutation_status.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_page.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_viewer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:storage/storage.dart';

import '../../../test_helpers.dart' as test_helpers;

void main() {
  late HiveService hiveService;
  late HiveSocialFeedLocalDataSource local;
  DateTime now = DateTime.utc(2026, 8, 20, 12);

  SocialFeedPost post(String id) => SocialFeedPost(
    id: id,
    authorId: 'a1',
    authorDisplayName: 'Author',
    body: 'body $id',
    createdAt: DateTime.utc(2026, 8, 1),
    isLikedByMe: false,
    likeCount: 1,
    commentCount: 0,
    serverRevision: 1,
  );

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await test_helpers.setupHiveForTesting();
  });

  setUp(() async {
    hiveService = await test_helpers.createHiveService();
    local = HiveSocialFeedLocalDataSource(
      hiveService: hiveService,
      clock: () => now,
    );
  });

  tearDown(() async {
    await test_helpers.cleanupHiveBoxes(<String>[
      HiveSocialFeedLocalDataSource.boxNameValue,
    ]);
  });

  test('save and read round-trip is viewer scoped', () async {
    final SocialFeedPage page = SocialFeedPage(
      posts: <SocialFeedPost>[post('p1'), post('p2')],
      nextCursor: 'p2',
      hasMore: true,
      source: SocialFeedDataSource.remote,
      fetchedAt: now,
    );
    await local.savePage(SocialFeedViewer.alex, page);

    final SocialFeedPage? alex = await local.readPage(SocialFeedViewer.alex);
    final SocialFeedPage? sam = await local.readPage(SocialFeedViewer.sam);
    expect(alex?.posts.map((SocialFeedPost p) => p.id), <String>['p1', 'p2']);
    expect(sam, isNull);
  });

  test('schema mismatch clears snapshot', () async {
    await local.savePage(
      SocialFeedViewer.alex,
      SocialFeedPage(
        posts: <SocialFeedPost>[post('p1')],
        nextCursor: 'p1',
        hasMore: true,
        source: SocialFeedDataSource.remote,
        fetchedAt: now,
      ),
    );
    final Box<dynamic> box = await hiveService.openBox(
      HiveSocialFeedLocalDataSource.boxNameValue,
      encrypted: false,
    );
    final Map<String, Object?> raw = Map<String, Object?>.from(
      box.get('cache:v1:demo-alex') as Map,
    );
    raw['schemaVersion'] = 99;
    await box.put('cache:v1:demo-alex', raw);

    expect(await local.readPage(SocialFeedViewer.alex), isNull);
  });

  test('corrupt post records are skipped; all corrupt clears', () async {
    final Box<dynamic> box = await hiveService.openBox(
      HiveSocialFeedLocalDataSource.boxNameValue,
      encrypted: false,
    );
    await box.put('cache:v1:demo-alex', <String, Object?>{
      'schemaVersion': 1,
      'fetchedAt': now.toIso8601String(),
      'nextCursor': 'p1',
      'posts': <Object?>[
        <String, Object?>{'id': 'bad'},
        <String, Object?>{
          'id': 'p1',
          'authorId': 'a1',
          'authorDisplayName': 'Author',
          'body': 'ok',
          'createdAt': '2026-08-01T00:00:00.000Z',
          'isLikedByMe': false,
          'likeCount': 0,
          'commentCount': 0,
          'serverRevision': 1,
        },
      ],
    });
    final SocialFeedPage? page = await local.readPage(SocialFeedViewer.alex);
    expect(page?.posts.single.id, 'p1');

    await box.put('cache:v1:demo-alex', <String, Object?>{
      'schemaVersion': 1,
      'fetchedAt': now.toIso8601String(),
      'nextCursor': null,
      'posts': <Object?>[
        <String, Object?>{'id': 'bad'},
      ],
    });
    expect(await local.readPage(SocialFeedViewer.alex), isNull);
  });

  test('shared comment threads survive hive round-trip', () async {
    await local.saveCommentThreads(<String, List<SocialFeedComment>>{
      'post-060': <SocialFeedComment>[
        SocialFeedComment(
          id: 'c-alex',
          postId: 'post-060',
          viewerId: SocialFeedViewer.alex.id,
          body: 'From Alex',
          createdAt: now,
          syncStatus: SocialFeedMutationStatus.synced,
        ),
        SocialFeedComment(
          id: 'c-sam',
          postId: 'post-060',
          viewerId: SocialFeedViewer.sam.id,
          body: 'From Sam',
          createdAt: now.add(const Duration(minutes: 1)),
          syncStatus: SocialFeedMutationStatus.synced,
        ),
      ],
    });

    final Map<String, List<SocialFeedComment>>? threads = await local
        .readCommentThreads();
    expect(threads, isNotNull);
    expect(threads!['post-060'], hasLength(2));
    expect(threads['post-060']!.map((c) => c.body), <String>[
      'From Alex',
      'From Sam',
    ]);
  });
}
