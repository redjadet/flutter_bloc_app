import 'package:design_system/design_system.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_freshness.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_snapshot.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_showcase_telemetry_status.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_platform_showcase_cubit.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/cubit/native_platform_showcase_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:ilkersevim_type_safe_bloc/ilkersevim_type_safe_bloc.dart';
import 'package:material_ui/material_ui.dart';

class NativePlatformShowcaseTelemetrySection extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return TypeSafeBlocSelector<
      NativePlatformShowcaseCubit,
      NativePlatformShowcaseState,
      (NativeShowcaseTelemetrySnapshot?, NativeShowcaseTelemetryFreshness?)
    >(
      selector: (state) {
        final loaded = state.mapOrNull(loaded: (value) => value);
        return (loaded?.telemetry, loaded?.telemetryFreshness);
      },
      builder: (context, view) {
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
                _TelemetryBody(
                  telemetry: view.$1,
                  freshness: view.$2,
                  l10n: l10n,
                  theme: theme,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TelemetryBody extends StatelessWidget {
  const new({
    required this.telemetry,
    required this.freshness,
    required this.l10n,
    required this.theme,
  });

  final NativeShowcaseTelemetrySnapshot? telemetry;
  final NativeShowcaseTelemetryFreshness? freshness;
  final AppLocalizations l10n;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final NativeShowcaseTelemetrySnapshot? snapshot = telemetry;
    final NativeShowcaseTelemetryFreshness? freshnessInfo = freshness;
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
            value: '${snapshot.acceptedCount}',
          ),
          _MetricRow(
            label: l10n.nativePlatformShowcaseTelemetryDroppedCountLabel,
            value: '${snapshot.droppedBeforeBridgeCount}',
          ),
          _MetricRow(
            label: l10n.nativePlatformShowcaseTelemetryAverageValueLabel,
            value: snapshot.averageValue.toStringAsFixed(2),
          ),
          if (freshnessInfo != null) ...<Widget>[
            _MetricRow(
              label: l10n.nativePlatformShowcaseTelemetryValueAgeLabel,
              value: l10n.nativePlatformShowcaseTelemetryAgeValue(
                freshnessInfo.valueAge.inMilliseconds,
              ),
            ),
            _MetricRow(
              label: l10n.nativePlatformShowcaseTelemetryReceiptAgeLabel,
              value: l10n.nativePlatformShowcaseTelemetryAgeValue(
                freshnessInfo.receiptAge.inMilliseconds,
              ),
            ),
            Text(
              key: ValueKey<String>(
                freshnessInfo.isValueStale
                    ? 'native-platform-showcase-telemetry-stale'
                    : 'native-platform-showcase-telemetry-fresh',
              ),
              freshnessInfo.isValueStale
                  ? l10n.nativePlatformShowcaseTelemetryValueStale
                  : l10n.nativePlatformShowcaseTelemetryValueFresh,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: freshnessInfo.isValueStale
                    ? theme.colorScheme.error
                    : null,
              ),
            ),
            Text(
              key: ValueKey<String>(
                freshnessInfo.isSourceLive
                    ? 'native-platform-showcase-telemetry-source-live'
                    : 'native-platform-showcase-telemetry-source-quiet',
              ),
              freshnessInfo.isSourceLive
                  ? l10n.nativePlatformShowcaseTelemetrySourceLive
                  : l10n.nativePlatformShowcaseTelemetrySourceQuiet,
              style: theme.textTheme.bodyMedium,
            ),
          ],
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
  const new({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
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
