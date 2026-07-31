import 'dart:async';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc_app/features/fcm_demo/data/fcm_log_redaction.dart';
import 'package:flutter_bloc_app/features/fcm_demo/data/firebase_messaging_repository.dart';
import 'package:flutter_bloc_app/features/fcm_demo/domain/push_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

void main() {
  tearDown(() {
    AppLogger.observer = null;
  });

  test('summaryFromPushMessage excludes title body and token values', () {
    final Map<String, Object?> summary = FcmLogRedaction.summaryFromPushMessage(
      const PushMessage(
        messageId: 'secret-message-id',
        title: 'Super Secret Title',
        body: 'Super Secret Body',
        sentTime: null,
        data: <String, String>{'token': 'abc', 'user': 'someone'},
        source: PushMessageSource.foreground,
      ),
    );

    expect(summary['hasTitle'], isTrue);
    expect(summary['hasBody'], isTrue);
    expect(summary['dataKeyCount'], 2);
    expect(summary.values, isNot(contains('Super Secret Title')));
    expect(summary.values, isNot(contains('Super Secret Body')));
    expect(summary.values, isNot(contains('abc')));
  });

  test('repository foreground logging redacts payload via observer', () async {
    final List<AppLogEntry> entries = <AppLogEntry>[];
    AppLogger.observer = entries.add;

    final _MockFirebaseMessaging messaging = _MockFirebaseMessaging();
    final StreamController<RemoteMessage> foreground =
        StreamController<RemoteMessage>.broadcast();

    when(
      () => messaging.onTokenRefresh,
    ).thenAnswer((_) => const Stream<String>.empty());

    final FirebaseMessagingRepository repository = FirebaseMessagingRepository(
      messaging: messaging,
      foregroundMessages: foreground.stream,
      openedMessages: const Stream<RemoteMessage>.empty(),
    );

    const String leakedTitle = 'Leaked Notification Title';
    const String leakedBody = 'Leaked notification body text';
    const String leakedToken = 'fcm-token-should-never-log';

    final Future<PushMessage> next = repository.foregroundMessages.first;

    foreground.add(
      RemoteMessage(
        messageId: 'msg-1',
        notification: const RemoteNotification(
          title: leakedTitle,
          body: leakedBody,
        ),
        data: <String, dynamic>{'token': leakedToken},
      ),
    );

    await next;

    expect(entries, isNotEmpty);
    final String logged = entries.map((final e) => e.message).join('\n');
    expect(logged, isNot(contains(leakedTitle)));
    expect(logged, isNot(contains(leakedBody)));
    expect(logged, isNot(contains(leakedToken)));
    expect(logged, contains('hasTitle=true'));
    expect(logged, contains('hasBody=true'));

    await foreground.close();
  });
}
