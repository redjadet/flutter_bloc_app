import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_comment.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_mutation_status.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_viewer.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/widgets/social_feed_visible_comments.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final SocialFeedPost post = SocialFeedPost(
    id: 'post-001',
    authorId: 'author-a',
    authorDisplayName: 'Jordan',
    body: 'Hello',
    createdAt: DateTime.utc(2026, 8, 1),
    isLikedByMe: false,
    likeCount: 0,
    commentCount: 2,
    serverRevision: 1,
  );

  test('stored comments render with author labels', () {
    final List<SocialFeedVisibleComment> rows =
        resolveSocialFeedVisibleComments(
          post: post,
          storedComments: <SocialFeedComment>[
            SocialFeedComment(
              id: 'post-001-cmt-1',
              postId: 'post-001',
              viewerId: 'author-a',
              body: 'Nice catch on the reconnect path.',
              createdAt: DateTime.utc(2026, 8, 1, 0, 1),
              syncStatus: SocialFeedMutationStatus.synced,
            ),
            SocialFeedComment(
              id: 'comment-sam',
              postId: 'post-001',
              viewerId: SocialFeedViewer.sam.id,
              body: 'Sam wrote this',
              createdAt: DateTime.utc(2026, 8, 1, 0, 2),
              syncStatus: SocialFeedMutationStatus.synced,
            ),
          ],
          pendingComments: const <SocialFeedComment>[],
        );
    expect(rows, hasLength(2));
    expect(rows.first.authorLabel, 'Jordan');
    expect(rows.last.authorLabel, 'Sam');
    expect(rows.last.body, 'Sam wrote this');
  });

  test('pending comments append when not already stored', () {
    final SocialFeedComment pending = SocialFeedComment(
      id: 'comment-local-1',
      postId: 'post-001',
      viewerId: SocialFeedViewer.alex.id,
      body: 'Nice post',
      createdAt: DateTime.utc(2026, 8, 1, 12),
      syncStatus: SocialFeedMutationStatus.pending,
    );
    final List<SocialFeedVisibleComment> rows =
        resolveSocialFeedVisibleComments(
          post: post.copyWith(commentCount: 1),
          storedComments: const <SocialFeedComment>[],
          pendingComments: <SocialFeedComment>[pending],
        );
    expect(rows, hasLength(1));
    expect(rows.single.authorLabel, 'Alex');
    expect(rows.single.body, 'Nice post');
  });

  test('socialFeedCommentAuthorLabel maps demo viewers', () {
    expect(socialFeedCommentAuthorLabel(SocialFeedViewer.sam.id), 'Sam');
    expect(socialFeedCommentAuthorLabel(SocialFeedViewer.alex.id), 'Alex');
  });
}
