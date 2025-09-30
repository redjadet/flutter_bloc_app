import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bloc_app/shared/utils/isolate_samples.dart';

void main() {
  group('IsolateSamples', () {
    test('computes fibonacci number on a background isolate', () async {
      const int input = 20;
      final int expected = _fibonacciBaseline(input);

      final int result = await IsolateSamples.fibonacci(input);

      expect(result, expected);
    });

    test('executes multiple tasks in parallel isolates', () async {
      final Stopwatch stopwatch = Stopwatch()..start();
      final List<int> result = await IsolateSamples.delayedDoubleAll(<int>[
        1,
        2,
        3,
      ], delay: const Duration(milliseconds: 120));
      stopwatch.stop();

      expect(result, <int>[2, 4, 6]);

      // Sequential execution would take roughly 360ms. Allow generous overhead
      // while still asserting that the work happened in parallel isolates.
      expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 320)));
    });
  });
}

int _fibonacciBaseline(int n) {
  if (n <= 0) {
    return 0;
  }
  if (n == 1) {
    return 1;
  }
  int previous = 0;
  int current = 1;
  for (int i = 2; i <= n; i++) {
    final int next = previous + current;
    previous = current;
    current = next;
  }
  return current;
}
