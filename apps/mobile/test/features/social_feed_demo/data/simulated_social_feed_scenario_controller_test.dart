import 'package:flutter_bloc_app/features/social_feed_demo/data/simulated_social_feed_scenario_controller.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_viewer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SimulatedSocialFeedScenarioController scenario;

  setUp(() {
    scenario = SimulatedSocialFeedScenarioController();
  });

  test('online flag toggles', () {
    expect(scenario.isSimulatedOnline, isTrue);
    scenario.setSimulatedOnline(online: false);
    expect(scenario.isSimulatedOnline, isFalse);
  });

  test('failNext refresh and loadMore consume once per viewer', () {
    scenario.failNextInitialOrRefresh(viewer: SocialFeedViewer.alex);
    expect(
      scenario.consumeFailNextRefresh(viewer: SocialFeedViewer.alex),
      isTrue,
    );
    expect(
      scenario.consumeFailNextRefresh(viewer: SocialFeedViewer.alex),
      isFalse,
    );
    expect(
      scenario.consumeFailNextRefresh(viewer: SocialFeedViewer.sam),
      isFalse,
    );

    scenario.failNextLoadMore(viewer: SocialFeedViewer.sam);
    expect(
      scenario.consumeFailNextLoadMore(viewer: SocialFeedViewer.sam),
      isTrue,
    );
    expect(
      scenario.consumeFailNextLoadMore(viewer: SocialFeedViewer.sam),
      isFalse,
    );
  });

  test('emitThreeNewPosts is viewer scoped', () {
    scenario.emitThreeNewPosts(viewer: SocialFeedViewer.alex);
    expect(scenario.consumePendingNewPosts(viewer: SocialFeedViewer.alex), 3);
    expect(scenario.consumePendingNewPosts(viewer: SocialFeedViewer.sam), 0);
  });

  test('fault commands are viewer-scoped and deterministic', () {
    scenario.disconnectRealtimeAndFailNextReconnect(
      viewer: SocialFeedViewer.alex,
    );
    expect(
      scenario.consumeForceRealtimeDisconnect(viewer: SocialFeedViewer.alex),
      isTrue,
    );
    expect(
      scenario.consumeFailNextRealtimeReconnect(viewer: SocialFeedViewer.alex),
      isTrue,
    );

    scenario.failNextFiveQueuedDispatchesRetryably(
      viewer: SocialFeedViewer.alex,
    );
    for (var i = 0; i < 5; i++) {
      expect(
        scenario.consumeRetryableDispatchFailure(viewer: SocialFeedViewer.alex),
        isTrue,
      );
    }
    expect(
      scenario.consumeRetryableDispatchFailure(viewer: SocialFeedViewer.alex),
      isFalse,
    );

    scenario.rejectNextLikePermanently(viewer: SocialFeedViewer.alex);
    scenario.rejectNextCommentPermanently(viewer: SocialFeedViewer.alex);
    scenario.returnMalformedNextPayload(viewer: SocialFeedViewer.alex);
    expect(
      scenario.consumeRejectNextLike(viewer: SocialFeedViewer.alex),
      isTrue,
    );
    expect(
      scenario.consumeRejectNextComment(viewer: SocialFeedViewer.alex),
      isTrue,
    );
    expect(
      scenario.consumeMalformedNextPayload(viewer: SocialFeedViewer.alex),
      isTrue,
    );
    expect(
      scenario.consumeRejectNextLike(viewer: SocialFeedViewer.sam),
      isFalse,
    );
  });
}
