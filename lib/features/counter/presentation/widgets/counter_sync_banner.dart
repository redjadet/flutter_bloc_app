import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/core.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_domain.dart';
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
  DateTime? _lastSyncedAt;
  String? _lastChangeId;

  @override
  void initState() {
    super.initState();
    unawaited(_refreshSyncDetails());
  }

  Future<void> _refreshSyncDetails() async {
    final int count = (await _pendingRepository.getPendingOperations(
      now: DateTime.now().toUtc(),
    )).length;
    final CounterRepository counterRepository = getIt<CounterRepository>();
    final CounterSnapshot snapshot = await counterRepository.load();
    if (!mounted) return;
    setState(() => _pendingCount = count);
    setState(() {
      _lastSyncedAt = snapshot.lastSyncedAt;
      _lastChangeId = snapshot.changeId;
    });
  }

  @override
  Widget build(final BuildContext context) =>
      BlocConsumer<SyncStatusCubit, SyncStatusState>(
        listener: (final context, final state) =>
            unawaited(_refreshSyncDetails()),
        builder: (final context, final state) {
          final bool isOffline = state.networkStatus == NetworkStatus.offline;
          final bool isSyncing = state.syncStatus == SyncStatus.syncing;
          final bool hasMetadata =
              (_lastSyncedAt != null) || (_lastChangeId?.isNotEmpty ?? false);
          final bool shouldHide =
              !isOffline && !isSyncing && _pendingCount == 0 && !hasMetadata;
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
          final MaterialLocalizations materialLocalizations =
              MaterialLocalizations.of(context);
          final String? lastSyncedText = _lastSyncedAt != null
              ? _formatLastSynced(materialLocalizations, _lastSyncedAt!)
              : null;
          final String? changeIdText =
              _lastChangeId != null && _lastChangeId!.isNotEmpty
              ? l10n.counterChangeId(_lastChangeId!)
              : null;

          return Padding(
            padding: EdgeInsets.only(bottom: context.responsiveGapS),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AppMessage(
                  title: title,
                  message: message,
                  isError: isError,
                ),
                if (lastSyncedText != null || changeIdText != null) ...[
                  SizedBox(height: context.responsiveGapXS),
                  if (lastSyncedText != null)
                    Text(
                      l10n.counterLastSynced(lastSyncedText),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  if (changeIdText != null)
                    Text(
                      changeIdText,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ],
            ),
          );
        },
      );

  String _formatLastSynced(
    final MaterialLocalizations localizations,
    final DateTime timestamp,
  ) {
    final DateTime local = timestamp.toLocal();
    final String date = localizations.formatShortDate(local);
    final String time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(local),
    );
    return '$date · $time';
  }
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
