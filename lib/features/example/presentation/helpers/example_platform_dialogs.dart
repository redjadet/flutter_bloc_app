import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

Future<void> showExamplePlatformInfoDialog({
  required final BuildContext context,
  required final NativePlatformInfo info,
}) async {
  if (!context.mounted) {
    ContextUtils.logNotMounted('ExamplePlatformDialogs.showInfo');
    return;
  }
  final l10n = context.l10n;
  final List<Widget> rows = <Widget>[
    _buildInfoRow(
      context: context,
      label: l10n.exampleNativeInfoDialogPlatformLabel,
      value: info.platform,
    ),
    _buildInfoRow(
      context: context,
      label: l10n.exampleNativeInfoDialogVersionLabel,
      value: info.version,
    ),
    if (info.manufacturer case final m?)
      _buildInfoRow(
        context: context,
        label: l10n.exampleNativeInfoDialogManufacturerLabel,
        value: m,
      ),
    if (info.model case final m?)
      _buildInfoRow(
        context: context,
        label: l10n.exampleNativeInfoDialogModelLabel,
        value: m,
      ),
    if (info.batteryLevel case final batteryLevel?)
      _buildInfoRow(
        context: context,
        label: l10n.exampleNativeInfoDialogBatteryLabel,
        value: '$batteryLevel%',
      ),
  ];

  await showAdaptiveDialog<void>(
    context: context,
    builder: (final dialogContext) => AlertDialog.adaptive(
      title: Text(l10n.exampleNativeInfoDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
      actions: [
        PlatformAdaptive.dialogAction(
          context: dialogContext,
          label: l10n.exampleDialogCloseButton,
          onPressed: () => NavigationUtils.maybePop(dialogContext),
        ),
      ],
    ),
  );
}

Future<void> showExamplePlatformInfoErrorDialog({
  required final BuildContext context,
  final String? message,
}) async {
  if (!context.mounted) {
    ContextUtils.logNotMounted('ExamplePlatformDialogs.showError');
    return;
  }
  final l10n = context.l10n;
  final String? detail = switch (message) {
    final m? when m.trim().isNotEmpty => m.trim(),
    _ => null,
  };
  await showAdaptiveDialog<void>(
    context: context,
    builder: (final dialogContext) => AlertDialog.adaptive(
      title: Text(l10n.exampleNativeInfoDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.exampleNativeInfoError),
          if (detail case final message?) ...[
            SizedBox(height: context.responsiveGapM),
            Text(message),
          ],
        ],
      ),
      actions: [
        PlatformAdaptive.dialogAction(
          context: dialogContext,
          label: l10n.exampleDialogCloseButton,
          onPressed: () => NavigationUtils.maybePop(dialogContext),
        ),
      ],
    ),
  );
}

Widget _buildInfoRow({
  required final BuildContext context,
  required final String label,
  required final String value,
}) => Padding(
  padding: EdgeInsets.only(bottom: context.responsiveGapS),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      SizedBox(width: context.responsiveGapM),
      Expanded(
        child: Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.right,
        ),
      ),
    ],
  ),
);
