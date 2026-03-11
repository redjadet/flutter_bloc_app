/// Exception thrown when chart data cannot be loaded (e.g. remote failure).
///
/// Use in chart data layer instead of raw [Exception] for consistent
/// handling and testability. Presentation can catch [ChartDataException]
/// to show user-facing messages.
class ChartDataException implements Exception {
  ChartDataException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'ChartDataException(message: $message, cause: $cause)';
}
