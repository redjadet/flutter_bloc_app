import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_conversation.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_history_repository.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_message.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_repository.dart';
import 'package:flutter_bloc_app/features/chat/presentation/chat_cubit.dart';
import 'package:flutter_bloc_app/features/chat/presentation/widgets/chat_history_sheet.dart';
import 'package:flutter_bloc_app/features/example/presentation/pages/example_page.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_info.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_info_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/app_locale.dart';
import 'package:flutter_bloc_app/features/settings/domain/locale_repository.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_preference.dart';
import 'package:flutter_bloc_app/features/settings/domain/theme_repository.dart';
import 'package:flutter_bloc_app/features/settings/presentation/cubits/locale_cubit.dart';
import 'package:flutter_bloc_app/features/settings/presentation/cubits/theme_cubit.dart';
import 'package:flutter_bloc_app/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/services/network_status_service.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/presentation/sync_status_cubit.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();

  group('Responsive layouts', () {
    testWidgets('ExamplePage card is constrained on wide screens', (
      WidgetTester tester,
    ) async {
      await binding.setSurfaceSize(const Size(1400, 1000));
      addTearDown(() => binding.setSurfaceSize(const Size(390, 844)));

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ExamplePage(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      final Finder cardFinder = find.byKey(
        const ValueKey('example-content-card'),
      );
      expect(cardFinder, findsOneWidget);
      final Size cardSize = tester.getSize(cardFinder);
      expect(cardSize.width, lessThanOrEqualTo(840));
    });

    testWidgets('SettingsPage list respects content width on desktop', (
      WidgetTester tester,
    ) async {
      final SyncStatusCubit syncCubit = _buildSyncStatusCubit();
      addTearDown(syncCubit.close);

      await binding.setSurfaceSize(const Size(1400, 1000));
      addTearDown(() => binding.setSurfaceSize(const Size(390, 844)));

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MultiBlocProvider(
            providers: [
              BlocProvider<ThemeCubit>(
                create: (_) =>
                    ThemeCubit(repository: _FakeThemeRepository())
                      ..loadInitial(),
              ),
              BlocProvider<LocaleCubit>(
                create: (_) =>
                    LocaleCubit(repository: _FakeLocaleRepository())
                      ..loadInitial(),
              ),
              BlocProvider<SyncStatusCubit>.value(value: syncCubit),
            ],
            child: SettingsPage(appInfoRepository: _FakeAppInfoRepository()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Finder listFinder = find.byKey(const ValueKey('settings-list'));
      expect(listFinder, findsOneWidget);
      final Size listSize = tester.getSize(listFinder);
      expect(listSize.width, lessThanOrEqualTo(840));
    });

    testWidgets('ChatHistorySheet max width honors responsive breakpoint', (
      WidgetTester tester,
    ) async {
      final List<ChatConversation> conversations = <ChatConversation>[
        ChatConversation(
          id: 'c1',
          messages: const [
            ChatMessage(author: ChatAuthor.user, text: 'Hello'),
            ChatMessage(author: ChatAuthor.assistant, text: 'Hi there!'),
          ],
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 2),
        ),
        ChatConversation(
          id: 'c2',
          messages: const [
            ChatMessage(author: ChatAuthor.user, text: 'Any updates?'),
            ChatMessage(author: ChatAuthor.assistant, text: 'Working on it.'),
          ],
          createdAt: DateTime(2024, 1, 3),
          updatedAt: DateTime(2024, 1, 4),
        ),
      ];
      final ChatCubit cubit = ChatCubit(
        repository: _FakeChatRepository(),
        historyRepository: _FakeChatHistoryRepository(conversations),
      );
      await cubit.loadHistory();
      addTearDown(cubit.close);

      await binding.setSurfaceSize(const Size(1400, 1000));
      addTearDown(() => binding.setSurfaceSize(const Size(390, 844)));

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider.value(
            value: cubit,
            child: Scaffold(body: ChatHistorySheet(onClose: () {})),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Finder contentFinder = find.byKey(
        const ValueKey('chat-history-sheet-content'),
      );
      expect(contentFinder, findsOneWidget);
      final Size contentSize = tester.getSize(contentFinder);
      expect(contentSize.width, lessThanOrEqualTo(900));
    });
  });
}

class _FakeThemeRepository implements ThemeRepository {
  @override
  Future<ThemePreference?> load() async => ThemePreference.system;

  @override
  Future<void> save(ThemePreference mode) async {}
}

class _FakeLocaleRepository implements LocaleRepository {
  AppLocale? _stored;

  @override
  Future<AppLocale?> load() async => _stored;

  @override
  Future<void> save(AppLocale? locale) async {
    _stored = locale;
  }
}

class _FakeAppInfoRepository implements AppInfoRepository {
  @override
  Future<AppInfo> load() async =>
      const AppInfo(version: '1.0.0', buildNumber: '1');
}

class _StubNetworkStatusService implements NetworkStatusService {
  @override
  Stream<NetworkStatus> get statusStream => const Stream<NetworkStatus>.empty();

  @override
  Future<NetworkStatus> getCurrentStatus() async => NetworkStatus.online;

  @override
  Future<void> dispose() async {}
}

class _StubBackgroundSyncCoordinator implements BackgroundSyncCoordinator {
  final StreamController<SyncStatus> _controller =
      StreamController<SyncStatus>.broadcast();

  @override
  SyncStatus get currentStatus => SyncStatus.idle;

  @override
  Stream<SyncStatus> get statusStream => _controller.stream;

  @override
  List<SyncCycleSummary> get history => const <SyncCycleSummary>[];

  @override
  Stream<SyncCycleSummary> get summaryStream =>
      const Stream<SyncCycleSummary>.empty();

  @override
  SyncCycleSummary? get latestSummary => null;

  @override
  Future<void> dispose() async {
    await _controller.close();
  }

  @override
  Future<void> flush() async {}

  @override
  Future<void> start() async {}

  @override
  Future<void> ensureStarted() async {}

  @override
  Future<void> stop() async {}
}

SyncStatusCubit _buildSyncStatusCubit() => SyncStatusCubit(
  networkStatusService: _StubNetworkStatusService(),
  coordinator: _StubBackgroundSyncCoordinator(),
);

class _FakeChatRepository implements ChatRepository {
  @override
  Future<ChatResult> sendMessage({
    required List<String> pastUserInputs,
    required List<String> generatedResponses,
    required String prompt,
    String? model,
    String? conversationId,
    String? clientMessageId,
  }) async {
    return ChatResult(
      reply: const ChatMessage(author: ChatAuthor.assistant, text: 'Mock'),
      pastUserInputs: pastUserInputs,
      generatedResponses: generatedResponses,
    );
  }
}

class _FakeChatHistoryRepository implements ChatHistoryRepository {
  _FakeChatHistoryRepository(this._conversations);

  final List<ChatConversation> _conversations;

  @override
  Future<List<ChatConversation>> load() async =>
      List<ChatConversation>.from(_conversations);

  @override
  Future<void> save(List<ChatConversation> conversations) async {}
}
