import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_state.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_history_sheet.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ChatHistorySheet shows empty message when no history', (
    WidgetTester tester,
  ) async {
    final _StubChatCubit cubit = _StubChatCubit(
      const ChatState(status: ViewStatus.success),
    );
    addTearDown(cubit.close);

    int closeCount = 0;
    await tester.pumpWidget(_buildSheet(cubit, onClose: () => closeCount += 1));

    final AppLocalizationsEn en = AppLocalizationsEn();
    expect(find.text(en.chatHistoryEmpty), findsOneWidget);

    expect(find.text(en.chatHistoryClearAll), findsOneWidget);
    expect(closeCount, 0);
  });

  testWidgets('ChatHistorySheet wires cubit actions for history controls', (
    WidgetTester tester,
  ) async {
    final DateTime updatedAt = DateTime(2024, 1, 2, 12, 30);
    final ChatConversation conversation = ChatConversation(
      id: 'conversation-1',
      messages: const <ChatMessage>[
        ChatMessage(author: ChatAuthor.user, text: 'Hello'),
        ChatMessage(author: ChatAuthor.assistant, text: 'How can I help?'),
      ],
      pastUserInputs: const <String>['Hello'],
      generatedResponses: const <String>['How can I help?'],
      createdAt: DateTime(2024, 1, 1),
      updatedAt: updatedAt,
      model: 'distil',
    );

    final ChatState seededState = ChatState(
      history: <ChatConversation>[conversation],
      activeConversationId: conversation.id,
      messages: conversation.messages,
      pastUserInputs: conversation.pastUserInputs,
      generatedResponses: conversation.generatedResponses,
      status: ViewStatus.success,
    );

    final _StubChatCubit cubit = _StubChatCubit(seededState);
    addTearDown(cubit.close);

    int closeCount = 0;
    await tester.pumpWidget(_buildSheet(cubit, onClose: () => closeCount += 1));
    await tester.pump();

    final AppLocalizationsEn en = AppLocalizationsEn();

    // Verify conversation list renders expected metadata.
    expect(find.text('distil'), findsOneWidget);
    expect(find.text('How can I help?'), findsOneWidget);

    final BuildContext tileContext = tester.element(find.byType(ListTile));
    final MaterialLocalizations materialLocalizations =
        MaterialLocalizations.of(tileContext);
    final String timestamp = materialLocalizations.formatMediumDate(updatedAt);
    final TimeOfDay timeOfDay = TimeOfDay.fromDateTime(updatedAt);
    final String formattedTime = materialLocalizations.formatTimeOfDay(
      timeOfDay,
    );
    final AppLocalizations l10n = AppLocalizations.of(tileContext);
    final String expectedTimestamp = l10n.chatHistoryUpdatedAt(
      '$timestamp · $formattedTime',
    );
    expect(find.text(expectedTimestamp), findsOneWidget);

    // Start new conversation.
    await tester.tap(find.text(en.chatHistoryStartNew));
    await tester.pumpAndSettle();
    expect(cubit.resetCalled, isTrue);
    expect(closeCount, 1);

    // Clear all conversations (confirm dialog).
    await tester.tap(find.text(en.chatHistoryClearAll));
    await tester.pumpAndSettle();
    expect(find.text(en.chatHistoryClearAllWarning), findsOneWidget);
    await tester.tap(find.text(en.deleteButtonLabel));
    await tester.pumpAndSettle();
    expect(cubit.clearCalled, isTrue);
    expect(closeCount, 2);

    // Selecting the existing conversation closes the sheet.
    await tester.tap(find.text('distil'));
    await tester.pumpAndSettle();
    expect(cubit.selectedId, 'conversation-1');
    expect(closeCount, 3);

    // Deleting the conversation shows confirmation and calls cubit.
    await tester.tap(find.byTooltip(en.chatHistoryDeleteConversation));
    await tester.pumpAndSettle();
    final String warning = en.chatHistoryDeleteConversationWarning('distil');
    expect(find.text(warning), findsOneWidget);
    await tester.tap(find.text(en.deleteButtonLabel));
    await tester.pumpAndSettle();
    expect(cubit.deletedId, 'conversation-1');
    // No additional close callback for delete path.
    expect(closeCount, 3);
  });
}

Widget _buildSheet(ChatCubit cubit, {required VoidCallback onClose}) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<ChatCubit>.value(
      value: cubit,
      child: Scaffold(body: ChatHistorySheet(onClose: onClose)),
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

  bool resetCalled = false;
  bool clearCalled = false;
  String? selectedId;
  String? deletedId;

  @override
  Future<void> resetConversation() {
    resetCalled = true;
    return Future<void>.value();
  }

  @override
  Future<void> clearHistory() {
    clearCalled = true;
    return Future<void>.value();
  }

  @override
  Future<void> deleteConversation(String conversationId) {
    deletedId = conversationId;
    return Future<void>.value();
  }

  @override
  void selectConversation(String conversationId) {
    selectedId = conversationId;
  }
}

class _StubChatRepository implements ChatRepository {
  @override
  Future<ChatResult> sendMessage({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
    String? model,
  }) async => const ChatResult(
    reply: ChatMessage(author: ChatAuthor.assistant, text: 'stub'),
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
