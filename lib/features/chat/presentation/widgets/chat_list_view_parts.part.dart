part of 'chat_list_view.dart';

const ListEquality<ChatContact> _chatContactListEquality =
    ListEquality<ChatContact>();

/// Narrow selector data to reduce rebuilds when only unrelated state changes.
@immutable
class _ChatListSelectorData {
  const _ChatListSelectorData({
    required this.isLoading,
    this.contacts,
    this.errorMessage,
  });

  final bool isLoading;
  final List<ChatContact>? contacts;
  final String? errorMessage;

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is _ChatListSelectorData &&
          isLoading == other.isLoading &&
          _chatContactListEquality.equals(contacts, other.contacts) &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(
    isLoading,
    switch (contacts) {
      final contacts? => _chatContactListEquality.hash(contacts),
      null => null,
    },
    errorMessage,
  );
}

class _ChatDivider extends StatelessWidget {
  const _ChatDivider();

  @override
  Widget build(final BuildContext context) => Divider(
    height: 0.5,
    thickness: 0.5,
    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
  );
}
