import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';

/// Pure merge helpers: pending local intent wins until ack/reject.
class SocialFeedMergePolicy {
  const SocialFeedMergePolicy();

  /// Prefer higher revision; equal revision keeps [existing].
  SocialFeedPost preferByRevision({
    required SocialFeedPost existing,
    required SocialFeedPost incoming,
  }) {
    if (incoming.serverRevision > existing.serverRevision) {
      return incoming;
    }
    return existing;
  }

  /// Overlay pending like intent onto a remote/canonical post.
  SocialFeedPost applyPendingLike({
    required SocialFeedPost base,
    required bool? pendingLiked,
  }) {
    if (pendingLiked == null) {
      return base;
    }
    if (pendingLiked == base.isLikedByMe) {
      return base;
    }
    final int delta = pendingLiked ? 1 : -1;
    final int nextCount = (base.likeCount + delta).clamp(0, 1 << 30);
    return base.copyWith(isLikedByMe: pendingLiked, likeCount: nextCount);
  }

  /// Overlay unacknowledged comment submission count.
  SocialFeedPost applyPendingCommentCount({
    required SocialFeedPost base,
    required int pendingCommentSubmissions,
  }) {
    if (pendingCommentSubmissions <= 0) {
      return base;
    }
    return base.copyWith(
      commentCount: base.commentCount + pendingCommentSubmissions,
    );
  }

  /// De-duplicate by id; higher revision wins; equal keeps first stable item.
  List<SocialFeedPost> dedupeById(Iterable<SocialFeedPost> posts) {
    final Map<String, SocialFeedPost> byId = <String, SocialFeedPost>{};
    final List<String> order = <String>[];
    for (final SocialFeedPost post in posts) {
      final SocialFeedPost? existing = byId[post.id];
      if (existing == null) {
        byId[post.id] = post;
        order.add(post.id);
        continue;
      }
      byId[post.id] = preferByRevision(existing: existing, incoming: post);
    }
    return <SocialFeedPost>[
      for (final String id in order)
        if (byId[id] case final SocialFeedPost post) post,
    ];
  }
}
