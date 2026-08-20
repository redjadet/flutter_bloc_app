import 'package:flutter_bloc_app/features/social_feed_demo/data/social_feed_post_mapper.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_page.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_viewer.dart';
import 'package:storage/storage.dart';

/// Viewer-scoped first-page cache. Schema mismatch invalidates only this
/// feature/viewer snapshot — never shared Hive.
class HiveSocialFeedLocalDataSource extends HiveRepositoryBase {
  HiveSocialFeedLocalDataSource({
    required super.hiveService,
    required this._clock,
    this.schemaVersion = 1,
    this.maxCachedPosts = 50,
    this.staleAfter = const Duration(minutes: 15),
    this._mapper = const SocialFeedPostMapper(),
  });

  static const String boxNameValue = 'social_feed_demo_v1';
  static const String _schemaNamespace = 'social_feed_cache:v1';

  final DateTime Function() _clock;
  final SocialFeedPostMapper _mapper;
  final int schemaVersion;
  final int maxCachedPosts;
  final Duration staleAfter;

  @override
  String get boxName => boxNameValue;

  @override
  HiveBoxSchema? get schema => HiveBoxSchema(
    boxName: boxName,
    namespace: _schemaNamespace,
    fingerprint: hiveSchemaFingerprints[_schemaNamespace] ?? 'dev-untracked',
  );

  String _key(SocialFeedViewer viewer) => 'cache:v$schemaVersion:${viewer.id}';

  Future<SocialFeedPage?> readPage(SocialFeedViewer viewer) async {
    try {
      return await runWithBox((box) async {
        final Object? raw = box.get(_key(viewer));
        if (raw is! Map) {
          return null;
        }
        final Map<String, Object?> map = raw.map(
          (k, v) => MapEntry(k.toString(), v),
        );
        final Object? version = map['schemaVersion'];
        if (version is! int || version != schemaVersion) {
          await safeDeleteKey(box, _key(viewer));
          return null;
        }
        final Object? fetchedAtRaw = map['fetchedAt'];
        final Object? postsRaw = map['posts'];
        final Object? nextCursor = map['nextCursor'];
        if (fetchedAtRaw is! String || postsRaw is! List) {
          await safeDeleteKey(box, _key(viewer));
          return null;
        }
        final DateTime fetchedAt = DateTime.parse(fetchedAtRaw).toUtc();
        final List<SocialFeedPost> posts = <SocialFeedPost>[];
        for (final Object? item in postsRaw) {
          if (item is! Map) {
            continue;
          }
          try {
            final Map<String, Object?> json = item.map(
              (k, v) => MapEntry(k.toString(), v),
            );
            posts.add(_mapper.toDomain(_mapper.fromJson(json)));
          } on Object {
            // Ignore only the corrupt record.
          }
        }
        if (posts.isEmpty) {
          await safeDeleteKey(box, _key(viewer));
          return null;
        }
        final String? cursor = nextCursor is String ? nextCursor : null;
        return SocialFeedPage(
          posts: posts,
          nextCursor: cursor,
          hasMore: cursor != null,
          source: SocialFeedDataSource.cache,
          fetchedAt: fetchedAt,
        );
      });
    } on Object {
      return null;
    }
  }

  Duration cacheAge(SocialFeedPage page) {
    final Duration age = _clock().toUtc().difference(page.fetchedAt);
    if (age.isNegative) {
      return Duration.zero;
    }
    return age;
  }

  bool isStale(SocialFeedPage page) => cacheAge(page) > staleAfter;

  Future<void> savePage(SocialFeedViewer viewer, SocialFeedPage page) async {
    final List<SocialFeedPost> trimmed = page.posts
        .take(maxCachedPosts)
        .toList();
    final String? continuation = trimmed.isNotEmpty
        ? trimmed.last.id
        : page.nextCursor;
    await runWithBox((box) async {
      await box.put(_key(viewer), <String, Object?>{
        'schemaVersion': schemaVersion,
        'fetchedAt': page.fetchedAt.toUtc().toIso8601String(),
        'nextCursor': continuation,
        'posts': <Map<String, Object?>>[
          for (final SocialFeedPost post in trimmed) _mapper.toJson(post),
        ],
      });
    });
  }

  Future<void> clearViewer(SocialFeedViewer viewer) async {
    await runWithBox((box) async {
      await safeDeleteKey(box, _key(viewer));
    });
  }
}
