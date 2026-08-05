import 'package:test/test.dart';
import 'package:utilities/utilities.dart';

void main() {
  group('PushMessage', () {
    test('equality, copyWith, default source via public barrel', () {
      final PushMessage a = PushMessage(
        messageId: 'id-1',
        title: 'Hello',
        body: 'World',
        sentTime: DateTime.utc(2026, 8, 5),
        data: <String, String>{'k': 'v'},
      );
      final PushMessage b = PushMessage(
        messageId: 'id-1',
        title: 'Hello',
        body: 'World',
        sentTime: DateTime.utc(2026, 8, 5),
        data: <String, String>{'k': 'v'},
      );

      expect(a, equals(b));
      expect(a.source, PushMessageSource.foreground);
      expect(a.copyWith(messageId: 'next').messageId, 'next');
      expect(a.copyWith(messageId: 'next'), isNot(equals(a)));
    });
  });
}
