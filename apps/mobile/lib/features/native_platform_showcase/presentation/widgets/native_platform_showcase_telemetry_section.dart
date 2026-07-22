import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_snapshot.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_status.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_platform_showcase_cubit.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_platform_showcase_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';

class NativePlatformShowcaseTelemetrySection extends StatelessWidget {
  const NativePlatformShowcaseTelemetrySection({super.key});

  @override
  Widget build(final BuildContext context) {
    return TypeSafeBlocSelector<
      NativePlatformShowcaseCubit,
      NativePlatformShowcaseState,
      NativeShowcaseTelemetrySnapshot?
    >(
      selector: (final state) =>
          state.mapOrNull(loaded: (final loaded) => loaded.telemetry),
      builder: (final context, final telemetry) {
        final AppLocalizations l10n = AppLocalizations.of(context);
        final ThemeData theme = Theme.of(context);

        return KeyedSubtree(
          key: const ValueKey<String>('native-platform-showcase-telemetry'),
          child: CommonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  l10n.nativePlatformShowcaseTelemetryTitle,
                  style: theme.textTheme.titleMedium,
                ),
                SizedBox(height: context.responsiveGapS),
                Text(
                  l10n.nativePlatformShowcaseTelemetrySubtitle,
                  style: theme.textTheme.bodyMedium,
                ),
                SizedBox(height: context.responsiveGapM),
                _TelemetryBody(telemetry: telemetry, l10n: l10n, theme: theme),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TelemetryBody extends StatelessWidget {
  const _TelemetryBody({
    required this.telemetry,
    required this.l10n,
    required this.theme,
  });

  final NativeShowcaseTelemetrySnapshot? telemetry;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(final BuildContext context) {
    final NativeShowcaseTelemetrySnapshot? snapshot = telemetry;
    if (snapshot == null) {
      return Text(
        l10n.nativePlatformShowcaseTelemetryWaiting,
        style: theme.textTheme.bodyMedium,
      );
    }

    return switch (snapshot.status) {
      NativeShowcaseTelemetryStatus.unavailable => Text(
        l10n.nativePlatformShowcaseTelemetryUnavailable,
        style: theme.textTheme.bodyMedium,
      ),
      NativeShowcaseTelemetryStatus.streaming => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _MetricRow(
            label: l10n.nativePlatformShowcaseTelemetrySourceRateLabel,
            value: l10n.nativePlatformShowcaseTelemetryRateValue(
              snapshot.sourceRateHz,
            ),
          ),
          _MetricRow(
            label: l10n.nativePlatformShowcaseTelemetryDeliveredRateLabel,
            value: l10n.nativePlatformShowcaseTelemetryRateValue(
              snapshot.deliveredRateHz,
            ),
          ),
          _MetricRow(
            label: l10n.nativePlatformShowcaseTelemetrySampleCountLabel,
            value: '${snapshot.sampleCount}',
          ),
          _MetricRow(
            label: l10n.nativePlatformShowcaseTelemetryDroppedCountLabel,
            value: '${snapshot.droppedCount}',
          ),
          _MetricRow(
            label: l10n.nativePlatformShowcaseTelemetryAverageValueLabel,
            value: snapshot.averageValue.toStringAsFixed(2),
          ),
        ],
      ),
      NativeShowcaseTelemetryStatus.failed => Text(
        snapshot.message ?? l10n.nativePlatformShowcaseTelemetryFailed,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    };
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(final BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.responsiveGapXS),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
