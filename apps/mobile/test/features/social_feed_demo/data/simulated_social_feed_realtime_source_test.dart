import 'package:flutter_bloc_app/features/social_feed_demo/data/simulated_social_feed_realtime_source.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/data/simulated_social_feed_remote_data_source.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/data/simulated_social_feed_scenario_controller.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_realtime_source.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_viewer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_helpers.dart' as test_helpers;

void main() {
  late SimulatedSocialFeedScenarioController scenario;
  late SimulatedSocialFeedRemoteDataSource remote;
  late SimulatedSocialFeedRealtimeSource source;
  late test_helpers.FakeTimerService timer;

  setUp(() {
    scenario = SimulatedSocialFeedScenarioController();
    remote = SimulatedSocialFeedRemoteDataSource(
      scenario: scenario,
      clock: () => DateTime.utc(2026, 8, 20),
    );
    timer = test_helpers.FakeTimerService();
    source = SimulatedSocialFeedRealtimeSource(
      scenario: scenario,
      remote: remote,
      timerService: timer,
    );
  });

  tearDown(() async {
    await source.dispose();
  });

  test('flushPendingPosts emits scenario posts on active lease', () async {
    final SocialFeedRealtimeLease lease = await source.acquire(
      SocialFeedViewer.alex,
    );
    final List<SocialFeedPost> posts = <SocialFeedPost>[];
    lease.posts.listen(posts.add);

    scenario.emitThreeNewPosts(viewer: SocialFeedViewer.alex);
    source.flushPendingPosts(SocialFeedViewer.alex);
    await Future<void>.delayed(Duration.zero);

    expect(posts, hasLength(3));
    await lease.close();
  });

  test('dispose closes sessions', () async {
    final SocialFeedRealtimeLease lease = await source.acquire(
      SocialFeedViewer.alex,
    );
    await source.dispose();
    await expectLater(lease.close(), completes);
  });
}
