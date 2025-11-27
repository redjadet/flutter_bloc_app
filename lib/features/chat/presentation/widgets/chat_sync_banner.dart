import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_sync_constants.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

class ChatSyncBanner extends StatefulWidget {
  const ChatSyncBanner({super.key});

  @override
  State<ChatSyncBanner> createState() => _ChatSyncBannerState();
}

class _ChatSyncBannerState extends State<ChatSyncBanner> {
  final PendingSyncRepository _pendingRepository =
      getIt<PendingSyncRepository>();
  int _pendingCount = 0;
  bool _isManualSyncing = false;
  late final SyncStatusCubit _syncCubit;

  @override
  void initState() {
    super.initState();
    _syncCubit = context.read<SyncStatusCubit>();
    unawaited(_refreshPendingCount());
  }

  Future<void> _refreshPendingCount() async {
    try {
      final List<SyncOperation> operations = await _pendingRepository
          .getPendingOperations(
            now: DateTime.now().toUtc(),
          );

      final int chatPending = operations
          .where(
            (final SyncOperation op) => op.entityType == chatSyncEntityType,
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

  Future<void> _handleSyncNow() async {
    if (_isManualSyncing) {
      return;
    }
    setState(() => _isManualSyncing = true);
    try {
      await _syncCubit.flush();
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
  Widget build(final BuildContext context) =>
      BlocListener<SyncStatusCubit, SyncStatusState>(
        listener: (context, state) => unawaited(_refreshPendingCount()),
        child: BlocBuilder<SyncStatusCubit, SyncStatusState>(
          builder: (final context, final syncState) {
            final bool isOffline =
                syncState.networkStatus == NetworkStatus.offline;
            final bool isSyncing = syncState.syncStatus == SyncStatus.syncing;
            final bool showBanner = isOffline || isSyncing || _pendingCount > 0;
            if (!showBanner) {
              return const SizedBox.shrink();
            }
            final AppLocalizations l10n = context.l10n;
            final bool isError = isOffline;
            final String title;
            final String message;
            if (isOffline) {
              title = l10n.syncStatusOfflineTitle;
              message = l10n.syncStatusOfflineMessage(_pendingCount);
            } else if (isSyncing) {
              title = l10n.syncStatusSyncingTitle;
              message = l10n.syncStatusSyncingMessage(_pendingCount);
            } else {
              title = l10n.syncStatusPendingTitle;
              message = l10n.syncStatusPendingMessage(_pendingCount);
            }
            final bool canManualSync =
                !isOffline && _pendingCount > 0 && !isSyncing;
            final bool showSyncAction = _pendingCount > 0;

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
                  if (showSyncAction)
                    Align(
                      alignment: Alignment.centerRight,
                      child: PlatformAdaptive.textButton(
                        context: context,
                        onPressed: canManualSync && !_isManualSyncing
                            ? _handleSyncNow
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
        ),
      );
}
