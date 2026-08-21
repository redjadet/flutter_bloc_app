import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

class SocialFeedPostCard extends StatelessWidget {
  const SocialFeedPostCard({
    required this.post,
    required this.isPending,
    required this.onLike,
    required this.onComment,
    this.needsAttention = false,
    this.onRetryAttention,
    super.key,
  });

  final SocialFeedPost post;
  final bool isPending;
  final bool needsAttention;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback? onRetryAttention;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              post.authorDisplayName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(post.body),
            const SizedBox(height: 8),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: <Widget>[
                Semantics(
                  container: true,
                  button: true,
                  toggled: post.isLikedByMe,
                  label: post.isLikedByMe
                      ? l10n.socialFeedDemoLiked
                      : l10n.socialFeedDemoNotLiked,
                  child: IconButton(
                    key: ValueKey('social-feed-like-${post.id}'),
                    onPressed: onLike,
                    icon: Icon(
                      post.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                    ),
                    tooltip: post.isLikedByMe
                        ? l10n.socialFeedDemoLiked
                        : l10n.socialFeedDemoNotLiked,
                  ),
                ),
                Text('${post.likeCount}'),
                IconButton(
                  key: ValueKey('social-feed-comment-${post.id}'),
                  onPressed: onComment,
                  icon: const Icon(Icons.comment_outlined),
                  tooltip: l10n.socialFeedDemoComment,
                ),
                Text('${post.commentCount}'),
                if (isPending) Text(l10n.socialFeedDemoPending),
                if (needsAttention && onRetryAttention != null)
                  Semantics(
                    liveRegion: true,
                    child: TextButton(
                      key: ValueKey('social-feed-retry-${post.id}'),
                      onPressed: onRetryAttention,
                      child: Text(l10n.socialFeedDemoRetry),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
