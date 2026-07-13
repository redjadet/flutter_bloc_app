/// Domain failures for certificate pin validation.
sealed class CertificatePinningFailure {
  const CertificatePinningFailure({this.cause});

  final Object? cause;
}

final class PinMismatchFailure extends CertificatePinningFailure {
  const PinMismatchFailure({super.cause});
}

final class MissingPinFailure extends CertificatePinningFailure {
  const MissingPinFailure({super.cause});
}

final class UnsupportedHostFailure extends CertificatePinningFailure {
  const UnsupportedHostFailure({super.cause});
}

final class CertificateExpiredFailure extends CertificatePinningFailure {
  const CertificateExpiredFailure({super.cause});
}

final class CertificateValidationTimeoutFailure
    extends CertificatePinningFailure {
  const CertificateValidationTimeoutFailure({super.cause});
}

final class CertificateMalformedFailure extends CertificatePinningFailure {
  const CertificateMalformedFailure({super.cause});
}

final class CertificateNetworkUnavailableFailure
    extends CertificatePinningFailure {
  const CertificateNetworkUnavailableFailure({super.cause});
}

final class CertificateValidationFailure extends CertificatePinningFailure {
  const CertificateValidationFailure({super.cause});
}
