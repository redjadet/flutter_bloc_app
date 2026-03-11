import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/widgets/app_message.dart';

/// Whether the sync banner should be shown (not hidden).
///
/// Use in sync banner widgets so the hide condition is defined in one place.
bool shouldShowSyncBanner({
  required final bool isOffline,
  required final bool isSyncing,
  required final int pendingCount,
  final bool hasMetadata = false,
}) => isOffline || isSyncing || pendingCount > 0 || hasMetadata;

/// Returns title and message for a sync status banner from [l10n] and state.
///
/// Use in sync banner widgets to avoid repeating the same if/else for
/// offline / syncing / pending.
(String title, String message) syncBannerTitleAndMessage(
  final AppLocalizations l10n, {
  required final bool isOffline,
  required final bool isSyncing,
  required final int pendingCount,
}) {
  if (isOffline) {
    return (
      l10n.syncStatusOfflineTitle,
      l10n.syncStatusOfflineMessage(pendingCount),
    );
  }
  if (isSyncing) {
    return (
      l10n.syncStatusSyncingTitle,
      l10n.syncStatusSyncingMessage(pendingCount),
    );
  }
  return (
    l10n.syncStatusPendingTitle,
    l10n.syncStatusPendingMessage(pendingCount),
  );
}

/// Shared content for sync status banners: [AppMessage] plus optional
/// [trailing] (e.g. Sync now button). Wrap with [Padding] as needed.
class SyncBannerContent extends StatelessWidget {
  const SyncBannerContent({
    required this.title,
    required this.message,
    required this.isError,
    super.key,
    this.trailing,
  });

  final String title;
  final String message;
  final bool isError;
  final Widget? trailing;

  @override
  Widget build(final BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppMessage(
          title: title,
          message: message,
          isError: isError,
        ),
        if (trailing case final Widget t) t,
      ],
    );
  }
}
