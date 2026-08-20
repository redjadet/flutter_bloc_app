import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_realtime_source.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_viewer.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/cubit/social_feed_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ready hasMore follows nextCursor', () {
    final SocialFeedReadyData withCursor = SocialFeedReadyData(
      viewer: SocialFeedViewer.alex,
      posts: const <SocialFeedPost>[],
      nextCursor: 'x',
      refreshStatus: const SocialFeedRefreshStatus.idle(),
      pageStatus: const SocialFeedPageStatus.idle(),
      isShowingCachedData: false,
      cacheAge: Duration.zero,
      connectionStatus: SocialFeedConnectionStatus.connected,
      isSimulatedOffline: false,
      bufferedRealtimePosts: const <SocialFeedPost>[],
      pendingMutationCount: 0,
      needsAttentionCount: 0,
      pendingPostIds: const <String>{},
      needsAttentionByPostId: const <String, String>{},
      pendingCommentsByPostId: const {},
    );
    expect(withCursor.hasMore, isTrue);
    expect(withCursor.copyWith(nextCursor: null).hasMore, isFalse);
  });

  test('effectId increments via copyWith', () {
    final SocialFeedReadyData data = SocialFeedReadyData(
      viewer: SocialFeedViewer.alex,
      posts: const <SocialFeedPost>[],
      nextCursor: null,
      refreshStatus: const SocialFeedRefreshStatus.idle(),
      pageStatus: const SocialFeedPageStatus.exhausted(),
      isShowingCachedData: false,
      cacheAge: Duration.zero,
      connectionStatus: SocialFeedConnectionStatus.disconnected,
      isSimulatedOffline: false,
      bufferedRealtimePosts: const <SocialFeedPost>[],
      pendingMutationCount: 0,
      needsAttentionCount: 0,
      pendingPostIds: const <String>{},
      needsAttentionByPostId: const <String, String>{},
      pendingCommentsByPostId: const {},
    );
    final SocialFeedReadyData next = data.copyWith(
      effect: const SocialFeedEffect.mutationRejected(),
      effectId: data.effectId + 1,
    );
    expect(next.effectId, 1);
    expect(next.effect, isA<SocialFeedMutationRejectedEffect>());
  });
}
