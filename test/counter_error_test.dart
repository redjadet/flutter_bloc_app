import 'package:flutter_bloc_app/features/counter/domain/counter_error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CounterError exposes type, message and original error', () {
    const CounterError cannot = CounterError.cannotGoBelowZero();
    expect(cannot.type, CounterErrorType.cannotGoBelowZero);
    expect(cannot.message, isNull);
    expect(cannot.originalError, isNull);

    final CounterError load = CounterError.load(
      originalError: Exception('load'),
      message: 'load failed',
    );
    expect(load.type, CounterErrorType.loadError);
    expect(load.message, 'load failed');
    expect(load.originalError, isA<Exception>());

    final CounterError save = CounterError.save(message: 'save failed');
    expect(save.type, CounterErrorType.saveError);
    expect(save.message, 'save failed');

    final CounterError unknown = CounterError.unknown();
    expect(unknown.type, CounterErrorType.unknown);
  });
}
