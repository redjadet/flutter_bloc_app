import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';

/// Deterministic fictional seed (60 posts). Shared content; likes personalize
/// per viewer in the simulated remote.
class SocialFeedSeedData {
  const SocialFeedSeedData();

  static const int postCount = 60;

  List<SocialFeedPost> build({required DateTime Function() clock}) {
    final DateTime now = clock().toUtc();
    return <SocialFeedPost>[
      for (int i = 0; i < postCount; i++)
        SocialFeedPost(
          id: 'post-${(postCount - i).toString().padLeft(3, '0')}',
          authorId: i.isEven ? 'author-a' : 'author-b',
          authorDisplayName: i.isEven ? 'Jordan' : 'Riley',
          body:
              'Fictional seed post ${postCount - i} for the social feed demo.',
          createdAt: now.subtract(Duration(minutes: i * 3)),
          isLikedByMe: false,
          likeCount: i % 7,
          commentCount: i % 4,
          serverRevision: 1,
        ),
    ];
  }
}
