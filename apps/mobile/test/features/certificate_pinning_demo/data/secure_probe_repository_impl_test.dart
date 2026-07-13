import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/data/secure_probe_repository_impl.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/certificate_pinning_demo_failure.dart';
import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/secure_probe_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:networking/networking.dart';

class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  void close({final bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    final RequestOptions options,
    final Stream<Uint8List>? requestStream,
    final Future<void>? cancelFuture,
  ) => _handler(options);
}

CertificatePinningConfig _realConfig({final String? probeUrl}) =>
    CertificatePinningConfig(
      mode: CertificatePinningMode.real,
      allowedHosts: const <String>{'example.com'},
      sha256PinsByHost: const <String, Set<String>>{
        'example.com': <String>{
          'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
        },
      },
      realProbeUrl: probeUrl,
    );

void main() {
  late MockCertificateScenarioController scenarios;
  late CertificatePinningLogger logger;
  late MockCertificatePinValidator mockValidator;
  late Dio dio;

  setUp(() {
    scenarios = MockCertificateScenarioController();
    logger = CertificatePinningLogger();
    mockValidator = MockCertificatePinValidator(
      scenarioController: scenarios,
      validationTimeout: const Duration(seconds: 2),
      logger: logger,
    );
    dio = Dio();
  });

  tearDown(() {
    dio.close();
  });

  test('disabled mode uses mock validator success path', () async {
    final SecureProbeRepositoryImpl repo = SecureProbeRepositoryImpl(
      config: CertificatePinningConfig.disabled(),
      mockValidator: mockValidator,
      dio: dio,
    );

    final SecureProbeOutcome outcome = await repo.probe();
    expect(outcome, isA<SecureProbeSuccess>());
  });

  test('mock failure scenario maps to pin failure', () async {
    scenarios.setScenario(MockCertificateScenario.invalidPin);
    final SecureProbeRepositoryImpl repo = SecureProbeRepositoryImpl(
      config: CertificatePinningConfig.disabled(),
      mockValidator: mockValidator,
      dio: dio,
    );

    final SecureProbeOutcome outcome = await repo.probe();
    expect(
      outcome,
      isA<SecureProbeFailure>().having(
        (final f) => f.failure.l10nCode,
        'l10nCode',
        'pinMismatch',
      ),
    );
  });

  test('real mode without probe URL returns validation failure', () async {
    final SecureProbeRepositoryImpl repo = SecureProbeRepositoryImpl(
      config: _realConfig(),
      mockValidator: mockValidator,
      dio: dio,
    );

    final SecureProbeOutcome outcome = await repo.probe();
    expect(
      outcome,
      isA<SecureProbeFailure>().having(
        (final f) => f.failure,
        'failure',
        isA<CertificatePinningDemoPinFailure>().having(
          (final p) => p.l10nCode,
          'l10nCode',
          'validation',
        ),
      ),
    );
  });

  test('real mode Dio success maps to SecureProbeSuccess', () async {
    const String url = 'https://example.com/health';
    dio.httpClientAdapter = _ScriptedAdapter(
      (final options) async => ResponseBody.fromString(
        '{}',
        200,
        headers: <String, List<String>>{
          Headers.contentTypeHeader: <String>['application/json'],
        },
      ),
    );

    final SecureProbeOutcome outcome = await SecureProbeRepositoryImpl(
      config: _realConfig(probeUrl: url),
      mockValidator: mockValidator,
      dio: dio,
    ).probe();

    expect(
      outcome,
      isA<SecureProbeSuccess>().having(
        (final s) => s.matchKind,
        'matchKind',
        CertificatePinMatchKind.primary,
      ),
    );
  });

  test('real mode badCertificate maps to pinMismatch', () async {
    const String url = 'https://example.com/pin-fail';
    dio.httpClientAdapter = _ScriptedAdapter((final options) async {
      throw DioException.badCertificate(requestOptions: options);
    });

    final SecureProbeOutcome outcome = await SecureProbeRepositoryImpl(
      config: _realConfig(probeUrl: url),
      mockValidator: mockValidator,
      dio: dio,
    ).probe();

    expect(
      outcome,
      isA<SecureProbeFailure>().having(
        (final f) => f.failure.l10nCode,
        'l10nCode',
        'pinMismatch',
      ),
    );
  });

  test('real mode other Dio errors map to unknown failure', () async {
    const String url = 'https://example.com/down';
    dio.httpClientAdapter = _ScriptedAdapter((final options) async {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    });

    final SecureProbeOutcome outcome = await SecureProbeRepositoryImpl(
      config: _realConfig(probeUrl: url),
      mockValidator: mockValidator,
      dio: dio,
    ).probe();

    expect(
      outcome,
      isA<SecureProbeFailure>().having(
        (final f) => f.failure,
        'failure',
        isA<CertificatePinningDemoUnknownFailure>(),
      ),
    );
  });
}
