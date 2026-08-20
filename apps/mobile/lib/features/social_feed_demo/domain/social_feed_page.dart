import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';

enum SocialFeedDataSource { cache, remote }

class const SocialFeedPage({
  required final List<SocialFeedPost> posts,
  required final String? nextCursor,
  required final bool hasMore,
  required final SocialFeedDataSource source,
  required final DateTime fetchedAt,
});
