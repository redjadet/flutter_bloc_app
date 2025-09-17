import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
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

  void _showHistorySheet(BuildContext context) {
    final ChatCubit cubit = context.read<ChatCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return BlocProvider.value(
          value: cubit,
          child: _ChatHistoryPanel(
            onClose: () => Navigator.of(sheetContext).pop(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

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
                    SizedBox(width: UI.horizontalGapS),
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
                if (state.hasError) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(state.error!)));
                  context.read<ChatCubit>().clearError();
                }
                if (state.hasMessages) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!_scrollController.hasClients) return;
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: UI.animFast,
                      curve: Curves.easeOut,
                    );
                  });
                }
              },
              builder: (context, state) {
                if (!state.hasMessages) {
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
                          horizontal: UI.horizontalGapM,
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
                UI.horizontalGapL,
                UI.gapS,
                UI.horizontalGapL,
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
                  SizedBox(width: UI.horizontalGapS),
                  BlocBuilder<ChatCubit, ChatState>(
                    builder: (context, state) {
                      return IconButton(
                        tooltip: l10n.chatSendButton,
                        onPressed: state.canSend
                            ? () => _submit(context)
                            : null,
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

class _ChatHistoryPanel extends StatelessWidget {
  const _ChatHistoryPanel({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final ChatCubit cubit = context.read<ChatCubit>();
    final MaterialLocalizations materialLocalizations =
        MaterialLocalizations.of(context);
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return FractionallySizedBox(
      heightFactor: 0.9,
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(UI.radiusM)),
        child: Material(
          color: theme.colorScheme.surface,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                UI.horizontalGapL,
                UI.gapM,
                UI.horizontalGapL,
                UI.gapM + bottomInset,
              ),
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  final List<ChatConversation> conversations = state.history;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              l10n.chatHistoryPanelTitle,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          IconButton(
                            tooltip: l10n.chatHistoryHideTooltip,
                            onPressed: onClose,
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      SizedBox(height: UI.gapS),
                      TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: Text(l10n.chatHistoryStartNew),
                        onPressed: () {
                          cubit.resetConversation();
                          onClose();
                        },
                      ),
                      SizedBox(height: UI.gapS),
                      Expanded(
                        child: state.hasHistory
                            ? ListView.separated(
                                itemBuilder: (context, index) {
                                  final ChatConversation conversation =
                                      conversations[index];
                                  final bool isActive =
                                      conversation.id ==
                                      state.activeConversationId;
                                  final String timestamp = _formatTimestamp(
                                    materialLocalizations,
                                    conversation.updatedAt,
                                  );
                                  final String title =
                                      conversation.model ??
                                      l10n.chatHistoryConversationTitle(
                                        index + 1,
                                      );
                                  final String? preview =
                                      conversation.messages.isNotEmpty
                                      ? conversation.messages.last.text
                                      : null;

                                  final Color baseTextColor = isActive
                                      ? theme.colorScheme.onPrimaryContainer
                                      : theme.colorScheme.onSurface;

                                  return ListTile(
                                    onTap: () {
                                      cubit.selectConversation(conversation.id);
                                      onClose();
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        UI.radiusM,
                                      ),
                                    ),
                                    tileColor: isActive
                                        ? theme.colorScheme.primaryContainer
                                        : theme
                                              .colorScheme
                                              .surfaceContainerHighest,
                                    title: Text(
                                      title,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(color: baseTextColor),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          l10n.chatHistoryUpdatedAt(timestamp),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: isActive
                                                    ? baseTextColor.withValues(
                                                        alpha: 0.85,
                                                      )
                                                    : theme
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                              ),
                                        ),
                                        if (preview != null &&
                                            preview.isNotEmpty)
                                          Padding(
                                            padding: EdgeInsets.only(
                                              top: UI.gapXS,
                                            ),
                                            child: Text(
                                              preview,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: baseTextColor,
                                                  ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                                separatorBuilder: (context, _) =>
                                    SizedBox(height: UI.gapS),
                                itemCount: conversations.length,
                              )
                            : Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: UI.horizontalGapL,
                                  ),
                                  child: Text(
                                    l10n.chatHistoryEmpty,
                                    style: theme.textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(
    MaterialLocalizations materialLocalizations,
    DateTime timestamp,
  ) {
    final String date = materialLocalizations.formatMediumDate(timestamp);
    final TimeOfDay time = TimeOfDay.fromDateTime(timestamp);
    final String formattedTime = materialLocalizations.formatTimeOfDay(time);
    return '$date · $formattedTime';
  }
}
