import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

class CounterSyncBanner extends StatefulWidget {
  const CounterSyncBanner({required this.l10n, super.key});

  final AppLocalizations l10n;

  @override
  State<CounterSyncBanner> createState() => _CounterSyncBannerState();
}

class _CounterSyncBannerState extends State<CounterSyncBanner> {
  final PendingSyncRepository _pendingRepository =
      getIt<PendingSyncRepository>();
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_refreshPendingCount());
  }

  Future<void> _refreshPendingCount() async {
    final int count = (await _pendingRepository.getPendingOperations(
      now: DateTime.now().toUtc(),
    )).length;
    if (!mounted) return;
    setState(() => _pendingCount = count);
  }

  @override
  Widget build(final BuildContext context) =>
      BlocConsumer<SyncStatusCubit, SyncStatusState>(
        listener: (final context, final state) =>
            unawaited(_refreshPendingCount()),
        builder: (final context, final state) {
          final bool isOffline = state.networkStatus == NetworkStatus.offline;
          final bool isSyncing = state.syncStatus == SyncStatus.syncing;
          final bool shouldHide =
              !isOffline && !isSyncing && _pendingCount == 0;
          if (shouldHide) {
            return const SizedBox.shrink();
          }
          final AppLocalizations l10n = widget.l10n;
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
}

class CounterSyncQueueInspectorButton extends StatelessWidget {
  const CounterSyncQueueInspectorButton({super.key});

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return Align(
      alignment: Alignment.centerRight,
      child: PlatformAdaptive.textButton(
        context: context,
        onPressed: () => _showInspector(context, l10n),
        child: Text(l10n.syncQueueInspectorButton),
      ),
    );
  }

  Future<void> _showInspector(
    final BuildContext context,
    final AppLocalizations l10n,
  ) async {
    final PendingSyncRepository repository = getIt<PendingSyncRepository>();
    final List<SyncOperation> operations = await repository
        .getPendingOperations(
          now: DateTime.now().toUtc(),
        );
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (final BuildContext sheetContext) => _SyncQueueInspectorSheet(
        operations: operations,
        l10n: l10n,
      ),
    );
  }
}

class _SyncQueueInspectorSheet extends StatelessWidget {
  const _SyncQueueInspectorSheet({
    required this.operations,
    required this.l10n,
  });

  final List<SyncOperation> operations;
  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) {
    if (operations.isEmpty) {
      return Padding(
        padding: context.pagePadding,
        child: AppMessage(message: l10n.syncQueueInspectorEmpty),
      );
    }
    return SafeArea(
      child: Padding(
        padding: context.pagePadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.syncQueueInspectorTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: context.responsiveGapM),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (final BuildContext itemContext, final int index) {
                  final SyncOperation operation = operations[index];
                  final String subtitle = l10n.syncQueueInspectorOperation(
                    operation.entityType,
                    operation.retryCount,
                  );
                  return ListTile(
                    dense: true,
                    title: Text(operation.id),
                    subtitle: Text(subtitle),
                  );
                },
                separatorBuilder:
                    (
                      final BuildContext itemContext,
                      final int _,
                    ) => SizedBox(height: context.responsiveGapS),
                itemCount: operations.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
