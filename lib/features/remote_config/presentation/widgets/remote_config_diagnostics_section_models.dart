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
      if (s.isNotEmpty) {
        parts.add(context.l10n.settingsDiagnosticsDataSource(s));
      }
    }
    if (lastSyncedAt case final t?) {
      if (isPlausibleDiagnosticsSyncTime(t)) {
        final DateTime local = t.toLocal();
        final MaterialLocalizations material = MaterialLocalizations.of(
          context,
        );
        parts.add(
          context.l10n.settingsDiagnosticsLastSyncedAt(
            material.formatShortDate(local),
            material.formatTimeOfDay(TimeOfDay.fromDateTime(local)),
          ),
        );
      }
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
