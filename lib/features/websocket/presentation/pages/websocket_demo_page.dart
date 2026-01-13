import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_message.dart';
import 'package:flutter_bloc_app/features/websocket/presentation/cubit/websocket_cubit.dart';
import 'package:flutter_bloc_app/features/websocket/presentation/cubit/websocket_state.dart';
import 'package:flutter_bloc_app/features/websocket/presentation/widgets/websocket_connection_banner.dart';
import 'package:flutter_bloc_app/features/websocket/presentation/widgets/websocket_message_list.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

@immutable
class _WebsocketViewData extends Equatable {
  const _WebsocketViewData({
    required this.isConnecting,
    required this.isConnected,
    required this.isSending,
    required this.messages,
  });

  final bool isConnecting;
  final bool isConnected;
  final bool isSending;
  final List<WebsocketMessage> messages;

  @override
  List<Object?> get props => [isConnecting, isConnected, isSending, messages];
}

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
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await _cubit.connect();
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    unawaited(_cubit.disconnect());
    super.dispose();
  }

  Future<void> _sendCurrentMessage() async {
    final String raw = _messageController.text;
    if (raw.trim().isEmpty) {
      return;
    }
    await _cubit.sendMessage(raw);
    _messageController.clear();
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    if (kIsWeb) {
      return CommonPageLayout(
        title: l10n.websocketDemoTitle,
        body: Center(
          child: Padding(
            padding: context.allGapL,
            child: Text(
              l10n.websocketDemoWebUnsupported,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return BlocSelector<WebsocketCubit, WebsocketState, _WebsocketViewData>(
      selector: (final state) => _WebsocketViewData(
        isConnecting: state.isConnecting,
        isConnected: state.isConnected,
        isSending: state.isSending,
        messages: state.messages,
      ),
      builder: (final context, final data) => CommonPageLayout(
        title: l10n.websocketDemoTitle,
        actions: [
          IconButton(
            tooltip: l10n.websocketReconnectTooltip,
            onPressed: data.isConnecting ? null : _cubit.reconnect,
            icon: const Icon(Icons.refresh),
          ),
        ],
        body: BlocBuilder<WebsocketCubit, WebsocketState>(
          buildWhen: (final previous, final current) =>
              previous.status != current.status,
          builder: (final context, final state) => Column(
            children: [
              WebsocketConnectionBanner(state: state),
              const Divider(height: 1),
              Expanded(
                child: WebsocketMessageList(
                  messages: data.messages,
                  emptyLabel: l10n.websocketEmptyState,
                ),
              ),
              const Divider(height: 1),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.responsiveHorizontalGapL,
                    context.responsiveGapS,
                    context.responsiveHorizontalGapL,
                    context.responsiveGapS,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: PlatformAdaptive.textField(
                          context: context,
                          controller: _messageController,
                          hintText: l10n.websocketMessageHint,
                          enabled: data.isConnected && !data.isSending,
                          decoration: InputDecoration(
                            hintText: l10n.websocketMessageHint,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                context.responsiveCardRadius,
                              ),
                            ),
                          ),
                          onSubmitted: (_) => _sendCurrentMessage(),
                        ),
                      ),
                      SizedBox(width: context.responsiveGapS),
                      PlatformAdaptive.filledButton(
                        context: context,
                        onPressed: data.isConnected && !data.isSending
                            ? _sendCurrentMessage
                            : null,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.send),
                            SizedBox(width: context.responsiveGapXS),
                            Text(l10n.websocketSendButton),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
