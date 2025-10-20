import 'dart:async';
import 'dart:isolate';

/// Provides small examples demonstrating how to offload work to isolates.
///
/// The helpers below intentionally keep the public API simple so the
/// accompanying tests can focus on multi-isolate behavior.
class IsolateSamples {
  const IsolateSamples._();

  /// Computes the `n`th Fibonacci number on a background isolate.
  ///
  /// The computation itself is intentionally CPU-bound so we can observe the
  /// advantage of moving the work off the main isolate.
  static Future<int> fibonacci(final int n) async {
    final ReceivePort receivePort = ReceivePort();
    await Isolate.spawn<_FibonacciMessage>(
      _fibonacciEntryPoint,
      _FibonacciMessage(n, receivePort.sendPort),
    );
    return (await receivePort.first) as int;
  }

  /// Runs multiple "delay then double" tasks in parallel isolates.
  ///
  /// Each value is processed on its own isolate which waits for [delay] and
  /// then returns `value * 2`. The combined result demonstrates how work can be
  /// parallelized.
  static Future<List<int>> delayedDoubleAll(
    final List<int> values, {
    final Duration delay = const Duration(milliseconds: 120),
  }) async {
    final List<Future<int>> tasks = <Future<int>>[
      for (final int value in values) _delayedDouble(value, delay),
    ];
    return Future.wait(tasks);
  }

  static Future<int> _delayedDouble(
    final int value,
    final Duration delay,
  ) async {
    final ReceivePort receivePort = ReceivePort();
    await Isolate.spawn<_DelayMessage>(
      _delayEntryPoint,
      _DelayMessage(value, delay, receivePort.sendPort),
    );
    return (await receivePort.first) as int;
  }
}

class _FibonacciMessage {
  const _FibonacciMessage(this.n, this.replyPort);

  final int n;
  final SendPort replyPort;
}

class _DelayMessage {
  const _DelayMessage(this.value, this.delay, this.replyPort);

  final int value;
  final Duration delay;
  final SendPort replyPort;
}

Future<void> _fibonacciEntryPoint(final _FibonacciMessage message) async {
  final int result = _calculateFibonacci(message.n);
  message.replyPort.send(result);
}

Future<void> _delayEntryPoint(final _DelayMessage message) async {
  await Future<void>.delayed(message.delay);
  message.replyPort.send(message.value * 2);
}

int _calculateFibonacci(final int n) {
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
