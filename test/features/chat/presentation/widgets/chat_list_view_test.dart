import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_contact.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_list_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_list_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_list_view.dart';
import 'package:flutter_bloc_app/shared/services/error_notification_service.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mocktail/mocktail.dart';

class MockChatListRepository extends Mock implements ChatListRepository {}

class MockChatRepository extends Mock implements ChatRepository {}

class MockChatHistoryRepository extends Mock implements ChatHistoryRepository {}

class MockErrorNotificationService extends Mock
    implements ErrorNotificationService {}

void main() {
  group('ChatListView', () {
    late MockChatListRepository mockRepository;
    late MockChatRepository chatRepository;
    late MockChatHistoryRepository historyRepository;
    late MockErrorNotificationService errorNotificationService;

    setUp(() {
      mockRepository = MockChatListRepository();
      chatRepository = MockChatRepository();
      historyRepository = MockChatHistoryRepository();
      errorNotificationService = MockErrorNotificationService();
    });

    Widget createWidgetUnderTest({required ChatListState initialState}) {
      return MaterialApp(
        home: BlocProvider<ChatListCubit>(
          create: (context) =>
              ChatListCubit(repository: mockRepository)..emit(initialState),
          child: Scaffold(
            body: ChatListView(
              chatRepository: chatRepository,
              historyRepository: historyRepository,
              errorNotificationService: errorNotificationService,
              pendingSyncRepository: _FakePendingSyncRepository(),
            ),
          ),
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

      expect(find.text('Network error'), findsOneWidget);
      expect(find.text('TRY AGAIN'), findsOneWidget);
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

      await tester.tap(find.text('TRY AGAIN'));
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

      // Should find dividers for each gap plus leading and trailing
      expect(find.byType(Divider), findsNWidgets(mockContacts.length + 1));
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
      await tester.pump(); // Don't wait for network images to load

      expect(find.byType(ListView), findsOneWidget);

      // Test tablet size
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpWidget(
        createWidgetUnderTest(
          initialState: ChatListState.loaded(contacts: mockContacts),
        ),
      );
      await tester.pump(); // Don't wait for network images to load

      expect(find.byType(ListView), findsOneWidget);

      // Test desktop size
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpWidget(
        createWidgetUnderTest(
          initialState: ChatListState.loaded(contacts: mockContacts),
        ),
      );
      await tester.pump(); // Don't wait for network images to load

      expect(find.byType(ListView), findsOneWidget);
    });
  });
}

class _FakePendingSyncRepository implements PendingSyncRepository {
  @override
  String get boxName => 'fake-pending-sync';

  @override
  Future<SyncOperation> enqueue(final SyncOperation operation) async =>
      operation;

  @override
  Future<int> prune({
    int maxRetryCount = 10,
    Duration maxAge = const Duration(days: 30),
  }) async => 0;

  @override
  Future<List<SyncOperation>> getPendingOperations({
    DateTime? now,
    int? limit,
  }) async => const <SyncOperation>[];

  @override
  Future<void> markCompleted(final String operationId) async {}

  @override
  Future<void> markFailed({
    required final String operationId,
    required final DateTime nextRetryAt,
    final int? retryCount,
  }) async {}

  @override
  Future<void> clear() async {}

  @override
  Future<Box<dynamic>> getBox() =>
      Future<Box<dynamic>>.error(UnimplementedError('Not used in fake'));

  @override
  Future<void> safeDeleteKey(final Box<dynamic> box, final String key) async {}
}
