/// Domain failures for secure messaging demo. Mapped from native bridge only.
sealed class SecureCoreFailure implements Exception {
  const new();
}

final class SecureCoreInvalidInputFailure extends SecureCoreFailure {
  const new();
}

final class SecureCoreMalformedCiphertextFailure extends SecureCoreFailure {
  const new();
}

final class SecureCoreAuthenticationFailedFailure extends SecureCoreFailure {
  const new();
}

final class SecureCoreUnsupportedVersionFailure extends SecureCoreFailure {
  const new();
}

final class SecureCoreUnavailableFailure extends SecureCoreFailure {
  const new();
}

final class SecureCoreInternalFailure extends SecureCoreFailure {
  const new();
}

final class SecureCoreMismatchFailure extends SecureCoreFailure {
  const new();
}

/// Factory helpers matching prior Freezed-style constructors.
abstract final class SecureCoreFailures {
  static const SecureCoreFailure invalidInput = SecureCoreInvalidInputFailure();
  static const SecureCoreFailure malformedCiphertext =
      SecureCoreMalformedCiphertextFailure();
  static const SecureCoreFailure authenticationFailed =
      SecureCoreAuthenticationFailedFailure();
  static const SecureCoreFailure unsupportedVersion =
      SecureCoreUnsupportedVersionFailure();
  static const SecureCoreFailure unavailable = SecureCoreUnavailableFailure();
  static const SecureCoreFailure internal = SecureCoreInternalFailure();
  static const SecureCoreFailure mismatch = SecureCoreMismatchFailure();
}
