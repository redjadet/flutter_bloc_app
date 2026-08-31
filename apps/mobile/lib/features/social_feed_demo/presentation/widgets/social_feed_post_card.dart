import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_post.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/widgets/social_feed_comment_thread.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/widgets/social_feed_visible_comments.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

class SocialFeedPostCard extends StatelessWidget {
  const SocialFeedPostCard({
    required this.post,
    required this.isPending,
    required this.onLike,
    required this.onComment,
    required this.expanded,
    required this.onToggleExpanded,
    this.visibleComments = const <SocialFeedVisibleComment>[],
    this.needsAttention = false,
    this.onRetryAttention,
    super.key,
  });

  final SocialFeedPost post;
  final bool isPending;
  final bool needsAttention;
  final bool expanded;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onToggleExpanded;
  final List<SocialFeedVisibleComment> visibleComments;
  final VoidCallback? onRetryAttention;

  /// Thread rows are the badge source of truth (avoids stale hive counts).
  int _displayCommentCount() => visibleComments.length;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        key: ValueKey('social-feed-post-tap-${post.id}'),
        onTap: onToggleExpanded,
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
                        post.isLikedByMe
                            ? Icons.favorite
                            : Icons.favorite_border,
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
                  Text(
                    key: ValueKey('social-feed-comment-count-${post.id}'),
                    '${_displayCommentCount()}',
                  ),
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
              if (expanded) SocialFeedCommentThread(comments: visibleComments),
            ],
          ),
        ),
      ),
    );
  }
}
