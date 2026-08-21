import 'dart:async';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/app/sync/sync_banner_helpers.dart';
import 'package:flutter_bloc_app/app/sync/sync_context_extensions.dart';
import 'package:flutter_bloc_app/app/utils/bloc/cubit_helpers.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_sync_diagnostics_port.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_sync_queue_entry.dart';
import 'package:flutter_bloc_app/features/counter/presentation/cubit/counter_cubit.dart';
import 'package:flutter_bloc_app/features/counter/presentation/widgets/counter_sync_queue_inspector_sheet.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Dev/QA control to inspect counter pending-sync queue entries.
///
/// When [repository] is set (e.g. Settings QA extras), pending counts are read
/// from the sync-diagnostics port directly. Otherwise the widget expects
/// [CounterCubit] in the tree (counter page).
class CounterSyncQueueInspectorButton extends StatefulWidget {
  const CounterSyncQueueInspectorButton({
    this.repository,
    this.onPendingSyncEnqueued,
    super.key,
  });

  final CounterSyncDiagnosticsPort? repository;

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
  bool _didEnsureSyncStarted = false;

  @override
  void initState() {
    super.initState();
    if (widget.repository != null) {
      unawaited(_refreshRepositoryPendingCount());
      _subscribePendingEnqueueStream();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!kShowPendingSyncQueueUi) return;
    if (_didEnsureSyncStarted) return;
    _didEnsureSyncStarted = true;
    context.ensureSyncStartedIfAvailable();
  }

  @override
  void didUpdateWidget(CounterSyncQueueInspectorButton oldWidget) {
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
      onError: (Object error, StackTrace stackTrace) {
        AppLogger.error(
          'CounterSyncQueueInspectorButton enqueue stream error',
          error,
          stackTrace,
        );
      },
    );
  }

  Future<void> _refreshRepositoryPendingCount() async {
    final CounterSyncDiagnosticsPort? repository = widget.repository;
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
  Widget build(BuildContext context) {
    if (!kShowPendingSyncQueueUi) {
      return const SizedBox.shrink();
    }

    final Widget child = widget.repository != null
        ? _buildRepositoryBacked(context)
        : _buildCubitBacked(context);

    if (!CubitHelpers.isCubitAvailable<SyncStatusCubit, SyncStatusState>(
      context,
    )) {
      return child;
    }

    return TypeSafeBlocListener<SyncStatusCubit, SyncStatusState>(
      listener: (context, state) {
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

  Widget _buildRepositoryBacked(BuildContext context) {
    final int pendingCount = _repositoryPendingCount ?? 0;
    if (_repositoryPendingCount == null || pendingCount == 0) {
      return const SizedBox.shrink();
    }
    return _inspectorButton(context);
  }

  Widget _buildCubitBacked(BuildContext context) {
    if (!CubitHelpers.isCubitAvailable<CounterCubit, CounterState>(context)) {
      return const SizedBox.shrink();
    }

    return TypeSafeBlocBuilder<CounterCubit, CounterState>(
      builder: (context, counterState) {
        if (counterState.pendingSyncCount == 0) {
          return const SizedBox.shrink();
        }
        return _inspectorButton(context);
      },
    );
  }

  Widget _inspectorButton(BuildContext context) => Align(
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
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final List<CounterSyncQueueEntry> entries;
    if (widget.repository case final CounterSyncDiagnosticsPort repository) {
      entries = await repository.pendingSyncQueueEntries();
    } else {
      entries = await context.cubit<CounterCubit>().pendingSyncQueueEntries();
    }
    if (!context.mounted) {
      return;
    }
    // modal_bloc_provider:ignore sheet is data-only; queue entries passed in.
    await PlatformAdaptive.showAdaptiveModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => CounterSyncQueueInspectorSheet(
        entries: entries,
        l10n: l10n,
      ),
    );
  }
}
