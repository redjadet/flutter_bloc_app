import 'package:networking/networking.dart';

/// Safe demo-facing failure (no certs, hashes, or stack traces).
sealed class CertificatePinningDemoFailure {
  const CertificatePinningDemoFailure({required this.l10nCode});

  /// Stable key for l10n mapping in presentation.
  final String l10nCode;
}

final class CertificatePinningDemoPinFailure
    extends CertificatePinningDemoFailure {
  const CertificatePinningDemoPinFailure({required super.l10nCode});

  factory CertificatePinningDemoPinFailure.fromDomain(
    final CertificatePinningFailure failure,
  ) {
    final String code = switch (failure) {
      PinMismatchFailure() => 'pinMismatch',
      MissingPinFailure() => 'missingPin',
      UnsupportedHostFailure() => 'unsupportedHost',
      CertificateExpiredFailure() => 'expired',
      CertificateValidationTimeoutFailure() => 'timeout',
      CertificateMalformedFailure() => 'malformed',
      CertificateNetworkUnavailableFailure() => 'networkUnavailable',
      CertificateValidationFailure() => 'validation',
    };
    return CertificatePinningDemoPinFailure(l10nCode: code);
  }
}

final class CertificatePinningDemoUnknownFailure
    extends CertificatePinningDemoFailure {
  const CertificatePinningDemoUnknownFailure() : super(l10nCode: 'unknown');
}
