import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/shared/utils/completer_helper.dart';

void main() {
  group('CompleterHelper', () {
    late CompleterHelper<String> stringHelper;
    late CompleterHelper<void> voidHelper;
    late CompleterHelper<int?> nullableIntHelper;

    setUp(() {
      stringHelper = CompleterHelper<String>();
      voidHelper = CompleterHelper<void>();
      nullableIntHelper = CompleterHelper<int?>();
    });

    test('can complete nullable type without value', () async {
      final completer = nullableIntHelper.start();
      final result = nullableIntHelper.complete();
      expect(result, isTrue);

      final value = await completer.future;
      expect(value, isNull);
    });

    test('can complete void type without value', () async {
      final completer = voidHelper.start();
      final result = voidHelper.complete();
      expect(result, isTrue);

      await completer.future; // Should complete without error
    });

    test('throws when completing non-nullable type without value', () {
      stringHelper.start();
      expect(
        () => stringHelper.complete(),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Cannot complete non-nullable type'),
          ),
        ),
      );
    });

    test('can complete non-nullable type with value', () async {
      final completer = stringHelper.start();
      final result = stringHelper.complete('test value');
      expect(result, isTrue);

      final value = await completer.future;
      expect(value, equals('test value'));
    });

    test('complete returns false when no pending completer', () {
      final result = stringHelper.complete('value');
      expect(result, isFalse);
    });

    test('completeAndReset works for void type', () async {
      final completer = voidHelper.start();
      final result = voidHelper.completeAndReset();
      expect(result, isTrue);

      await completer.future; // Should complete without error
      expect(voidHelper.pending, isNull);
    });

    test('completeAndReset throws for non-nullable type without value', () {
      stringHelper.start();
      expect(
        () => stringHelper.completeAndReset(),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
