import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_sync_constants.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_state.dart';
import 'package:flutter_bloc_app/features/chat/presentation/pages/chat_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/pending_sync_repository.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_operation.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_bloc_app/shared/widgets/message_bubble.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'test_helpers.dart' as test_helpers;

void main() {
  setUpAll(() async {
    await test_helpers.setupHiveForTesting();
  });

  setUp(() async {
    await configureDependencies();
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('ChatPage sends message via ChatCubit', (
    WidgetTester tester,
  ) async {
    final _TestChatCubit cubit = _TestChatCubit(
      initialModel: 'model-a',
      supportedModels: const <String>['model-a', 'model-b'],
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(_wrapWithCubit(cubit));

    await tester.enterText(find.byType(TextField), 'Hello world');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();

    expect(cubit.sentMessages, contains('Hello world'));
  });

  testWidgets('ChatPage clears history after confirmation dialog', (
    WidgetTester tester,
  ) async {
    final _TestChatCubit cubit = _TestChatCubit(
      supportedModels: const <String>['only-model'],
    );
    addTearDown(cubit.close);

    cubit.emit(
      ChatState(
        history: <ChatConversation>[
          ChatConversation(
            id: 'conversation-1',
            createdAt: DateTime(2024),
            updatedAt: DateTime(2024),
            messages: const <ChatMessage>[
              ChatMessage(author: ChatAuthor.user, text: 'Hi'),
            ],
          ),
        ],
        status: ViewStatus.success,
      ),
    );

    await tester.pumpWidget(_wrapWithCubit(cubit));

    await tester.tap(
      find.widgetWithIcon(IconButton, Icons.delete_sweep_outlined),
    );
    await tester.pumpAndSettle();

    // Dialog should be shown (either AlertDialog or CupertinoAlertDialog)
    expect(
      find.byType(AlertDialog).evaluate().isNotEmpty ||
          find.byType(CupertinoAlertDialog).evaluate().isNotEmpty,
      isTrue,
    );
    await tester.tap(find.text(AppLocalizationsEn().deleteButtonLabel));
    await tester.pumpAndSettle();

    expect(cubit.clearHistoryCalled, isTrue);
  });

  testWidgets('ChatPage dialog buttons are tappable on iOS', (
    WidgetTester tester,
  ) async {
    final _TestChatCubit cubit = _TestChatCubit(
      supportedModels: const <String>['only-model'],
    );
    addTearDown(cubit.close);

    cubit.emit(
      ChatState(
        history: <ChatConversation>[
          ChatConversation(
            id: 'conversation-1',
            createdAt: DateTime(2024),
            updatedAt: DateTime(2024),
            messages: const <ChatMessage>[
              ChatMessage(author: ChatAuthor.user, text: 'Hi'),
            ],
          ),
        ],
        status: ViewStatus.success,
      ),
    );

    // Use MaterialApp with iOS platform to simulate iOS
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<ChatCubit>.value(value: cubit),
            BlocProvider<SyncStatusCubit>.value(value: _buildSyncStatusCubit()),
          ],
          child: const ChatPage(),
        ),
      ),
    );

    await tester.tap(
      find.widgetWithIcon(IconButton, Icons.delete_sweep_outlined),
    );
    await tester.pumpAndSettle();

    // Should use CupertinoAlertDialog on iOS
    expect(find.byType(CupertinoAlertDialog), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    // Cancel button should be tappable
    final cancelButton = find.text(AppLocalizationsEn().cancelButtonLabel);
    expect(cancelButton, findsOneWidget);

    // Verify the button is actually interactive
    final cancelAction = find.ancestor(
      of: cancelButton,
      matching: find.byType(CupertinoDialogAction),
    );
    expect(cancelAction, findsOneWidget);

    final cancelActionWidget = tester.widget<CupertinoDialogAction>(
      cancelAction,
    );
    expect(cancelActionWidget.onPressed, isNotNull);

    // Tap Cancel - should work
    await tester.tap(cancelButton);
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoAlertDialog), findsNothing);
    expect(cubit.clearHistoryCalled, isFalse);

    // Test Delete button
    await tester.tap(
      find.widgetWithIcon(IconButton, Icons.delete_sweep_outlined),
    );
    await tester.pumpAndSettle();

    final deleteButton = find.text(AppLocalizationsEn().deleteButtonLabel);
    expect(deleteButton, findsOneWidget);

    final deleteAction = find.ancestor(
      of: deleteButton,
      matching: find.byType(CupertinoDialogAction),
    );
    expect(deleteAction, findsOneWidget);

    final deleteActionWidget = tester.widget<CupertinoDialogAction>(
      deleteAction,
    );
    expect(deleteActionWidget.onPressed, isNotNull);
    expect(deleteActionWidget.isDestructiveAction, isTrue);

    // Tap Delete - should work
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoAlertDialog), findsNothing);
    expect(cubit.clearHistoryCalled, isTrue);
  });

  testWidgets('ChatModelSelector dropdown selects alternate model', (
    WidgetTester tester,
  ) async {
    final _TestChatCubit cubit = _TestChatCubit(
      initialModel: 'openai/gpt-oss-20b',
      supportedModels: const <String>['openai/gpt-oss-20b', 'custom-model'],
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(_wrapWithCubit(cubit));

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('custom-model').last);
    await tester.pump();

    expect(cubit.selectedModels, contains('custom-model'));
  });

  testWidgets('ChatPage banner clears after manual sync flush', (
    WidgetTester tester,
  ) async {
    final _PendingStateChatCubit cubit = _PendingStateChatCubit();
    addTearDown(cubit.close);

    final _MockPendingSyncRepository pendingRepository =
        _MockPendingSyncRepository();
    int pendingCount = 0;
    final SyncOperation pendingOperation = SyncOperation.create(
      entityType: chatSyncEntityType,
      payload: const <String, dynamic>{},
      idempotencyKey: 'pending',
    );

    when(
      () => pendingRepository.getPendingOperations(now: any(named: 'now')),
    ).thenAnswer(
      (_) async => pendingCount > 0
          ? <SyncOperation>[pendingOperation]
          : <SyncOperation>[],
    );
    when(() => pendingRepository.markCompleted(any())).thenAnswer((_) async {});

    if (getIt.isRegistered<PendingSyncRepository>()) {
      getIt.unregister<PendingSyncRepository>();
    }
    getIt.registerSingleton<PendingSyncRepository>(pendingRepository);

    final _TestNetworkStatusService networkService =
        _TestNetworkStatusService();
    final _ManualFlushCoordinator coordinator = _ManualFlushCoordinator(
      onFlush: () async {
        pendingCount = 0;
        await cubit.markSynced();
      },
    );
    final SyncStatusCubit syncCubit = SyncStatusCubit(
      networkStatusService: networkService,
      coordinator: coordinator,
    );
    addTearDown(syncCubit.close);
    networkService.emit(NetworkStatus.online);

    await tester.pumpWidget(_wrapWithCubit(cubit, syncCubit));
    await tester.pump();

    pendingCount = 1;
    await tester.enterText(find.byType(TextField), 'Offline pending message');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();

    networkService.emit(NetworkStatus.offline);
    await tester.pump();
    networkService.emit(NetworkStatus.online);
    await tester.pump();

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(ChatPage)),
    );
    expect(find.text(l10n.syncStatusPendingTitle), findsOneWidget);
    expect(find.text(l10n.syncStatusSyncNowButton), findsOneWidget);
    expect(find.text(l10n.chatMessageStatusPending), findsOneWidget);

    await tester.tap(find.text(l10n.syncStatusSyncNowButton));
    await tester.pump();

    expect(find.text(l10n.chatMessageStatusPending), findsNothing);
    expect(find.text(l10n.syncStatusPendingTitle), findsNothing);
    expect(find.byType(MessageBubble), findsNWidgets(2));
  });
}

class FakeNetworkStatusService implements NetworkStatusService {
  @override
  Stream<NetworkStatus> get statusStream => const Stream<NetworkStatus>.empty();

  @override
  Future<NetworkStatus> getCurrentStatus() async => NetworkStatus.online;

  @override
  Future<void> dispose() async {}
}

class FakeBackgroundSyncCoordinator implements BackgroundSyncCoordinator {
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
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> flush() async {}
}

Widget _wrapWithCubit(ChatCubit cubit, [SyncStatusCubit? syncCubit]) {
  final SyncStatusCubit sync = syncCubit ?? _buildSyncStatusCubit();
  addTearDown(sync.close);
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<ChatCubit>.value(value: cubit),
        BlocProvider<SyncStatusCubit>.value(value: sync),
      ],
      child: const ChatPage(),
    ),
  );
}

SyncStatusCubit _buildSyncStatusCubit() => SyncStatusCubit(
  networkStatusService: FakeNetworkStatusService(),
  coordinator: FakeBackgroundSyncCoordinator(),
);

class _TestChatCubit extends ChatCubit {
  _TestChatCubit({super.initialModel, super.supportedModels})
    : super(
        repository: _StubChatRepository(),
        historyRepository: _StubHistoryRepository(),
      );

  final List<String> sentMessages = <String>[];
  final List<String> selectedModels = <String>[];
  bool clearHistoryCalled = false;

  @override
  Future<void> sendMessage(String message) async {
    sentMessages.add(message);
  }

  @override
  Future<void> clearHistory() async {
    clearHistoryCalled = true;
  }

  @override
  void selectModel(String model) {
    selectedModels.add(model);
    super.selectModel(model);
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

class _PendingStateChatCubit extends ChatCubit {
  _PendingStateChatCubit()
    : super(
        repository: _StubChatRepository(),
        historyRepository: _StubHistoryRepository(),
      );

  @override
  Future<void> sendMessage(String message) async {
    final DateTime now = DateTime.now();
    final ChatConversation conversation = ChatConversation(
      id: 'pending-convo',
      createdAt: now,
      updatedAt: now,
      messages: <ChatMessage>[
        ChatMessage(
          author: ChatAuthor.user,
          text: message,
          createdAt: now,
          synchronized: false,
        ),
      ],
      pastUserInputs: <String>[message],
    );
    emit(
      state.copyWith(
        history: <ChatConversation>[conversation],
        activeConversationId: conversation.id,
        messages: conversation.messages,
        generatedResponses: conversation.generatedResponses,
        pastUserInputs: conversation.pastUserInputs,
      ),
    );
  }

  Future<void> markSynced() async {
    if (state.messages.isEmpty) {
      return;
    }
    final DateTime now = DateTime.now();
    final ChatMessage user = state.messages.first;
    final ChatMessage syncedUser = ChatMessage(
      author: user.author,
      text: user.text,
      createdAt: user.createdAt,
      synchronized: true,
      lastSyncedAt: now,
    );
    final ChatMessage assistant = ChatMessage(
      author: ChatAuthor.assistant,
      text: 'Synced reply',
      createdAt: now,
      synchronized: true,
      lastSyncedAt: now,
    );
    final ChatConversation conversation = ChatConversation(
      id: state.activeConversationId ?? 'pending-convo',
      createdAt: now,
      updatedAt: now,
      messages: <ChatMessage>[syncedUser, assistant],
      pastUserInputs: <String>[user.text],
      generatedResponses: const <String>['Synced reply'],
      lastSyncedAt: now,
      synchronized: true,
    );
    emit(
      state.copyWith(
        history: <ChatConversation>[conversation],
        activeConversationId: conversation.id,
        messages: conversation.messages,
        generatedResponses: conversation.generatedResponses,
        pastUserInputs: conversation.pastUserInputs,
      ),
    );
  }
}

class _TestNetworkStatusService implements NetworkStatusService {
  final StreamController<NetworkStatus> _controller =
      StreamController<NetworkStatus>.broadcast();
  NetworkStatus _current = NetworkStatus.unknown;

  void emit(NetworkStatus status) {
    _current = status;
    _controller.add(status);
  }

  @override
  Stream<NetworkStatus> get statusStream => _controller.stream;

  @override
  Future<NetworkStatus> getCurrentStatus() async => _current;

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}

class _ManualFlushCoordinator implements BackgroundSyncCoordinator {
  _ManualFlushCoordinator({required this.onFlush});

  final Future<void> Function() onFlush;
  final StreamController<SyncStatus> _controller =
      StreamController<SyncStatus>.broadcast();
  SyncStatus _currentStatus = SyncStatus.idle;

  void _emit(SyncStatus status) {
    if (_currentStatus == status) return;
    _currentStatus = status;
    if (!_controller.isClosed) {
      _controller.add(status);
    }
  }

  @override
  Stream<SyncStatus> get statusStream => _controller.stream;

  @override
  SyncStatus get currentStatus => _currentStatus;

  @override
  List<SyncCycleSummary> get history => const <SyncCycleSummary>[];

  @override
  Stream<SyncCycleSummary> get summaryStream =>
      const Stream<SyncCycleSummary>.empty();

  @override
  SyncCycleSummary? get latestSummary => null;

  @override
  Future<void> flush() async {
    _emit(SyncStatus.syncing);
    await onFlush();
    _emit(SyncStatus.idle);
  }

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}

class _MockPendingSyncRepository extends Mock
    implements PendingSyncRepository {}
