import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/theme/mix_app_theme.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_message_list.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/services/error_notification_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _FakeChatRepository extends Fake implements ChatRepository {}

class _MockErrorNotificationService extends Mock
    implements ErrorNotificationService {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
  });

  testWidgets('shows terminal sync failure copy under user bubble', (
    final WidgetTester tester,
  ) async {
    final _MockErrorNotificationService errors = _MockErrorNotificationService();
    when(
      () => errors.showSnackBar(any(), any()),
    ).thenAnswer((_) async {});

    final ChatCubit cubit = ChatCubit(
      repository: _FakeChatRepository(),
      historyRepository: _FakeChatRepository() as dynamic,
    );
    addTearDown(cubit.close);

    cubit.emit(
      cubit.state.copyWith(
        messages: const <ChatMessage>[
          ChatMessage(
            author: ChatAuthor.user,
            text: 'Hello',
            clientMessageId: 'c1',
            synchronized: false,
            terminalSyncFailureCode: 'auth_required',
          ),
        ],
        pastUserInputs: const <String>['Hello'],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        builder: (final BuildContext context, final Widget? child) =>
            buildAppMixScope(context, child: child ?? const SizedBox.shrink()),
        home: Scaffold(
          body: BlocProvider<ChatCubit>.value(
            value: cubit,
            child: ChatMessageList(
              controller: ScrollController(),
              errorNotificationService: errors,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('sign', findRichText: true), findsWidgets);
  });
}

class FakeBuildContext extends Fake implements BuildContext {}
