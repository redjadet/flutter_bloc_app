class GraphqlDemoException implements Exception {
  GraphqlDemoException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'GraphqlDemoException(message: $message, cause: $cause)';
}
