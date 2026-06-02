part of 'chat_page.dart';

extension _ChatPageStateActions on _ChatPageState {
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
    if (!context.mounted) return;
    await cubit.clearHistory();
  }
}
