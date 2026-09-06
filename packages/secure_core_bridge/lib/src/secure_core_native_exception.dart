/// Native-bridge failure. Mapped to domain failures in the app data layer.
enum SecureCoreNativeFailureKind {
  invalidInput,
  malformedCiphertext,
  authenticationFailed,
  unsupportedVersion,
  unavailable,
  internal,
}

final class SecureCoreNativeException implements Exception {
  const SecureCoreNativeException(this.kind, {this.statusCode});

  final SecureCoreNativeFailureKind kind;
  final int? statusCode;

  @override
  String toString() => 'SecureCoreNativeException($kind, status=$statusCode)';
}
