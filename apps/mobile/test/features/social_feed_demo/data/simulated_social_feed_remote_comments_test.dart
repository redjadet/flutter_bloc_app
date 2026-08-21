import 'package:flutter_bloc_app/features/social_feed_demo/data/simulated_social_feed_remote_data_source.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/data/simulated_social_feed_scenario_controller.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_comment.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_viewer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('applyComment stores body and author across viewers', () async {
    final SimulatedSocialFeedScenarioController scenario =
        SimulatedSocialFeedScenarioController();
    final SimulatedSocialFeedRemoteDataSource remote =
        SimulatedSocialFeedRemoteDataSource(
          scenario: scenario,
          clock: () => DateTime.utc(2026, 8, 21, 12),
        );

    final String postId = remote
        .createRealtimePosts(viewer: SocialFeedViewer.sam, count: 1)
        .first
        .id;

    await remote.applyComment(
      viewer: SocialFeedViewer.sam,
      postId: postId,
      body: 'Hello from Sam',
      mutationId: 'comment-sam-1',
    );

    final List<SocialFeedComment> forAlex = remote.commentsForPost(postId);
    expect(forAlex, hasLength(1));
    expect(forAlex.single.body, 'Hello from Sam');
    expect(forAlex.single.viewerId, SocialFeedViewer.sam.id);

    final projected = (await remote.fetchPage(
      viewer: SocialFeedViewer.alex,
      isRefresh: true,
    )).posts.firstWhere((p) => p.id == postId);
    expect(projected.commentCount, 1);
  });
}
