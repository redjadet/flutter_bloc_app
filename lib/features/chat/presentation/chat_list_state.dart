part of 'chat_list_cubit.dart';

abstract class ChatListState extends Equatable {
  const ChatListState();

  const factory ChatListState.initial() = ChatListInitial;
  const factory ChatListState.loading() = ChatListLoading;
  const factory ChatListState.loaded({
    required final List<ChatContact> contacts,
  }) = ChatListLoaded;
  const factory ChatListState.error({
    required final String message,
  }) = ChatListError;

  @override
  List<Object?> get props => [];
}

class ChatListInitial extends ChatListState {
  const ChatListInitial();
}

class ChatListLoading extends ChatListState {
  const ChatListLoading();
}

class ChatListLoaded extends ChatListState {
  const ChatListLoaded({required this.contacts});

  final List<ChatContact> contacts;

  @override
  List<Object?> get props => [contacts];
}

class ChatListError extends ChatListState {
  const ChatListError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
