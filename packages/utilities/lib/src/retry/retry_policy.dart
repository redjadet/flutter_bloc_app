import 'dart:async';
import 'dart:math';

part 'retry_policy_execute.part.dart';

/// Delay callback used by [RetryPolicy.executeWithRetry] for backoff waits.
///
/// Production default is [Future.delayed]. Callers that need [TimerService]
/// (or other controllable clocks) pass an adapter that completes after
/// [duration]. Cancellation polling still invokes this once per ≤50 ms chunk.
typedef RetryDelay = Future<void> Function(Duration duration);

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
/// When a [RetryDelay] is passed to [executeWithRetry], backoff waits use it
/// (testable / app-adapted delays). When null, uses [Future.delayed].
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
  /// When [delay] is provided, backoff waits use it (enables test / TimerService
  /// adapters). When null, uses [Future.delayed].
  Future<T> executeWithRetry<T>({
    required final Future<T> Function() action,
    final CancelToken? cancelToken,
    final bool Function(Object error)? shouldRetry,
    final RetryDelay? delay,
  }) => _retryPolicyExecuteWithRetry(
    this,
    action: action,
    cancelToken: cancelToken,
    shouldRetry: shouldRetry,
    delay: delay,
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
