import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_viewer.dart';

enum SocialFeedConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

abstract class SocialFeedRealtimeLease {
  Stream<SocialFeedConnectionStatus> get connectionStatus;
  Stream<SocialFeedPost> get posts;
  Future<void> close();
}

abstract class SocialFeedRealtimeSource {
  Future<SocialFeedRealtimeLease> acquire(SocialFeedViewer viewer);

  /// Flush scenario-queued posts into active leases (no-op when disconnected).
  void flushPendingPosts(SocialFeedViewer viewer);
}
