import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/theme/mix_app_theme.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/pages/chat_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_bloc_app/shared/services/error_notification_service.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'ChatPage shows strict line under orchestration when strict override is true',
    (final WidgetTester tester) async {
      final ChatCubit cubit = ChatCubit(
        repository: _OrchestrationHintRepository(),
        historyRepository: _StubHistoryRepository(),
        supportedModels: const <String>['openai/gpt-oss-20b'],
      );
      addTearDown(cubit.close);
      cubit.emit(
        cubit.state.copyWith(
          runnableTransportHint: ChatRemotePath.renderOrchestration,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (final BuildContext context, final Widget? child) =>
              buildAppMixScope(
                context,
                child: child ?? const SizedBox.shrink(),
              ),
          home: MultiBlocProvider(
            providers: <BlocProvider<dynamic>>[
              BlocProvider<ChatCubit>.value(value: cubit),
              BlocProvider<SyncStatusCubit>.value(
                value: _buildSyncStatusCubit(),
              ),
            ],
            child: ChatPage(
              errorNotificationService: _FakeErrorNotificationService(),
              renderTransportDemoStrictOverride: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(AppLocalizationsEn().chatTransportRenderOrchestration),
        findsOneWidget,
      );
      expect(
        find.text(AppLocalizationsEn().chatRenderStrictMode),
        findsOneWidget,
      );
    },
  );
}

class _OrchestrationHintRepository implements ChatRepository {
  @override
  ChatRemotePath? get chatRemoteTransportHint =>
      ChatRemotePath.renderOrchestration;

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
}

SyncStatusCubit _buildSyncStatusCubit() => SyncStatusCubit(
  networkStatusService: _FakeNetworkStatusService(),
  coordinator: _FakeBackgroundSyncCoordinator(),
);
