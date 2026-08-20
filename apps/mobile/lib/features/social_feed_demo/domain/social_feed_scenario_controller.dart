import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_viewer.dart';

/// Deterministic connectivity/fault injection (labels must say simulated).
abstract class SocialFeedScenarioController {
  bool get isSimulatedOnline;

  void setSimulatedOnline({required bool online});

  void emitThreeNewPosts({required SocialFeedViewer viewer});

  void failNextInitialOrRefresh({required SocialFeedViewer viewer});

  void failNextLoadMore({required SocialFeedViewer viewer});

  void disconnectRealtimeAndFailNextReconnect({
    required SocialFeedViewer viewer,
  });

  void failNextFiveQueuedDispatchesRetryably({
    required SocialFeedViewer viewer,
  });

  void rejectNextLikePermanently({required SocialFeedViewer viewer});

  void rejectNextCommentPermanently({required SocialFeedViewer viewer});

  void returnMalformedNextPayload({required SocialFeedViewer viewer});

  void resetViewerSimulatorFaults({required SocialFeedViewer viewer});
}
