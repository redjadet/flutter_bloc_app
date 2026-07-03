import 'package:flutter_bloc_app/features/chat/domain/chat_contact.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_list_repository.dart';

class MockChatListRepository implements ChatListRepository {
  static final List<ChatContact> _mockContacts = [
    ChatContact(
      id: '1',
      name: 'James',
      lastMessage: 'Thank you! That was very helpful!',
      profileImageUrl: 'assets/figma/Chats_mockup_0-702/Ellipse_0-713.svg',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      isOnline: true,
    ),
    ChatContact(
      id: '2',
      name: 'Will Kenny',
      lastMessage: "I know... I'm trying to get the funds.",
      profileImageUrl: 'assets/figma/Chats_mockup_0-702/Ellipse_0-722.svg',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
      unreadCount: 2,
    ),
    ChatContact(
      id: '3',
      name: 'Beth Williams',
      lastMessage:
          "I'm looking for tips around capturing the milky way. I have a 6D with a 24-100mm...",
      profileImageUrl: 'assets/figma/Chats_mockup_0-702/Ellipse_0-723.svg',
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
      isOnline: true,
      unreadCount: 1,
    ),
    ChatContact(
      id: '4',
      name: 'Rev Shawn',
      lastMessage:
          "Wanted to ask if you're available for a portrait shoot next week.",
      profileImageUrl: 'assets/figma/Chats_mockup_0-702/Ellipse_0-724.svg',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Future<List<ChatContact>> getChatContacts() async {
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return List.from(_mockContacts);
  }

  @override
  Future<void> deleteChatContact(final String contactId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _mockContacts.removeWhere((final contact) => contact.id == contactId);
  }

  @override
  Future<void> markAsRead(final String contactId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final index = _mockContacts.indexWhere(
      (final contact) => contact.id == contactId,
    );
    if (index != -1) {
      _mockContacts[index] = _mockContacts[index].copyWith(unreadCount: 0);
    }
  }
}
