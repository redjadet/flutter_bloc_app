import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_state.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_input_bar.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_bloc_app/shared/ui/ui_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    UI.screenUtilReady = false;
  });

  testWidgets('ChatInputBar triggers onSend when submit and button tapped', (
    WidgetTester tester,
  ) async {
    final _StubChatCubit cubit = _StubChatCubit(const ChatState());
    addTearDown(cubit.close);

    bool sendCalled = false;
    final TextEditingController controller = TextEditingController();

    await tester.pumpWidget(
      _wrapWithApp(
        cubit,
        ChatInputBar(controller: controller, onSend: () => sendCalled = true),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(sendCalled, isTrue);

    sendCalled = false;
    await tester.tap(find.byTooltip(AppLocalizationsEn().chatSendButton));
    await tester.pump();

    expect(sendCalled, isTrue);
  });

  testWidgets('ChatInputBar shows progress indicator when loading', (
    WidgetTester tester,
  ) async {
    final _StubChatCubit cubit = _StubChatCubit(
      const ChatState(isLoading: true),
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      _wrapWithApp(
        cubit,
        ChatInputBar(controller: TextEditingController(), onSend: () {}),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final IconButton button = tester.widget(find.byType(IconButton));
    expect(button.onPressed, isNull);
  });
}

Widget _wrapWithApp(ChatCubit cubit, Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<ChatCubit>.value(
      value: cubit,
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
