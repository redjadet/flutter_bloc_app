part of 'remote_config_diagnostics_section.dart';

class _RemoteConfigFlagRow extends StatelessWidget {
  const _RemoteConfigFlagRow({required this.isEnabled});

  final bool isEnabled;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? style = theme.textTheme.bodyMedium;
    final String label = isEnabled
        ? context.l10n.settingsRemoteConfigFlagEnabled
        : context.l10n.settingsRemoteConfigFlagDisabled;

    return Text(
      '${context.l10n.settingsRemoteConfigFlagLabel}: $label',
      style: style,
    );
  }
}

class _RemoteConfigTestValueRow extends StatelessWidget {
  const _RemoteConfigTestValueRow({required this.testValue});

  final String testValue;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? style = theme.textTheme.bodyMedium;
    final String resolvedValue = testValue.trim().isEmpty
        ? context.l10n.settingsRemoteConfigTestValueEmpty
        : testValue;

    return Text(
      '${context.l10n.settingsRemoteConfigTestValueLabel}: $resolvedValue',
      style: style,
    );
  }
}

class _RemoteConfigStatusBadge extends StatelessWidget {
  const _RemoteConfigStatusBadge({
    required this.status,
    required this.theme,
  });

  final RemoteConfigViewStatus status;
  final ThemeData theme;

  @override
  Widget build(final BuildContext context) {
    final ColorScheme scheme = theme.colorScheme;
    final _StatusPalette palette = switch (status) {
      RemoteConfigViewStatus.loading => _StatusPalette(
        background: scheme.surfaceContainerHigh,
        color: scheme.onSurface,
        icon: Icons.sync,
        label: context.l10n.settingsRemoteConfigStatusLoading,
      ),
      RemoteConfigViewStatus.loaded => _StatusPalette(
        background: scheme.surfaceContainerHighest,
        color: scheme.primary,
        icon: Icons.check_circle,
        label: context.l10n.settingsRemoteConfigStatusLoaded,
      ),
      RemoteConfigViewStatus.error => _StatusPalette(
        background: scheme.errorContainer,
        color: scheme.onErrorContainer,
        icon: Icons.error_outline,
        label: context.l10n.settingsRemoteConfigStatusError,
      ),
      RemoteConfigViewStatus.idle => _StatusPalette(
        background: scheme.surfaceContainerLow,
        color: scheme.onSurfaceVariant,
        icon: Icons.hourglass_empty,
        label: context.l10n.settingsRemoteConfigStatusIdle,
      ),
    };

    return CommonCard(
      color: palette.background,
      elevation: 0,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveGapM,
        vertical: context.responsiveGapS,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            palette.icon,
            color: palette.color,
            size: context.responsiveIconSize,
          ),
          SizedBox(width: context.responsiveGapS),
          Flexible(
            child: Text(
              palette.label,
              style: theme.textTheme.bodyMedium?.copyWith(color: palette.color),
            ),
          ),
        ],
      ),
    );
  }
}
