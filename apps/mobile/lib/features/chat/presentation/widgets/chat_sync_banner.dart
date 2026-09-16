import 'dart:async';

import 'package:design_system/responsive.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/sync/ensure_sync_started_mixin.dart';
import 'package:flutter_bloc_app/app/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/app/sync/sync_banner_helpers.dart';
import 'package:flutter_bloc_app/app/sync/sync_now_trailing_button.dart';
import 'package:flutter_bloc_app/app/utils/bloc/cubit_helpers.dart';
import 'package:flutter_bloc_app/features/chat/presentation/cubit/chat_sync_status_cubit.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:networking/networking.dart';

/// Banner showing pending chat sync count and optional manual sync action.
class ChatSyncBanner extends StatefulWidget {
  const new({super.key});

  @override
  State<ChatSyncBanner> createState() => _ChatSyncBannerState();
}

class _ChatSyncBannerState extends State<ChatSyncBanner>
    with EnsureSyncStartedMixin {
  @override
  void onSyncEnsureStarted() {
    if (CubitHelpers.isCubitAvailable<ChatSyncStatusCubit, ChatSyncStatusState>(
      context,
    )) {
      unawaited(context.cubit<ChatSyncStatusCubit>().refresh());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!CubitHelpers.isCubitAvailable<SyncStatusCubit, SyncStatusState>(
          context,
        ) ||
        !CubitHelpers.isCubitAvailable<
          ChatSyncStatusCubit,
          ChatSyncStatusState
        >(context)) {
      return const SizedBox.shrink();
    }

    return TypeSafeBlocListener<SyncStatusCubit, SyncStatusState>(
      listener: (context, state) {
        // check-ignore: listener callback is event-driven, not a build side effect
        unawaited(context.cubit<ChatSyncStatusCubit>().refresh());
      },
      child: TypeSafeBlocBuilder<ChatSyncStatusCubit, ChatSyncStatusState>(
        builder: (context, chatSyncState) {
          return TypeSafeBlocSelector<
            SyncStatusCubit,
            SyncStatusState,
            (NetworkStatus, SyncStatus)
          >(
            selector: (s) => (s.networkStatus, s.syncStatus),
            builder: (context, pair) {
              final bool isOffline = pair.$1 == NetworkStatus.offline;
              final bool isSyncing = pair.$2 == SyncStatus.syncing;
              final int pendingCount = chatSyncState.pendingCount;
              if (!shouldShowSyncBanner(
                isOffline: isOffline,
                isSyncing: isSyncing,
                pendingCount: pendingCount,
              )) {
                return const SizedBox.shrink();
              }
              final (String title, String message) = syncBannerTitleAndMessage(
                context.l10n,
                isOffline: isOffline,
                isSyncing: isSyncing,
                pendingCount: pendingCount,
              );
              final bool canManualSync =
                  !isOffline && pendingCount > 0 && !isSyncing;
              final Widget? trailing = pendingCount > 0
                  ? SyncNowTrailingButton(
                      enabled: canManualSync,
                      logLabel: 'ChatSyncBanner',
                    )
                  : null;
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsiveHorizontalGapL,
                  vertical: context.responsiveGapS,
                ),
                child: SyncBannerContent(
                  title: title,
                  message: message,
                  isError: isOffline,
                  trailing: trailing,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
