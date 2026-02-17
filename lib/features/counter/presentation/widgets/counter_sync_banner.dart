import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/counter/domain/counter_domain.dart';
import 'package:flutter_bloc_app/features/counter/presentation/counter_cubit.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_banner_helpers.dart';
import 'package:flutter_bloc_app/shared/sync/sync_context_extensions.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';

class CounterSyncBanner extends StatefulWidget {
  const CounterSyncBanner({
    required this.l10n,
    required this.pendingRepository,
    required this.counterRepository,
    super.key,
  });

  final AppLocalizations l10n;
  final PendingSyncRepository pendingRepository;
  final CounterRepository counterRepository;

  @override
  State<CounterSyncBanner> createState() => _CounterSyncBannerState();
}

class _CounterSyncBannerState extends State<CounterSyncBanner> {
  int _pendingCount = 0;
  DateTime? _lastSyncedAt;
  String? _lastChangeId;
  StreamSubscription<CounterSnapshot>? _counterSubscription;

  @override
  void initState() {
    super.initState();
    context.ensureSyncStartedIfAvailable();
    try {
      final CounterCubit cubit = context.cubit<CounterCubit>();
      _lastSyncedAt = cubit.state.lastSyncedAt;
      _lastChangeId = cubit.state.changeId;
    } on Object {
      // CounterCubit not available; rely on repository stream below.
    }
    unawaited(_refreshPendingCount());
    // Listen to counter snapshot changes for real-time lastSyncedAt/changeId updates
    _counterSubscription = widget.counterRepository.watch().listen(
      (final snapshot) {
        if (!mounted) return;
        setState(() {
          _lastSyncedAt = snapshot.lastSyncedAt;
          _lastChangeId = snapshot.changeId;
        });
      },
    );
  }

  @override
  void dispose() {
    unawaited(_counterSubscription?.cancel());
    super.dispose();
  }

  Future<void> _refreshPendingCount() async {
    final int count = (await widget.pendingRepository.getPendingOperations(
      now: DateTime.now().toUtc(),
    )).length;
    if (!mounted) return;
    setState(() => _pendingCount = count);
  }

  @override
  Widget build(
    final BuildContext context,
  ) {
    final Widget banner = BlocConsumer<SyncStatusCubit, SyncStatusState>(
      listener: (final context, final state) {
        // Refresh pending count when sync status changes (operations may have been processed)
        // check-ignore: listener callback is event-driven, not a build side effect
        unawaited(_refreshPendingCount());
      },
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
        final (String title, String message) = syncBannerTitleAndMessage(
          l10n,
          isOffline: isOffline,
          isSyncing: isSyncing,
          pendingCount: _pendingCount,
        );
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

    CounterCubit? counterCubit;
    if (CubitHelpers.isCubitAvailable<CounterCubit, CounterState>(
      context,
    )) {
      counterCubit = context.cubit<CounterCubit>();
    } else {
      counterCubit = null;
    }

    if (counterCubit == null) {
      return banner;
    }

    return BlocListener<CounterCubit, CounterState>(
      bloc: counterCubit,
      listenWhen: (final previous, final current) =>
          previous.count != current.count,
      listener: (final context, final state) {
        // check-ignore: listener callback is event-driven, not a build side effect
        unawaited(_refreshPendingCount());
      },
      child: banner,
    );
  }

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
