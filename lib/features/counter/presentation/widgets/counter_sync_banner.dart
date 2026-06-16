import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/counter/presentation/cubit/counter_cubit.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_banner_helpers.dart';
import 'package:flutter_bloc_app/shared/sync/sync_context_extensions.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';

/// Sync status banner for the counter feature. Uses shared logic from
/// sync_banner_helpers (shouldShowSyncBanner, syncBannerTitleAndMessage).
class CounterSyncBanner extends StatelessWidget {
  const CounterSyncBanner({
    required this.l10n,
    super.key,
  });

  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) {
    if (!CubitHelpers.isCubitAvailable<SyncStatusCubit, SyncStatusState>(
      context,
    )) {
      return const SizedBox.shrink();
    }

    context.ensureSyncStartedIfAvailable();

    return TypeSafeBlocConsumer<SyncStatusCubit, SyncStatusState>(
      listener: (final context, final state) {
        if (!CubitHelpers.isCubitAvailable<CounterCubit, CounterState>(
          context,
        )) {
          return;
        }
        // check-ignore: listener callback is event-driven, not a build side effect
        unawaited(context.cubit<CounterCubit>().refreshPendingSyncCount());
      },
      builder: (final context, final syncState) {
        if (!CubitHelpers.isCubitAvailable<CounterCubit, CounterState>(
          context,
        )) {
          return const SizedBox.shrink();
        }

        return TypeSafeBlocBuilder<CounterCubit, CounterState>(
          builder: (final context, final counterState) {
            final bool isOffline =
                syncState.networkStatus == NetworkStatus.offline;
            final bool isSyncing = syncState.syncStatus == SyncStatus.syncing;
            final int pendingCount = counterState.pendingSyncCount;
            final DateTime? lastSyncedAt = counterState.lastSyncedAt;
            final String? lastChangeId = counterState.changeId;
            final bool hasMetadata =
                (lastSyncedAt != null) || (lastChangeId?.isNotEmpty ?? false);
            if (!shouldShowSyncBanner(
              isOffline: isOffline,
              isSyncing: isSyncing,
              pendingCount: pendingCount,
              hasMetadata: hasMetadata,
            )) {
              return const SizedBox.shrink();
            }
            final bool isError = isOffline;
            final (String title, String message) = syncBannerTitleAndMessage(
              l10n,
              isOffline: isOffline,
              isSyncing: isSyncing,
              pendingCount: pendingCount,
            );
            final MaterialLocalizations materialLocalizations =
                MaterialLocalizations.of(context);
            final String? lastSyncedText = switch (lastSyncedAt) {
              final t? => _formatLastSynced(materialLocalizations, t),
              _ => null,
            };
            final String? changeIdText = switch (lastChangeId) {
              final id? when id.isNotEmpty => l10n.counterChangeId(id),
              _ => null,
            };

            return Padding(
              padding: EdgeInsets.only(bottom: context.responsiveGapS),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (title.isNotEmpty || message.isNotEmpty)
                    AppMessage(
                      title: title,
                      message: message,
                      isError: isError,
                    ),
                  if (lastSyncedText case final synced?) ...[
                    SizedBox(height: context.responsiveGapXS),
                    Text(
                      l10n.counterLastSynced(synced),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (changeIdText case final changeId?)
                      Text(
                        changeId,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ] else if (changeIdText case final changeId?) ...[
                    SizedBox(height: context.responsiveGapXS),
                    Text(
                      changeId,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
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
