import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_context_extensions.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

class CounterSyncQueueInspectorButton extends StatefulWidget {
  const CounterSyncQueueInspectorButton({
    required this.pendingRepository,
    super.key,
  });

  final PendingSyncRepository pendingRepository;

  @override
  State<CounterSyncQueueInspectorButton> createState() =>
      _CounterSyncQueueInspectorButtonState();
}

class _CounterSyncQueueInspectorButtonState
    extends State<CounterSyncQueueInspectorButton> {
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    context.ensureSyncStartedIfAvailable();
    unawaited(_refreshPendingCount());
  }

  Future<void> _refreshPendingCount() async {
    final int count = (await widget.pendingRepository.getPendingOperations(
      now: DateTime.now().toUtc(),
    )).length;
    if (!mounted) return;
    setState(() => _pendingCount = count);
  }

  @override
  Widget build(final BuildContext context) {
    SyncStatusCubit? syncCubit;
    if (CubitHelpers.isCubitAvailable<SyncStatusCubit, SyncStatusState>(
      context,
    )) {
      syncCubit = context.cubit<SyncStatusCubit>();
    } else {
      syncCubit = null;
    }

    final Widget child = _pendingCount == 0
        ? const SizedBox.shrink()
        : Align(
            alignment: Alignment.centerRight,
            child: PlatformAdaptive.textButton(
              context: context,
              onPressed: () => _showInspector(context, context.l10n),
              child: Text(context.l10n.syncQueueInspectorButton),
            ),
          );

    if (syncCubit == null) {
      return child;
    }

    return TypeSafeBlocListener<SyncStatusCubit, SyncStatusState>(
      bloc: syncCubit,
      listener: (final context, final state) {
        // Refresh pending count when sync status changes
        // check-ignore: listener callback is event-driven, not a build side effect
        unawaited(_refreshPendingCount());
      },
      child: child,
    );
  }

  Future<void> _showInspector(
    final BuildContext context,
    final AppLocalizations l10n,
  ) async {
    final List<SyncOperation> operations = await widget.pendingRepository
        .getPendingOperations(
          now: DateTime.now().toUtc(),
        );
    if (!context.mounted) return;
    await PlatformAdaptive.showAdaptiveModalBottomSheet<void>(
      context: context,
      builder: (final sheetContext) => _SyncQueueInspectorSheet(
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
                itemBuilder: (final itemContext, final index) {
                  final SyncOperation operation = operations[index];
                  final String subtitle = l10n.syncQueueInspectorOperation(
                    operation.entityType,
                    operation.retryCount,
                  );
                  return PlatformAdaptive.listTile(
                    context: itemContext,
                    title: Text(operation.id),
                    subtitle: Text(subtitle),
                  );
                },
                separatorBuilder:
                    (
                      final itemContext,
                      final _,
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
