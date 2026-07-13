import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/certificate_pinning_demo_failure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:networking/networking.dart';

void main() {
  test('fromDomain maps every CertificatePinningFailure variant', () {
    expect(
      CertificatePinningDemoPinFailure.fromDomain(
        const PinMismatchFailure(),
      ).l10nCode,
      'pinMismatch',
    );
    expect(
      CertificatePinningDemoPinFailure.fromDomain(
        const MissingPinFailure(),
      ).l10nCode,
      'missingPin',
    );
    expect(
      CertificatePinningDemoPinFailure.fromDomain(
        const UnsupportedHostFailure(),
      ).l10nCode,
      'unsupportedHost',
    );
    expect(
      CertificatePinningDemoPinFailure.fromDomain(
        const CertificateExpiredFailure(),
      ).l10nCode,
      'expired',
    );
    expect(
      CertificatePinningDemoPinFailure.fromDomain(
        const CertificateValidationTimeoutFailure(),
      ).l10nCode,
      'timeout',
    );
    expect(
      CertificatePinningDemoPinFailure.fromDomain(
        const CertificateMalformedFailure(),
      ).l10nCode,
      'malformed',
    );
    expect(
      CertificatePinningDemoPinFailure.fromDomain(
        const CertificateNetworkUnavailableFailure(),
      ).l10nCode,
      'networkUnavailable',
    );
    expect(
      CertificatePinningDemoPinFailure.fromDomain(
        const CertificateValidationFailure(),
      ).l10nCode,
      'validation',
    );
  });
}
