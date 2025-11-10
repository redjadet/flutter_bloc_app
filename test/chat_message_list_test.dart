import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/di/injector.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_state.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_message_list.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await configureDependencies();
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('ChatMessageList shows empty placeholder when no messages', (
    WidgetTester tester,
  ) async {
    final _StubChatCubit cubit = _StubChatCubit(const ChatState());
    addTearDown(cubit.close);

    await tester.pumpWidget(
      _wrapWithApp(cubit, ChatMessageList(controller: ScrollController())),
    );

    expect(find.text(AppLocalizationsEn().chatEmptyState), findsOneWidget);
  });

  testWidgets('ChatMessageList renders bubbles and clears error via SnackBar', (
    WidgetTester tester,
  ) async {
    final _StubChatCubit cubit = _StubChatCubit(const ChatState());
    addTearDown(cubit.close);

    await tester.pumpWidget(
      _wrapWithApp(cubit, ChatMessageList(controller: ScrollController())),
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

    expect(find.text('hi'), findsOneWidget);
    expect(find.text('hello'), findsOneWidget);
    expect(find.text('boom'), findsOneWidget);

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(
      tester.element(find.byType(Scaffold)),
    );
    messenger.hideCurrentSnackBar();
    messenger.clearSnackBars();
    await tester.pumpAndSettle();

    expect(cubit.clearErrorCalled, isTrue);
  });
}

Widget _wrapWithApp(ChatCubit cubit, Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: BlocProvider<ChatCubit>.value(value: cubit, child: child),
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
