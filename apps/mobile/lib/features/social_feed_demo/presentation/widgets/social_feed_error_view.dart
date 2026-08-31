import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_failure.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

class SocialFeedErrorView extends StatelessWidget {
  const SocialFeedErrorView({
    required this.failure,
    required this.onRetry,
    super.key,
  });

  final SocialFeedFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String message = switch (failure) {
      SocialFeedOfflineFailure() => l10n.socialFeedDemoOffline,
      SocialFeedMalformedDataFailure() => l10n.socialFeedDemoMalformed,
      _ => l10n.socialFeedDemoUnknownError,
    };
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(message),
          const SizedBox(height: 12),
          FilledButton(
            key: const ValueKey('social-feed-retry'),
            onPressed: onRetry,
            child: Text(l10n.socialFeedDemoRetry),
          ),
        ],
      ),
    );
  }
}
