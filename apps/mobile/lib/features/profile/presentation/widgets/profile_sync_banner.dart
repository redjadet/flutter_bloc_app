import 'package:design_system/responsive.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/sync/ensure_sync_started_mixin.dart';
import 'package:flutter_bloc_app/app/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/app/sync/sync_banner_helpers.dart';
import 'package:flutter_bloc_app/app/sync/sync_now_trailing_button.dart';
import 'package:flutter_bloc_app/app/utils/bloc/cubit_helpers.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:networking/networking.dart';

/// Banner widget that surfaces profile sync status (offline/syncing) and
/// allows a manual refresh when online.
class ProfileSyncBanner extends StatefulWidget {
  const new({super.key});

  @override
  State<ProfileSyncBanner> createState() => _ProfileSyncBannerState();
}

class _ProfileSyncBannerState extends State<ProfileSyncBanner>
    with EnsureSyncStartedMixin {
  @override
  Widget build(BuildContext context) {
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
      selector: (s) => (s.networkStatus, s.syncStatus),
      builder: (context, pair) {
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
            trailing: SyncNowTrailingButton(
              enabled: !isSyncing,
              logLabel: 'ProfileSyncBanner',
            ),
          ),
        );
      },
    );
  }
}
