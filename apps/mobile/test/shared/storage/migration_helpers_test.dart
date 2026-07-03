import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/shared/storage/migration_helpers.dart';

void main() {
  group('MigrationHelpers', () {
    group('normalizeCount', () {
      test('returns positive integer as-is', () {
        expect(MigrationHelpers.normalizeCount(5), 5);
        expect(MigrationHelpers.normalizeCount(100), 100);
        expect(MigrationHelpers.normalizeCount(0), 0);
      });

      test('normalizes negative integers to zero', () {
        expect(MigrationHelpers.normalizeCount(-1), 0);
        expect(MigrationHelpers.normalizeCount(-100), 0);
      });

      test('truncates positive floats to integers', () {
        expect(MigrationHelpers.normalizeCount(3.7), 3);
        expect(MigrationHelpers.normalizeCount(10.9), 10);
        expect(MigrationHelpers.normalizeCount(0.5), 0);
      });

      test('normalizes negative floats to zero', () {
        expect(MigrationHelpers.normalizeCount(-3.7), 0);
        expect(MigrationHelpers.normalizeCount(-0.1), 0);
      });

      test('returns null for non-numeric types', () {
        expect(MigrationHelpers.normalizeCount('invalid'), isNull);
        expect(MigrationHelpers.normalizeCount(null), isNull);
        expect(MigrationHelpers.normalizeCount(true), isNull);
        expect(MigrationHelpers.normalizeCount([]), isNull);
        expect(MigrationHelpers.normalizeCount({}), isNull);
      });

      test('handles edge cases', () {
        // Infinity and NaN cannot be converted to int, so they throw UnsupportedError
        // UnsupportedError is an Error, not an Exception
        expect(
          () => MigrationHelpers.normalizeCount(double.infinity),
          throwsA(isA<UnsupportedError>()),
        );
        expect(
          () => MigrationHelpers.normalizeCount(double.nan),
          throwsA(isA<UnsupportedError>()),
        );
      });
    });

    group('normalizeTimestamp', () {
      test('returns valid timestamp as-is', () {
        final now = DateTime.now().millisecondsSinceEpoch;
        expect(MigrationHelpers.normalizeTimestamp(now), now);
        expect(MigrationHelpers.normalizeTimestamp(0), 0);
      });

      test('converts numeric types to int', () {
        final now = DateTime.now().millisecondsSinceEpoch;
        expect(MigrationHelpers.normalizeTimestamp(now.toDouble()), now);
      });

      test('returns null for negative timestamps', () {
        expect(MigrationHelpers.normalizeTimestamp(-1), isNull);
        expect(MigrationHelpers.normalizeTimestamp(-1000), isNull);
      });

      test('returns null for timestamps too far in the future', () {
        final now = DateTime.now().millisecondsSinceEpoch;
        final tooFarFuture = now + (366 * 24 * 60 * 60 * 1000); // 366 days
        expect(MigrationHelpers.normalizeTimestamp(tooFarFuture), isNull);
      });

      test('accepts timestamps up to 1 year in the future', () {
        final now = DateTime.now().millisecondsSinceEpoch;
        final oneYearFuture = now + (365 * 24 * 60 * 60 * 1000); // 365 days
        expect(
          MigrationHelpers.normalizeTimestamp(oneYearFuture),
          oneYearFuture,
        );
      });

      test('returns null for non-numeric types', () {
        expect(MigrationHelpers.normalizeTimestamp('invalid'), isNull);
        expect(MigrationHelpers.normalizeTimestamp(null), isNull);
        expect(MigrationHelpers.normalizeTimestamp(true), isNull);
        expect(MigrationHelpers.normalizeTimestamp([]), isNull);
        expect(MigrationHelpers.normalizeTimestamp({}), isNull);
      });

      test('handles edge cases', () {
        // Infinity and NaN cannot be converted to int, so they throw UnsupportedError
        // UnsupportedError is an Error, not an Exception
        expect(
          () => MigrationHelpers.normalizeTimestamp(double.infinity),
          throwsA(isA<UnsupportedError>()),
        );
        expect(
          () => MigrationHelpers.normalizeTimestamp(double.nan),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('handles very old timestamps', () {
        // Timestamp from year 2000
        final oldTimestamp = DateTime(2000, 1, 1).millisecondsSinceEpoch;
        expect(MigrationHelpers.normalizeTimestamp(oldTimestamp), oldTimestamp);
      });

      test('handles timestamps at boundary (exactly 1 year)', () {
        final now = DateTime.now().millisecondsSinceEpoch;
        final exactlyOneYear = now + (365 * 24 * 60 * 60 * 1000);
        expect(
          MigrationHelpers.normalizeTimestamp(exactlyOneYear),
          exactlyOneYear,
        );
      });
    });
  });
}
