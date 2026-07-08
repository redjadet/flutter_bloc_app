import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/app/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/app/extensions/type_safe_bloc_access.dart';
import 'package:flutter_bloc_app/app/widgets/common_page_layout.dart';
import 'package:flutter_bloc_app/features/websocket/domain/websocket_message.dart';
import 'package:flutter_bloc_app/features/websocket/presentation/cubit/websocket_cubit.dart';
import 'package:flutter_bloc_app/features/websocket/presentation/cubit/websocket_state.dart';
import 'package:flutter_bloc_app/features/websocket/presentation/widgets/websocket_connection_banner.dart';
import 'package:flutter_bloc_app/features/websocket/presentation/widgets/websocket_message_list.dart';

part 'websocket_demo_page_sections.part.dart';

class WebsocketDemoPage extends StatefulWidget {
  const WebsocketDemoPage({super.key});

  @override
  State<WebsocketDemoPage> createState() => _WebsocketDemoPageState();
}

class _WebsocketDemoPageState extends State<WebsocketDemoPage> {
  final TextEditingController _messageController = TextEditingController();
  WebsocketCubit? _cubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final WebsocketCubit cubit = context.cubit<WebsocketCubit>();
      _cubit = cubit;
      await cubit.connect();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    final WebsocketCubit? cubit = _cubit;
    if (cubit != null) {
      unawaited(cubit.disconnect());
    }
    super.dispose();
  }

  Future<void> _sendCurrentMessage() async {
    final String raw = _messageController.text;
    if (raw.trim().isEmpty) {
      return;
    }
    final WebsocketCubit cubit = _cubit ?? context.cubit<WebsocketCubit>();
    final bool didSend = await cubit.sendMessage(raw);
    if (didSend) {
      _messageController.clear();
    }
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return CommonPageLayout(
      title: l10n.websocketDemoTitle,
      actions: const [_ReconnectAction()],
      body: Column(
        children: [
          const _ConnectionBannerSection(),
          const Divider(height: 1),
          Expanded(
            child: _MessagesSection(emptyLabel: l10n.websocketEmptyState),
          ),
          const Divider(height: 1),
          _ComposerSection(
            messageController: _messageController,
            onSendCurrentMessage: _sendCurrentMessage,
          ),
        ],
      ),
    );
  }
}
