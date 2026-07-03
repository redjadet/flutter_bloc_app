/// Structured output validation failure.
class StructuredOutputValidationError implements Exception {
  StructuredOutputValidationError(this.message, {this.field});

  final String message;
  final String? field;

  @override
  String toString() => 'StructuredOutputValidationError: $message';
}
