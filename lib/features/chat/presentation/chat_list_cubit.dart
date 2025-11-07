import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_contact.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_list_repository.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';

part 'chat_list_state.dart';

class ChatListCubit extends Cubit<ChatListState> {
  ChatListCubit({
    required ChatListRepository repository,
  }) : _repository = repository,
       super(const ChatListState.initial());

  final ChatListRepository _repository;

  Future<void> loadChatContacts() async {
    emit(const ChatListState.loading());

    await CubitExceptionHandler.executeAsync(
      operation: _repository.getChatContacts,
      onSuccess: (final List<ChatContact> contacts) {
        emit(ChatListState.loaded(contacts: contacts));
      },
      onError: (final String message) {
        emit(ChatListState.error(message: message));
      },
      logContext: 'ChatListCubit.loadChatContacts',
    );
  }

  Future<void> deleteContact(String contactId) async {
    final currentState = state;
    if (currentState is! ChatListLoaded) return;

    await CubitExceptionHandler.executeAsyncVoid(
      operation: () async {
        await _repository.deleteChatContact(contactId);
        final List<ChatContact> updatedContacts = currentState.contacts
            .where((contact) => contact.id != contactId)
            .toList();
        emit(ChatListState.loaded(contacts: updatedContacts));
      },
      onError: (final String message) {
        emit(ChatListState.error(message: message));
      },
      logContext: 'ChatListCubit.deleteContact',
    );
  }

  Future<void> markAsRead(String contactId) async {
    final currentState = state;
    if (currentState is! ChatListLoaded) return;

    await CubitExceptionHandler.executeAsyncVoid(
      operation: () async {
        await _repository.markAsRead(contactId);
        final List<ChatContact> updatedContacts = currentState.contacts.map((
          contact,
        ) {
          if (contact.id == contactId) {
            return contact.copyWith(unreadCount: 0);
          }
          return contact;
        }).toList();
        emit(ChatListState.loaded(contacts: updatedContacts));
      },
      onError: (final String message) {
        emit(ChatListState.error(message: message));
      },
      logContext: 'ChatListCubit.markAsRead',
    );
  }
}
