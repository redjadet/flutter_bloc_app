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
            SizedBox(height: context.responsiveGapM),
            Text(detail),
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
