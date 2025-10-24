import 'package:flutter_bloc_app/features/chat/data/mock_chat_list_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_contact.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MockChatListRepository', () {
    late MockChatListRepository repository;

    setUp(() {
      repository = MockChatListRepository();
    });

    group('getChatContacts', () {
      test('should return list of mock contacts', () async {
        final contacts = await repository.getChatContacts();

        expect(contacts, isA<List<ChatContact>>());
        expect(contacts.length, greaterThan(0));

        // Verify first contact has expected structure
        final firstContact = contacts.first;
        expect(firstContact.id, isNotEmpty);
        expect(firstContact.name, isNotEmpty);
        expect(firstContact.lastMessage, isNotEmpty);
        expect(firstContact.profileImageUrl, isNotEmpty);
        expect(firstContact.lastMessageTime, isA<DateTime>());
        expect(firstContact.isOnline, isA<bool>());
        expect(firstContact.unreadCount, isA<int>());
      });

      test('should simulate network delay', () async {
        final stopwatch = Stopwatch()..start();
        await repository.getChatContacts();
        stopwatch.stop();

        // Should take at least 500ms (simulated network delay)
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(400));
      });
    });

    group('deleteChatContact', () {
      test('should remove contact from mock data', () async {
        final initialContacts = await repository.getChatContacts();
        final initialLength = initialContacts.length;

        // Delete the first contact
        await repository.deleteChatContact(initialContacts.first.id);

        final updatedContacts = await repository.getChatContacts();
        expect(updatedContacts.length, equals(initialLength - 1));

        // Verify the deleted contact is not in the list
        final deletedContactExists = updatedContacts.any(
          (contact) => contact.id == initialContacts.first.id,
        );
        expect(deletedContactExists, isFalse);
      });

      test('should simulate network delay', () async {
        final stopwatch = Stopwatch()..start();
        await repository.deleteChatContact('1');
        stopwatch.stop();

        // Should take at least 300ms (simulated network delay)
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(250));
      });
    });

    group('markAsRead', () {
      test('should reset unread count to 0', () async {
        final contacts = await repository.getChatContacts();

        // Find a contact with unread messages
        final contactWithUnread = contacts.firstWhere(
          (contact) => contact.unreadCount > 0,
          orElse: () => contacts.first,
        );

        await repository.markAsRead(contactWithUnread.id);

        final updatedContacts = await repository.getChatContacts();
        final updatedContact = updatedContacts.firstWhere(
          (contact) => contact.id == contactWithUnread.id,
        );

        expect(updatedContact.unreadCount, equals(0));
      });

      test('should simulate network delay', () async {
        final stopwatch = Stopwatch()..start();
        await repository.markAsRead('1');
        stopwatch.stop();

        // Should take at least 200ms (simulated network delay)
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(150));
      });
    });
  });
}
