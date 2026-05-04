import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/theme/mix_app_theme.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_messaging_service.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_permission_state.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/push_message.dart';
import 'package:flutter_bloc_app/features/fcm_demo/presentation/cubit/fcm_demo_cubit.dart';
import 'package:flutter_bloc_app/features/fcm_demo/presentation/cubit/fcm_demo_state.dart';
import 'package:flutter_bloc_app/features/fcm_demo/presentation/pages/fcm_demo_page.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/l10n/app_localizations_en.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoopMessagingService implements FcmMessagingService {
  @override
  Stream<PushMessage> get foregroundMessages => const Stream.empty();

  @override
  Stream<PushMessage> get openedMessages => const Stream.empty();

  @override
  Stream<String> get tokenRefreshes => const Stream.empty();

  @override
  Future<String?> getApnsToken() async => null;

  @override
  Future<PushMessage?> getInitialMessage() async => null;

  @override
  Future<String?> getToken() async => null;

  @override
  Future<FcmPermissionState> requestPermission() async =>
      FcmPermissionState.notDetermined;
}

class _NoopBackgroundSyncCoordinator implements BackgroundSyncCoordinator {
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

class _TestFcmDemoCubit extends FcmDemoCubit {
  _TestFcmDemoCubit()
    : super(
        messaging: _NoopMessagingService(),
        coordinator: _NoopBackgroundSyncCoordinator(),
      );

  void setTestState(final FcmDemoState value) => emit(value);
}

PushMessage _message() => PushMessage(
  messageId: 'message-1',
  title: 'Demo title',
  body: 'Demo body',
  sentTime: DateTime(2026, 1, 3),
  data: const {'type': 'demo'},
  source: PushMessageSource.foreground,
);

Future<void> _pumpPage(
  final WidgetTester tester, {
  required final FcmDemoState state,
}) async {
  final cubit = _TestFcmDemoCubit()..setTestState(state);
  addTearDown(cubit.close);

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (final context) => buildAppMixScope(
          context,
          child: BlocProvider<FcmDemoCubit>.value(
            value: cubit,
            child: const FcmDemoPage(),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('FcmDemoPage', () {
    final l10n = AppLocalizationsEn();

    testWidgets('shows progress indicator in initial state', (
      final tester,
    ) async {
      await _pumpPage(tester, state: const FcmDemoState());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows fallback error text when error message is null', (
      final tester,
    ) async {
      await _pumpPage(
        tester,
        state: const FcmDemoState(status: FcmDemoStatus.error),
      );

      expect(find.text(l10n.errorUnknown), findsOneWidget);
    });

    testWidgets('renders permission, token, and last message in ready state', (
      final tester,
    ) async {
      await _pumpPage(
        tester,
        state: FcmDemoState(
          status: FcmDemoStatus.ready,
          permissionState: FcmPermissionState.authorized,
          fcmToken: 'fcm-token-1',
          apnsToken: null,
          lastMessage: _message(),
        ),
      );

      expect(find.text(l10n.fcmDemoPermissionLabel), findsOneWidget);
      expect(find.text(l10n.fcmDemoPermissionAuthorized), findsOneWidget);
      expect(find.text('fcm-token-1'), findsOneWidget);
      expect(find.text(l10n.fcmDemoTokenNotAvailable), findsOneWidget);
      expect(find.text(l10n.fcmDemoCopyToken), findsOneWidget);
      expect(find.text('Demo title'), findsOneWidget);
      expect(find.text('Demo body'), findsOneWidget);
      expect(find.text('type: demo'), findsOneWidget);
    });

    testWidgets('copy token action copies FCM token and shows feedback', (
      final tester,
    ) async {
      String? copiedText;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (final call) {
            if (call.method == 'Clipboard.setData') {
              final data = call.arguments as Map<dynamic, dynamic>;
              copiedText = data['text'] as String?;
            }
            return Future<void>.value();
          });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null);
      });

      await _pumpPage(
        tester,
        state: const FcmDemoState(
          status: FcmDemoStatus.ready,
          permissionState: FcmPermissionState.authorized,
          fcmToken: 'fcm-token-1',
        ),
      );

      await tester.tap(find.text(l10n.fcmDemoCopyToken));
      await tester.pumpAndSettle();

      expect(copiedText, 'fcm-token-1');
      expect(tester.takeException(), isNull);
      expect(find.text(l10n.fcmDemoCopySuccess), findsOneWidget);
    });
  });
}
