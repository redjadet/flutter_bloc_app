import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_contact.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_list_repository.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_list_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_list_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatListRepository extends Mock implements ChatListRepository {}

void main() {
  group('ChatListView', () {
    late MockChatListRepository mockRepository;

    setUp(() {
      mockRepository = MockChatListRepository();
    });

    Widget createWidgetUnderTest({required ChatListState initialState}) {
      return MaterialApp(
        home: BlocProvider<ChatListCubit>(
          create: (context) =>
              ChatListCubit(repository: mockRepository)..emit(initialState),
          child: const Scaffold(body: ChatListView()),
        ),
      );
    }

    testWidgets('should show nothing when state is initial', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(initialState: const ChatListState.initial()),
      );

      expect(find.byType(ChatListView), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should show loading indicator when state is loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(initialState: const ChatListState.loading()),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('should show contact list when state is loaded', (
      tester,
    ) async {
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

      await tester.pumpWidget(
        createWidgetUnderTest(
          initialState: ChatListState.loaded(contacts: mockContacts),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);
      expect(find.text('Hello there!'), findsOneWidget);
      expect(find.text('How are you?'), findsOneWidget);
    });

    testWidgets('should show error state when state is error', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          initialState: const ChatListState.error(message: 'Network error'),
        ),
      );

      expect(find.text('Error loading chats'), findsOneWidget);
      expect(find.text('Network error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should call loadChatContacts when retry button is tapped', (
      tester,
    ) async {
      when(() => mockRepository.getChatContacts()).thenAnswer((_) async => []);

      await tester.pumpWidget(
        createWidgetUnderTest(
          initialState: const ChatListState.error(message: 'Network error'),
        ),
      );

      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(() => mockRepository.getChatContacts()).called(1);
    });

    testWidgets('should show dividers between contacts', (tester) async {
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

      await tester.pumpWidget(
        createWidgetUnderTest(
          initialState: ChatListState.loaded(contacts: mockContacts),
        ),
      );

      // Should find dividers (one less than the number of contacts)
      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('should handle responsive padding', (tester) async {
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

      // Test mobile size
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        createWidgetUnderTest(
          initialState: ChatListState.loaded(contacts: mockContacts),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);

      // Test tablet size
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(
        createWidgetUnderTest(
          initialState: ChatListState.loaded(contacts: mockContacts),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);

      // Test desktop size
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        createWidgetUnderTest(
          initialState: ChatListState.loaded(contacts: mockContacts),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
