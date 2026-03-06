part of 'remote_config_diagnostics_section.dart';

class _StatusPalette {
  const _StatusPalette({
    required this.background,
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color background;
  final Color color;
  final IconData icon;
  final String label;
}

class _RemoteConfigSyncStatusBanner extends StatelessWidget {
  const _RemoteConfigSyncStatusBanner({required this.gap});

  final double gap;

  @override
  Widget build(final BuildContext context) =>
      TypeSafeBlocSelector<
        SyncStatusCubit,
        SyncStatusState,
        (NetworkStatus, SyncStatus)
      >(
        selector: (final s) => (s.networkStatus, s.syncStatus),
        builder: (final context, final pair) {
          final bool isOffline = pair.$1 == NetworkStatus.offline;
          final bool isSyncing = pair.$2 == SyncStatus.syncing;
          if (!isOffline && !isSyncing) {
            return const SizedBox.shrink();
          }
          final l10n = context.l10n;
          final String title = isOffline
              ? l10n.syncStatusOfflineTitle
              : l10n.syncStatusSyncingTitle;
          final String message = isOffline
              ? l10n.syncStatusOfflineMessage(0)
              : l10n.syncStatusSyncingMessage(0);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AppMessage(
                title: title,
                message: message,
                isError: isOffline,
              ),
              SizedBox(height: gap),
            ],
          );
        },
      );
}

class _RemoteConfigMetadataRow extends StatelessWidget {
  const _RemoteConfigMetadataRow({
    this.dataSource,
    this.lastSyncedAt,
  });

  final String? dataSource;
  final DateTime? lastSyncedAt;

  @override
  Widget build(final BuildContext context) {
    final List<String> parts = <String>[];
    if (dataSource case final s?) {
      if (s.isNotEmpty) parts.add('Source: $s');
    }
    if (lastSyncedAt case final t?) {
      final DateTime local = t.toLocal();
      final MaterialLocalizations material = MaterialLocalizations.of(context);
      parts.add(
        'Last synced: ${material.formatShortDate(local)} ${material.formatTimeOfDay(TimeOfDay.fromDateTime(local))}',
      );
    }
    if (parts.isEmpty) {
      return const SizedBox.shrink();
    }
    return Text(
      parts.join(' · '),
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
