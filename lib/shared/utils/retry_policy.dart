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
  });

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
    required Future<T> Function() action,
    CancelToken? cancelToken,
    bool Function(Object error)? shouldRetry,
  }) async {
    Object? lastError;
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      // Check cancellation before each attempt
      if (cancelToken?.isCancelled ?? false) {
        throw CancellationException('Retry cancelled');
      }

      try {
        return await action();
      } on Object catch (error) {
        lastError = error;

        // Check if we should retry this error
        if (shouldRetry != null && !shouldRetry(error)) {
          rethrow;
        }

        // Don't delay after the last attempt
        if (attempt < maxAttempts - 1) {
          final Duration delay = _calculateDelay(attempt);
          await Future.delayed(delay, () {
            // Check cancellation during delay
            if (cancelToken?.isCancelled ?? false) {
              throw CancellationException('Retry cancelled during delay');
            }
          });
        }
      }
    }

    // All retries exhausted, throw last error
    if (lastError == null) {
      throw Exception('Retry failed: unknown error');
    }
    if (lastError is Exception) {
      throw lastError;
    }
    if (lastError is Error) {
      throw lastError;
    }
    throw Exception(lastError.toString());
  }

  /// Calculate delay for the given attempt number (0-indexed).
  Duration _calculateDelay(final int attempt) {
    final Duration calculatedDelay = switch (strategy) {
      RetryStrategy.exponential => Duration(
        milliseconds: (baseDelay.inMilliseconds * pow(2, attempt)).toInt(),
      ),
      RetryStrategy.linear => Duration(
        milliseconds: baseDelay.inMilliseconds * (attempt + 1),
      ),
      RetryStrategy.fixed => baseDelay,
    };

    // Cap at maxDelay
    final Duration cappedDelay = calculatedDelay > maxDelay
        ? maxDelay
        : calculatedDelay;

    // Add jitter if enabled (random value between 0 and 25% of delay)
    if (jitter) {
      final Random random = Random();
      final int jitterMs =
          (cappedDelay.inMilliseconds * 0.25 * random.nextDouble()).toInt();
      return Duration(milliseconds: cappedDelay.inMilliseconds + jitterMs);
    }

    return cappedDelay;
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
