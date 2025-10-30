import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/chat.dart';
import 'package:flutter_bloc_app/shared/shared.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _submit(final BuildContext context) {
    final String text = _controller.text;
    _controller.clear();
    CubitHelpers.safeExecute<ChatCubit, ChatState>(
      context,
      (final cubit) => cubit.sendMessage(text),
    );
  }

  Future<void> _showHistorySheet(final BuildContext context) async {
    final ChatCubit cubit = context.read<ChatCubit>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (final BuildContext sheetContext) => BlocProvider.value(
        value: cubit,
        child: ChatHistorySheet(
          onClose: () => Navigator.of(sheetContext).pop(),
        ),
      ),
    );
  }

  Future<void> _confirmAndClearHistory(final BuildContext context) async {
    final ChatCubit cubit = context.read<ChatCubit>();
    final l10n = context.l10n;
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (final BuildContext dialogContext) => AlertDialog(
            title: Text(l10n.chatHistoryClearAll),
            content: Text(l10n.chatHistoryClearAllWarning),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.cancelButtonLabel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n.deleteButtonLabel),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    await cubit.clearHistory();
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;

    return CommonPageLayout(
      title: l10n.chatPageTitle,
      actions: <Widget>[
        IconButton(
          tooltip: l10n.chatHistoryShowTooltip,
          onPressed: () => _showHistorySheet(context),
          icon: const Icon(Icons.history),
        ),
        BlocBuilder<ChatCubit, ChatState>(
          buildWhen: (final previous, final current) =>
              previous.history.length != current.history.length,
          builder: (final context, final state) => IconButton(
            tooltip: l10n.chatHistoryClearAll,
            onPressed: state.hasHistory
                ? () => _confirmAndClearHistory(context)
                : null,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ),
      ],
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(
              UI.horizontalGapL,
              UI.gapM,
              UI.horizontalGapL,
              UI.gapS,
            ),
            child: const ChatModelSelector(),
          ),
          Expanded(child: ChatMessageList(controller: _scrollController)),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                UI.horizontalGapL,
                UI.gapS,
                UI.horizontalGapL,
                UI.gapS,
              ),
              child: ChatInputBar(
                controller: _controller,
                onSend: () => _submit(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
