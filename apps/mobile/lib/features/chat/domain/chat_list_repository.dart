import 'package:flutter_bloc_app/features/chat/domain/chat_contact.dart';

abstract class ChatListRepository {
  Future<List<ChatContact>> getChatContacts();
  Future<void> deleteChatContact(final String contactId);
  Future<void> markAsRead(final String contactId);
}
