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
import 'package:flutter_bloc_app/shared/services/error_notification_service.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SnackBar uses chatTokenMissing when remoteFailureL10nCode is token_missing', (
    final WidgetTester tester,
  ) async {
    final _StubChatCubit cubit = _StubChatCubit(const ChatState());
    addTearDown(cubit.close);

    await tester.pumpWidget(
      _wrapWithApp(
        cubit,
        ChatMessageList(
          controller: ScrollController(),
          errorNotificationService: SnackbarErrorNotificationService(),
        ),
      ),
    );

    cubit.emit(
      const ChatState(
        messages: <ChatMessage>[ChatMessage(author: ChatAuthor.user, text: 'hi')],
        error: 'opaque-upstream-detail',
        remoteFailureL10nCode: 'token_missing',
        status: ViewStatus.error,
      ),
    );
    await tester.pump();

    expect(find.text(AppLocalizationsEn().chatTokenMissing), findsOneWidget);
    expect(find.text('opaque-upstream-detail'), findsNothing);
  });

  testWidgets('SnackBar uses chatSessionEnded when remoteFailureL10nCode is rate_limited', (
    final WidgetTester tester,
  ) async {
    final _StubChatCubit cubit = _StubChatCubit(const ChatState());
    addTearDown(cubit.close);

    await tester.pumpWidget(
      _wrapWithApp(
        cubit,
        ChatMessageList(
          controller: ScrollController(),
          errorNotificationService: SnackbarErrorNotificationService(),
        ),
      ),
    );

    cubit.emit(
      const ChatState(
        messages: <ChatMessage>[ChatMessage(author: ChatAuthor.user, text: 'hi')],
        error: 'rate limit detail',
        remoteFailureL10nCode: 'rate_limited',
        status: ViewStatus.error,
      ),
    );
    await tester.pump();

    expect(find.text(AppLocalizationsEn().chatSessionEnded), findsOneWidget);
    expect(find.text('rate limit detail'), findsNothing);
  });

  testWidgets('SnackBar uses chatSwitchAccount when remoteFailureL10nCode is forbidden', (
    final WidgetTester tester,
  ) async {
    final _StubChatCubit cubit = _StubChatCubit(const ChatState());
    addTearDown(cubit.close);

    await tester.pumpWidget(
      _wrapWithApp(
        cubit,
        ChatMessageList(
          controller: ScrollController(),
          errorNotificationService: SnackbarErrorNotificationService(),
        ),
      ),
    );

    cubit.emit(
      const ChatState(
        messages: <ChatMessage>[ChatMessage(author: ChatAuthor.user, text: 'hi')],
        error: 'opaque-forbidden-detail',
        remoteFailureL10nCode: 'forbidden',
        status: ViewStatus.error,
      ),
    );
    await tester.pump();

    expect(find.text(AppLocalizationsEn().chatSwitchAccount), findsOneWidget);
    expect(find.text('opaque-forbidden-detail'), findsNothing);
  });

  testWidgets('shows terminal chatTokenMissing for token_missing dead-letter user messages', (
    final WidgetTester tester,
  ) async {
    final _StubChatCubit cubit = _StubChatCubit(
      const ChatState(
        messages: <ChatMessage>[
          ChatMessage(
            author: ChatAuthor.user,
            text: 'Queued',
            clientMessageId: 'm-token-missing',
            synchronized: false,
            terminalSyncFailureCode: 'token_missing',
          ),
        ],
        pastUserInputs: <String>['Queued'],
      ),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      _wrapWithApp(
        cubit,
        ChatMessageList(
          controller: ScrollController(),
          errorNotificationService: SnackbarErrorNotificationService(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text(AppLocalizationsEn().chatTokenMissing), findsOneWidget);
  });

  testWidgets('shows terminal chatSwitchAccount for forbidden dead-letter user messages', (
    final WidgetTester tester,
  ) async {
    final _StubChatCubit cubit = _StubChatCubit(
      const ChatState(
        messages: <ChatMessage>[
          ChatMessage(
            author: ChatAuthor.user,
            text: 'Queued',
            clientMessageId: 'm-forbidden',
            synchronized: false,
            terminalSyncFailureCode: 'forbidden',
          ),
        ],
        pastUserInputs: <String>['Queued'],
      ),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      _wrapWithApp(
        cubit,
        ChatMessageList(
          controller: ScrollController(),
          errorNotificationService: SnackbarErrorNotificationService(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text(AppLocalizationsEn().chatSwitchAccount), findsOneWidget);
  });
}

Widget _wrapWithApp(final ChatCubit cubit, final Widget child) {
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
  _StubChatCubit(final ChatState initialState)
    : super(repository: _StubChatRepository(), historyRepository: _StubHistoryRepository()) {
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
  ChatInferenceTransport? get chatRemoteTransportHint => null;

  @override
  Future<ChatResult> sendMessage({
    required final List<String> pastUserInputs,
    required final List<String> generatedResponses,
    required final String prompt,
    final String? model,
    final String? conversationId,
    final String? clientMessageId,
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
  Future<void> save(final List<ChatConversation> conversations) async {}
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
  Stream<SyncCycleSummary> get summaryStream => const Stream<SyncCycleSummary>.empty();

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

  @override
  Future<void> triggerFromFcm({final String? hint}) async {}
}
