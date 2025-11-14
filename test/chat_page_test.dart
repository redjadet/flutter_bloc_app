import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_state.dart';
import 'package:flutter_bloc_app/features/chat/presentation/pages/chat_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  setUpAll(() async {
    // Initialize Hive for testing
    final Directory testDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(testDir.path);
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
        home: BlocProvider<ChatCubit>.value(
          value: cubit,
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
}

Widget _wrapWithCubit(ChatCubit cubit) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<ChatCubit>.value(value: cubit, child: const ChatPage()),
  );
}

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
