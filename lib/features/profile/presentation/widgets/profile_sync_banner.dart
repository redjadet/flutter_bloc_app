import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_banner_helpers.dart';
import 'package:flutter_bloc_app/shared/sync/sync_context_extensions.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

/// Banner widget that surfaces profile sync status (offline/syncing) and
/// allows a manual refresh when online.
class ProfileSyncBanner extends StatefulWidget {
  const ProfileSyncBanner({super.key});

  @override
  State<ProfileSyncBanner> createState() => _ProfileSyncBannerState();
}

class _ProfileSyncBannerState extends State<ProfileSyncBanner> {
  bool _isManualSyncing = false;

  @override
  void initState() {
    super.initState();
    context.ensureSyncStartedIfAvailable();
  }

  Future<void> _handleSyncNow(final SyncStatusCubit cubit) async {
    if (_isManualSyncing) {
      return;
    }
    setState(() => _isManualSyncing = true);
    try {
      await cubit.flush();
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'ProfileSyncBanner.handleSyncNow failed',
        error,
        stackTrace,
      );
    } finally {
      if (mounted) {
        setState(() => _isManualSyncing = false);
      }
    }
  }

  @override
  Widget build(final BuildContext context) =>
      TypeSafeBlocBuilder<SyncStatusCubit, SyncStatusState>(
        builder: (final context, final syncState) {
          final SyncStatusCubit syncCubit = context.cubit<SyncStatusCubit>();
          final bool isOffline =
              syncState.networkStatus == NetworkStatus.offline;
          final bool isSyncing = syncState.syncStatus == SyncStatus.syncing;
          if (!isOffline && !isSyncing) {
            return const SizedBox.shrink();
          }
          final AppLocalizations l10n = context.l10n;
          final bool isError = isOffline;
          final (String title, String message) = syncBannerTitleAndMessage(
            l10n,
            isOffline: isOffline,
            isSyncing: isSyncing,
            pendingCount: 0,
          );
          final bool canManualSync = !isSyncing && !_isManualSyncing;

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsiveHorizontalGapL,
              vertical: context.responsiveGapS,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AppMessage(
                  title: title,
                  message: message,
                  isError: isError,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: PlatformAdaptive.textButton(
                    context: context,
                    onPressed: canManualSync
                        ? () => _handleSyncNow(syncCubit)
                        : null,
                    child: _isManualSyncing
                        ? SizedBox(
                            height: context.responsiveGapM,
                            width: context.responsiveGapM,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(l10n.syncStatusSyncNowButton),
                  ),
                ),
              ],
            ),
          );
        },
      );
}
