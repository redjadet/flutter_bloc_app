import 'package:flutter_bloc_app/shared/utils/request_id_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RequestIdGuard', () {
    test('next() returns incrementing ids', () {
      final RequestIdGuard guard = RequestIdGuard();
      expect(guard.next(), 1);
      expect(guard.next(), 2);
      expect(guard.next(), 3);
    });

    test('isCurrent returns true only for latest id', () {
      final RequestIdGuard guard = RequestIdGuard();
      final int a = guard.next();
      expect(guard.isCurrent(a), isTrue);
      final int b = guard.next();
      expect(guard.isCurrent(a), isFalse);
      expect(guard.isCurrent(b), isTrue);
    });

    test('invalidate() makes current id stale', () {
      final RequestIdGuard guard = RequestIdGuard();
      final int id = guard.next();
      expect(guard.isCurrent(id), isTrue);
      guard.invalidate();
      expect(guard.isCurrent(id), isFalse);
    });

    test('currentId returns latest id', () {
      final RequestIdGuard guard = RequestIdGuard();
      expect(guard.currentId, 0);
      guard.next();
      expect(guard.currentId, 1);
      guard.next();
      expect(guard.currentId, 2);
    });

    test('currentId setter sets current id for tests', () {
      final RequestIdGuard guard = RequestIdGuard();
      guard.next();
      guard.currentId = 42;
      expect(guard.currentId, 42);
      expect(guard.isCurrent(42), isTrue);
      expect(guard.isCurrent(1), isFalse);
    });
  });
}
