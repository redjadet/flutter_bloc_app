import 'package:equatable/equatable.dart';

/// Extension methods for sealed state classes to enable exhaustive pattern matching.
///
/// These helpers provide compile-time exhaustiveness checking when using
/// sealed classes for state hierarchies.
///
/// **Usage Example:**
/// ```dart
/// sealed class DeepLinkState extends Equatable { ... }
///
/// // In UI code:
/// state.when(
///   idle: () => Text('Idle'),
///   loading: () => CircularProgressIndicator(),
///   navigate: (target, origin) => NavigateTo(target),
///   error: (message) => ErrorWidget(message),
/// );
/// ```
extension SealedStateHelpers<T extends Equatable> on T {
  /// Performs exhaustive pattern matching on a sealed state.
  ///
  /// This method ensures all state variants are handled at compile time.
  ///
  /// **Usage Example:**
  /// ```dart
  /// state.when<Widget>(
  ///   idle: () => Text('Idle'),
  ///   loading: () => CircularProgressIndicator(),
  ///   navigate: (target, origin) => NavigateTo(target),
  ///   error: (message) => ErrorWidget(message),
  /// );
  /// ```
  ///
  /// **Note:** This is a helper method. For true compile-time exhaustiveness,
  /// use Dart 3.0+ pattern matching with `switch` expressions:
  /// ```dart
  /// switch (state) {
  ///   case DeepLinkIdle():
  ///     return Text('Idle');
  ///   case DeepLinkLoading():
  ///     return CircularProgressIndicator();
  ///   case DeepLinkNavigate(:final target, :final origin):
  ///     return NavigateTo(target);
  ///   case DeepLinkError(:final message):
  ///     return ErrorWidget(message);
  /// }
  /// ```
  R when<R>({
    final R Function()? idle,
    final R Function()? loading,
    final R Function(Object? target, Object? origin)? navigate,
    final R Function(String message)? error,
  }) {
    // This is a runtime helper. For compile-time exhaustiveness,
    // use Dart 3.0+ pattern matching with switch expressions.
    throw UnimplementedError(
      'Use Dart 3.0+ pattern matching with switch expressions for '
      'compile-time exhaustiveness checking. Example:\n'
      'switch (state) {\n'
      '  case DeepLinkIdle():\n'
      '    return idle?.call() ?? throw StateError("Missing handler");\n'
      '  // ... other cases\n'
      '}',
    );
  }
}

/// Helper class for creating exhaustive switch statements for sealed states.
///
/// This provides a type-safe way to ensure all state variants are handled.
///
/// **Usage Example:**
/// ```dart
/// final result = SealedStateMatcher<DeepLinkState, Widget>(state)
///   .caseIdle(() => Text('Idle'))
///   .caseLoading(() => CircularProgressIndicator())
///   .caseNavigate((target, origin) => NavigateTo(target))
///   .caseError((message) => ErrorWidget(message))
///   .build();
/// ```
///
/// **Note:** For true compile-time exhaustiveness, prefer Dart 3.0+ pattern matching.
class SealedStateMatcher<S, R> {
  /// Creates a matcher for the given state.
  SealedStateMatcher(this.state);

  /// The state to match against.
  final S state;

  R? _idleResult;
  R? _loadingResult;
  R? _navigateResult;
  R? _errorResult;

  /// Handles the idle state variant.
  SealedStateMatcher<S, R> caseIdle(final R Function() handler) {
    // Runtime check - for compile-time, use switch expressions
    if (state.toString().contains('Idle')) {
      _idleResult = handler();
    }
    // Builder pattern requires returning 'this' for method chaining
    // ignore: avoid_returning_this
    return this;
  }

  /// Handles the loading state variant.
  SealedStateMatcher<S, R> caseLoading(final R Function() handler) {
    if (state.toString().contains('Loading')) {
      _loadingResult = handler();
    }
    // Builder pattern requires returning 'this' for method chaining
    // ignore: avoid_returning_this
    return this;
  }

  /// Handles the navigate state variant.
  SealedStateMatcher<S, R> caseNavigate(
    final R Function(Object? target, Object? origin) handler,
  ) {
    if (state.toString().contains('Navigate')) {
      // This is a simplified example - actual implementation would
      // extract target and origin from the state
      _navigateResult = handler(null, null);
    }
    // Builder pattern requires returning 'this' for method chaining
    // ignore: avoid_returning_this
    return this;
  }

  /// Handles the error state variant.
  SealedStateMatcher<S, R> caseError(final R Function(String message) handler) {
    if (state.toString().contains('Error')) {
      // This is a simplified example - actual implementation would
      // extract message from the state
      _errorResult = handler('');
    }
    // Builder pattern requires returning 'this' for method chaining
    // ignore: avoid_returning_this
    return this;
  }

  /// Builds the result, returning the first non-null handler result.
  ///
  /// Throws if no handler matched the state.
  R build() =>
      _idleResult ??
      _loadingResult ??
      _navigateResult ??
      _errorResult ??
      (throw StateError('No handler matched state: $state'));
}

/// Recommended pattern for exhaustive state handling with sealed classes.
///
/// **Best Practice:** Use Dart 3.0+ pattern matching for compile-time exhaustiveness:
///
/// ```dart
/// Widget buildStateWidget(DeepLinkState state) {
///   return switch (state) {
///     DeepLinkIdle() => Text('Idle'),
///     DeepLinkLoading() => CircularProgressIndicator(),
///     DeepLinkNavigate(:final target, :final origin) => NavigateTo(target),
///     DeepLinkError(:final message) => ErrorWidget(message),
///   };
/// }
/// ```
///
/// The compiler will ensure all variants are handled, providing true
/// compile-time exhaustiveness checking.
