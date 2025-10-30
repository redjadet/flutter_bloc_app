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
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    UI.screenUtilReady = false;
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

    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text(AppLocalizationsEn().deleteButtonLabel));
    await tester.pumpAndSettle();

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
