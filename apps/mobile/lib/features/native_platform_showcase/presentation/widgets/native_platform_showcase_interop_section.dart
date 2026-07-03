import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_bridge_kind.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_call_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_interop_status.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/presentation/widgets/native_platform_showcase_adaptive.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';
import 'package:flutter_bloc_app/shared/widgets/common_card.dart';

class NativePlatformShowcaseInteropSection extends StatelessWidget {
  const NativePlatformShowcaseInteropSection({
    required this.results,
    super.key,
  });

  final List<NativeInteropCallResult> results;

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          l10n.nativePlatformShowcaseInteropTitle,
          style: theme.textTheme.titleMedium,
        ),
        SizedBox(height: context.responsiveGapS),
        Text(
          l10n.nativePlatformShowcaseInteropSubtitle,
          style: theme.textTheme.bodyMedium,
        ),
        SizedBox(height: context.responsiveGapM),
        ...results.map(
          (result) => KeyedSubtree(
            key: ValueKey<String>(
              'native-platform-showcase-interop-${result.kind.name}',
            ),
            child: Padding(
              padding: EdgeInsets.only(bottom: context.responsiveGapS),
              child: _InteropTile(result: result, l10n: l10n),
            ),
          ),
        ),
      ],
    );
  }
}

class _InteropTile extends StatelessWidget {
  const _InteropTile({
    required this.result,
    required this.l10n,
  });

  final NativeInteropCallResult result;
  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String bridgeLabel = _bridgeLabel(l10n);
    final String statusLabel = _statusLabel(l10n);
    final Color statusColor = switch (result.status) {
      NativeInteropStatus.success => theme.colorScheme.primary,
      NativeInteropStatus.unavailable => theme.colorScheme.outline,
      NativeInteropStatus.failed => theme.colorScheme.error,
    };

    if (NativePlatformShowcaseAdaptive.isCupertino(context)) {
      return NativePlatformShowcaseAdaptive.capabilityTile(
        context: context,
        leading: Icon(_bridgeIcon(result.kind)),
        title: Text(bridgeLabel),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              statusLabel,
              style: theme.textTheme.labelMedium?.copyWith(color: statusColor),
            ),
            SizedBox(height: context.responsiveGapXS),
            Text(result.message),
          ],
        ),
      );
    }

    return CommonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(_bridgeIcon(result.kind)),
              SizedBox(width: context.responsiveGapS),
              Expanded(
                child: Text(
                  bridgeLabel,
                  style: theme.textTheme.titleSmall,
                ),
              ),
            ],
          ),
          SizedBox(height: context.responsiveGapS),
          Text(
            statusLabel,
            style: theme.textTheme.labelMedium?.copyWith(color: statusColor),
          ),
          SizedBox(height: context.responsiveGapXS),
          Text(result.message),
        ],
      ),
    );
  }

  String _bridgeLabel(final AppLocalizations l10n) => switch (result.kind) {
    NativeInteropBridgeKind.swift =>
      l10n.nativePlatformShowcaseInteropSwiftLabel,
    NativeInteropBridgeKind.kotlin =>
      l10n.nativePlatformShowcaseInteropKotlinLabel,
    NativeInteropBridgeKind.cpp => l10n.nativePlatformShowcaseInteropCppLabel,
  };

  String _statusLabel(final AppLocalizations l10n) => switch (result.status) {
    NativeInteropStatus.success =>
      l10n.nativePlatformShowcaseInteropStatusSuccess,
    NativeInteropStatus.unavailable =>
      l10n.nativePlatformShowcaseInteropStatusUnavailable,
    NativeInteropStatus.failed =>
      l10n.nativePlatformShowcaseInteropStatusFailed,
  };

  IconData _bridgeIcon(final NativeInteropBridgeKind kind) => switch (kind) {
    NativeInteropBridgeKind.swift => Icons.apple,
    NativeInteropBridgeKind.kotlin => Icons.android,
    NativeInteropBridgeKind.cpp => Icons.memory_outlined,
  };
}
