import 'package:flutter_bloc_app/features/social_feed_demo/domain/social_feed_realtime_source.dart';
import 'package:flutter_bloc_app/features/social_feed_demo/presentation/cubit/social_feed_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

class SocialFeedStatusBanner extends StatelessWidget {
  const SocialFeedStatusBanner({required this.data, super.key});

  final SocialFeedReadyData data;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<String> lines = <String>[];
    if (data.isSimulatedOffline) {
      lines.add(l10n.socialFeedDemoSimulatedOffline);
    }
    if (data.isShowingCachedData) {
      lines.add(
        l10n.socialFeedDemoStaleCache(data.cacheAge.inMinutes),
      );
    }
    if (data.pendingMutationCount > 0) {
      lines.add(l10n.socialFeedDemoPendingCount(data.pendingMutationCount));
    }
    if (data.needsAttentionCount > 0) {
      lines.add(
        l10n.socialFeedDemoNeedsAttentionCount(data.needsAttentionCount),
      );
    }
    if (data.connectionStatus == SocialFeedConnectionStatus.reconnecting ||
        data.connectionStatus == SocialFeedConnectionStatus.connecting) {
      lines.add(l10n.socialFeedDemoReconnecting);
    }
    if (lines.isEmpty) {
      return const SizedBox.shrink();
    }
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (final String line in lines) Text(line),
          ],
        ),
      ),
    );
  }
}
