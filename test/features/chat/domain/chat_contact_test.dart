import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_contact.dart';

void main() {
  group('ChatContact', () {
    final testContact = ChatContact(
      id: '1',
      name: 'John Doe',
      lastMessage: 'Hello there!',
      profileImageUrl: 'https://example.com/image1.jpg',
      lastMessageTime: DateTime(2024, 1, 1, 12, 0),
      isOnline: true,
      unreadCount: 2,
    );

    test('should create instance with all required parameters', () {
      expect(testContact.id, equals('1'));
      expect(testContact.name, equals('John Doe'));
      expect(testContact.lastMessage, equals('Hello there!'));
      expect(
        testContact.profileImageUrl,
        equals('https://example.com/image1.jpg'),
      );
      expect(testContact.lastMessageTime, equals(DateTime(2024, 1, 1, 12, 0)));
      expect(testContact.isOnline, equals(true));
      expect(testContact.unreadCount, equals(2));
    });

    test(
      'should create instance with default values for optional parameters',
      () {
        final contact = ChatContact(
          id: '2',
          name: 'Jane Smith',
          lastMessage: 'How are you?',
          profileImageUrl: 'https://example.com/image2.jpg',
          lastMessageTime: DateTime(2024, 1, 1, 11, 0),
        );

        expect(contact.isOnline, equals(false));
        expect(contact.unreadCount, equals(0));
      },
    );

    test('should support copyWith method', () {
      final updatedContact = testContact.copyWith(
        name: 'John Updated',
        unreadCount: 5,
      );

      expect(updatedContact.id, equals('1'));
      expect(updatedContact.name, equals('John Updated'));
      expect(updatedContact.lastMessage, equals('Hello there!'));
      expect(
        updatedContact.profileImageUrl,
        equals('https://example.com/image1.jpg'),
      );
      expect(
        updatedContact.lastMessageTime,
        equals(DateTime(2024, 1, 1, 12, 0)),
      );
      expect(updatedContact.isOnline, equals(true));
      expect(updatedContact.unreadCount, equals(5));
    });

    test('should support equality comparison', () {
      final contact1 = ChatContact(
        id: '1',
        name: 'John Doe',
        lastMessage: 'Hello there!',
        profileImageUrl: 'https://example.com/image1.jpg',
        lastMessageTime: DateTime(2024, 1, 1, 12, 0),
        isOnline: true,
        unreadCount: 2,
      );

      final contact2 = ChatContact(
        id: '1',
        name: 'John Doe',
        lastMessage: 'Hello there!',
        profileImageUrl: 'https://example.com/image1.jpg',
        lastMessageTime: DateTime(2024, 1, 1, 12, 0),
        isOnline: true,
        unreadCount: 2,
      );

      final contact3 = ChatContact(
        id: '2',
        name: 'Jane Smith',
        lastMessage: 'How are you?',
        profileImageUrl: 'https://example.com/image2.jpg',
        lastMessageTime: DateTime(2024, 1, 1, 11, 0),
        isOnline: false,
        unreadCount: 0,
      );

      expect(contact1, equals(contact2));
      expect(contact1, isNot(equals(contact3)));
    });

    test('equality uses all properties', () {
      expect(testContact.id, '1');
      expect(testContact.name, 'John Doe');
      expect(testContact.lastMessage, 'Hello there!');
      expect(testContact.profileImageUrl, 'https://example.com/image1.jpg');
      expect(testContact.lastMessageTime, DateTime(2024, 1, 1, 12, 0));
      expect(testContact.isOnline, true);
      expect(testContact.unreadCount, 2);
    });
  });
}
