import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_contact.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_list_repository.dart';

part 'chat_list_state.dart';

class ChatListCubit extends Cubit<ChatListState> {
  ChatListCubit({
    required ChatListRepository repository,
  }) : _repository = repository,
       super(const ChatListState.initial());

  final ChatListRepository _repository;

  Future<void> loadChatContacts() async {
    emit(const ChatListState.loading());

    try {
      final contacts = await _repository.getChatContacts();
      emit(ChatListState.loaded(contacts: contacts));
    } on Exception catch (error) {
      emit(ChatListState.error(message: error.toString()));
    }
  }

  Future<void> deleteContact(String contactId) async {
    final currentState = state;
    if (currentState is! ChatListLoaded) return;

    try {
      await _repository.deleteChatContact(contactId);
      final updatedContacts = currentState.contacts
          .where((contact) => contact.id != contactId)
          .toList();
      emit(ChatListState.loaded(contacts: updatedContacts));
    } on Exception catch (error) {
      emit(ChatListState.error(message: error.toString()));
    }
  }

  Future<void> markAsRead(String contactId) async {
    final currentState = state;
    if (currentState is! ChatListLoaded) return;

    try {
      await _repository.markAsRead(contactId);
      final updatedContacts = currentState.contacts.map((contact) {
        if (contact.id == contactId) {
          return contact.copyWith(unreadCount: 0);
        }
        return contact;
      }).toList();
      emit(ChatListState.loaded(contacts: updatedContacts));
    } on Exception catch (error) {
      emit(ChatListState.error(message: error.toString()));
    }
  }
}
