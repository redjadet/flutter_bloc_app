/// Error types for counter operations
enum CounterErrorType { cannotGoBelowZero, loadError, saveError, unknown }

/// Counter error model with type and optional message
class CounterError {

  /// Creates a cannot go below zero error
  factory CounterError.cannotGoBelowZero() {
    return const CounterError(type: CounterErrorType.cannotGoBelowZero);
  }

  /// Creates a load error
  factory CounterError.loadError([Object? originalError]) {
    return CounterError(
      type: CounterErrorType.loadError,
      originalError: originalError,
    );
  }

  /// Creates a save error
  factory CounterError.saveError([Object? originalError]) {
    return CounterError(
      type: CounterErrorType.saveError,
      originalError: originalError,
    );
  }

  /// Creates an unknown error
  factory CounterError.unknown([Object? originalError]) {
    return CounterError(
      type: CounterErrorType.unknown,
      originalError: originalError,
    );
  }
  const CounterError({required this.type, this.message, this.originalError});

  final CounterErrorType type;
  final String? message;
  final Object? originalError;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CounterError &&
        other.type == type &&
        other.message == message;
  }

  @override
  int get hashCode => Object.hash(type, message);

  @override
  String toString() {
    return 'CounterError(type: $type, message: $message, originalError: $originalError)';
  }
}
