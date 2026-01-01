import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/pages/chat_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_bloc_app/shared/services/error_notification_service.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_bloc_app/shared/widgets/message_bubble.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _FakeChatRepository implements ChatRepository {
  @override
  Future<ChatResult> sendMessage({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
    String? model,
    String? conversationId,
    String? clientMessageId,
  }) async => const ChatResult(
    reply: ChatMessage(author: ChatAuthor.assistant, text: 'hi'),
    pastUserInputs: <String>[],
    generatedResponses: <String>[],
  );
}

class _MemoryHistoryRepository implements ChatHistoryRepository {
  _MemoryHistoryRepository(this._conversations);

  List<ChatConversation> _conversations;

  @override
  Future<List<ChatConversation>> load() async => _conversations;

  @override
  Future<void> save(List<ChatConversation> conversations) async {
    _conversations = conversations;
  }
}

class _MockPendingSyncRepository extends Mock
    implements PendingSyncRepository {}

class _MockNetworkStatusService extends Mock implements NetworkStatusService {}

class _MockBackgroundSyncCoordinator extends Mock
    implements BackgroundSyncCoordinator {}

class _MockErrorNotificationService extends Mock
    implements ErrorNotificationService {}

class _FakeBuildContext extends Fake implements BuildContext {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(_FakeBuildContext());
  });

  group('ChatPage history selection', () {
    late _MemoryHistoryRepository historyRepository;
    late _MockPendingSyncRepository pendingSyncRepository;
    late _MockNetworkStatusService networkStatusService;
    late _MockBackgroundSyncCoordinator coordinator;
    late _MockErrorNotificationService errorNotificationService;

    setUp(() {
      pendingSyncRepository = _MockPendingSyncRepository();
      networkStatusService = _MockNetworkStatusService();
      coordinator = _MockBackgroundSyncCoordinator();
      errorNotificationService = _MockErrorNotificationService();

      when(
        () => pendingSyncRepository.getPendingOperations(
          now: any(named: 'now'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => <SyncOperation>[]);
      when(
        () => networkStatusService.statusStream,
      ).thenAnswer((_) => Stream<NetworkStatus>.value(NetworkStatus.online));
      when(
        () => networkStatusService.getCurrentStatus(),
      ).thenAnswer((_) async => NetworkStatus.online);
      when(() => coordinator.currentStatus).thenReturn(SyncStatus.idle);
      when(() => coordinator.latestSummary).thenReturn(null);
      when(() => coordinator.history).thenReturn(const <SyncCycleSummary>[]);
      when(
        () => coordinator.statusStream,
      ).thenAnswer((_) => const Stream<SyncStatus>.empty());
      when(
        () => coordinator.summaryStream,
      ).thenAnswer((_) => const Stream<SyncCycleSummary>.empty());
      when(() => coordinator.flush()).thenAnswer((_) async {});
      when(() => coordinator.ensureStarted()).thenAnswer((_) async {});
      when(
        () => errorNotificationService.showSnackBar(any(), any()),
      ).thenAnswer((_) async {});
    });

    tearDown(() {});

    Widget buildSubject(ChatCubit cubit) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<ChatCubit>.value(value: cubit),
          BlocProvider<SyncStatusCubit>(
            create: (_) => SyncStatusCubit(
              networkStatusService: networkStatusService,
              coordinator: coordinator,
            ),
          ),
        ],
        child: ChatPage(
          errorNotificationService: errorNotificationService,
          pendingSyncRepository: pendingSyncRepository,
        ),
      ),
    );

    testWidgets(
      'loads messages when selecting conversation from history sheet',
      (tester) async {
        historyRepository = _MemoryHistoryRepository(<ChatConversation>[
          ChatConversation(
            id: 'conv-1',
            messages: const <ChatMessage>[
              ChatMessage(author: ChatAuthor.user, text: 'Hello world'),
              ChatMessage(author: ChatAuthor.assistant, text: 'Hi there'),
            ],
            pastUserInputs: const <String>['Hello world'],
            generatedResponses: const <String>['Hi there'],
            createdAt: DateTime(2024, 1, 1, 12, 0),
            updatedAt: DateTime(2024, 1, 1, 12, 5),
          ),
          ChatConversation(
            id: 'conv-2',
            messages: const <ChatMessage>[
              ChatMessage(author: ChatAuthor.user, text: 'Another'),
              ChatMessage(author: ChatAuthor.assistant, text: 'Reply'),
            ],
            pastUserInputs: const <String>['Another'],
            generatedResponses: const <String>['Reply'],
            createdAt: DateTime(2024, 1, 1, 11, 50),
            updatedAt: DateTime(2024, 1, 1, 11, 55),
          ),
        ]);

        final ChatCubit cubit = ChatCubit(
          repository: _FakeChatRepository(),
          historyRepository: historyRepository,
        );
        addTearDown(cubit.close);
        await cubit.loadHistory();

        await tester.pumpWidget(buildSubject(cubit));
        await tester.pumpAndSettle();

        // Open history sheet
        await tester.tap(
          find.byTooltip(AppLocalizationsEn().chatHistoryShowTooltip),
        );
        await tester.pumpAndSettle();

        // Tap second conversation
        await tester.tap(
          find.text(AppLocalizationsEn().chatHistoryConversationTitle(2)),
        );
        await tester.pumpAndSettle();

        // Verify messages from selected conversation render
        // RichText widgets contain the message text
        final RichText anotherRichText = tester.widget<RichText>(
          find.descendant(
            of: find.byType(MessageBubble).first,
            matching: find.byType(RichText),
          ),
        );
        expect(anotherRichText.text.toPlainText(), contains('Another'));

        final RichText replyRichText = tester.widget<RichText>(
          find.descendant(
            of: find.byType(MessageBubble).last,
            matching: find.byType(RichText),
          ),
        );
        expect(replyRichText.text.toPlainText(), contains('Reply'));
        expect(cubit.state.activeConversationId, 'conv-2');
      },
    );
  });
}
