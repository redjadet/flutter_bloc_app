import 'dart:async';
import 'dart:math';

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
  Future<T> executeWithRetry<T>({
    required final Future<T> Function() action,
    final CancelToken? cancelToken,
    final bool Function(Object error)? shouldRetry,
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

        if (error is CancellationException) {
          rethrow;
        }

        if (shouldRetry != null && !shouldRetry(error)) {
          rethrow;
        }

        if (attempt < maxAttempts - 1) {
          final Duration delay = _calculateDelay(attempt);
          await _waitBeforeRetry(delay, cancelToken);
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
    final Duration calculatedDelay = switch (strategy) {
      RetryStrategy.exponential => Duration(
        milliseconds: (baseDelay.inMilliseconds * pow(2, attempt)).toInt(),
      ),
      RetryStrategy.linear => Duration(
        milliseconds: baseDelay.inMilliseconds * (attempt + 1),
      ),
      RetryStrategy.fixed => baseDelay,
    };

    final Duration cappedDelay = calculatedDelay > maxDelay
        ? maxDelay
        : calculatedDelay;

    if (jitter && cappedDelay > Duration.zero) {
      final Random random = Random();
      final int cappedMs = cappedDelay.inMilliseconds;
      final int maxMs = maxDelay.inMilliseconds;
      final int jitterRange = (cappedMs * 0.25).toInt();
      final int jitterOffset =
          random.nextInt((jitterRange * 2) + 1) - jitterRange;
      final int jitteredMs = cappedMs + jitterOffset;
      final int clampedMs = jitteredMs.clamp(0, maxMs);
      return Duration(milliseconds: clampedMs);
    }

    return cappedDelay;
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
  ) async {
    if (cancelToken == null) {
      await Future<void>.delayed(delay);
      return;
    }

    const Duration checkInterval = Duration(milliseconds: 50);
    final Stopwatch stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < delay) {
      _throwIfCancelled(cancelToken, duringDelay: true);
      final Duration remaining = delay - stopwatch.elapsed;
      final Duration waitDuration = remaining < checkInterval
          ? remaining
          : checkInterval;
      await Future<void>.delayed(waitDuration);
    }

    _throwIfCancelled(cancelToken, duringDelay: true);
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
