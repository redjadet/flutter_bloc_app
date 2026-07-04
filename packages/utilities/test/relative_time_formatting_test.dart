import 'package:utilities/utilities.dart';
import 'package:test/test.dart';

void main() {
  group('formatRelativeTimeShort', () {
    final DateTime now = DateTime(2026, 6, 23, 12, 0);

    test('returns days when difference is at least one day', () {
      expect(
        formatRelativeTimeShort(
          now.subtract(const Duration(days: 3, hours: 2)),
          now: now,
        ),
        '3d',
      );
    });

    test('returns hours when difference is under one day', () {
      expect(
        formatRelativeTimeShort(
          now.subtract(const Duration(hours: 2, minutes: 10)),
          now: now,
        ),
        '2h',
      );
    });

    test('returns now when difference is under one minute', () {
      expect(
        formatRelativeTimeShort(
          now.subtract(const Duration(seconds: 20)),
          now: now,
        ),
        'now',
      );
    });
  });
}
