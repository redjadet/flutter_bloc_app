import 'package:design_system/design_system.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/features/carrier_line_demo/domain/carrier_connection_status.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

class CarrierConnectionBanner extends StatelessWidget {
  const new({
    required this.status,
    required this.endpoint,
    this.errorMessage,
    this.onConnect,
    this.onDisconnect,
    super.key,
  });

  final CarrierConnectionStatus status;
  final Uri endpoint;
  final String? errorMessage;
  final VoidCallback? onConnect;
  final VoidCallback? onDisconnect;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final AppLocalizations l10n = context.l10n;
    final (Color bg, String label) = switch (status) {
      CarrierConnectionStatus.connected => (
        colors.primaryContainer,
        l10n.carrierLineConnectionConnected,
      ),
      CarrierConnectionStatus.connecting => (
        colors.secondaryContainer,
        l10n.carrierLineConnectionConnecting,
      ),
      CarrierConnectionStatus.error => (
        colors.errorContainer,
        errorMessage ?? l10n.carrierLineConnectionError,
      ),
      CarrierConnectionStatus.disconnected => (
        colors.surfaceContainerHighest,
        l10n.carrierLineConnectionDisconnected,
      ),
    };

    return CommonCard(
      key: const ValueKey<String>('carrier-line-connection-banner'),
      color: bg,
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.carrierLineSimulatedBadge,
            style: theme.textTheme.labelSmall,
          ),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            endpoint.toString(),
            style: theme.textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              FilledButton.tonal(
                key: const ValueKey<String>('carrier-line-connect'),
                onPressed:
                    status == CarrierConnectionStatus.connecting ||
                        status == CarrierConnectionStatus.connected
                    ? null
                    : onConnect,
                child: Text(l10n.carrierLineConnectButton),
              ),
              OutlinedButton(
                key: const ValueKey<String>('carrier-line-disconnect'),
                onPressed: status == CarrierConnectionStatus.disconnected
                    ? null
                    : onDisconnect,
                child: Text(l10n.carrierLineDisconnectButton),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
