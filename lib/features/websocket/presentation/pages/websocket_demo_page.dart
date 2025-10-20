import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/websocket/presentation/cubit/websocket_cubit.dart';
import 'package:flutter_bloc_app/features/websocket/presentation/cubit/websocket_state.dart';
import 'package:flutter_bloc_app/features/websocket/presentation/widgets/websocket_connection_banner.dart';
import 'package:flutter_bloc_app/features/websocket/presentation/widgets/websocket_message_list.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/shared.dart';

class WebsocketDemoPage extends StatefulWidget {
  const WebsocketDemoPage({super.key});

  @override
  State<WebsocketDemoPage> createState() => _WebsocketDemoPageState();
}

class _WebsocketDemoPageState extends State<WebsocketDemoPage> {
  final TextEditingController _messageController = TextEditingController();
  late final WebsocketCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<WebsocketCubit>();
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _cubit.connect();
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _cubit.disconnect();
    super.dispose();
  }

  void _sendCurrentMessage() {
    final String raw = _messageController.text;
    if (raw.trim().isEmpty) {
      return;
    }
    _cubit.sendMessage(raw);
    _messageController.clear();
  }

  @override
  Widget build(final BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (kIsWeb) {
      return CommonPageLayout(
        title: l10n.websocketDemoTitle,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(UI.gapL),
            child: Text(
              l10n.websocketDemoWebUnsupported,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return BlocBuilder<WebsocketCubit, WebsocketState>(
      builder: (final context, final state) => CommonPageLayout(
        title: l10n.websocketDemoTitle,
        actions: [
          IconButton(
            tooltip: l10n.websocketReconnectTooltip,
            onPressed: state.isConnecting ? null : _cubit.reconnect,
            icon: const Icon(Icons.refresh),
          ),
        ],
        body: Column(
          children: [
            WebsocketConnectionBanner(state: state),
            const Divider(height: 1),
            Expanded(
              child: WebsocketMessageList(
                messages: state.messages,
                emptyLabel: l10n.websocketEmptyState,
              ),
            ),
            const Divider(height: 1),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  UI.horizontalGapL,
                  UI.gapS,
                  UI.horizontalGapL,
                  UI.gapS,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        enabled: state.isConnected && !state.isSending,
                        decoration: InputDecoration(
                          hintText: l10n.websocketMessageHint,
                          border: const OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _sendCurrentMessage(),
                      ),
                    ),
                    SizedBox(width: UI.gapS),
                    FilledButton.icon(
                      onPressed: state.isConnected && !state.isSending
                          ? _sendCurrentMessage
                          : null,
                      icon: const Icon(Icons.send),
                      label: Text(l10n.websocketSendButton),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
