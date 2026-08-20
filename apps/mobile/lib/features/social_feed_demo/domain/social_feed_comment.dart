import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_mutation_status.dart';

/// Local comment submission feedback (no history fetch in this slice).
class const SocialFeedComment({
  required final String id,
  required final String postId,
  required final String viewerId,
  required final String body,
  required final DateTime createdAt,
  required final SocialFeedMutationStatus syncStatus,
}) {
  SocialFeedComment copyWith({
    String? id,
    String? postId,
    String? viewerId,
    String? body,
    DateTime? createdAt,
    SocialFeedMutationStatus? syncStatus,
  }) {
    return SocialFeedComment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      viewerId: viewerId ?? this.viewerId,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
