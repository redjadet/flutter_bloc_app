import 'package:flutter_bloc_app/l10n/app_localizations.dart';

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
