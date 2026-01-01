import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_state.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_message_list.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/services/error_notification_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_bloc_app/shared/widgets/message_bubble.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ChatMessageList shows empty placeholder when no messages', (
    WidgetTester tester,
  ) async {
    final _StubChatCubit cubit = _StubChatCubit(const ChatState());
    addTearDown(cubit.close);
    final ErrorNotificationService errorNotificationService =
        SnackbarErrorNotificationService();

    await tester.pumpWidget(
      _wrapWithApp(
        cubit,
        ChatMessageList(
          controller: ScrollController(),
          errorNotificationService: errorNotificationService,
        ),
      ),
    );

    expect(find.text(AppLocalizationsEn().chatEmptyState), findsOneWidget);
  });

  testWidgets('ChatMessageList renders bubbles and clears error via SnackBar', (
    WidgetTester tester,
  ) async {
    final _StubChatCubit cubit = _StubChatCubit(const ChatState());
    addTearDown(cubit.close);
    final ErrorNotificationService errorNotificationService =
        SnackbarErrorNotificationService();

    await tester.pumpWidget(
      _wrapWithApp(
        cubit,
        ChatMessageList(
          controller: ScrollController(),
          errorNotificationService: errorNotificationService,
        ),
      ),
    );

    cubit.emit(
      ChatState(
        messages: const <ChatMessage>[
          ChatMessage(author: ChatAuthor.user, text: 'hi'),
          ChatMessage(author: ChatAuthor.assistant, text: 'hello'),
        ],
        error: 'boom',
        status: ViewStatus.error,
      ),
    );
    await tester.pump();

    // RichText widgets contain the message text
    final RichText hiRichText = tester.widget<RichText>(
      find.descendant(
        of: find.byType(MessageBubble).first,
        matching: find.byType(RichText),
      ),
    );
    expect(hiRichText.text.toPlainText(), contains('hi'));

    final RichText helloRichText = tester.widget<RichText>(
      find.descendant(
        of: find.byType(MessageBubble).last,
        matching: find.byType(RichText),
      ),
    );
    expect(helloRichText.text.toPlainText(), contains('hello'));

    expect(find.text('boom'), findsOneWidget);

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(
      tester.element(find.byType(Scaffold)),
    );
    messenger.hideCurrentSnackBar();
    messenger.clearSnackBars();
    await tester.pumpAndSettle();

    expect(cubit.clearErrorCalled, isTrue);
  });

  testWidgets('shows pending sync label for unsent user messages', (
    WidgetTester tester,
  ) async {
    final _StubChatCubit cubit = _StubChatCubit(
      const ChatState(
        messages: <ChatMessage>[
          ChatMessage(
            author: ChatAuthor.user,
            text: 'Pending',
            synchronized: false,
          ),
          ChatMessage(author: ChatAuthor.assistant, text: 'Reply'),
        ],
      ),
    );
    addTearDown(cubit.close);
    final ErrorNotificationService errorNotificationService =
        SnackbarErrorNotificationService();

    await tester.pumpWidget(
      _wrapWithApp(
        cubit,
        ChatMessageList(
          controller: ScrollController(),
          errorNotificationService: errorNotificationService,
        ),
      ),
    );
    await tester.pump();

    // RichText widgets contain the message text
    final RichText pendingRichText = tester.widget<RichText>(
      find.descendant(
        of: find.byType(MessageBubble).first,
        matching: find.byType(RichText),
      ),
    );
    expect(pendingRichText.text.toPlainText(), contains('Pending'));

    final RichText replyRichText = tester.widget<RichText>(
      find.descendant(
        of: find.byType(MessageBubble).last,
        matching: find.byType(RichText),
      ),
    );
    expect(replyRichText.text.toPlainText(), contains('Reply'));
    // Pending sync text is no longer displayed in the UI
  });
}

Widget _wrapWithApp(ChatCubit cubit, Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<ChatCubit>.value(value: cubit),
        BlocProvider<SyncStatusCubit>(
          create: (_) => SyncStatusCubit(
            networkStatusService: _FakeNetworkStatusService(),
            coordinator: _FakeBackgroundSyncCoordinator(),
          ),
        ),
      ],
      child: Scaffold(body: child),
    ),
  );
}

class _StubChatCubit extends ChatCubit {
  _StubChatCubit(ChatState initialState)
    : super(
        repository: _StubChatRepository(),
        historyRepository: _StubHistoryRepository(),
      ) {
    emit(initialState);
  }

  bool clearErrorCalled = false;

  @override
  void clearError() {
    clearErrorCalled = true;
    super.clearError();
  }

  @override
  Future<void> loadHistory() async {}
}

class _StubChatRepository implements ChatRepository {
  @override
  Future<ChatResult> sendMessage({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
    String? model,
    String? conversationId,
    String? clientMessageId,
  }) async => const ChatResult(
    reply: ChatMessage(author: ChatAuthor.assistant, text: ''),
    pastUserInputs: <String>[],
    generatedResponses: <String>[],
  );
}

class _StubHistoryRepository implements ChatHistoryRepository {
  @override
  Future<List<ChatConversation>> load() async => const <ChatConversation>[];

  @override
  Future<void> save(List<ChatConversation> conversations) async {}
}

class _FakeNetworkStatusService implements NetworkStatusService {
  @override
  Stream<NetworkStatus> get statusStream => const Stream<NetworkStatus>.empty();

  @override
  Future<NetworkStatus> getCurrentStatus() async => NetworkStatus.online;

  @override
  Future<void> dispose() async {}
}

class _FakeBackgroundSyncCoordinator implements BackgroundSyncCoordinator {
  @override
  Stream<SyncStatus> get statusStream => const Stream<SyncStatus>.empty();

  @override
  SyncStatus get currentStatus => SyncStatus.idle;

  @override
  List<SyncCycleSummary> get history => const <SyncCycleSummary>[];

  @override
  Stream<SyncCycleSummary> get summaryStream =>
      const Stream<SyncCycleSummary>.empty();

  @override
  SyncCycleSummary? get latestSummary => null;

  @override
  Future<void> start() async {}

  @override
  Future<void> ensureStarted() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> flush() async {}
}
