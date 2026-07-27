import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    AppLogger.observer = null;
  });

  test('legacy levels sanitize message and error for observer', () {
    final entries = <AppLogEntry>[];
    AppLogger.observer = entries.add;

    AppLogger.debug('token=leak');
    AppLogger.info('password=leak');
    AppLogger.warning('Bearer abc.def.ghi');
    AppLogger.error(
      'failed',
      StateError('access_token=atk'),
      StackTrace.current,
    );

    expect(entries, hasLength(4));
    for (final entry in entries) {
      expect(entry.message, isNot(contains('leak')));
      expect(entry.message, isNot(contains('abc.def.ghi')));
      expect(entry.message, isNot(contains('atk')));
    }
    expect(entries.last.error, isA<String>());
    expect(entries.last.error.toString(), isNot(contains('atk')));
    expect(entries.last.error.toString(), contains(LogRedaction.redacted));
  });

  test('event builds stable key=value fields without secrets', () {
    final entries = <AppLogEntry>[];
    AppLogger.observer = entries.add;

    AppLogger.event(
      AppLogLevel.info,
      'login_failed',
      fields: {
        'statusCode': 401,
        'token': 'should-not-appear',
        'uri': Uri.parse('https://api.example/login?token=secret'),
      },
    );

    expect(entries, hasLength(1));
    final message = entries.single.message;
    expect(message.startsWith('login_failed'), isTrue);
    expect(message, contains('statusCode=401'));
    expect(message, contains('token=${LogRedaction.redacted}'));
    expect(message, isNot(contains('should-not-appear')));
    expect(message, isNot(contains('secret')));
    expect(message, contains('uri='));
  });
}
