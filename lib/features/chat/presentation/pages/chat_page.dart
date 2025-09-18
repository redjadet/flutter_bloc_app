import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_history_sheet.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_input_bar.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_message_list.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_model_selector.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';

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
    context.read<ChatCubit>().sendMessage(text);
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

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chatPageTitle),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.chatHistoryShowTooltip,
            onPressed: () => _showHistorySheet(context),
            icon: const Icon(Icons.history),
          ),
        ],
      ),
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
