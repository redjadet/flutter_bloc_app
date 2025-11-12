import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/shared.dart';

Future<void> showExamplePlatformInfoDialog({
  required BuildContext context,
  required NativePlatformInfo info,
}) async {
  if (!context.mounted) return;
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
    if (info.manufacturer != null)
      _buildInfoRow(
        context: context,
        label: l10n.exampleNativeInfoDialogManufacturerLabel,
        value: info.manufacturer!,
      ),
    if (info.model != null)
      _buildInfoRow(
        context: context,
        label: l10n.exampleNativeInfoDialogModelLabel,
        value: info.model!,
      ),
    if (info.batteryLevel != null)
      _buildInfoRow(
        context: context,
        label: l10n.exampleNativeInfoDialogBatteryLabel,
        value: '${info.batteryLevel}%',
      ),
  ];

  await showAdaptiveDialog<void>(
    context: context,
    builder: (final BuildContext dialogContext) => AlertDialog.adaptive(
      title: Text(l10n.exampleNativeInfoDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(l10n.exampleDialogCloseButton),
        ),
      ],
    ),
  );
}

Future<void> showExamplePlatformInfoErrorDialog({
  required BuildContext context,
  String? message,
}) async {
  if (!context.mounted) return;
  final l10n = context.l10n;
  final String? detail = (message?.trim().isNotEmpty ?? false)
      ? message!.trim()
      : null;
  await showAdaptiveDialog<void>(
    context: context,
    builder: (final BuildContext dialogContext) => AlertDialog.adaptive(
      title: Text(l10n.exampleNativeInfoDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.exampleNativeInfoError),
          if (detail != null) ...[
            const SizedBox(height: 12),
            Text(detail),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(l10n.exampleDialogCloseButton),
        ),
      ],
    ),
  );
}

Widget _buildInfoRow({
  required BuildContext context,
  required String label,
  required String value,
}) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
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
      const SizedBox(width: 12),
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
