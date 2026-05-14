part of 'online_therapy_demo_shell_page.dart';

class _MessagingPanel extends StatefulWidget {
  const _MessagingPanel();

  @override
  State<_MessagingPanel> createState() => _MessagingPanelState();
}

class _MessagingPanelState extends State<_MessagingPanel> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final state = context.read<MessagingCubit>().state;
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
    final state = context.watchBloc<MessagingCubit>().state;
    final cubit = context.cubit<MessagingCubit>();
    final conversations = List<Conversation>.unmodifiable(
      state.conversations,
    );
    final messages = List<Message>.unmodifiable(state.messages);

    final nextText = state.draft ?? '';
    if (_controller.text != nextText) {
      _controller.value = _controller.value.copyWith(
        text: nextText,
        selection: TextSelection.collapsed(offset: nextText.length),
      );
    }

    if (state.errorMessage case final String errorMessage?) {
      return Center(
        child: Text(
          errorMessage,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    final convId = state.selectedConversationId;
    Widget buildMessagesPane({
      required final bool compact,
    }) {
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
                                onPressed: state.isBusy
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
                    enabled: !state.isBusy && convId != null,
                    controller: _controller,
                    decoration: InputDecoration(hintText: l10n.typeMessageHint),
                    onChanged: cubit.setDraft,
                  ),
                ),
                const SizedBox(width: 8),
                if (compact)
                  IconButton(
                    onPressed: state.isBusy || convId == null
                        ? null
                        : () => cubit.send(),
                    icon: const Icon(Icons.send),
                    tooltip: l10n.sendButtonLabel,
                  )
                else
                  ElevatedButton(
                    onPressed: state.isBusy || convId == null
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
                  onChanged: state.isBusy
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

class _CallPanel extends StatelessWidget {
  const _CallPanel();

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final state = context.watchBloc<CallCubit>().state;
    final cubit = context.cubit<CallCubit>();

    final apptId = state.selectedAppointmentId;
    final session = state.session;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            DropdownButton<String>(
              value: apptId,
              hint: Text(l10n.selectAppointmentHintLabel),
              onChanged: state.isBusy
                  ? null
                  : (final v) => v == null ? null : cubit.selectAppointment(v),
              items: state.appointments
                  .map(
                    (a) => DropdownMenuItem<String>(
                      value: a.id,
                      child: Text(a.id),
                    ),
                  )
                  .toList(growable: false),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: state.cameraPermissionGranted,
              onChanged: state.isBusy
                  ? null
                  : (final v) => v == null
                        ? null
                        : cubit.toggleCameraPermission(granted: v),
              title: Text(l10n.cameraLabel),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: state.microphonePermissionGranted,
              onChanged: state.isBusy
                  ? null
                  : (final v) => v == null
                        ? null
                        : cubit.toggleMicrophonePermission(granted: v),
              title: Text(l10n.microphoneLabel),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            ElevatedButton(
              onPressed: state.isBusy || apptId == null
                  ? null
                  : () => cubit.createSession(),
              child: Text(l10n.createSessionButtonLabel),
            ),
            ElevatedButton(
              onPressed: state.isBusy || session == null
                  ? null
                  : () => cubit.join(),
              child: Text(l10n.joinButtonLabel),
            ),
          ],
        ),
        if (state.errorMessage case final String errorMessage?)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        const SizedBox(height: 8),
        Text('Session: ${session?.id ?? '-'}'),
        Text('Join status: ${session?.joinStatus.name ?? '-'}'),
        if (session?.joinStatus == CallJoinStatus.failed)
          const Text(
            'Fallback: join failed — simulated provider.',
            style: TextStyle(color: Colors.orange),
          ),
      ],
    );
  }
}
