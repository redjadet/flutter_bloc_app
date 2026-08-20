import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

class SocialFeedNewPostsBanner extends StatelessWidget {
  const SocialFeedNewPostsBanner({
    required this.count,
    required this.onActivate,
    super.key,
  });

  final int count;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Semantics(
      liveRegion: true,
      child: Material(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: InkWell(
          key: const ValueKey('social-feed-new-posts-banner'),
          onTap: onActivate,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(l10n.socialFeedDemoNewPosts(count)),
          ),
        ),
      ),
    );
  }
}
