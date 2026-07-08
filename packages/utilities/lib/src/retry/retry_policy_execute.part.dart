part of 'retry_policy.dart';

final DefaultTimerService _retryPolicyDefaultTimerService =
    DefaultTimerService();

Future<T> _retryPolicyExecuteWithRetry<T>(
  final RetryPolicy policy, {
  required final Future<T> Function() action,
  final CancelToken? cancelToken,
  final bool Function(Object error)? shouldRetry,
  final TimerService? timerService,
}) async {
  Object? lastError;
  StackTrace? lastStackTrace;
  for (int attempt = 0; attempt < policy.maxAttempts; attempt++) {
    _retryPolicyThrowIfCancelled(cancelToken);

    try {
      return await action();
    } on Object catch (error, stackTrace) {
      lastError = error;
      lastStackTrace = stackTrace;

      if (!_retryPolicyShouldRetryError(error, shouldRetry)) {
        rethrow;
      }

      final bool hasRemainingAttempts = attempt < policy.maxAttempts - 1;
      if (hasRemainingAttempts) {
        await _retryPolicyWaitBeforeRetry(
          RetryPolicy.calculateDelay(
            attempt: attempt,
            baseDelay: policy.baseDelay,
            maxDelay: policy.maxDelay,
            strategy: policy.strategy,
            jitter: policy.jitter,
          ),
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

bool _retryPolicyShouldRetryError(
  final Object error,
  final bool Function(Object error)? shouldRetry,
) {
  if (error is CancellationException) {
    return false;
  }
  return shouldRetry?.call(error) ?? true;
}

void _retryPolicyThrowIfCancelled(
  final CancelToken? cancelToken, {
  final bool duringDelay = false,
}) {
  if (cancelToken?.isCancelled ?? false) {
    throw CancellationException(
      duringDelay ? 'Retry cancelled during delay' : 'Retry cancelled',
    );
  }
}

Future<void> _retryPolicyWaitBeforeRetry(
  final Duration delay,
  final CancelToken? cancelToken,
  final TimerService? timerService,
) async {
  final TimerService effectiveTimerService =
      timerService ?? _retryPolicyDefaultTimerService;

  if (cancelToken == null) {
    await _retryPolicyDelayViaTimerService(effectiveTimerService, delay);
    return;
  }

  const Duration checkInterval = Duration(milliseconds: 50);
  Duration elapsed = Duration.zero;

  while (elapsed < delay) {
    _retryPolicyThrowIfCancelled(cancelToken, duringDelay: true);
    final Duration waitDuration = _retryPolicyNextDelayChunk(
      remaining: delay - elapsed,
      checkInterval: checkInterval,
    );
    await _retryPolicyDelayViaTimerService(effectiveTimerService, waitDuration);
    elapsed += waitDuration;
  }

  _retryPolicyThrowIfCancelled(cancelToken, duringDelay: true);
}

Duration _retryPolicyNextDelayChunk({
  required final Duration remaining,
  required final Duration checkInterval,
}) {
  return remaining < checkInterval ? remaining : checkInterval;
}

Future<void> _retryPolicyDelayViaTimerService(
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
