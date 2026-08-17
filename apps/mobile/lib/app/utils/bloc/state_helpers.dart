import 'package:design_system/design_system.dart';

/// Helper utilities for common state checking patterns.
///
/// **Why this exists:** Provides a consistent API for checking ViewStatus states
/// across the codebase, making state checks more readable and reducing duplication.
///
/// **Usage Example:**
/// ```dart
/// if (StateHelpers.isLoading(state.status)) {
///   return const LoadingIndicator();
/// }
/// if (StateHelpers.hasError(state.status)) {
///   return ErrorView(error: state.error);
/// }
/// ```
class StateHelpers {
  StateHelpers._();

  /// Check if a ViewStatus indicates loading
  static bool isLoading(ViewStatus status) => status.isLoading;

  /// Check if a ViewStatus indicates error
  static bool hasError(ViewStatus status) => status.isError;

  /// Check if a ViewStatus indicates success
  static bool isSuccess(ViewStatus status) => status.isSuccess;

  /// Check if a ViewStatus indicates initial state
  static bool isInitial(ViewStatus status) => status.isInitial;
}
