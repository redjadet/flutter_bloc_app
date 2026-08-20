import 'package:flutter_bloc_app/features/social_feed_demo/data/simulated_social_feed_remote_data_source.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/data/simulated_social_feed_scenario_controller.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_page.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_viewer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SimulatedSocialFeedScenarioController scenario;
  late SimulatedSocialFeedRemoteDataSource remote;
  final DateTime now = DateTime.utc(2026, 8, 20);

  setUp(() {
    scenario = SimulatedSocialFeedScenarioController();
    remote = SimulatedSocialFeedRemoteDataSource(
      scenario: scenario,
      clock: () => now,
    );
  });

  test('cursor remains stable after top insertion', () async {
    final SocialFeedPage first = await remote.fetchPage(
      viewer: SocialFeedViewer.alex,
      isRefresh: true,
    );
    expect(first.posts, hasLength(10));
    final String cursor = first.nextCursor!;

    remote.insertTopPosts(<SocialFeedPost>[
      SocialFeedPost(
        id: 'inserted-top',
        authorId: 'x',
        authorDisplayName: 'X',
        body: 'top',
        createdAt: now.add(const Duration(minutes: 1)),
        isLikedByMe: false,
        likeCount: 0,
        commentCount: 0,
        serverRevision: 1,
      ),
    ]);

    final SocialFeedPage second = await remote.fetchPage(
      viewer: SocialFeedViewer.alex,
      cursor: cursor,
      isRefresh: false,
    );
    final Set<String> firstIds = first.posts
        .map((SocialFeedPost p) => p.id)
        .toSet();
    final Set<String> secondIds = second.posts
        .map((SocialFeedPost p) => p.id)
        .toSet();
    expect(firstIds.intersection(secondIds), isEmpty);
    expect(
      second.posts.any((SocialFeedPost p) => p.id == 'inserted-top'),
      isFalse,
    );
  });
}
