/// Domain failures for secure messaging demo. Mapped from native bridge only.
sealed class SecureCoreFailure implements Exception {
  const SecureCoreFailure();
}

final class SecureCoreInvalidInputFailure extends SecureCoreFailure {
  const SecureCoreInvalidInputFailure();
}

final class SecureCoreMalformedCiphertextFailure extends SecureCoreFailure {
  const SecureCoreMalformedCiphertextFailure();
}

final class SecureCoreAuthenticationFailedFailure extends SecureCoreFailure {
  const SecureCoreAuthenticationFailedFailure();
}

final class SecureCoreUnsupportedVersionFailure extends SecureCoreFailure {
  const SecureCoreUnsupportedVersionFailure();
}

final class SecureCoreUnavailableFailure extends SecureCoreFailure {
  const SecureCoreUnavailableFailure();
}

final class SecureCoreInternalFailure extends SecureCoreFailure {
  const SecureCoreInternalFailure();
}

final class SecureCoreMismatchFailure extends SecureCoreFailure {
  const SecureCoreMismatchFailure();
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
