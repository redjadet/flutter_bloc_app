import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_state.dart';
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

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.chatPageTitle)),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(UI.hgapL, UI.gapM, UI.hgapL, UI.gapS),
            child: BlocBuilder<ChatCubit, ChatState>(
              buildWhen: (prev, curr) => prev.currentModel != curr.currentModel,
              builder: (context, state) {
                final ChatCubit cubit = context.read<ChatCubit>();
                final List<String> models = cubit.models;
                final String currentModel = state.currentModel ?? models.first;

                if (models.length <= 1) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${l10n.chatModelLabel}: '
                      '${_modelLabel(l10n, currentModel)}',
                      style: theme.textTheme.titleMedium,
                    ),
                  );
                }

                return Row(
                  children: <Widget>[
                    Text(
                      l10n.chatModelLabel,
                      style: theme.textTheme.titleMedium,
                    ),
                    SizedBox(width: UI.hgapS),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: currentModel,
                        items: models
                            .map(
                              (String model) => DropdownMenuItem<String>(
                                value: model,
                                child: Text(_modelLabel(l10n, model)),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (String? value) {
                          if (value != null) {
                            cubit.selectModel(value);
                          }
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        isExpanded: true,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: BlocConsumer<ChatCubit, ChatState>(
              listener: (context, state) {
                if (state.error != null) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(state.error!)));
                  context.read<ChatCubit>().clearError();
                }
                if (state.messages.isNotEmpty) {
                  Future<void>.delayed(Duration.zero, () {
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: UI.animFast,
                        curve: Curves.easeOut,
                      );
                    }
                  });
                }
              },
              builder: (context, state) {
                if (state.messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(UI.gapL),
                      child: Text(
                        l10n.chatEmptyState,
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(UI.gapM),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final ChatMessage message = state.messages[index];
                    final bool isUser = message.author == ChatAuthor.user;
                    final Alignment alignment = isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft;
                    final Color bubbleColor = isUser
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest;
                    final Color textColor = isUser
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface;

                    return Align(
                      alignment: alignment,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: UI.gapS / 2),
                        padding: EdgeInsets.symmetric(
                          horizontal: UI.hgapM,
                          vertical: UI.gapS,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: bubbleColor,
                          borderRadius: BorderRadius.circular(UI.radiusM),
                        ),
                        child: Text(
                          message.text,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: textColor,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                UI.hgapL,
                UI.gapS,
                UI.hgapL,
                UI.gapS,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _submit(context),
                      decoration: InputDecoration(
                        hintText: l10n.chatInputHint,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: UI.hgapS),
                  BlocBuilder<ChatCubit, ChatState>(
                    builder: (context, state) {
                      return IconButton(
                        tooltip: l10n.chatSendButton,
                        onPressed: state.isLoading
                            ? null
                            : () => _submit(context),
                        icon: state.isLoading
                            ? SizedBox.square(
                                dimension: UI.iconM,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.primary,
                                ),
                              )
                            : const Icon(Icons.send),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _modelLabel(AppLocalizations l10n, String model) {
    switch (model) {
      case 'openai/gpt-oss-20b':
        return l10n.chatModelGptOss20b;
      case 'openai/gpt-oss-120b':
        return l10n.chatModelGptOss120b;
      default:
        return model;
    }
  }
}
