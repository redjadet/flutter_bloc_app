import 'dart:async';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/app/sync/sync_banner_helpers.dart';
import 'package:flutter_bloc_app/app/sync/sync_context_extensions.dart';
import 'package:flutter_bloc_app/app/utils/bloc/cubit_helpers.dart';
import 'package:flutter_bloc_app/features/chat/presentation/cubit/chat_sync_status_cubit.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';
import 'package:networking/networking.dart';

/// Banner showing pending chat sync count and optional manual sync action.
class ChatSyncBanner extends StatefulWidget {
  const ChatSyncBanner({super.key});

  @override
  State<ChatSyncBanner> createState() => _ChatSyncBannerState();
}

class _ChatSyncBannerState extends State<ChatSyncBanner> {
  bool _isManualSyncing = false;
  bool _didEnsureSyncStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didEnsureSyncStarted) {
      return;
    }
    _didEnsureSyncStarted = true;
    context.ensureSyncStartedIfAvailable();
    if (CubitHelpers.isCubitAvailable<ChatSyncStatusCubit, ChatSyncStatusState>(
      context,
    )) {
      unawaited(context.cubit<ChatSyncStatusCubit>().refresh());
    }
  }

  Future<void> _handleSyncNow(final BuildContext context) async {
    if (_isManualSyncing) {
      return;
    }
    setState(() => _isManualSyncing = true);
    try {
      final SyncStatusCubit syncCubit = context.cubit<SyncStatusCubit>();
      await syncCubit.flush();
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'ChatSyncBanner.handleSyncNow failed',
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
  Widget build(final BuildContext context) {
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
      listener: (final context, final state) {
        // check-ignore: listener callback is event-driven, not a build side effect
        unawaited(context.cubit<ChatSyncStatusCubit>().refresh());
      },
      child: TypeSafeBlocBuilder<ChatSyncStatusCubit, ChatSyncStatusState>(
        builder: (final context, final chatSyncState) {
          return TypeSafeBlocSelector<
            SyncStatusCubit,
            SyncStatusState,
            (NetworkStatus, SyncStatus)
          >(
            selector: (final s) => (s.networkStatus, s.syncStatus),
            builder: (final context, final pair) {
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
                  ? Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: PlatformAdaptive.textButton(
                        context: context,
                        onPressed: canManualSync && !_isManualSyncing
                            ? () => _handleSyncNow(context)
                            : null,
                        child: _isManualSyncing
                            ? SizedBox(
                                height: context.responsiveGapM,
                                width: context.responsiveGapM,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(context.l10n.syncStatusSyncNowButton),
                      ),
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
