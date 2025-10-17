import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/chat.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
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

  void _submit(BuildContext context) {
    final String text = _controller.text;
    _controller.clear();
    CubitHelpers.safeExecute<ChatCubit, ChatState>(
      context,
      (cubit) => cubit.sendMessage(text),
    );
  }

  void _showHistorySheet(BuildContext context) {
    final ChatCubit cubit = context.read<ChatCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return BlocProvider.value(
          value: cubit,
          child: ChatHistorySheet(
            onClose: () => Navigator.of(sheetContext).pop(),
          ),
        );
      },
    );
  }

  Future<void> _confirmAndClearHistory(BuildContext context) async {
    final ChatCubit cubit = context.read<ChatCubit>();
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
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
            );
          },
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    await cubit.clearHistory();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return CommonPageLayout(
      title: l10n.chatPageTitle,
      actions: <Widget>[
        IconButton(
          tooltip: l10n.chatHistoryShowTooltip,
          onPressed: () => _showHistorySheet(context),
          icon: const Icon(Icons.history),
        ),
        BlocBuilder<ChatCubit, ChatState>(
          buildWhen: (previous, current) =>
              previous.history.length != current.history.length,
          builder: (context, state) {
            return IconButton(
              tooltip: l10n.chatHistoryClearAll,
              onPressed: state.hasHistory
                  ? () => _confirmAndClearHistory(context)
                  : null,
              icon: const Icon(Icons.delete_sweep_outlined),
            );
          },
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
