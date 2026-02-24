import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// State of the circuit.
enum CircuitState {
  /// Requests are allowed.
  closed,

  /// Too many failures; requests fail fast until cooldown.
  open,

  /// Allowing one probe request to test recovery.
  halfOpen,
}

/// Optional circuit breaker for HTTP or repository calls.
///
/// Use for high-traffic or enterprise builds to avoid hammering a failing
/// endpoint: after [failureThreshold] failures in [window], the circuit opens
/// and calls fail fast until [cooldown] expires, then one probe is allowed.
///
/// Enable via feature-flag or build config; not required for normal usage.
class CircuitBreaker {
  /// Creates a circuit breaker.
  ///
  /// [key] identifies the circuit (e.g. endpoint or repository name).
  CircuitBreaker({
    required this.key,
    this.failureThreshold = 5,
    this.window = const Duration(seconds: 60),
    this.cooldown = const Duration(seconds: 30),
  });

  /// Identifier for this circuit (e.g. 'api.example.com' or 'graphql').
  final String key;

  /// Number of failures in [window] that open the circuit.
  final int failureThreshold;

  /// Time window in which failures are counted.
  final Duration window;

  /// How long the circuit stays open before allowing a probe.
  final Duration cooldown;

  CircuitState _state = CircuitState.closed;
  int _failures = 0;
  DateTime? _windowStart;
  DateTime? _openedAt;
  bool _halfOpenProbeInFlight = false;

  /// Current state (for tests or diagnostics).
  CircuitState get state => _state;

  /// Executes [action] if the circuit allows; otherwise throws immediately.
  ///
  /// On success in halfOpen, closes the circuit. On failure in halfOpen,
  /// reopens. Call [recordSuccess] / [recordFailure] from the caller after
  /// the operation if you need to drive the breaker from outside; or use
  /// [execute] which does it automatically.
  Future<T> execute<T>(final Future<T> Function() action) async {
    if (_state == CircuitState.open) {
      if (_openedAt case final DateTime openAt
          when DateTime.now().difference(openAt) > cooldown) {
        _state = CircuitState.halfOpen;
        _halfOpenProbeInFlight = false;
        _openedAt = null;
        AppLogger.debug('CircuitBreaker[$key] halfOpen (probe allowed)');
      } else {
        throw CircuitOpenException(key);
      }
    }

    bool enteredHalfOpen = false;
    if (_state == CircuitState.halfOpen) {
      if (_halfOpenProbeInFlight) {
        throw CircuitOpenException(key);
      }
      _halfOpenProbeInFlight = true;
      enteredHalfOpen = true;
    }

    try {
      final T result = await action();
      if (_state == CircuitState.halfOpen) {
        _state = CircuitState.closed;
        _failures = 0;
        _windowStart = null;
        AppLogger.debug('CircuitBreaker[$key] closed (probe succeeded)');
      }
      return result;
    } on Object {
      _recordFailure();
      rethrow;
    } finally {
      if (enteredHalfOpen) {
        _halfOpenProbeInFlight = false;
      }
    }
  }

  /// Records a failure (call from outside if not using [execute]).
  void recordFailure() => _recordFailure();

  void _recordFailure() {
    final DateTime now = DateTime.now();
    if (_windowStart == null || now.difference(_windowStart!) > window) {
      _windowStart = now;
      _failures = 0;
    }
    _failures++;

    if (_state == CircuitState.halfOpen) {
      _state = CircuitState.open;
      _openedAt = now;
      AppLogger.debug('CircuitBreaker[$key] open (probe failed)');
      return;
    }

    if (_failures >= failureThreshold) {
      _state = CircuitState.open;
      _openedAt = now;
      AppLogger.debug(
        'CircuitBreaker[$key] open after $failureThreshold failures',
      );
    }
  }

  /// Records a success (call from outside if not using [execute]).
  void recordSuccess() {
    if (_state == CircuitState.halfOpen) {
      _state = CircuitState.closed;
      _failures = 0;
      _windowStart = null;
    }
  }

  /// Resets the circuit to closed (e.g. for tests).
  void reset() {
    _state = CircuitState.closed;
    _failures = 0;
    _windowStart = null;
    _openedAt = null;
    _halfOpenProbeInFlight = false;
  }
}

/// Thrown when the circuit is open and the call is rejected.
class CircuitOpenException implements Exception {
  CircuitOpenException(this.circuitKey);

  final String circuitKey;

  @override
  String toString() => 'CircuitOpenException: circuit $circuitKey is open';
}
