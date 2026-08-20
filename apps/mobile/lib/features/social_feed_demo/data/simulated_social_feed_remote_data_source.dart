import 'package:flutter_bloc_app/features/social_feed_demo/data/simulated_social_feed_scenario_controller.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/data/social_feed_seed_data.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_failure.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_page.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_viewer.dart';

part 'simulated_social_feed_remote_mutations.part.dart';
part 'simulated_social_feed_remote_rejection.part.dart';

/// Deterministic in-memory remote with opaque cursor = last post id.
class SimulatedSocialFeedRemoteDataSource {
  SimulatedSocialFeedRemoteDataSource({
    required this._scenario,
    required this._clock,
    this.pageSize = 10,
    this.latency = Duration.zero,
    this._seedData = const SocialFeedSeedData(),
  }) {
    _posts = _seedData.build(clock: _clock);
  }

  final SimulatedSocialFeedScenarioController _scenario;
  final DateTime Function() _clock;
  final SocialFeedSeedData _seedData;
  final int pageSize;
  final Duration latency;

  late List<SocialFeedPost> _posts;
  final Map<String, Set<String>> _likedByViewer = <String, Set<String>>{};
  final Map<String, Map<String, SocialFeedPost>> _mutationAckCache =
      <String, Map<String, SocialFeedPost>>{};
  final Map<String, int> _commentExtras = <String, int>{};

  List<SocialFeedPost> get serverPosts =>
      List<SocialFeedPost>.unmodifiable(_posts);

  Future<void> _delay() async {
    if (latency > Duration.zero) {
      // check-ignore: simulated remote uses injected Duration for test latency only
      await Future<void>.delayed(latency);
    }
  }

  SocialFeedPost _project(SocialFeedViewer viewer, SocialFeedPost post) {
    final bool liked = _likedByViewer[viewer.id]?.contains(post.id) ?? false;
    final int commentExtra = _commentExtras[post.id] ?? 0;
    var likeCount = post.likeCount;
    if (liked && !post.isLikedByMe) {
      likeCount += 1;
    } else if (!liked && post.isLikedByMe) {
      likeCount = (likeCount - 1).clamp(0, 1 << 30);
    }
    return post.copyWith(
      isLikedByMe: liked,
      likeCount: likeCount,
      commentCount: post.commentCount + commentExtra,
    );
  }

  List<SocialFeedPost> _projected(SocialFeedViewer viewer) {
    return <SocialFeedPost>[
      for (final SocialFeedPost post in _posts) _project(viewer, post),
    ];
  }

  Future<SocialFeedPage> fetchPage({
    required SocialFeedViewer viewer,
    required bool isRefresh,
    String? cursor,
  }) async {
    await _delay();
    if (!_scenario.isSimulatedOnline) {
      throw const SocialFeedOfflineFailure();
    }
    if (isRefresh && _scenario.consumeFailNextRefresh(viewer: viewer)) {
      throw const SocialFeedUnknownFailure();
    }
    if (!isRefresh &&
        cursor != null &&
        _scenario.consumeFailNextLoadMore(viewer: viewer)) {
      throw const SocialFeedPageFailure();
    }
    if (_scenario.consumeMalformedNextPayload(viewer: viewer)) {
      throw const SocialFeedMalformedDataFailure();
    }

    final List<SocialFeedPost> all = _projected(viewer);
    int start = 0;
    if (cursor != null) {
      final int index = all.indexWhere((p) => p.id == cursor);
      if (index < 0) {
        throw const SocialFeedPageFailure();
      }
      start = index + 1;
    }
    final List<SocialFeedPost> slice = all.skip(start).take(pageSize).toList();
    final String? next = slice.isNotEmpty && start + slice.length < all.length
        ? slice.last.id
        : null;
    return SocialFeedPage(
      posts: slice,
      nextCursor: next,
      hasMore: next != null,
      source: SocialFeedDataSource.remote,
      fetchedAt: _clock().toUtc(),
    );
  }

  /// Insert newest posts at the head without invalidating continuation cursors
  /// (cursor remains last id of a prior page; later pages still continue).
  void insertTopPosts(List<SocialFeedPost> posts) {
    _posts = <SocialFeedPost>[...posts, ..._posts];
  }

  List<SocialFeedPost> createRealtimePosts({
    required SocialFeedViewer viewer,
    required int count,
  }) {
    final DateTime now = _clock().toUtc();
    final List<SocialFeedPost> created = <SocialFeedPost>[];
    for (int i = 0; i < count; i++) {
      final int ordinal = _scenario.nextNewPostOrdinal();
      final SocialFeedPost post = SocialFeedPost(
        id: 'rt-$ordinal',
        authorId: 'author-rt',
        authorDisplayName: 'Casey',
        body: 'Realtime fictional post $ordinal',
        createdAt: now.add(Duration(milliseconds: i)),
        isLikedByMe: false,
        likeCount: 0,
        commentCount: 0,
        serverRevision: 1,
      );
      created.add(post);
    }
    insertTopPosts(created);
    return <SocialFeedPost>[
      for (final SocialFeedPost p in created) _project(viewer, p),
    ];
  }
}
