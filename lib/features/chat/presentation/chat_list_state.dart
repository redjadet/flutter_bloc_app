import 'package:flutter_bloc_app/features/chat/domain/chat_contact.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_list_state.freezed.dart';

/// Union state for the chat list cubit.
@freezed
sealed class ChatListState with _$ChatListState {
  const factory ChatListState.initial() = ChatListInitial;

  const factory ChatListState.loading() = ChatListLoading;

  const factory ChatListState.loaded({
    required final List<ChatContact> contacts,
  }) = ChatListLoaded;

  const factory ChatListState.error({
    required final String message,
  }) = ChatListError;
}
