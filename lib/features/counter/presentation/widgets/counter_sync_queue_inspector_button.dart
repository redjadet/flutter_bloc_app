import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_repository.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_sync_queue_entry.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_context_extensions.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

/// Dev/QA control to inspect counter pending-sync queue entries.
///
/// When [repository] is set (e.g. Settings QA extras), pending counts are read
/// from the repository directly. Otherwise the widget expects [CounterCubit] in
/// the tree (counter page).
class CounterSyncQueueInspectorButton extends StatefulWidget {
  const CounterSyncQueueInspectorButton({
    this.repository,
    this.onPendingSyncEnqueued,
    super.key,
  });

  final CounterRepository? repository;

  /// When set with [repository], refreshes pending count as soon as the shared
  /// queue enqueues (without waiting for [SyncStatusCubit] transitions).
  final Stream<void>? onPendingSyncEnqueued;

  @override
  State<CounterSyncQueueInspectorButton> createState() =>
      _CounterSyncQueueInspectorButtonState();
}

class _CounterSyncQueueInspectorButtonState
    extends State<CounterSyncQueueInspectorButton> {
  int? _repositoryPendingCount;
  StreamSubscription<void>? _pendingEnqueueSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.repository != null) {
      unawaited(_refreshRepositoryPendingCount());
      _subscribePendingEnqueueStream();
    }
  }

  @override
  void didUpdateWidget(final CounterSyncQueueInspectorButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.repository != null &&
        widget.repository != oldWidget.repository) {
      unawaited(_refreshRepositoryPendingCount());
    }
    if (widget.onPendingSyncEnqueued != oldWidget.onPendingSyncEnqueued) {
      unawaited(_pendingEnqueueSubscription?.cancel());
      _pendingEnqueueSubscription = null;
      _subscribePendingEnqueueStream();
    }
  }

  @override
  void dispose() {
    unawaited(_pendingEnqueueSubscription?.cancel());
    super.dispose();
  }

  void _subscribePendingEnqueueStream() {
    final Stream<void>? stream = widget.onPendingSyncEnqueued;
    if (widget.repository == null || stream == null) {
      return;
    }
    _pendingEnqueueSubscription = stream.listen(
      (_) {
        unawaited(_refreshRepositoryPendingCount());
      },
      onError: (final Object error, final StackTrace stackTrace) {
        AppLogger.error(
          'CounterSyncQueueInspectorButton enqueue stream error',
          error,
          stackTrace,
        );
      },
    );
  }

  Future<void> _refreshRepositoryPendingCount() async {
    final CounterRepository? repository = widget.repository;
    if (repository == null) {
      return;
    }
    final int count = await repository.pendingSyncOperationCount();
    if (!mounted) {
      return;
    }
    setState(() => _repositoryPendingCount = count);
  }

  @override
  Widget build(final BuildContext context) {
    context.ensureSyncStartedIfAvailable();

    final Widget child = widget.repository != null
        ? _buildRepositoryBacked(context)
        : _buildCubitBacked(context);

    if (!CubitHelpers.isCubitAvailable<SyncStatusCubit, SyncStatusState>(
      context,
    )) {
      return child;
    }

    return TypeSafeBlocListener<SyncStatusCubit, SyncStatusState>(
      listener: (final context, final state) {
        if (widget.repository != null) {
          // check-ignore: listener callback is event-driven, not a build side effect
          unawaited(_refreshRepositoryPendingCount());
          return;
        }
        if (!CubitHelpers.isCubitAvailable<CounterCubit, CounterState>(
          context,
        )) {
          return;
        }
        // check-ignore: listener callback is event-driven, not a build side effect
        unawaited(context.cubit<CounterCubit>().refreshPendingSyncCount());
      },
      child: child,
    );
  }

  Widget _buildRepositoryBacked(final BuildContext context) {
    final int pendingCount = _repositoryPendingCount ?? 0;
    if (_repositoryPendingCount == null || pendingCount == 0) {
      return const SizedBox.shrink();
    }
    return _inspectorButton(context);
  }

  Widget _buildCubitBacked(final BuildContext context) {
    if (!CubitHelpers.isCubitAvailable<CounterCubit, CounterState>(context)) {
      return const SizedBox.shrink();
    }

    return TypeSafeBlocBuilder<CounterCubit, CounterState>(
      builder: (final context, final counterState) {
        if (counterState.pendingSyncCount == 0) {
          return const SizedBox.shrink();
        }
        return _inspectorButton(context);
      },
    );
  }

  Widget _inspectorButton(final BuildContext context) => Align(
    alignment: AlignmentDirectional.centerEnd,
    child: Semantics(
      button: true,
      label: context.l10n.syncQueueInspectorButton,
      child: PlatformAdaptive.textButton(
        context: context,
        onPressed: () => _showInspector(context, context.l10n),
        child: Text(context.l10n.syncQueueInspectorButton),
      ),
    ),
  );

  Future<void> _showInspector(
    final BuildContext context,
    final AppLocalizations l10n,
  ) async {
    final List<CounterSyncQueueEntry> entries;
    if (widget.repository case final CounterRepository repository) {
      entries = await repository.pendingSyncQueueEntries();
    } else {
      entries = await context.cubit<CounterCubit>().pendingSyncQueueEntries();
    }
    if (!context.mounted) {
      return;
    }
    await PlatformAdaptive.showAdaptiveModalBottomSheet<void>(
      context: context,
      builder: (final sheetContext) => _SyncQueueInspectorSheet(
        entries: entries,
        l10n: l10n,
      ),
    );
  }
}

class _SyncQueueInspectorSheet extends StatelessWidget {
  const _SyncQueueInspectorSheet({
    required this.entries,
    required this.l10n,
  });

  final List<CounterSyncQueueEntry> entries;
  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) {
    if (entries.isEmpty) {
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
                itemBuilder: (final itemContext, final index) {
                  final CounterSyncQueueEntry entry = entries[index];
                  final String subtitle = l10n.syncQueueInspectorOperation(
                    entry.entityType,
                    entry.retryCount,
                  );
                  return KeyedSubtree(
                    key: ValueKey<String>('sync-op-${entry.id}'),
                    child: PlatformAdaptive.listTile(
                      context: itemContext,
                      title: Text(entry.id),
                      subtitle: Text(subtitle),
                    ),
                  );
                },
                separatorBuilder:
                    (
                      final itemContext,
                      final _,
                    ) => SizedBox(height: context.responsiveGapS),
                itemCount: entries.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
