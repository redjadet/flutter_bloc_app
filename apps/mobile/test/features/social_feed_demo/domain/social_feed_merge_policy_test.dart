import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_merge_policy.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const SocialFeedMergePolicy policy = SocialFeedMergePolicy();

  SocialFeedPost post({
    required String id,
    int revision = 1,
    bool liked = false,
    int likes = 0,
    int comments = 0,
  }) {
    return SocialFeedPost(
      id: id,
      authorId: 'a',
      authorDisplayName: 'A',
      body: 'b',
      createdAt: DateTime.utc(2026),
      isLikedByMe: liked,
      likeCount: likes,
      commentCount: comments,
      serverRevision: revision,
    );
  }

  test('pending local like wins over remote unlike', () {
    final SocialFeedPost remote = post(id: '1', liked: false, likes: 2);
    final SocialFeedPost merged = policy.applyPendingLike(
      base: remote,
      pendingLiked: true,
    );
    expect(merged.isLikedByMe, isTrue);
    expect(merged.likeCount, 3);
  });

  test('dedupe keeps higher revision', () {
    final List<SocialFeedPost> out = policy.dedupeById(<SocialFeedPost>[
      post(id: '1', revision: 1, likes: 1),
      post(id: '1', revision: 2, likes: 5),
    ]);
    expect(out, hasLength(1));
    expect(out.single.serverRevision, 2);
    expect(out.single.likeCount, 5);
  });
}
