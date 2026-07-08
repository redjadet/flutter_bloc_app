import 'package:design_system/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/app/sync/sync_banner_helpers.dart';
import 'package:flutter_bloc_app/app/sync/sync_context_extensions.dart';
import 'package:flutter_bloc_app/app/utils/bloc/cubit_helpers.dart';
import 'package:flutter_bloc_app/app/widgets/type_safe_bloc_selector.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:networking/networking.dart';

/// Banner widget that displays search sync status (offline/syncing).
///
/// Search doesn't queue operations, so this banner only shows network/sync
/// status to inform users when results are being refreshed or when offline.
class SearchSyncBanner extends StatefulWidget {
  const SearchSyncBanner({super.key});

  @override
  State<SearchSyncBanner> createState() => _SearchSyncBannerState();
}

class _SearchSyncBannerState extends State<SearchSyncBanner> {
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
    if (!CubitHelpers.isCubitAvailable<SyncStatusCubit, SyncStatusState>(
      context,
    )) {
      return const SizedBox.shrink();
    }
    return TypeSafeBlocSelector<
      SyncStatusCubit,
      SyncStatusState,
      (NetworkStatus, SyncStatus)
    >(
      selector: (final s) => (s.networkStatus, s.syncStatus),
      builder: (final context, final pair) {
        final bool isOffline = pair.$1 == NetworkStatus.offline;
        final bool isSyncing = pair.$2 == SyncStatus.syncing;
        if (!shouldShowSyncBanner(
          isOffline: isOffline,
          isSyncing: isSyncing,
          pendingCount: 0,
        )) {
          return const SizedBox.shrink();
        }
        final AppLocalizations l10n = context.l10n;
        final (String title, String message) = syncBannerTitleAndMessage(
          l10n,
          isOffline: isOffline,
          isSyncing: isSyncing,
          pendingCount: 0,
        );
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveHorizontalGapL,
            vertical: context.responsiveGapS,
          ),
          child: SyncBannerContent(
            title: title,
            message: message,
            isError: isOffline,
          ),
        );
      },
    );
  }
}
