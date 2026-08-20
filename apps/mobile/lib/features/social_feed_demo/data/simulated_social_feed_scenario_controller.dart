import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_scenario_controller.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_viewer.dart';

/// In-memory simulated fault flags shared by remote/realtime/repository.
class SimulatedSocialFeedScenarioController
    implements SocialFeedScenarioController {
  SimulatedSocialFeedScenarioController();

  bool _online = true;
  final Map<String, _ViewerFaults> _byViewer = <String, _ViewerFaults>{};
  int _newPostSeq = 0;

  _ViewerFaults _for(SocialFeedViewer viewer) =>
      _byViewer.putIfAbsent(viewer.id, _ViewerFaults.new);

  @override
  bool get isSimulatedOnline => _online;

  @override
  void setSimulatedOnline({required bool online}) {
    _online = online;
  }

  @override
  void emitThreeNewPosts({required SocialFeedViewer viewer}) {
    _for(viewer).pendingNewPosts += 3;
  }

  int consumePendingNewPosts({required SocialFeedViewer viewer}) {
    final _ViewerFaults faults = _for(viewer);
    final int n = faults.pendingNewPosts;
    faults.pendingNewPosts = 0;
    return n;
  }

  int nextNewPostOrdinal() => ++_newPostSeq;

  @override
  void failNextInitialOrRefresh({required SocialFeedViewer viewer}) {
    _for(viewer).failNextRefresh = true;
  }

  bool consumeFailNextRefresh({required SocialFeedViewer viewer}) {
    final _ViewerFaults faults = _for(viewer);
    if (!faults.failNextRefresh) {
      return false;
    }
    faults.failNextRefresh = false;
    return true;
  }

  @override
  void failNextLoadMore({required SocialFeedViewer viewer}) {
    _for(viewer).failNextLoadMore = true;
  }

  bool consumeFailNextLoadMore({required SocialFeedViewer viewer}) {
    final _ViewerFaults faults = _for(viewer);
    if (!faults.failNextLoadMore) {
      return false;
    }
    faults.failNextLoadMore = false;
    return true;
  }

  @override
  void disconnectRealtimeAndFailNextReconnect({
    required SocialFeedViewer viewer,
  }) {
    _for(viewer).failNextRealtimeReconnect = true;
    _for(viewer).forceRealtimeDisconnect = true;
  }

  bool consumeForceRealtimeDisconnect({required SocialFeedViewer viewer}) {
    final _ViewerFaults faults = _for(viewer);
    if (!faults.forceRealtimeDisconnect) {
      return false;
    }
    faults.forceRealtimeDisconnect = false;
    return true;
  }

  bool consumeFailNextRealtimeReconnect({required SocialFeedViewer viewer}) {
    final _ViewerFaults faults = _for(viewer);
    if (!faults.failNextRealtimeReconnect) {
      return false;
    }
    faults.failNextRealtimeReconnect = false;
    return true;
  }

  @override
  void failNextFiveQueuedDispatchesRetryably({
    required SocialFeedViewer viewer,
  }) {
    _for(viewer).retryableDispatchFailuresRemaining = 5;
  }

  bool consumeRetryableDispatchFailure({required SocialFeedViewer viewer}) {
    final _ViewerFaults faults = _for(viewer);
    if (faults.retryableDispatchFailuresRemaining <= 0) {
      return false;
    }
    faults.retryableDispatchFailuresRemaining -= 1;
    return true;
  }

  @override
  void rejectNextLikePermanently({required SocialFeedViewer viewer}) {
    _for(viewer).rejectNextLike = true;
  }

  bool consumeRejectNextLike({required SocialFeedViewer viewer}) {
    final _ViewerFaults faults = _for(viewer);
    if (!faults.rejectNextLike) {
      return false;
    }
    faults.rejectNextLike = false;
    return true;
  }

  @override
  void rejectNextCommentPermanently({required SocialFeedViewer viewer}) {
    _for(viewer).rejectNextComment = true;
  }

  bool consumeRejectNextComment({required SocialFeedViewer viewer}) {
    final _ViewerFaults faults = _for(viewer);
    if (!faults.rejectNextComment) {
      return false;
    }
    faults.rejectNextComment = false;
    return true;
  }

  @override
  void returnMalformedNextPayload({required SocialFeedViewer viewer}) {
    _for(viewer).malformedNextPayload = true;
  }

  bool consumeMalformedNextPayload({required SocialFeedViewer viewer}) {
    final _ViewerFaults faults = _for(viewer);
    if (!faults.malformedNextPayload) {
      return false;
    }
    faults.malformedNextPayload = false;
    return true;
  }

  @override
  void resetViewerSimulatorFaults({required SocialFeedViewer viewer}) {
    _byViewer[viewer.id] = _ViewerFaults();
  }
}

class _ViewerFaults {
  int pendingNewPosts = 0;
  bool failNextRefresh = false;
  bool failNextLoadMore = false;
  bool failNextRealtimeReconnect = false;
  bool forceRealtimeDisconnect = false;
  int retryableDispatchFailuresRemaining = 0;
  bool rejectNextLike = false;
  bool rejectNextComment = false;
  bool malformedNextPayload = false;
}
