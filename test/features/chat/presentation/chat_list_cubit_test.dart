import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_contact.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_list_repository.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_list_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatListRepository extends Mock implements ChatListRepository {}

void main() {
  group('ChatListCubit', () {
    late ChatListCubit chatListCubit;
    late MockChatListRepository mockRepository;

    setUp(() {
      mockRepository = MockChatListRepository();
      chatListCubit = ChatListCubit(repository: mockRepository);
    });

    tearDown(() {
      chatListCubit.close();
    });

    test('initial state is ChatListInitial', () {
      expect(chatListCubit.state, equals(const ChatListState.initial()));
    });

    group('loadChatContacts', () {
      final mockContacts = [
        ChatContact(
          id: '1',
          name: 'John Doe',
          lastMessage: 'Hello there!',
          profileImageUrl: 'https://example.com/image1.jpg',
          lastMessageTime: DateTime(2024, 1, 1, 12, 0),
          isOnline: true,
          unreadCount: 2,
        ),
        ChatContact(
          id: '2',
          name: 'Jane Smith',
          lastMessage: 'How are you?',
          profileImageUrl: 'https://example.com/image2.jpg',
          lastMessageTime: DateTime(2024, 1, 1, 11, 0),
          isOnline: false,
          unreadCount: 0,
        ),
      ];

      blocTest<ChatListCubit, ChatListState>(
        'emits [loading, loaded] when repository returns contacts',
        build: () {
          when(
            () => mockRepository.getChatContacts(),
          ).thenAnswer((_) async => mockContacts);
          return chatListCubit;
        },
        act: (cubit) => cubit.loadChatContacts(),
        expect: () => [
          const ChatListState.loading(),
          ChatListState.loaded(contacts: mockContacts),
        ],
        verify: (_) {
          verify(() => mockRepository.getChatContacts()).called(1);
        },
      );

      blocTest<ChatListCubit, ChatListState>(
        'emits [loading, error] when repository throws exception',
        build: () {
          when(
            () => mockRepository.getChatContacts(),
          ).thenThrow(Exception('Network error'));
          return chatListCubit;
        },
        act: (cubit) => cubit.loadChatContacts(),
        expect: () => [
          const ChatListState.loading(),
          const ChatListState.error(message: 'Exception: Network error'),
        ],
        verify: (_) {
          verify(() => mockRepository.getChatContacts()).called(1);
        },
      );
    });

    group('deleteContact', () {
      final mockContacts = [
        ChatContact(
          id: '1',
          name: 'John Doe',
          lastMessage: 'Hello there!',
          profileImageUrl: 'https://example.com/image1.jpg',
          lastMessageTime: DateTime(2024, 1, 1, 12, 0),
          isOnline: true,
          unreadCount: 2,
        ),
        ChatContact(
          id: '2',
          name: 'Jane Smith',
          lastMessage: 'How are you?',
          profileImageUrl: 'https://example.com/image2.jpg',
          lastMessageTime: DateTime(2024, 1, 1, 11, 0),
          isOnline: false,
          unreadCount: 0,
        ),
      ];

      blocTest<ChatListCubit, ChatListState>(
        'does nothing when state is not loaded',
        build: () => chatListCubit,
        act: (cubit) => cubit.deleteContact('1'),
        expect: () => [],
      );

      blocTest<ChatListCubit, ChatListState>(
        'emits updated state with contact removed when successful',
        build: () {
          when(
            () => mockRepository.deleteChatContact('1'),
          ).thenAnswer((_) async {});
          return chatListCubit;
        },
        seed: () => ChatListState.loaded(contacts: mockContacts),
        act: (cubit) => cubit.deleteContact('1'),
        expect: () => [
          ChatListState.loaded(
            contacts: [
              ChatContact(
                id: '2',
                name: 'Jane Smith',
                lastMessage: 'How are you?',
                profileImageUrl: 'https://example.com/image2.jpg',
                lastMessageTime: DateTime(2024, 1, 1, 11, 0),
                isOnline: false,
                unreadCount: 0,
              ),
            ],
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.deleteChatContact('1')).called(1);
        },
      );

      blocTest<ChatListCubit, ChatListState>(
        'emits error state when repository throws exception',
        build: () {
          when(
            () => mockRepository.deleteChatContact('1'),
          ).thenThrow(Exception('Delete failed'));
          return chatListCubit;
        },
        seed: () => ChatListState.loaded(contacts: mockContacts),
        act: (cubit) => cubit.deleteContact('1'),
        expect: () => [
          const ChatListState.error(message: 'Exception: Delete failed'),
        ],
        verify: (_) {
          verify(() => mockRepository.deleteChatContact('1')).called(1);
        },
      );
    });

    group('markAsRead', () {
      final mockContacts = [
        ChatContact(
          id: '1',
          name: 'John Doe',
          lastMessage: 'Hello there!',
          profileImageUrl: 'https://example.com/image1.jpg',
          lastMessageTime: DateTime(2024, 1, 1, 12, 0),
          isOnline: true,
          unreadCount: 2,
        ),
      ];

      blocTest<ChatListCubit, ChatListState>(
        'does nothing when state is not loaded',
        build: () => chatListCubit,
        act: (cubit) => cubit.markAsRead('1'),
        expect: () => [],
      );

      blocTest<ChatListCubit, ChatListState>(
        'emits updated state with unread count reset when successful',
        build: () {
          when(() => mockRepository.markAsRead('1')).thenAnswer((_) async {});
          return chatListCubit;
        },
        seed: () => ChatListState.loaded(contacts: mockContacts),
        act: (cubit) => cubit.markAsRead('1'),
        expect: () => [
          ChatListState.loaded(
            contacts: [
              ChatContact(
                id: '1',
                name: 'John Doe',
                lastMessage: 'Hello there!',
                profileImageUrl: 'https://example.com/image1.jpg',
                lastMessageTime: DateTime(2024, 1, 1, 12, 0),
                isOnline: true,
                unreadCount: 0,
              ),
            ],
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.markAsRead('1')).called(1);
        },
      );

      blocTest<ChatListCubit, ChatListState>(
        'emits error state when repository throws exception',
        build: () {
          when(
            () => mockRepository.markAsRead('1'),
          ).thenThrow(Exception('Mark as read failed'));
          return chatListCubit;
        },
        seed: () => ChatListState.loaded(contacts: mockContacts),
        act: (cubit) => cubit.markAsRead('1'),
        expect: () => [
          const ChatListState.error(message: 'Exception: Mark as read failed'),
        ],
        verify: (_) {
          verify(() => mockRepository.markAsRead('1')).called(1);
        },
      );
    });
  });
}
