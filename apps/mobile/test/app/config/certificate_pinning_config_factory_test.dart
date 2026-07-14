import 'package:flutter_bloc_app/app/config/certificate_pinning_config_factory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:networking/networking.dart';

void main() {
  group('parseModeForTest', () {
    test('empty defaults to disabled', () {
      expect(CertificatePinningConfigFactory.parseModeForTest(''), CertificatePinningMode.disabled);
    });

    test('accepts aliases', () {
      expect(
        CertificatePinningConfigFactory.parseModeForTest('mock_success'),
        CertificatePinningMode.mockSuccess,
      );
      expect(
        CertificatePinningConfigFactory.parseModeForTest('mockFailure'),
        CertificatePinningMode.mockFailure,
      );
      expect(CertificatePinningConfigFactory.parseModeForTest('REAL'), CertificatePinningMode.real);
    });

    test('rejects unknown mode', () {
      expect(() => CertificatePinningConfigFactory.parseModeForTest('oops'), throwsStateError);
    });
  });

  group('parseHashKindForTest', () {
    test('empty defaults to spki', () {
      expect(CertificatePinningConfigFactory.parseHashKindForTest(''), CertificatePinHashKind.spki);
    });

    test('accepts leaf aliases', () {
      expect(
        CertificatePinningConfigFactory.parseHashKindForTest('leaf_certificate'),
        CertificatePinHashKind.leafCertificate,
      );
    });

    test('rejects unknown kind', () {
      expect(() => CertificatePinningConfigFactory.parseHashKindForTest('md5'), throwsStateError);
    });
  });

  group('parseHostsForTest', () {
    test('parses comma-separated hosts and drops blanks', () {
      expect(
        CertificatePinningConfigFactory.parseHostsForTest(' api.example.com, ,cdn.example.com '),
        <String>{'api.example.com', 'cdn.example.com'},
      );
    });
  });

  group('parsePinsForTest', () {
    test('parses host pin map', () {
      expect(
        CertificatePinningConfigFactory.parsePinsForTest(
          'api.example.com=sha256/AAA=|sha256/BBB=;cdn.example.com=sha256/CCC=',
        ),
        <String, Set<String>>{
          'api.example.com': <String>{'sha256/AAA=', 'sha256/BBB='},
          'cdn.example.com': <String>{'sha256/CCC='},
        },
      );
    });

    test('rejects malformed entry', () {
      expect(() => CertificatePinningConfigFactory.parsePinsForTest('no-equals'), throwsStateError);
    });
  });
}
