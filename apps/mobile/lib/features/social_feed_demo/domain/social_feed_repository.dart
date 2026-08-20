import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_page.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_viewer.dart';

sealed class SocialFeedLikeResult {
  const SocialFeedLikeResult();
}

final class SocialFeedLikeSynced extends SocialFeedLikeResult {
  const SocialFeedLikeSynced(this.post);
  final SocialFeedPost post;
}

final class SocialFeedLikeQueued extends SocialFeedLikeResult {
  const SocialFeedLikeQueued(this.post);
  final SocialFeedPost post;
}

final class SocialFeedLikeRejected extends SocialFeedLikeResult {
  const SocialFeedLikeRejected(this.canonicalPost);
  final SocialFeedPost canonicalPost;
}

sealed class SocialFeedCommentResult {
  const SocialFeedCommentResult();
}

final class SocialFeedCommentSynced extends SocialFeedCommentResult {
  const SocialFeedCommentSynced({
    required this.post,
    required this.mutationId,
  });
  final SocialFeedPost post;
  final String mutationId;
}

final class SocialFeedCommentQueued extends SocialFeedCommentResult {
  const SocialFeedCommentQueued({
    required this.post,
    required this.mutationId,
  });
  final SocialFeedPost post;
  final String mutationId;
}

final class SocialFeedCommentRejected extends SocialFeedCommentResult {
  const SocialFeedCommentRejected(this.canonicalPost);
  final SocialFeedPost canonicalPost;
}

class SocialFeedAttentionMutation {
  const SocialFeedAttentionMutation({
    required this.mutationId,
    required this.postId,
  });

  final String mutationId;
  final String postId;
}

class SocialFeedRejectedSync {
  const SocialFeedRejectedSync({
    required this.postId,
    required this.canonicalPost,
    required this.wasComment,
    this.mutationId,
  });

  final String postId;
  final SocialFeedPost canonicalPost;
  final bool wasComment;
  final String? mutationId;
}

class SocialFeedSyncSummary {
  const SocialFeedSyncSummary({
    required this.pendingCount,
    required this.needsAttentionCount,
    this.attentionMutations = const <SocialFeedAttentionMutation>[],
    this.rejections = const <SocialFeedRejectedSync>[],
  });

  final int pendingCount;
  final int needsAttentionCount;
  final List<SocialFeedAttentionMutation> attentionMutations;
  final List<SocialFeedRejectedSync> rejections;
}

abstract class SocialFeedSyncLease {
  Stream<SocialFeedSyncSummary> get summaries;
  Future<void> close();
}

abstract class SocialFeedRepository {
  Future<SocialFeedPage?> readCachedPage({required SocialFeedViewer viewer});

  Future<SocialFeedPage> refresh({required SocialFeedViewer viewer});

  Future<SocialFeedPage> loadMore({
    required SocialFeedViewer viewer,
    required String cursor,
  });

  Future<SocialFeedLikeResult> setLiked({
    required SocialFeedViewer viewer,
    required String postId,
    required bool desiredLiked,
    required String mutationId,
  });

  Future<SocialFeedCommentResult> addComment({
    required SocialFeedViewer viewer,
    required String postId,
    required String body,
    required String mutationId,
  });

  Future<SocialFeedSyncLease> acquireSync({required SocialFeedViewer viewer});

  Future<void> retryNeedsAttention({
    required SocialFeedViewer viewer,
    required String mutationId,
  });

  Future<int> pendingMutationCount({required SocialFeedViewer viewer});

  Future<void> resetViewerData({required SocialFeedViewer viewer});
}
