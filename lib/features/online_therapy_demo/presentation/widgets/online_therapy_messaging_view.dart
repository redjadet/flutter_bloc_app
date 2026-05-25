import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/presentation/cubit/messaging_cubit.dart';
import 'package:flutter_bloc_app/shared/extensions/build_context_l10n.dart';
import 'package:flutter_bloc_app/shared/extensions/type_safe_bloc_access.dart';

class OnlineTherapyMessagingView extends StatefulWidget {
  const OnlineTherapyMessagingView({super.key});

  @override
  State<OnlineTherapyMessagingView> createState() =>
      _OnlineTherapyMessagingViewState();
}

class _OnlineTherapyMessagingViewState
    extends State<OnlineTherapyMessagingView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final state = context.cubit<MessagingCubit>().state;
    _controller = TextEditingController(text: state.draft ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final viewState = context
        .selectState<
          MessagingCubit,
          MessagingState,
          ({
            bool isBusy,
            List<Conversation> conversations,
            List<Message> messages,
            String? selectedConversationId,
            String? draft,
            String? errorMessage,
          })
        >(
          selector: (final state) => (
            isBusy: state.isBusy,
            conversations: state.conversations,
            messages: state.messages,
            selectedConversationId: state.selectedConversationId,
            draft: state.draft,
            errorMessage: state.errorMessage,
          ),
        );
    final cubit = context.cubit<MessagingCubit>();
    final conversations = List<Conversation>.unmodifiable(
      viewState.conversations,
    );
    final messages = List<Message>.unmodifiable(viewState.messages);

    final nextText = viewState.draft ?? '';
    if (_controller.text != nextText) {
      _controller.value = _controller.value.copyWith(
        text: nextText,
        selection: TextSelection.collapsed(offset: nextText.length),
      );
    }

    if (viewState.errorMessage case final String errorMessage?) {
      return Center(
        child: Text(
          errorMessage,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    final convId = viewState.selectedConversationId;

    Widget buildMessagesPane({required final bool compact}) {
      return Column(
        children: <Widget>[
          Expanded(
            child: convId == null
                ? Center(child: Text(l10n.conversationHintLabel))
                : ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      if (index >= messages.length) {
                        return const SizedBox.shrink();
                      }
                      final m = messages[index];
                      final retryHint =
                          m.deliveryStatus == MessageDeliveryStatus.failed
                          ? ' • ${l10n.retryButtonShortLabel.toLowerCase()}'
                          : '';
                      return ListTile(
                        key: ValueKey<String>('msg-${m.id}'),
                        dense: true,
                        title: Text(
                          m.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          'Status: ${m.deliveryStatus.name}$retryHint',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing:
                            m.deliveryStatus == MessageDeliveryStatus.failed
                            ? TextButton(
                                onPressed: viewState.isBusy
                                    ? null
                                    : () => cubit.retry(m.id),
                                child: Text(l10n.retryButtonShortLabel),
                              )
                            : null,
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    enabled: !viewState.isBusy && convId != null,
                    controller: _controller,
                    decoration: InputDecoration(hintText: l10n.typeMessageHint),
                    onChanged: cubit.setDraft,
                  ),
                ),
                const SizedBox(width: 8),
                if (compact)
                  IconButton(
                    onPressed: viewState.isBusy || convId == null
                        ? null
                        : () => cubit.send(),
                    icon: const Icon(Icons.send),
                    tooltip: l10n.sendButtonLabel,
                  )
                else
                  ElevatedButton(
                    onPressed: viewState.isBusy || convId == null
                        ? null
                        : () => cubit.send(),
                    child: Text(l10n.sendButtonLabel),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 420;
        if (isCompact) {
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: convId,
                  hint: Text(l10n.conversationHintLabel),
                  items: conversations
                      .map(
                        (c) => DropdownMenuItem<String>(
                          value: c.id,
                          child: Text(
                            c.id,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: viewState.isBusy
                      ? null
                      : (final id) {
                          if (id == null) return;
                          // check-ignore: side_effects_build - user gesture (dropdown).
                          unawaited(cubit.selectConversation(id));
                        },
                ),
              ),
              const Divider(height: 1),
              Expanded(child: buildMessagesPane(compact: true)),
            ],
          );
        }

        final sidebarWidth = (constraints.maxWidth * 0.45)
            .clamp(160, 220)
            .toDouble();
        return Row(
          children: <Widget>[
            SizedBox(
              width: sidebarWidth,
              child: ListView.separated(
                itemCount: conversations.length,
                separatorBuilder: (_, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  if (index >= conversations.length) {
                    return const SizedBox.shrink();
                  }
                  final c = conversations[index];
                  final selected = c.id == convId;
                  return ListTile(
                    key: ValueKey<String>('conv-${c.id}'),
                    dense: true,
                    selected: selected,
                    title: Text(
                      c.id,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: c.appointmentId == null
                        ? null
                        : Text(
                            'Appt: ${c.appointmentId}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                    // check-ignore: side_effects_build - triggered by user gesture callback.
                    onTap: () => unawaited(cubit.selectConversation(c.id)),
                  );
                },
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: buildMessagesPane(compact: false)),
          ],
        );
      },
    );
  }
}

// eof
// end
//
