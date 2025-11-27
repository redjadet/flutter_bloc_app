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

enum _RemoteConfigStatus { idle, loading, loaded, error }

class _RemoteConfigViewData extends Equatable {
  const _RemoteConfigViewData({
    required this.status,
    this.errorMessage,
    this.isAwesomeFeatureEnabled = false,
    this.testValue,
    this.dataSource,
    this.lastSyncedAt,
  });

  factory _RemoteConfigViewData.fromState(final RemoteConfigState state) {
    if (state is RemoteConfigLoading) {
      return const _RemoteConfigViewData(status: _RemoteConfigStatus.loading);
    }
    if (state is RemoteConfigLoaded) {
      return _RemoteConfigViewData(
        status: _RemoteConfigStatus.loaded,
        isAwesomeFeatureEnabled: state.isAwesomeFeatureEnabled,
        testValue: state.testValue,
        dataSource: state.dataSource,
        lastSyncedAt: state.lastSyncedAt,
      );
    }
    if (state is RemoteConfigError) {
      return _RemoteConfigViewData(
        status: _RemoteConfigStatus.error,
        errorMessage: state.message,
      );
    }
    return const _RemoteConfigViewData(status: _RemoteConfigStatus.idle);
  }

  final _RemoteConfigStatus status;
  final String? errorMessage;
  final bool isAwesomeFeatureEnabled;
  final String? testValue;
  final String? dataSource;
  final DateTime? lastSyncedAt;

  bool get showFlagStatus => status == _RemoteConfigStatus.loaded;
  bool get showTestValue => status == _RemoteConfigStatus.loaded;
  bool get isLoading => status == _RemoteConfigStatus.loading;
  bool get showMetadata => dataSource != null || lastSyncedAt != null;

  @override
  List<Object?> get props => <Object?>[
    status,
    errorMessage,
    isAwesomeFeatureEnabled,
    testValue,
    dataSource,
    lastSyncedAt,
  ];
}

class _RemoteConfigSyncStatusBanner extends StatelessWidget {
  const _RemoteConfigSyncStatusBanner({required this.gap});

  final double gap;

  @override
  Widget build(final BuildContext context) =>
      BlocBuilder<SyncStatusCubit, SyncStatusState>(
        builder: (final context, final syncState) {
          final bool isOffline =
              syncState.networkStatus == NetworkStatus.offline;
          final bool isSyncing = syncState.syncStatus == SyncStatus.syncing;
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
    if (dataSource != null && dataSource!.isNotEmpty) {
      parts.add('Source: $dataSource');
    }
    if (lastSyncedAt != null) {
      final DateTime local = lastSyncedAt!.toLocal();
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
