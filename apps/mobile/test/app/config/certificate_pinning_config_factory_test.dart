import 'package:flutter_bloc_app/app/config/certificate_pinning_config_factory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:networking/networking.dart';

void main() {
  group('CertificatePinningConfigFactory', () {
    test('parseModeForTest defaults empty to disabled', () {
      expect(
        CertificatePinningConfigFactory.parseModeForTest(''),
        CertificatePinningMode.disabled,
      );
    });

    test('parseModeForTest accepts known modes', () {
      expect(
        CertificatePinningConfigFactory.parseModeForTest('real'),
        CertificatePinningMode.real,
      );
      expect(
        CertificatePinningConfigFactory.parseModeForTest('mockSuccess'),
        CertificatePinningMode.mockSuccess,
      );
    });

    test('parseModeForTest rejects unknown', () {
      expect(
        () => CertificatePinningConfigFactory.parseModeForTest('nope'),
        throwsStateError,
      );
    });

    test('parseHashKindForTest defaults empty to spki', () {
      expect(
        CertificatePinningConfigFactory.parseHashKindForTest(''),
        CertificatePinHashKind.spki,
      );
    });

    test('parseHashKindForTest accepts spki and leaf aliases', () {
      expect(
        CertificatePinningConfigFactory.parseHashKindForTest('spki'),
        CertificatePinHashKind.spki,
      );
      expect(
        CertificatePinningConfigFactory.parseHashKindForTest('leaf'),
        CertificatePinHashKind.leafCertificate,
      );
      expect(
        CertificatePinningConfigFactory.parseHashKindForTest(
          'leaf_certificate',
        ),
        CertificatePinHashKind.leafCertificate,
      );
    });

    test('parseHashKindForTest rejects unknown', () {
      expect(
        () => CertificatePinningConfigFactory.parseHashKindForTest('md5'),
        throwsStateError,
      );
    });
  });
}
