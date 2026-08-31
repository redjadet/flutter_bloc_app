import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_mutation_status.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/widgets/social_feed_visible_comments.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

class SocialFeedCommentThread extends StatelessWidget {
  const SocialFeedCommentThread({
    required this.comments,
    super.key,
  });

  final List<SocialFeedVisibleComment> comments;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    if (comments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          l10n.socialFeedDemoNoComments,
          key: const ValueKey('social-feed-comments-empty'),
          style: theme.textTheme.bodySmall,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        key: const ValueKey('social-feed-comments-thread'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            l10n.socialFeedDemoCommentsHeading,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          for (final SocialFeedVisibleComment comment in comments)
            Padding(
              key: ValueKey('social-feed-comment-row-${comment.id}'),
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          comment.authorLabel,
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                      if (comment.syncStatus ==
                          SocialFeedMutationStatus.pending)
                        Text(
                          l10n.socialFeedDemoPending,
                          style: theme.textTheme.labelSmall,
                        ),
                    ],
                  ),
                  Text(comment.body),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
