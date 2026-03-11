import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_sync_constants.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_banner_helpers.dart';
import 'package:flutter_bloc_app/shared/sync/sync_context_extensions.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

class ChatSyncBanner extends StatefulWidget {
  const ChatSyncBanner({
    required this.pendingRepository,
    super.key,
  });

  final PendingSyncRepository pendingRepository;

  @override
  State<ChatSyncBanner> createState() => _ChatSyncBannerState();
}

class _ChatSyncBannerState extends State<ChatSyncBanner> {
  int _pendingCount = 0;
  bool _isManualSyncing = false;
  bool _didEnsureSyncStarted = false;

  @override
  void initState() {
    super.initState();
    unawaited(_refreshPendingCount());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didEnsureSyncStarted) {
      return;
    }
    _didEnsureSyncStarted = true;
    context.ensureSyncStartedIfAvailable();
  }

  Future<void> _refreshPendingCount() async {
    try {
      final List<SyncOperation> operations = await widget.pendingRepository
          .getPendingOperations(
            now: DateTime.now().toUtc(),
          );

      final int chatPending = operations
          .where(
            (final op) => op.entityType == chatSyncEntityType,
          )
          .length;
      if (!mounted) return;
      setState(() => _pendingCount = chatPending);
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'ChatSyncBanner.refreshPendingCount failed',
        error,
        stackTrace,
      );
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
  Widget build(
    final BuildContext context,
  ) {
    if (!CubitHelpers.isCubitAvailable<SyncStatusCubit, SyncStatusState>(
      context,
    )) {
      return const SizedBox.shrink();
    }
    return TypeSafeBlocListener<SyncStatusCubit, SyncStatusState>(
      listener: (final context, final state) {
        // check-ignore: listener callback is event-driven, not a build side effect
        unawaited(_refreshPendingCount());
      },
      child:
          TypeSafeBlocSelector<
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
                pendingCount: _pendingCount,
              )) {
                return const SizedBox.shrink();
              }
              final AppLocalizations l10n = context.l10n;
              final (String title, String message) = syncBannerTitleAndMessage(
                l10n,
                isOffline: isOffline,
                isSyncing: isSyncing,
                pendingCount: _pendingCount,
              );
              final bool canManualSync =
                  !isOffline && _pendingCount > 0 && !isSyncing;
              final Widget? trailing = _pendingCount > 0
                  ? Align(
                      alignment: Alignment.centerRight,
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
                            : Text(l10n.syncStatusSyncNowButton),
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
          ),
    );
  }
}
