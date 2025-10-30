import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/websocket/presentation/cubit/websocket_state.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';

class WebsocketConnectionBanner extends StatelessWidget {
  const WebsocketConnectionBanner({required this.state, super.key});

  final WebsocketState state;

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final l10n = context.l10n;
    if (state.errorMessage != null) {
      return Container(
        width: double.infinity,
        color: theme.colorScheme.errorContainer,
        padding: EdgeInsets.all(UI.gapS),
        child: Text(
          l10n.websocketErrorLabel(state.errorMessage!),
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
      padding: EdgeInsets.all(UI.gapS),
      child: Row(
        children: [
          if (state.isConnecting) ...[
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: UI.gapXS),
          ] else ...[
            Icon(Icons.bolt, color: foregroundColor),
            SizedBox(width: UI.gapXS),
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
