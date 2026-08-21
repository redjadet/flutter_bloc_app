import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_comment.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_mutation_status.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_viewer.dart';
import 'package:meta/meta.dart';

/// One visible comment row under an expanded post.
@immutable
class const SocialFeedVisibleComment({
  required final String id,
  required final String authorLabel,
  required final String body,
  required final SocialFeedMutationStatus syncStatus,
});

String socialFeedCommentAuthorLabel(String viewerId) {
  for (final SocialFeedViewer viewer in SocialFeedViewer.demoViewers) {
    if (viewer.id == viewerId) {
      return viewer.displayName;
    }
  }
  return switch (viewerId) {
    'author-a' => 'Jordan',
    'author-b' => 'Riley',
    'author-c' => 'Morgan',
    'author-d' => 'Avery',
    'author-e' => 'Quinn',
    'author-rt' => 'Casey',
    _ => viewerId,
  };
}

/// Merges shared stored comments with optimistic pending/submitted ones.
List<SocialFeedVisibleComment> resolveSocialFeedVisibleComments({
  required SocialFeedPost post,
  required List<SocialFeedComment> storedComments,
  required List<SocialFeedComment> pendingComments,
}) {
  final Set<String> storedIds = <String>{
    for (final SocialFeedComment comment in storedComments) comment.id,
  };
  return <SocialFeedVisibleComment>[
    for (final SocialFeedComment comment in storedComments)
      SocialFeedVisibleComment(
        id: comment.id,
        authorLabel: socialFeedCommentAuthorLabel(comment.viewerId),
        body: comment.body,
        syncStatus: comment.syncStatus,
      ),
    for (final SocialFeedComment comment in pendingComments)
      if (!storedIds.contains(comment.id))
        SocialFeedVisibleComment(
          id: comment.id,
          authorLabel: socialFeedCommentAuthorLabel(comment.viewerId),
          body: comment.body,
          syncStatus: comment.syncStatus,
        ),
  ];
}
