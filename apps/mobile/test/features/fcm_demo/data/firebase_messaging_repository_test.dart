import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc_app/features/fcm_demo/data/firebase_messaging_repository.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/fcm_permission_state.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/push_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

NotificationSettings _settings(final AuthorizationStatus status) =>
    NotificationSettings(
      alert: AppleNotificationSetting.enabled,
      announcement: AppleNotificationSetting.enabled,
      authorizationStatus: status,
      badge: AppleNotificationSetting.enabled,
      carPlay: AppleNotificationSetting.notSupported,
      lockScreen: AppleNotificationSetting.enabled,
      notificationCenter: AppleNotificationSetting.enabled,
      showPreviews: AppleShowPreviewSetting.always,
      timeSensitive: AppleNotificationSetting.notSupported,
      criticalAlert: AppleNotificationSetting.disabled,
      sound: AppleNotificationSetting.enabled,
      providesAppNotificationSettings: AppleNotificationSetting.disabled,
    );

RemoteMessage _message({
  required final String id,
  required final PushMessageSource source,
}) => RemoteMessage(
  messageId: id,
  sentTime: DateTime(2026, 1, 2),
  notification: RemoteNotification(title: 'Title-$id', body: 'Body-$id'),
  data: {'source': source.name, 'int': 42, 'bool': true, 'null': null},
);

void main() {
  group('FirebaseMessagingRepository', () {
    late _MockFirebaseMessaging messaging;
    late StreamController<RemoteMessage> foregroundController;
    late StreamController<RemoteMessage> openedController;
    late StreamController<String> tokenRefreshController;
    late FirebaseMessagingRepository repository;

    setUp(() {
      messaging = _MockFirebaseMessaging();
      foregroundController = StreamController<RemoteMessage>.broadcast();
      openedController = StreamController<RemoteMessage>.broadcast();
      tokenRefreshController = StreamController<String>.broadcast();

      when(
        () => messaging.onTokenRefresh,
      ).thenAnswer((_) => tokenRefreshController.stream);
      when(
        () => messaging.requestPermission(),
      ).thenAnswer((_) async => _settings(AuthorizationStatus.authorized));
      when(() => messaging.getToken()).thenAnswer((_) async => 'fcm-token');
      when(() => messaging.getAPNSToken()).thenAnswer((_) async => 'apns');
      when(() => messaging.getInitialMessage()).thenAnswer((_) async => null);

      repository = FirebaseMessagingRepository(
        messaging: messaging,
        foregroundMessages: foregroundController.stream,
        openedMessages: openedController.stream,
      );
    });

    tearDown(() async {
      await foregroundController.close();
      await openedController.close();
      await tokenRefreshController.close();
    });

    test('requestPermission maps authorization status', () async {
      when(
        () => messaging.requestPermission(),
      ).thenAnswer((_) async => _settings(AuthorizationStatus.provisional));

      final state = await repository.requestPermission();

      expect(state, FcmPermissionState.provisional);
    });

    test('getToken returns null when firebase throws', () async {
      when(() => messaging.getToken()).thenThrow(Exception('token failure'));

      final token = await repository.getToken();

      expect(token, isNull);
    });

    test('getInitialMessage maps to PushMessage', () async {
      when(() => messaging.getInitialMessage()).thenAnswer(
        (_) async =>
            _message(id: 'initial-id', source: PushMessageSource.initial),
      );

      final message = await repository.getInitialMessage();

      expect(message, isNotNull);
      expect(message?.messageId, 'initial-id');
      expect(message?.title, 'Title-initial-id');
      expect(message?.body, 'Body-initial-id');
      expect(message?.source, PushMessageSource.initial);
      expect(message?.data, containsPair('int', '42'));
      expect(message?.data, containsPair('bool', 'true'));
      expect(message?.data, containsPair('null', ''));
    });

    test('foregroundMessages maps source and payload', () async {
      final expectation = expectLater(
        repository.foregroundMessages,
        emits(
          isA<PushMessage>()
              .having(
                (final m) => m.source,
                'source',
                PushMessageSource.foreground,
              )
              .having((final m) => m.messageId, 'messageId', 'foreground-id')
              .having(
                (final m) => m.data['source'],
                'dataSource',
                'foreground',
              ),
        ),
      );

      foregroundController.add(
        _message(id: 'foreground-id', source: PushMessageSource.foreground),
      );

      await expectation;
    });

    test('openedMessages maps source and payload', () async {
      final expectation = expectLater(
        repository.openedMessages,
        emits(
          isA<PushMessage>()
              .having((final m) => m.source, 'source', PushMessageSource.opened)
              .having((final m) => m.messageId, 'messageId', 'opened-id')
              .having((final m) => m.data['source'], 'dataSource', 'opened'),
        ),
      );

      openedController.add(
        _message(id: 'opened-id', source: PushMessageSource.opened),
      );

      await expectation;
    });

    test('tokenRefreshes emits new tokens', () async {
      final expectation = expectLater(
        repository.tokenRefreshes,
        emits('refreshed-token'),
      );

      tokenRefreshController.add('refreshed-token');

      await expectation;
    });
  });
}
