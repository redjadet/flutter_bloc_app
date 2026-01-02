part of 'chat_list_cubit.dart';

// Generated exhaustive switch helper for ChatListState
extension ChatListStateSwitchHelper on ChatListState {
  /// Exhaustive pattern matching helper
  T when<T>({
    required final T Function() initial,
    required final T Function() loading,
    required final T Function(List<ChatContact> contacts) loaded,
    required final T Function(String message) error,
  }) => switch (this) {
    ChatListInitial() => initial(),
    ChatListLoading() => loading(),
    ChatListLoaded(:final contacts) => loaded(contacts),
    ChatListError(:final message) => error(message),
  };
}
