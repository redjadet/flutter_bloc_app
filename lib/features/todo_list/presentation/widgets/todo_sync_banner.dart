import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_banner_helpers.dart';
import 'package:flutter_bloc_app/shared/sync/sync_context_extensions.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';

class TodoSyncBanner extends StatefulWidget {
  const TodoSyncBanner({super.key});

  @override
  State<TodoSyncBanner> createState() => _TodoSyncBannerState();
}

class _TodoSyncBannerState extends State<TodoSyncBanner> {
  int _pendingCount = 0;
  static const String _todoEntityType = 'todo';

  @override
  void initState() {
    super.initState();
    context.ensureSyncStartedIfAvailable();
    unawaited(_refreshPendingCount());
  }

  Future<void> _refreshPendingCount() async {
    // check-ignore: direct_getit - sync status UI is debug/tooling
    final PendingSyncRepository pendingRepository =
        getIt<PendingSyncRepository>();
    final List<SyncOperation> pending = await pendingRepository
        .getPendingOperations(now: DateTime.now().toUtc());
    final int count = pending
        .where((final op) => op.entityType == _todoEntityType)
        .length;
    if (!mounted) return;
    setState(() => _pendingCount = count);
  }

  @override
  Widget build(final BuildContext context) {
    if (!CubitHelpers.isCubitAvailable<SyncStatusCubit, SyncStatusState>(
      context,
    )) {
      return const SizedBox.shrink();
    }
    final AppLocalizations l10n = context.l10n;
    final Widget
    banner = TypeSafeBlocConsumer<SyncStatusCubit, SyncStatusState>(
      listener: (final context, final state) {
        // Refresh pending count when sync status changes (operations may have been processed)
        // check-ignore: listener callback is event-driven, not a build side effect
        unawaited(_refreshPendingCount());
      },
      builder: (final context, final state) {
        final bool isOffline = state.networkStatus == NetworkStatus.offline;
        final bool isSyncing = state.syncStatus == SyncStatus.syncing;
        final bool shouldHide = !isOffline && !isSyncing && _pendingCount == 0;
        if (shouldHide) {
          return const SizedBox.shrink();
        }
        final bool isError = isOffline;
        final (String title, String message) = syncBannerTitleAndMessage(
          l10n,
          isOffline: isOffline,
          isSyncing: isSyncing,
          pendingCount: _pendingCount,
        );

        return Padding(
          padding: EdgeInsets.only(bottom: context.responsiveGapS),
          child: AppMessage(
            title: title,
            message: message,
            isError: isError,
          ),
        );
      },
    );

    return banner;
  }
}
