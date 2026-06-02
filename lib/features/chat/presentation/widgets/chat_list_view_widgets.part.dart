part of 'chat_list_view.dart';

class _ChatLoadedList extends StatelessWidget {
  const _ChatLoadedList({
    required this.contacts,
    required this.onContactTap,
    required this.onContactLongPress,
  });

  final List<ChatContact> contacts;
  final void Function(ChatContact contact) onContactTap;
  final void Function(ChatContact contact) onContactLongPress;

  @override
  Widget build(final BuildContext context) {
    if (contacts.isEmpty) {
      return CommonEmptyState(
        message: context.l10n.chatHistoryEmpty,
      );
    }

    final EdgeInsetsGeometry safeListPadding = context.responsiveListPadding
        .add(
          EdgeInsets.only(
            bottom: context.bottomInset + context.responsiveGap,
          ),
        );

    return SafeArea(
      top: false,
      bottom: false,
      child: CommonMaxWidth(
        child: ListView.separated(
          scrollCacheExtent: const ScrollCacheExtent.pixels(500),
          padding: safeListPadding,
          itemCount: contacts.length,
          separatorBuilder: (final context, final index) =>
              const _ChatDivider(),
          itemBuilder: (final context, final index) {
            final contact = contacts[index];
            return _ChatContactListItem(
              key: ValueKey<String>('chat-contact-row-${contact.id}'),
              contact: contact,
              isFirst: index == 0,
              isLast: index == contacts.length - 1,
              onTap: onContactTap,
              onLongPress: onContactLongPress,
            );
          },
        ),
      ),
    );
  }
}

class _ChatContactListItem extends StatelessWidget {
  const _ChatContactListItem({
    required this.contact,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
    required this.onLongPress,
    super.key,
  });

  final ChatContact contact;
  final bool isFirst;
  final bool isLast;
  final void Function(ChatContact contact) onTap;
  final void Function(ChatContact contact) onLongPress;

  @override
  Widget build(final BuildContext context) {
    return RepaintBoundary(
      key: ValueKey<String>('chat-contact-${contact.id}'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (isFirst) const _ChatDivider(),
          ChatContactTile(
            contact: contact,
            onTap: () => onTap(contact),
            onLongPress: () => onLongPress(contact),
          ),
          if (isLast) const _ChatDivider(),
        ],
      ),
    );
  }
}

class _ChatListErrorState extends StatelessWidget {
  const _ChatListErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(final BuildContext context) => CommonErrorView(
    message: message,
    onRetry: onRetry,
  );
}
