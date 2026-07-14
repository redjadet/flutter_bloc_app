import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:networking/networking.dart';

Uint8List _loadFixture() {
  // flutter test cwd may be package root or monorepo root.
  final List<String> candidates = <String>[
    'test/certificate_pinning/fixtures/pin_test_cert.der',
    'packages/networking/test/certificate_pinning/fixtures/pin_test_cert.der',
  ];
  for (final String path in candidates) {
    final File file = File(path);
    if (file.existsSync()) {
      return Uint8List.fromList(file.readAsBytesSync());
    }
  }
  fail('missing SPKI test fixture; cwd=${Directory.current.path}');
}

void main() {
  const String expectedSpkiPin =
      'sha256/3WbCnESgETyXhgHli8dpDKl0ag/VucLI5+q47FtiBr0=';
  const String expectedLeafPin =
      'sha256/Ym6BE+j1dGdMyzVYXqVn9XBUo5/wCgjU5XUrzmUw3Os=';

  group('CertificateSpkiExtractor', () {
    test('extracts SPKI matching openssl pkey pin', () {
      final Uint8List cert = _loadFixture();
      final Uint8List? spki = CertificateSpkiExtractor.extract(cert);
      expect(spki, isNotNull);
      final String pin = CertificatePinFormatter.fromSha256Bytes(
        sha256.convert(spki!).bytes,
      );
      expect(pin, expectedSpkiPin);
    });

    test('returns null for garbage DER', () {
      expect(
        CertificateSpkiExtractor.extract(Uint8List.fromList(<int>[1, 2, 3])),
        isNull,
      );
    });
  });

  group('CertificatePinFormatter', () {
    test('accepts canonical sha256/base64 of 32 bytes', () {
      final String pin = CertificatePinFormatter.fromSha256Bytes(
        List<int>.filled(32, 1),
      );
      expect(CertificatePinFormatter.isValidFormat(pin), isTrue);
    });

    test('rejects malformed pins', () {
      expect(CertificatePinFormatter.isValidFormat('sha256/'), isFalse);
      expect(CertificatePinFormatter.isValidFormat('md5/abc'), isFalse);
      expect(
        CertificatePinFormatter.isValidFormat('sha256/not-base64!!!'),
        isFalse,
      );
    });
  });

  group('CertificatePinningConfig.validate', () {
    test('disabled allows empty hosts', () {
      expect(
        () => CertificatePinningConfig.disabled().validate(isProdRelease: true),
        returnsNormally,
      );
    });

    test('prod release rejects mock modes', () {
      expect(
        () => CertificatePinningConfig(
          mode: CertificatePinningMode.mockSuccess,
        ).validate(isProdRelease: true),
        throwsStateError,
      );
    });

    test('real requires hosts and pins', () {
      expect(
        () => CertificatePinningConfig(
          mode: CertificatePinningMode.real,
        ).validate(isProdRelease: false),
        throwsStateError,
      );

      final String pin = CertificatePinFormatter.fromSha256Bytes(
        List<int>.filled(32, 2),
      );
      expect(
        () => CertificatePinningConfig(
          mode: CertificatePinningMode.real,
          allowedHosts: <String>{'api.example.com'},
          sha256PinsByHost: <String, Set<String>>{
            'api.example.com': <String>{pin},
          },
        ).validate(isProdRelease: false),
        returnsNormally,
      );
    });

    test('defaults pinHashKind to spki', () {
      expect(
        CertificatePinningConfig(
          mode: CertificatePinningMode.disabled,
        ).pinHashKind,
        CertificatePinHashKind.spki,
      );
    });

    test('normalizes host case for allowedHosts and pins', () {
      final String pin = CertificatePinFormatter.fromSha256Bytes(
        List<int>.filled(32, 2),
      );
      final CertificatePinningConfig config = CertificatePinningConfig(
        mode: CertificatePinningMode.real,
        allowedHosts: <String>{'API.Example.COM'},
        sha256PinsByHost: <String, Set<String>>{
          'api.example.com': <String>{pin},
        },
      );
      expect(config.allowedHosts, <String>{'api.example.com'});
      expect(config.sha256PinsByHost.containsKey('api.example.com'), isTrue);
      expect(() => config.validate(isProdRelease: false), returnsNormally);
    });

    test('real mode rejects web', () {
      final String pin = CertificatePinFormatter.fromSha256Bytes(
        List<int>.filled(32, 3),
      );
      expect(
        () => CertificatePinningConfig(
          mode: CertificatePinningMode.real,
          allowedHosts: <String>{'api.example.com'},
          sha256PinsByHost: <String, Set<String>>{
            'api.example.com': <String>{pin},
          },
        ).validate(isProdRelease: false, isWeb: true),
        throwsStateError,
      );
    });
  });

  group('RealCertificatePinValidator SPKI', () {
    late Uint8List certBytes;
    late RealCertificatePinValidator validator;

    setUp(() {
      certBytes = _loadFixture();
      validator = RealCertificatePinValidator(
        config: CertificatePinningConfig(
          mode: CertificatePinningMode.real,
          pinHashKind: CertificatePinHashKind.spki,
          allowedHosts: <String>{'api.example.com'},
          sha256PinsByHost: <String, Set<String>>{
            'api.example.com': <String>{
              expectedSpkiPin,
              'sha256/${base64Encode(List<int>.filled(32, 9))}',
            },
          },
        ),
      );
    });

    test('matches primary SPKI pin', () async {
      final CertificatePinResult result = await validator.validate(
        host: 'api.example.com',
        port: 443,
        certificateBytes: certBytes,
      );
      expect(
        result,
        isA<CertificatePinSuccess>().having(
          (final s) => s.matchKind,
          'matchKind',
          CertificatePinMatchKind.primary,
        ),
      );
    });

    test('matches mixed-case host', () async {
      final CertificatePinResult result = await validator.validate(
        host: 'API.Example.COM',
        port: 443,
        certificateBytes: certBytes,
      );
      expect(result, isA<CertificatePinSuccess>());
    });

    test('matches backup SPKI pin', () async {
      final RealCertificatePinValidator backupValidator =
          RealCertificatePinValidator(
            config: CertificatePinningConfig(
              mode: CertificatePinningMode.real,
              allowedHosts: <String>{'api.example.com'},
              sha256PinsByHost: <String, Set<String>>{
                'api.example.com': <String>{
                  'sha256/${base64Encode(List<int>.filled(32, 9))}',
                  expectedSpkiPin,
                },
              },
            ),
          );
      final CertificatePinResult result = await backupValidator.validate(
        host: 'api.example.com',
        port: 443,
        certificateBytes: certBytes,
      );
      expect(
        result,
        isA<CertificatePinSuccess>().having(
          (final s) => s.matchKind,
          'matchKind',
          CertificatePinMatchKind.backup,
        ),
      );
    });

    test('rejects leaf pin when mode is SPKI', () async {
      final RealCertificatePinValidator leafOnly = RealCertificatePinValidator(
        config: CertificatePinningConfig(
          mode: CertificatePinningMode.real,
          pinHashKind: CertificatePinHashKind.spki,
          allowedHosts: <String>{'api.example.com'},
          sha256PinsByHost: <String, Set<String>>{
            'api.example.com': <String>{expectedLeafPin},
          },
        ),
      );
      final CertificatePinResult result = await leafOnly.validate(
        host: 'api.example.com',
        port: 443,
        certificateBytes: certBytes,
      );
      expect(
        result,
        isA<CertificatePinFailureResult>().having(
          (final r) => r.failure,
          'failure',
          isA<PinMismatchFailure>(),
        ),
      );
    });

    test('leafCertificate kind accepts leaf pin', () async {
      final RealCertificatePinValidator leafValidator =
          RealCertificatePinValidator(
            config: CertificatePinningConfig(
              mode: CertificatePinningMode.real,
              pinHashKind: CertificatePinHashKind.leafCertificate,
              allowedHosts: <String>{'api.example.com'},
              sha256PinsByHost: <String, Set<String>>{
                'api.example.com': <String>{expectedLeafPin},
              },
            ),
          );
      final CertificatePinResult result = await leafValidator.validate(
        host: 'api.example.com',
        port: 443,
        certificateBytes: certBytes,
      );
      expect(result, isA<CertificatePinSuccess>());
    });

    test('rejects unsupported host', () async {
      final CertificatePinResult result = await validator.validate(
        host: 'evil.example.com',
        port: 443,
        certificateBytes: certBytes,
      );
      expect(
        result,
        isA<CertificatePinFailureResult>().having(
          (final r) => r.failure,
          'failure',
          isA<UnsupportedHostFailure>(),
        ),
      );
    });

    test('rejects empty certificate bytes', () {
      final CertificatePinResult result = validator.validateSync(
        host: 'api.example.com',
        port: 443,
        certificateBytes: Uint8List(0),
      );
      expect(
        result,
        isA<CertificatePinFailureResult>().having(
          (final r) => r.failure,
          'failure',
          isA<CertificateMalformedFailure>(),
        ),
      );
    });

    test('rejects malformed certificate for SPKI', () {
      final CertificatePinResult result = validator.validateSync(
        host: 'api.example.com',
        port: 443,
        certificateBytes: Uint8List.fromList(utf8.encode('not-a-cert')),
      );
      expect(
        result,
        isA<CertificatePinFailureResult>().having(
          (final r) => r.failure,
          'failure',
          isA<CertificateMalformedFailure>(),
        ),
      );
    });
  });

  group('MockCertificatePinValidator', () {
    late MockCertificateScenarioController controller;
    late List<Duration> delays;
    late MockCertificatePinValidator validator;

    setUp(() {
      controller = MockCertificateScenarioController();
      delays = <Duration>[];
      validator = MockCertificatePinValidator(
        scenarioController: controller,
        validationTimeout: const Duration(milliseconds: 10),
        delay: (final Duration d) async {
          delays.add(d);
        },
      );
    });

    test('deterministic scenarios', () async {
      final Map<MockCertificateScenario, Type> expected =
          <MockCertificateScenario, Type>{
            MockCertificateScenario.validPrimaryPin: CertificatePinSuccess,
            MockCertificateScenario.validBackupPin: CertificatePinSuccess,
            MockCertificateScenario.invalidPin: PinMismatchFailure,
            MockCertificateScenario.missingPin: MissingPinFailure,
            MockCertificateScenario.unsupportedHost: UnsupportedHostFailure,
            MockCertificateScenario.expiredCertificate:
                CertificateExpiredFailure,
            MockCertificateScenario.malformedCertificate:
                CertificateMalformedFailure,
            MockCertificateScenario.networkUnavailable:
                CertificateNetworkUnavailableFailure,
            MockCertificateScenario.allPinsRejected: PinMismatchFailure,
          };

      for (final MapEntry<MockCertificateScenario, Type> entry
          in expected.entries) {
        controller.setScenario(entry.key);
        final CertificatePinResult result = await validator.validate(
          host: 'demo.example.com',
          port: 443,
          certificateBytes: Uint8List.fromList(<int>[1]),
        );
        if (entry.value == CertificatePinSuccess) {
          expect(result, isA<CertificatePinSuccess>(), reason: '${entry.key}');
        } else {
          expect(
            result,
            isA<CertificatePinFailureResult>().having(
              (final r) => r.failure.runtimeType,
              'failureType',
              entry.value,
            ),
            reason: '${entry.key}',
          );
        }
      }
    });

    test('timeout scenario uses delay and returns timeout failure', () async {
      controller.setScenario(MockCertificateScenario.timeout);
      final CertificatePinResult result = await validator.validate(
        host: 'demo.example.com',
        port: 443,
        certificateBytes: Uint8List.fromList(<int>[1]),
      );
      expect(delays, isNotEmpty);
      expect(
        result,
        isA<CertificatePinFailureResult>().having(
          (final r) => r.failure,
          'failure',
          isA<CertificateValidationTimeoutFailure>(),
        ),
      );
    });

    test('reset returns to validPrimaryPin', () {
      controller.setScenario(MockCertificateScenario.invalidPin);
      controller.reset();
      expect(controller.scenario, MockCertificateScenario.validPrimaryPin);
    });
  });

  group('DisabledCertificatePinValidator', () {
    test('always succeeds', () async {
      const DisabledCertificatePinValidator validator =
          DisabledCertificatePinValidator();
      final CertificatePinResult result = await validator.validate(
        host: 'any',
        port: 443,
        certificateBytes: Uint8List(0),
      );
      expect(result, isA<CertificatePinSuccess>());
    });
  });
}
