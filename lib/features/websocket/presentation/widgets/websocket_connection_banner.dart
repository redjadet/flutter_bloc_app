import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/websocket/presentation/cubit/websocket_state.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/responsive.dart';

class WebsocketConnectionBanner extends StatelessWidget {
  const WebsocketConnectionBanner({required this.state, super.key});

  final WebsocketState state;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    if (state.errorMessage case final msg?) {
      return Container(
        width: double.infinity,
        color: theme.colorScheme.errorContainer,
        padding: context.allGapS,
        child: Text(
          l10n.websocketErrorLabel(msg),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onErrorContainer,
          ),
        ),
      );
    }
    final String statusText = state.isConnected
        ? l10n.websocketStatusConnected(state.endpoint.toString())
        : l10n.websocketStatusConnecting(state.endpoint.toString());
    final Color backgroundColor = state.isConnected
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHighest;
    final Color foregroundColor = state.isConnected
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurfaceVariant;
    return Container(
      width: double.infinity,
      color: backgroundColor,
      padding: context.allGapS,
      child: Row(
        children: [
          if (state.isConnecting) ...[
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
    );
  }
}
