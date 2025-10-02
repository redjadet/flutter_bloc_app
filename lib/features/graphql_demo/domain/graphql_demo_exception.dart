enum GraphqlDemoErrorType {
  network,
  invalidRequest,
  server,
  data,
  unknown,
}

class GraphqlDemoException implements Exception {
  GraphqlDemoException(
    this.message, {
    this.cause,
    this.type = GraphqlDemoErrorType.unknown,
  });

  final String message;
  final Object? cause;
  final GraphqlDemoErrorType type;

  @override
  String toString() =>
      'GraphqlDemoException(message: $message, type: $type, cause: $cause)';
}
