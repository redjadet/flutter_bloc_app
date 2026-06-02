part of 'websocket_demo_page.dart';

class _ReconnectAction extends StatelessWidget {
  const _ReconnectAction();

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final isConnecting = context
        .selectState<WebsocketCubit, WebsocketState, bool>(
          selector: (final state) => state.isConnecting,
        );
    return IconButton(
      tooltip: l10n.websocketReconnectTooltip,
      onPressed: isConnecting
          ? null
          : context.cubit<WebsocketCubit>().reconnect,
      icon: const Icon(Icons.refresh),
    );
  }
}

class _ConnectionBannerSection extends StatelessWidget {
  const _ConnectionBannerSection();

  @override
  Widget build(final BuildContext context) {
    final bannerState = context
        .selectState<
          WebsocketCubit,
          WebsocketState,
          ({
            Uri endpoint,
            bool isConnecting,
            bool isConnected,
            String? errorMessage,
          })
        >(
          selector: (final state) => (
            endpoint: state.endpoint,
            isConnecting: state.isConnecting,
            isConnected: state.isConnected,
            errorMessage: state.errorMessage,
          ),
        );
    return WebsocketConnectionBanner(
      endpoint: bannerState.endpoint,
      isConnecting: bannerState.isConnecting,
      isConnected: bannerState.isConnected,
      errorMessage: bannerState.errorMessage,
    );
  }
}

class _MessagesSection extends StatelessWidget {
  const _MessagesSection({required this.emptyLabel});

  final String emptyLabel;

  @override
  Widget build(final BuildContext context) {
    final messages = context
        .selectState<WebsocketCubit, WebsocketState, List<WebsocketMessage>>(
          selector: (final state) => state.messages,
        );
    return WebsocketMessageList(messages: messages, emptyLabel: emptyLabel);
  }
}

class _ComposerSection extends StatelessWidget {
  const _ComposerSection({
    required this.messageController,
    required this.onSendCurrentMessage,
  });

  final TextEditingController messageController;
  final Future<void> Function() onSendCurrentMessage;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final composerState = context
        .selectState<
          WebsocketCubit,
          WebsocketState,
          ({bool isConnected, bool isSending})
        >(
          selector: (final state) => (
            isConnected: state.isConnected,
            isSending: state.isSending,
          ),
        );

    return SafeArea(
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
                controller: messageController,
                hintText: l10n.websocketMessageHint,
                enabled: composerState.isConnected && !composerState.isSending,
                decoration: InputDecoration(
                  hintText: l10n.websocketMessageHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      context.responsiveCardRadius,
                    ),
                  ),
                ),
                onSubmitted: (_) => onSendCurrentMessage(),
              ),
            ),
            SizedBox(width: context.responsiveGapS),
            PlatformAdaptive.filledButton(
              context: context,
              onPressed: composerState.isConnected && !composerState.isSending
                  ? onSendCurrentMessage
                  : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.send),
                  SizedBox(width: context.responsiveGapXS),
                  Flexible(
                    child: Text(
                      l10n.websocketSendButton,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
