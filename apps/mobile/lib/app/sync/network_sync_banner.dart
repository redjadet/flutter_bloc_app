import 'package:design_system/responsive.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/sync/ensure_sync_started_mixin.dart';
import 'package:flutter_bloc_app/app/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/app/sync/sync_banner_helpers.dart';
import 'package:flutter_bloc_app/app/utils/bloc/cubit_helpers.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:networking/networking.dart';

/// Sync banner driven only by [SyncStatusCubit] (offline / syncing / optional
/// pending from the last sync summary). Feature wrappers keep public names.
class NetworkSyncBanner extends StatefulWidget {
  const new({super.key, this.includePendingFromSummary = false});

  /// When true, pending count uses `lastSummary?.pendingAtStart` (IoT demo).
  /// When false, pending is always 0 (search — no feature queue UI).
  final bool includePendingFromSummary;

  @override
  State<NetworkSyncBanner> createState() => _NetworkSyncBannerState();
}

class _NetworkSyncBannerState extends State<NetworkSyncBanner>
    with EnsureSyncStartedMixin {
  @override
  Widget build(BuildContext context) {
    if (!CubitHelpers.isCubitAvailable<SyncStatusCubit, SyncStatusState>(
      context,
    )) {
      return const SizedBox.shrink();
    }

    if (widget.includePendingFromSummary) {
      return TypeSafeBlocSelector<
        SyncStatusCubit,
        SyncStatusState,
        (NetworkStatus, SyncStatus, int)
      >(
        selector: (s) =>
            (s.networkStatus, s.syncStatus, s.lastSummary?.pendingAtStart ?? 0),
        builder: (context, triple) => _buildBanner(
          context,
          isOffline: triple.$1 == NetworkStatus.offline,
          isSyncing: triple.$2 == SyncStatus.syncing,
          pendingCount: triple.$3,
        ),
      );
    }

    return TypeSafeBlocSelector<
      SyncStatusCubit,
      SyncStatusState,
      (NetworkStatus, SyncStatus)
    >(
      selector: (s) => (s.networkStatus, s.syncStatus),
      builder: (context, pair) => _buildBanner(
        context,
        isOffline: pair.$1 == NetworkStatus.offline,
        isSyncing: pair.$2 == SyncStatus.syncing,
        pendingCount: 0,
      ),
    );
  }

  Widget _buildBanner(
    BuildContext context, {
    required bool isOffline,
    required bool isSyncing,
    required int pendingCount,
  }) {
    if (!shouldShowSyncBanner(
      isOffline: isOffline,
      isSyncing: isSyncing,
      pendingCount: pendingCount,
    )) {
      return const SizedBox.shrink();
    }
    final AppLocalizations l10n = context.l10n;
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
      child: SyncBannerContent(
        title: title,
        message: message,
        isError: isOffline,
      ),
    );
  }
}
