import 'package:flutter_bloc_app/features/social_feed_demo/data/social_feed_seed_data.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('seed posts and comments avoid obvious filler phrasing', () {
    const SocialFeedSeedData seed = SocialFeedSeedData();
    final List<SocialFeedPost> posts = seed.build(
      clock: () => DateTime.utc(2026, 8, 21, 12),
    );

    expect(posts, hasLength(SocialFeedSeedData.postCount));
    for (final SocialFeedPost post in posts) {
      expect(post.body.toLowerCase(), isNot(contains('fictional seed')));
      expect(post.commentCount, lessThanOrEqualTo(2));
      final List<SocialFeedSeedComment> comments = seed.commentsFor(
        postId: post.id,
        count: post.commentCount,
        baseCreatedAt: post.createdAt,
      );
      expect(comments, hasLength(post.commentCount));
      for (final SocialFeedSeedComment comment in comments) {
        expect(
          comment.body.toLowerCase(),
          isNot(contains('fictional comment')),
        );
        expect(comment.body, isNot(contains(post.id)));
        expect(comment.authorDisplayName, isNotEmpty);
      }
    }
  });

  test('seed comment density stays sparse', () {
    const SocialFeedSeedData seed = SocialFeedSeedData();
    final List<SocialFeedPost> posts = seed.build(
      clock: () => DateTime.utc(2026, 8, 21, 12),
    );
    final int withComments = posts.where((p) => p.commentCount > 0).length;
    expect(withComments, lessThan(posts.length ~/ 2));
  });
}
