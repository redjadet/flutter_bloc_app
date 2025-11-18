import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/remote_config/presentation/cubit/remote_config_cubit.dart';
import 'package:flutter_bloc_app/features/settings/presentation/widgets/settings_section.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_helpers.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

part 'remote_config_diagnostics_section_models.dart';

class RemoteConfigDiagnosticsSection extends StatelessWidget {
  const RemoteConfigDiagnosticsSection({super.key});

  @override
  Widget build(final BuildContext context) {
    if (!CubitHelpers.isCubitAvailable<RemoteConfigCubit, RemoteConfigState>(
      context,
    )) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);
    final double gap = context.responsiveGapS;

    return SettingsSection(
      title: context.l10n.settingsRemoteConfigSectionTitle,
      child: Card(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsiveCardPadding,
            vertical: context.responsiveGapM,
          ),
          child:
              BlocSelector<
                RemoteConfigCubit,
                RemoteConfigState,
                _RemoteConfigViewData
              >(
                selector: _RemoteConfigViewData.fromState,
                builder: (final context, final data) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _RemoteConfigStatusBadge(
                      status: data.status,
                      theme: theme,
                    ),
                    if (data.showFlagStatus) ...<Widget>[
                      SizedBox(height: gap),
                      _RemoteConfigFlagRow(
                        isEnabled: data.isAwesomeFeatureEnabled,
                      ),
                    ],
                    if (data.showTestValue) ...<Widget>[
                      SizedBox(height: gap),
                      _RemoteConfigTestValueRow(
                        testValue: data.testValue ?? '',
                      ),
                    ],
                    if (data.errorMessage != null &&
                        data.errorMessage!.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: gap),
                        child: Text(
                          '${context.l10n.settingsRemoteConfigErrorLabel}: '
                          '${data.errorMessage}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    SizedBox(height: context.responsiveGapM),
                    SizedBox(
                      width: double.infinity,
                      child: PlatformAdaptive.filledButton(
                        context: context,
                        onPressed: data.isLoading
                            ? null
                            : () => context
                                  .read<RemoteConfigCubit>()
                                  .fetchValues(),
                        child: Text(
                          context.l10n.settingsRemoteConfigRetryButton,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}

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

  final _RemoteConfigStatus status;
  final ThemeData theme;

  @override
  Widget build(final BuildContext context) {
    final ColorScheme scheme = theme.colorScheme;
    final _StatusPalette palette = switch (status) {
      _RemoteConfigStatus.loading => _StatusPalette(
        background: scheme.surfaceContainerHigh,
        color: scheme.onSurface,
        icon: Icons.sync,
        label: context.l10n.settingsRemoteConfigStatusLoading,
      ),
      _RemoteConfigStatus.loaded => _StatusPalette(
        background: scheme.surfaceContainerHighest,
        color: scheme.primary,
        icon: Icons.check_circle,
        label: context.l10n.settingsRemoteConfigStatusLoaded,
      ),
      _RemoteConfigStatus.error => _StatusPalette(
        background: scheme.errorContainer,
        color: scheme.onErrorContainer,
        icon: Icons.error_outline,
        label: context.l10n.settingsRemoteConfigStatusError,
      ),
      _RemoteConfigStatus.idle => _StatusPalette(
        background: scheme.surfaceContainerLow,
        color: scheme.onSurfaceVariant,
        icon: Icons.hourglass_empty,
        label: context.l10n.settingsRemoteConfigStatusIdle,
      ),
    };

    final double gap = context.responsiveGapS;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveGapM,
        vertical: context.responsiveGapS,
      ),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(context.responsiveBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            palette.icon,
            color: palette.color,
            size: context.responsiveIconSize,
          ),
          SizedBox(width: gap),
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
