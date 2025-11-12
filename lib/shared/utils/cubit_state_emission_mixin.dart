import 'package:flutter_bloc_app/shared/ui/view_status.dart';

/// Helper utilities for common state checking patterns
class StateHelpers {
  StateHelpers._();

  /// Check if a ViewStatus indicates loading
  static bool isLoading(final ViewStatus status) => status.isLoading;

  /// Check if a ViewStatus indicates error
  static bool hasError(final ViewStatus status) => status.isError;

  /// Check if a ViewStatus indicates success
  static bool isSuccess(final ViewStatus status) => status.isSuccess;

  /// Check if a ViewStatus indicates initial state
  static bool isInitial(final ViewStatus status) => status.isInitial;
}
