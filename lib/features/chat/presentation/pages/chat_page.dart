import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/chat.dart';
import 'package:flutter_bloc_app/shared/shared.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/utils/platform_adaptive.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    required this.errorNotificationService,
    required this.pendingSyncRepository,
    super.key,
  });

  final ErrorNotificationService errorNotificationService;
  final PendingSyncRepository pendingSyncRepository;

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
    final ChatCubit cubit = context.cubit<ChatCubit>();
    await PlatformAdaptive.showAdaptiveModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (final sheetContext) => BlocProvider.value(
        value: cubit,
        child: ChatHistorySheet(
          onClose: () => NavigationUtils.maybePop(sheetContext),
        ),
      ),
    );
  }

  Future<void> _confirmAndClearHistory(final BuildContext context) async {
    final ChatCubit cubit = context.cubit<ChatCubit>();
    final l10n = context.l10n;
    final bool isCupertino = PlatformAdaptive.isCupertino(context);
    final bool confirmed =
        await showAdaptiveDialog<bool>(
          context: context,
          builder: (final dialogContext) {
            if (isCupertino) {
              return CupertinoAlertDialog(
                title: Text(l10n.chatHistoryClearAll),
                content: Text(l10n.chatHistoryClearAllWarning),
                actions: <Widget>[
                  CupertinoDialogAction(
                    onPressed: () =>
                        NavigationUtils.maybePop(dialogContext, result: false),
                    child: Text(l10n.cancelButtonLabel),
                  ),
                  CupertinoDialogAction(
                    isDestructiveAction: true,
                    onPressed: () =>
                        NavigationUtils.maybePop(dialogContext, result: true),
                    child: Text(l10n.deleteButtonLabel),
                  ),
                ],
              );
            }
            return AlertDialog(
              title: Text(l10n.chatHistoryClearAll),
              content: Text(l10n.chatHistoryClearAllWarning),
              actions: <Widget>[
                PlatformAdaptive.dialogAction(
                  context: dialogContext,
                  label: l10n.cancelButtonLabel,
                  onPressed: () =>
                      NavigationUtils.maybePop(dialogContext, result: false),
                ),
                PlatformAdaptive.dialogAction(
                  context: dialogContext,
                  label: l10n.deleteButtonLabel,
                  isDestructive: true,
                  onPressed: () =>
                      NavigationUtils.maybePop(dialogContext, result: true),
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
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final bool hasHistory = context.selectState<ChatCubit, ChatState, bool>(
      selector: (final state) => state.hasHistory,
    );
    return CommonPageLayout(
      title: l10n.chatPageTitle,
      actions: <Widget>[
        IconButton(
          tooltip: l10n.chatHistoryShowTooltip,
          onPressed: () => _showHistorySheet(context),
          icon: const Icon(Icons.history),
        ),
        IconButton(
          tooltip: l10n.chatHistoryClearAll,
          onPressed: hasHistory ? () => _confirmAndClearHistory(context) : null,
          icon: const Icon(Icons.delete_sweep_outlined),
        ),
      ],
      body: Column(
        children: <Widget>[
          ChatSyncBanner(
            pendingRepository: widget.pendingSyncRepository,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              context.responsiveHorizontalGapL,
              context.responsiveGapM,
              context.responsiveHorizontalGapL,
              context.responsiveGapS,
            ),
            child: const ChatModelSelector(),
          ),
          Expanded(
            child: ChatMessageList(
              controller: _scrollController,
              errorNotificationService: widget.errorNotificationService,
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                context.responsiveHorizontalGapL,
                context.responsiveGapS,
                context.responsiveHorizontalGapL,
                context.responsiveGapS,
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
