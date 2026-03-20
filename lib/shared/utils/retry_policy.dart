import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc_app/core/time/timer_service.dart';

/// Retry strategy types for different backoff patterns.
enum RetryStrategy {
  /// Exponential backoff: delay = baseDelay * 2^attempt
  exponential,

  /// Linear backoff: delay = baseDelay * attempt
  linear,

  /// Fixed delay: delay = baseDelay (constant)
  fixed,
}

/// A standardized retry policy for consistent retry behavior across features.
///
/// Provides helper methods for cubits to standardize retry behavior
/// (search, chat, charts, etc.) with cancellation support.
///
/// When a [TimerService] is passed to [executeWithRetry], backoff delays use it (testable time);
/// when null, uses [Future.delayed] (allow-listed in validation script).
class RetryPolicy {
  /// Creates a retry policy with the specified configuration.
  const RetryPolicy({
    this.maxAttempts = 3,
    this.baseDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.strategy = RetryStrategy.exponential,
    this.jitter = true,
  }) : assert(maxAttempts > 0, 'maxAttempts must be greater than 0');

  /// Maximum number of retry attempts (including initial attempt).
  final int maxAttempts;

  /// Base delay between retries.
  final Duration baseDelay;

  /// Maximum delay cap for exponential/linear backoff.
  final Duration maxDelay;

  /// Retry strategy to use for calculating delays.
  final RetryStrategy strategy;

  /// Whether to add random jitter to delays (helps prevent thundering herd).
  final bool jitter;

  /// Execute an action with retry logic.
  ///
  /// Returns the result of [action] if successful, or throws the last error
  /// after all retries are exhausted.
  ///
  /// If [cancelToken] is provided and cancelled, throws [CancellationException].
  /// When [timerService] is provided, backoff delays use it (enables test time control).
  Future<T> executeWithRetry<T>({
    required final Future<T> Function() action,
    final CancelToken? cancelToken,
    final bool Function(Object error)? shouldRetry,
    final TimerService? timerService,
  }) async {
    Object? lastError;
    StackTrace? lastStackTrace;
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      _throwIfCancelled(cancelToken);

      try {
        return await action();
      } on Object catch (error, stackTrace) {
        lastError = error;
        lastStackTrace = stackTrace;

        if (!_shouldRetryError(error, shouldRetry)) {
          rethrow;
        }

        final bool hasRemainingAttempts = attempt < maxAttempts - 1;
        if (hasRemainingAttempts) {
          await _waitBeforeRetry(
            _calculateDelay(attempt),
            cancelToken,
            timerService,
          );
        }
      }
    }

    if (lastError == null) {
      throw Exception('Retry failed: unknown error');
    }

    if (lastStackTrace != null) {
      Error.throwWithStackTrace(lastError, lastStackTrace);
    }

    throw Exception(lastError.toString());
  }

  bool _shouldRetryError(
    final Object error,
    final bool Function(Object error)? shouldRetry,
  ) {
    if (error is CancellationException) {
      return false;
    }
    return shouldRetry?.call(error) ?? true;
  }

  /// Calculate delay for the given attempt number (0-indexed).
  Duration _calculateDelay(final int attempt) => calculateDelay(
    attempt: attempt,
    baseDelay: baseDelay,
    maxDelay: maxDelay,
    strategy: strategy,
    jitter: jitter,
  );

  /// Shared delay calculation for use by other layers (e.g. HTTP client).
  ///
  /// Uses exponential backoff by default with cap and optional jitter.
  static Duration calculateDelay({
    required final int attempt,
    required final Duration baseDelay,
    required final Duration maxDelay,
    final RetryStrategy strategy = RetryStrategy.exponential,
    final bool jitter = true,
  }) {
    final Duration cappedDelay = _capDelay(
      _calculateBaseDelay(
        attempt: attempt,
        baseDelay: baseDelay,
        strategy: strategy,
      ),
      maxDelay,
    );

    if (jitter && cappedDelay > Duration.zero) {
      return _applyJitter(cappedDelay, maxDelay, Random());
    }

    return cappedDelay;
  }

  static Duration _calculateBaseDelay({
    required final int attempt,
    required final Duration baseDelay,
    required final RetryStrategy strategy,
  }) {
    return switch (strategy) {
      RetryStrategy.exponential => Duration(
        milliseconds: (baseDelay.inMilliseconds * pow(2, attempt)).toInt(),
      ),
      RetryStrategy.linear => Duration(
        milliseconds: baseDelay.inMilliseconds * (attempt + 1),
      ),
      RetryStrategy.fixed => baseDelay,
    };
  }

  static Duration _capDelay(
    final Duration calculatedDelay,
    final Duration maxDelay,
  ) {
    return calculatedDelay > maxDelay ? maxDelay : calculatedDelay;
  }

  static Duration _applyJitter(
    final Duration cappedDelay,
    final Duration maxDelay,
    final Random random,
  ) {
    final int cappedMs = cappedDelay.inMilliseconds;
    final int maxMs = maxDelay.inMilliseconds;
    final int jitterRange = (cappedMs * 0.25).toInt();
    final int jitterOffset =
        random.nextInt((jitterRange * 2) + 1) - jitterRange;
    final int jitteredMs = cappedMs + jitterOffset;
    final int clampedMs = jitteredMs.clamp(0, maxMs);
    return Duration(milliseconds: clampedMs);
  }

  void _throwIfCancelled(
    final CancelToken? cancelToken, {
    final bool duringDelay = false,
  }) {
    if (cancelToken?.isCancelled ?? false) {
      throw CancellationException(
        duringDelay ? 'Retry cancelled during delay' : 'Retry cancelled',
      );
    }
  }

  Future<void> _waitBeforeRetry(
    final Duration delay,
    final CancelToken? cancelToken,
    final TimerService? timerService,
  ) async {
    if (cancelToken == null && timerService == null) {
      await Future<void>.delayed(delay);
      return;
    }

    const Duration checkInterval = Duration(milliseconds: 50);
    Duration elapsed = Duration.zero;

    while (elapsed < delay) {
      _throwIfCancelled(cancelToken, duringDelay: true);
      final Duration waitDuration = _nextDelayChunk(
        remaining: delay - elapsed,
        checkInterval: checkInterval,
      );
      await _delay(waitDuration, timerService);
      elapsed += waitDuration;
    }

    _throwIfCancelled(cancelToken, duringDelay: true);
  }

  static Duration _nextDelayChunk({
    required final Duration remaining,
    required final Duration checkInterval,
  }) {
    return remaining < checkInterval ? remaining : checkInterval;
  }

  static Future<void> _delay(
    final Duration duration,
    final TimerService? timerService,
  ) {
    if (timerService != null) {
      return _delayViaTimerService(timerService, duration);
    }
    return Future<void>.delayed(duration);
  }

  static Future<void> _delayViaTimerService(
    final TimerService service,
    final Duration duration,
  ) {
    final Completer<void> completer = Completer<void>();
    final TimerDisposable handle = service.runOnce(duration, () {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
    return completer.future.whenComplete(handle.dispose);
  }

  /// Create a default retry policy for transient errors (5xx, timeouts).
  static const RetryPolicy transientErrors = RetryPolicy(
    maxDelay: Duration(seconds: 10),
  );

  /// Create a retry policy for network errors with longer delays.
  static const RetryPolicy networkErrors = RetryPolicy(
    baseDelay: Duration(seconds: 2),
  );
}

/// Token for cancelling retry operations.
class CancelToken {
  CancelToken();

  bool _isCancelled = false;

  /// Whether this token has been cancelled.
  bool get isCancelled => _isCancelled;

  /// Cancel the retry operation.
  void cancel() {
    _isCancelled = true;
  }
}

/// Exception thrown when a retry operation is cancelled.
class CancellationException implements Exception {
  CancellationException(this.message);

  final String message;

  @override
  String toString() => 'CancellationException: $message';
}
