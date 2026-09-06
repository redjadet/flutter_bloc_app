import 'package:flutter_bloc_app/features/chat/domain/chat_contact.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_failure.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_list_state.freezed.dart';

/// Union state for the chat list cubit.
@freezed
sealed class ChatListState with _$ChatListState {
  const factory initial() = ChatListInitial;

  const factory loading() = ChatListLoading;

  const factory loaded({required List<ChatContact> contacts}) = ChatListLoaded;

  const factory error({required ChatFailure failure}) = ChatListError;
}
