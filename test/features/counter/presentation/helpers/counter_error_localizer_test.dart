import 'package:flutter_bloc_app/features/counter/domain/counter_error.dart';
import 'package:flutter_bloc_app/features/counter/presentation/helpers/counter_error_localizer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../l10n/mocks.dart';

void main() {
  group('counterErrorMessage', () {
    late MockAppLocalizations l10n;

    setUp(() {
      l10n = MockAppLocalizations();
      when(() => l10n.cannotGoBelowZero).thenReturn('Cannot go below zero');
      when(() => l10n.loadErrorMessage).thenReturn('Load error');
    });

    test('returns correct message for cannotGoBelowZero', () {
      const error = CounterError.cannotGoBelowZero();
      expect(counterErrorMessage(l10n, error), 'Cannot go below zero');
    });

    test('returns correct message for loadError', () {
      const error = CounterError.load();
      expect(counterErrorMessage(l10n, error), 'Load error');
    });

    test('returns correct message for saveError', () {
      const error = CounterError.save();
      expect(counterErrorMessage(l10n, error), 'Load error');
    });

    test('returns correct message for unknown error with message', () {
      const error = CounterError.unknown(message: 'Unknown error');
      expect(counterErrorMessage(l10n, error), 'Unknown error');
    });

    test('returns correct message for unknown error without message', () {
      const error = CounterError.unknown();
      expect(counterErrorMessage(l10n, error), 'Load error');
    });
  });
}
