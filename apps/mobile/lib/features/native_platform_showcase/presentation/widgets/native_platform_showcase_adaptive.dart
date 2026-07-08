import 'package:design_system/design_system.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/native_capability_kind.dart';

/// Presentation-only platform chrome for the native platform showcase.
class NativePlatformShowcaseAdaptive {
  const NativePlatformShowcaseAdaptive._();

  static bool isCupertino(final BuildContext context) =>
      PlatformAdaptive.isCupertino(context);

  static IconData capabilityIcon(
    final NativeCapabilityKind kind,
  ) => switch (kind) {
    NativeCapabilityKind.nativeViewEmbedding => Icons.view_in_ar_outlined,
    NativeCapabilityKind.platformPackageManager => Icons.inventory_2_outlined,
    NativeCapabilityKind.nativeCodeInterop => Icons.integration_instructions,
    NativeCapabilityKind.lowLevelGraphics => Icons.auto_awesome_outlined,
    NativeCapabilityKind.adaptiveGestures => Icons.touch_app_outlined,
  };

  /// Label/value rows for the platform summary (runtime platform, UI family).
  static Widget summarySection({
    required final BuildContext context,
    required final List<({String label, String value})> rows,
  }) {
    if (isCupertino(context)) {
      return CupertinoListSection.insetGrouped(
        children: rows
            .map(
              (final row) => CupertinoListTile(
                title: Text(row.label),
                additionalInfo: Text(row.value),
              ),
            )
            .toList(growable: false),
      );
    }
    final ThemeData theme = Theme.of(context);
    return CommonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (var index = 0; index < rows.length; index++) ...<Widget>[
            if (index > 0) SizedBox(height: context.responsiveGapS),
            _MaterialSummaryRow(
              label: rows[index].label,
              value: rows[index].value,
              theme: theme,
            ),
          ],
        ],
      ),
    );
  }

  static Widget capabilityTile({
    required final BuildContext context,
    required final Widget title,
    final Widget? subtitle,
    final Widget? leading,
    final Widget? trailing,
    final VoidCallback? onTap,
  }) => PlatformAdaptive.listTile(
    context: context,
    title: title,
    subtitle: subtitle,
    leading: leading,
    trailing: trailing,
    onTap: onTap,
  );
}

class _MaterialSummaryRow extends StatelessWidget {
  const _MaterialSummaryRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(final BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}
