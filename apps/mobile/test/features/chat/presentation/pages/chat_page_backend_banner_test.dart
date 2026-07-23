import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/theme/theme.dart';
import 'package:flutter_bloc_app/app/widgets/backend_disabled_banner.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/pages/chat_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/app/services/error_notification_service.dart';
import 'package:networking/networking.dart';
import 'package:flutter_bloc_app/app/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'ChatPage shows backend banner when showBackendDisabledBanner is true',
    (final tester) async {
      await _pumpChatPage(tester, showBackendDisabledBanner: true);

      expect(find.byType(BackendDisabledBanner), findsOneWidget);
      expect(find.text('Backend disabled'), findsOneWidget);
    },
  );

  testWidgets(
    'ChatPage hides backend banner when showBackendDisabledBanner is false',
    (final tester) async {
      await _pumpChatPage(tester, showBackendDisabledBanner: false);

      expect(find.text('Backend disabled'), findsNothing);
    },
  );
}

Future<void> _pumpChatPage(
  final WidgetTester tester, {
  required final bool showBackendDisabledBanner,
}) async {
  final ChatCubit cubit = ChatCubit(
    repository: _StubChatRepository(),
    historyRepository: _StubHistoryRepository(),
    supportedModels: const <String>['model-a'],
  );
  addTearDown(cubit.close);

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (final BuildContext context, final Widget? child) =>
          buildAppMixScope(context, child: child ?? const SizedBox.shrink()),
      home: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<ChatCubit>.value(value: cubit),
          BlocProvider<SyncStatusCubit>.value(value: _buildSyncStatusCubit()),
        ],
        child: ChatPage(
          errorNotificationService: _FakeErrorNotificationService(),
          showBackendDisabledBanner: showBackendDisabledBanner,
          renderTransportDemoStrict: false,
          chatRenderDemoBaseUrl: '',
        ),
      ),
    ),
  );
  await tester.pump();
}

class _StubChatRepository implements ChatRepository {
  @override
  ChatRemotePath? get chatRemoteTransportHint => null;

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

class _FakeErrorNotificationService implements ErrorNotificationService {
  @override
  Future<void> showSnackBar(
    final BuildContext context,
    final String message,
  ) async {}

  @override
  Future<void> showAlertDialog(
    final BuildContext context,
    final String title,
    final String message,
  ) async {}
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

  @override
  Future<void> triggerFromFcm({final String? hint}) async {}
  @override
  Future<void> quiesceForSessionCleanup() async {}

  @override
  Future<void> resumeAfterSessionCleanup() async {}
}

SyncStatusCubit _buildSyncStatusCubit() => SyncStatusCubit(
  networkStatusService: _FakeNetworkStatusService(),
  coordinator: _FakeBackgroundSyncCoordinator(),
);
