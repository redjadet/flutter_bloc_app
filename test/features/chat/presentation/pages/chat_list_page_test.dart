import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_contact.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_list_repository.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_list_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/pages/chat_list_page.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_bottom_navigation_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatListRepository extends Mock implements ChatListRepository {}

void main() {
  group('ChatListPage', () {
    late MockChatListRepository mockRepository;

    setUp(() {
      mockRepository = MockChatListRepository();
      // Register mock repository in GetIt for testing
      getIt.reset();
      getIt.registerLazySingleton<ChatListRepository>(() => mockRepository);
    });

    tearDown(() {
      getIt.reset();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(home: ChatListPage(repository: mockRepository));
    }

    testWidgets('should display app bar with correct title', (tester) async {
      when(() => mockRepository.getChatContacts()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Chats'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('does not display bottom navigation bar', (tester) async {
      when(() => mockRepository.getChatContacts()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(ChatBottomNavigationBar), findsNothing);
    });

    testWidgets('should load and display chat contacts', (tester) async {
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

      when(
        () => mockRepository.getChatContacts(),
      ).thenAnswer((_) async => mockContacts);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Initial pump
      await tester.pump(
        const Duration(milliseconds: 100),
      ); // Allow async operations
      // Don't use pumpAndSettle() as it waits for network images which never load in tests

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);
      expect(find.text('Hello there!'), findsOneWidget);
      expect(find.text('How are you?'), findsOneWidget);
    });

    testWidgets('should show loading state initially', (tester) async {
      // Use a completer to control when the future completes
      final completer = Completer<List<ChatContact>>();
      when(
        () => mockRepository.getChatContacts(),
      ).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Should show loading indicator initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future to avoid hanging
      completer.complete([]);
    });

    testWidgets('should handle error state', (tester) async {
      when(
        () => mockRepository.getChatContacts(),
      ).thenThrow(Exception('Network error'));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Error loading chats'), findsOneWidget);
      expect(find.text('Exception: Network error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should handle responsive design', (tester) async {
      when(() => mockRepository.getChatContacts()).thenAnswer((_) async => []);

      // Test mobile size
      await tester.binding.setSurfaceSize(const Size(400, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(ChatListPage), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(ChatBottomNavigationBar), findsNothing);

      // Test tablet size
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(ChatListPage), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(ChatBottomNavigationBar), findsNothing);

      // Test desktop size
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(ChatListPage), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(ChatBottomNavigationBar), findsNothing);
    });

    testWidgets('should have correct scaffold structure', (tester) async {
      when(() => mockRepository.getChatContacts()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(BlocProvider<ChatListCubit>), findsOneWidget);
    });

    testWidgets('should call repository on initialization', (tester) async {
      when(() => mockRepository.getChatContacts()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      verify(() => mockRepository.getChatContacts()).called(1);
    });
  });
}
