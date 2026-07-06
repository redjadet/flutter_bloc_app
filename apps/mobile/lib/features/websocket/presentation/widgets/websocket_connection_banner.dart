import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';

class WebsocketConnectionBanner extends StatelessWidget {
  const WebsocketConnectionBanner({
    required this.endpoint,
    required this.isConnecting,
    required this.isConnected,
    required this.errorMessage,
    super.key,
  });

  final Uri endpoint;
  final bool isConnecting;
  final bool isConnected;
  final String? errorMessage;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    if (errorMessage case final msg?) {
      return SizedBox(
        width: double.infinity,
        child: CommonCard(
          color: theme.colorScheme.errorContainer,
          elevation: 0,
          margin: EdgeInsets.zero,
          padding: context.allGapS,
          child: Text(
            l10n.websocketErrorLabel(msg),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
        ),
      );
    }
    final String statusText = isConnected
        ? l10n.websocketStatusConnected(endpoint.toString())
        : l10n.websocketStatusConnecting(endpoint.toString());
    final Color backgroundColor = isConnected
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHighest;
    final Color foregroundColor = isConnected
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurfaceVariant;
    return SizedBox(
      width: double.infinity,
      child: CommonCard(
        color: backgroundColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        padding: context.allGapS,
        child: Row(
          children: [
            if (isConnecting) ...[
              SizedBox(
                width: context.responsiveIconSize * 0.67,
                height: context.responsiveIconSize * 0.67,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: context.responsiveGapXS),
            ] else ...[
              Icon(Icons.bolt, color: foregroundColor),
              SizedBox(width: context.responsiveGapXS),
            ],
            Expanded(
              child: Text(
                statusText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: foregroundColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
