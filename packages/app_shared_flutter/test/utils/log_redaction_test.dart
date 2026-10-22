import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LogRedaction.safeFields', () {
    test('redacts secret key variants and nested one level', () {
      final safe = LogRedaction.safeFields({
        'password': 'secret',
        'access_token': 'atk',
        'refreshToken': 'rtk',
        'api-key': 'k',
        'statusCode': 401,
        'nested': {'token': 'nested-secret', 'ok': true},
      });

      expect(safe['password'], LogRedaction.redacted);
      expect(safe['access_token'], LogRedaction.redacted);
      expect(safe['refreshToken'], LogRedaction.redacted);
      expect(safe['api-key'], LogRedaction.redacted);
      expect(safe['statusCode'], 401);
      final nested = safe['nested']! as Map<String, Object?>;
      expect(nested['token'], LogRedaction.redacted);
      expect(nested['ok'], isTrue);
    });

    test('marks deeper maps and unknown objects as unsafe', () {
      final safe = LogRedaction.safeFields({
        'outer': {
          'inner': {'token': 'x'},
        },
        'obj': Object(),
      });
      final outer = safe['outer']! as Map<String, Object?>;
      expect(outer['inner'], LogRedaction.unsafe);
      expect(safe['obj'], LogRedaction.unsafe);
    });

    test('sanitizes Uri field values', () {
      final uri = Uri.parse('https://ex.test/path?token=supersecret#frag');
      final safe = LogRedaction.safeFields({'uri': uri});
      final text = safe['uri']! as String;
      expect(text, contains('https://ex.test/path'));
      expect(text, isNot(contains('supersecret')));
      expect(text, contains(LogRedaction.redacted));
    });
  });

  group('LogRedaction.sanitizeUri', () {
    test('keeps scheme host path and redacts query fragment values', () {
      final uri = Uri.parse(
        'https://app.example:8443/x/y?token=abc&q=1#section',
      );
      final out = LogRedaction.sanitizeUri(uri);
      expect(out.scheme, 'https');
      expect(out.host, 'app.example');
      expect(out.port, 8443);
      expect(out.path, '/x/y');
      expect(out.queryParameters.keys, containsAll(<String>['token', 'q']));
      expect(
        out.queryParameters.values.every((v) => v.contains('REDACTED')),
        isTrue,
      );
      expect(out.fragment.contains('REDACTED'), isTrue);

      final logged = LogRedaction.uriForLog(uri);
      expect(logged, contains('https://app.example:8443/x/y'));
      expect(logged, contains('token=${LogRedaction.redacted}'));
      expect(logged, contains('q=${LogRedaction.redacted}'));
      expect(logged, endsWith('#${LogRedaction.redacted}'));
      expect(logged, isNot(contains('abc')));
    });
  });

  group('LogRedaction.sanitizeUriString', () {
    test('returns INVALID_URI without echoing input', () {
      expect(
        LogRedaction.sanitizeUriString('not a uri'),
        LogRedaction.invalidUri,
      );
      expect(
        LogRedaction.sanitizeUriString('/relative?token=x'),
        LogRedaction.invalidUri,
      );
      expect(
        LogRedaction.sanitizeUriString('not a uri'),
        isNot(contains('not a uri')),
      );
    });
  });

  group('LogRedaction.sanitizeMessage', () {
    test('collapses control characters and truncates', () {
      final scrubbed = LogRedaction.sanitizeMessage('a\nb\rc');
      expect(scrubbed, 'a b c');

      final long = 'x' * (LogRedaction.maxMessageLength + 50);
      final truncated = LogRedaction.sanitizeMessage(long);
      expect(truncated.length, LogRedaction.maxMessageLength);
      expect(truncated.endsWith(LogRedaction.truncationMarker), isTrue);
    });

    test('scrubs Bearer JWT and token assignments', () {
      final jwt =
          'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0In0.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';
      final text = LogRedaction.sanitizeMessage(
        'Authorization Bearer abc.def.ghi token=$jwt password=hunter2',
      );
      expect(text, isNot(contains('abc.def.ghi')));
      expect(text, isNot(contains('hunter2')));
      expect(text, contains('Bearer ${LogRedaction.redacted}'));
      expect(text, contains('token=${LogRedaction.redacted}'));
      expect(text, contains('password=${LogRedaction.redacted}'));
    });
  });

  group('LogRedaction compound keys, JSON text, and emails', () {
    test('safeFields redacts compound secret key names', () {
      final safe = LogRedaction.safeFields({
        'client_secret': 'cs',
        'x-api-key': 'xk',
        'set-cookie': 'sid=1',
        'csrfToken': 'ct',
        'private_key': 'pk',
        'maxTokens': 256,
        'tokenCount': 3,
      });

      expect(safe['client_secret'], LogRedaction.redacted);
      expect(safe['x-api-key'], LogRedaction.redacted);
      expect(safe['set-cookie'], LogRedaction.redacted);
      expect(safe['csrfToken'], LogRedaction.redacted);
      expect(safe['private_key'], LogRedaction.redacted);
      expect(safe['maxTokens'], 256);
      expect(safe['tokenCount'], 3);
    });

    test('sanitizeMessage scrubs JSON-style and compound assignments', () {
      final text = LogRedaction.sanitizeMessage(
        'HTTP 400 body={"refresh_token":"opaque-r1","client_secret": "cs-2",'
        ' "status":"bad"} x-api-key: xk-3',
      );
      expect(text, isNot(contains('opaque-r1')));
      expect(text, isNot(contains('cs-2')));
      expect(text, isNot(contains('xk-3')));
      expect(text, contains('refresh_token=${LogRedaction.redacted}'));
      expect(text, contains('"status":"bad"'));
    });

    test('sanitizeMessage scrubs email addresses', () {
      final text = LogRedaction.sanitizeMessage(
        'profile.update failed for jane.doe+demo@example.com reason=conflict',
      );
      expect(text, isNot(contains('jane.doe')));
      expect(text, isNot(contains('example.com')));
      expect(text, contains('reason=conflict'));
    });

    test('sanitizeError scrubs secrets inside exception JSON payloads', () {
      final scrubbed = LogRedaction.sanitizeError(
        const FormatException('{"password": "hunter2", "email": "a@b.io"}'),
      );
      expect(scrubbed.toString(), isNot(contains('hunter2')));
      expect(scrubbed.toString(), isNot(contains('a@b.io')));
    });
  });

  group('LogRedaction.sanitizeError', () {
    test('returns null and scrubs exception text', () {
      expect(LogRedaction.sanitizeError(null), isNull);
      final scrubbed = LogRedaction.sanitizeError(
        StateError('token=supersecret'),
      );
      expect(scrubbed, isA<String>());
      expect(scrubbed.toString(), isNot(contains('supersecret')));
    });
  });
}
