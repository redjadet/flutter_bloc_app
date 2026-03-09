import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_banner_helpers.dart';
import 'package:flutter_bloc_app/shared/sync/sync_context_extensions.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';

/// Banner that displays IoT demo sync status (offline/syncing/pending).
///
/// Triggers sync when the banner is first built so pullRemote runs and
/// devices are loaded from Supabase when online.
class IotDemoSyncBanner extends StatefulWidget {
  const IotDemoSyncBanner({super.key});

  @override
  State<IotDemoSyncBanner> createState() => _IotDemoSyncBannerState();
}

class _IotDemoSyncBannerState extends State<IotDemoSyncBanner> {
  bool _didEnsureSyncStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didEnsureSyncStarted) {
      return;
    }
    _didEnsureSyncStarted = true;
    context.ensureSyncStartedIfAvailable();
  }

  @override
  Widget build(final BuildContext context) {
    return TypeSafeBlocSelector<
      SyncStatusCubit,
      SyncStatusState,
      (NetworkStatus, SyncStatus, int)
    >(
      selector: (final s) => (
        s.networkStatus,
        s.syncStatus,
        s.lastSummary?.pendingAtStart ?? 0,
      ),
      builder: (final context, final triple) {
        final bool isOffline = triple.$1 == NetworkStatus.offline;
        final bool isSyncing = triple.$2 == SyncStatus.syncing;
        final int pendingCount = triple.$3;
        final bool showBanner = isOffline || isSyncing || pendingCount > 0;
        if (!showBanner) {
          return const SizedBox.shrink();
        }
        final AppLocalizations l10n = context.l10n;
        final bool isError = isOffline;
        final (String title, String message) = syncBannerTitleAndMessage(
          l10n,
          isOffline: isOffline,
          isSyncing: isSyncing,
          pendingCount: pendingCount,
        );

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveHorizontalGapL,
            vertical: context.responsiveGapS,
          ),
          child: AppMessage(
            title: title,
            message: message,
            isError: isError,
          ),
        );
      },
    );
  }
}
