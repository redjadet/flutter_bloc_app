part of 'chat_list_view.dart';

extension _ChatListViewNavigation on ChatListView {
  void navigateToChat(final BuildContext context, final ChatContact contact) {
    if (!context.mounted) {
      ContextUtils.logNotMounted('ChatListView._navigateToChat');
      return;
    }
    // Mark as read when opening chat
    unawaited(context.cubit<ChatListCubit>().markAsRead(contact.id));

    // Navigate to chat page
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (final context) => BlocProvider(
            create: (final context) {
              final cubit = ChatCubit(
                repository: chatRepository,
                historyRepository: historyRepository,
                initialModel: SecretConfig.huggingfaceModel,
              );
              unawaited(cubit.loadHistory());
              return cubit;
            },
            child: ChatPage(
              errorNotificationService: errorNotificationService,
              pendingSyncRepository: pendingSyncRepository,
            ),
          ),
        ),
      ),
    );
  }

  void showDeleteDialog(
    final BuildContext context,
    final ChatContact contact,
  ) {
    final chatListCubit = context.cubit<ChatListCubit>();
    final bool isCupertino = PlatformAdaptive.isCupertino(context);
    final l10n = context.l10n;
    unawaited(
      showAdaptiveDialog<void>(
        context: context,
        builder: (final dialogContext) {
          if (isCupertino) {
            return CupertinoAlertDialog(
              title: Text(l10n.chatHistoryDeleteConversation),
              content: Text(
                l10n.chatHistoryDeleteConversationWarning(contact.name),
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => NavigationUtils.maybePop(dialogContext),
                  child: Text(l10n.cancelButtonLabel),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: () {
                    NavigationUtils.maybePop(dialogContext);
                    unawaited(chatListCubit.deleteContact(contact.id));
                  },
                  child: Text(l10n.deleteButtonLabel),
                ),
              ],
            );
          }
          return AlertDialog(
            title: Text(l10n.chatHistoryDeleteConversation),
            content: Text(
              l10n.chatHistoryDeleteConversationWarning(contact.name),
            ),
            actions: [
              PlatformAdaptive.dialogAction(
                context: dialogContext,
                label: l10n.cancelButtonLabel,
                onPressed: () => NavigationUtils.maybePop(dialogContext),
              ),
              PlatformAdaptive.dialogAction(
                context: dialogContext,
                label: l10n.deleteButtonLabel,
                isDestructive: true,
                onPressed: () {
                  NavigationUtils.maybePop(dialogContext);
                  unawaited(chatListCubit.deleteContact(contact.id));
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
