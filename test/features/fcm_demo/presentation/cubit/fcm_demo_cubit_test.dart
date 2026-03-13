import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_messaging_service.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_permission_state.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/push_message.dart';
import 'package:flutter_bloc_app/features/fcm_demo/presentation/cubit/fcm_demo_cubit.dart';
import 'package:flutter_bloc_app/features/fcm_demo/presentation/cubit/fcm_demo_state.dart';
import 'package:flutter_bloc_app/shared/sync/background_sync_coordinator.dart';
import 'package:flutter_bloc_app/shared/sync/sync_status.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeFcmMessagingService implements FcmMessagingService {
  _FakeFcmMessagingService({
    this.permissionState = FcmPermissionState.authorized,
    this.token = 'fcm-token',
    this.apnsToken = 'apns-token',
    this.initialMessage,
    this.throwPermissionError = false,
  });

  final FcmPermissionState permissionState;
  final String? token;
  final String? apnsToken;
  final PushMessage? initialMessage;
  final bool throwPermissionError;

  final StreamController<PushMessage> foregroundController =
      StreamController<PushMessage>.broadcast();
  final StreamController<PushMessage> openedController =
      StreamController<PushMessage>.broadcast();
  final StreamController<String> tokenRefreshController =
      StreamController<String>.broadcast();

  int getTokenCallCount = 0;

  @override
  Future<FcmPermissionState> requestPermission() async {
    if (throwPermissionError) {
      throw Exception('permission failure');
    }
    return permissionState;
  }

  @override
  Future<String?> getToken() async {
    getTokenCallCount++;
    return token;
  }

  @override
  Future<String?> getApnsToken() async => apnsToken;

  @override
  Future<PushMessage?> getInitialMessage() async => initialMessage;

  @override
  Stream<PushMessage> get foregroundMessages => foregroundController.stream;

  @override
  Stream<PushMessage> get openedMessages => openedController.stream;

  @override
  Stream<String> get tokenRefreshes => tokenRefreshController.stream;

  Future<void> dispose() async {
    await foregroundController.close();
    await openedController.close();
    await tokenRefreshController.close();
  }
}

class _FakeBackgroundSyncCoordinator implements BackgroundSyncCoordinator {
  int triggerFromFcmCallCount = 0;
  String? lastHint;

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
  Future<void> triggerFromFcm({final String? hint}) async {
    triggerFromFcmCallCount += 1;
    lastHint = hint;
  }
}

PushMessage _message({
  required final String id,
  final PushMessageSource source = PushMessageSource.foreground,
}) => PushMessage(
  messageId: id,
  title: 'Title $id',
  body: 'Body $id',
  sentTime: DateTime(2026),
  data: {'id': id},
  source: source,
);

void main() {
  group('FcmDemoCubit', () {
    late _FakeFcmMessagingService service;
    late _FakeBackgroundSyncCoordinator coordinator;

    setUp(() {
      service = _FakeFcmMessagingService();
      coordinator = _FakeBackgroundSyncCoordinator();
    });

    tearDown(() async {
      await service.dispose();
    });

    blocTest<FcmDemoCubit, FcmDemoState>(
      'initialize emits loading -> permission update -> ready',
      build: () {
        service = _FakeFcmMessagingService(
          permissionState: FcmPermissionState.provisional,
          apnsToken: 'custom-apns-token',
          initialMessage: _message(
            id: 'initial',
            source: PushMessageSource.initial,
          ),
        );
        return FcmDemoCubit(messaging: service, coordinator: coordinator);
      },
      act: (final cubit) async {
        await cubit.initialize();
      },
      expect: () => [
        isA<FcmDemoState>().having(
          (final s) => s.status,
          'status',
          FcmDemoStatus.loading,
        ),
        isA<FcmDemoState>()
            .having((final s) => s.status, 'status', FcmDemoStatus.loading)
            .having(
              (final s) => s.permissionState,
              'permission',
              FcmPermissionState.provisional,
            ),
        isA<FcmDemoState>()
            .having((final s) => s.status, 'status', FcmDemoStatus.ready)
            .having((final s) => s.fcmToken, 'token', 'fcm-token')
            .having((final s) => s.apnsToken, 'apnsToken', 'custom-apns-token')
            .having(
              (final s) => s.lastMessage?.source,
              'initialSource',
              PushMessageSource.initial,
            ),
      ],
    );

    blocTest<FcmDemoCubit, FcmDemoState>(
      'initialize emits error and does not load token when permission fails',
      build: () {
        service = _FakeFcmMessagingService(throwPermissionError: true);
        return FcmDemoCubit(messaging: service, coordinator: coordinator);
      },
      act: (final cubit) async {
        await cubit.initialize();
      },
      expect: () => [
        isA<FcmDemoState>().having(
          (final s) => s.status,
          'status',
          FcmDemoStatus.loading,
        ),
        isA<FcmDemoState>().having(
          (final s) => s.status,
          'status',
          FcmDemoStatus.error,
        ),
      ],
      verify: (final cubit) {
        expect(service.getTokenCallCount, 0);
      },
    );

    blocTest<FcmDemoCubit, FcmDemoState>(
      'token refresh stream updates token after initialize',
      build: () {
        service = _FakeFcmMessagingService(token: 'initial-token');
        return FcmDemoCubit(messaging: service, coordinator: coordinator);
      },
      act: (final cubit) async {
        await cubit.initialize();
        service.tokenRefreshController.add('refreshed-token');
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        isA<FcmDemoState>().having(
          (final s) => s.status,
          'status',
          FcmDemoStatus.loading,
        ),
        isA<FcmDemoState>().having(
          (final s) => s.permissionState,
          'permission',
          FcmPermissionState.authorized,
        ),
        isA<FcmDemoState>().having(
          (final s) => s.fcmToken,
          'token',
          'initial-token',
        ),
        isA<FcmDemoState>().having(
          (final s) => s.fcmToken,
          'token',
          'refreshed-token',
        ),
      ],
    );

    test('ignores stream events after close', () async {
      service = _FakeFcmMessagingService();
      final FcmDemoCubit cubit = FcmDemoCubit(
        messaging: service,
        coordinator: coordinator,
      );

      await cubit.initialize();
      await cubit.close();

      service.foregroundController.add(_message(id: 'late'));
      service.openedController.add(
        _message(id: 'late-opened', source: PushMessageSource.opened),
      );
      service.tokenRefreshController.add('late-token');
      await Future<void>.delayed(Duration.zero);

      expect(cubit.isClosed, true);
    });
  });
}
