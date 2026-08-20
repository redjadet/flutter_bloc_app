import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_comment.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_failure.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_realtime_source.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_viewer.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'social_feed_state.freezed.dart';

@freezed
sealed class SocialFeedRefreshStatus with _$SocialFeedRefreshStatus {
  const factory SocialFeedRefreshStatus.idle() = SocialFeedRefreshIdle;
  const factory SocialFeedRefreshStatus.loading() = SocialFeedRefreshLoading;
  const factory SocialFeedRefreshStatus.failure(SocialFeedFailure failure) =
      SocialFeedRefreshFailure;
}

@freezed
sealed class SocialFeedPageStatus with _$SocialFeedPageStatus {
  const factory SocialFeedPageStatus.idle() = SocialFeedPageIdle;
  const factory SocialFeedPageStatus.loading() = SocialFeedPageLoading;
  const factory SocialFeedPageStatus.failure(SocialFeedFailure failure) =
      SocialFeedPageFailureStatus;
  const factory SocialFeedPageStatus.exhausted() = SocialFeedPageExhausted;
}

@freezed
sealed class SocialFeedEffect with _$SocialFeedEffect {
  const factory SocialFeedEffect.mutationRejected() =
      SocialFeedMutationRejectedEffect;
  const factory SocialFeedEffect.announcement(String code) =
      SocialFeedAnnouncementEffect;
}

@freezed
abstract class SocialFeedReadyData with _$SocialFeedReadyData {
  const factory SocialFeedReadyData({
    required SocialFeedViewer viewer,
    required List<SocialFeedPost> posts,
    required String? nextCursor,
    required SocialFeedRefreshStatus refreshStatus,
    required SocialFeedPageStatus pageStatus,
    required bool isShowingCachedData,
    required Duration cacheAge,
    required SocialFeedConnectionStatus connectionStatus,
    required bool isSimulatedOffline,
    required List<SocialFeedPost> bufferedRealtimePosts,
    required int pendingMutationCount,
    required int needsAttentionCount,
    required Set<String> pendingPostIds,

    /// postId → mutationId for manual retry of dead-lettered ops.
    required Map<String, String> needsAttentionByPostId,
    required Map<String, List<SocialFeedComment>> pendingCommentsByPostId,
    SocialFeedEffect? effect,
    @Default(0) int effectId,
  }) = _SocialFeedReadyData;

  const SocialFeedReadyData._();

  bool get hasMore => nextCursor != null;
}

@freezed
sealed class SocialFeedState with _$SocialFeedState {
  const factory SocialFeedState.initial(SocialFeedViewer viewer) =
      SocialFeedInitial;
  const factory SocialFeedState.loading(SocialFeedViewer viewer) =
      SocialFeedLoading;
  const factory SocialFeedState.failure({
    required SocialFeedViewer viewer,
    required SocialFeedFailure failure,
  }) = SocialFeedFailureState;
  const factory SocialFeedState.ready(SocialFeedReadyData data) =
      SocialFeedReady;
}
