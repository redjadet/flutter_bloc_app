import 'dart:typed_data';

import 'certificate_pin_result.dart';
import 'certificate_pin_validator.dart';
import 'certificate_pinning_failure.dart';
import 'certificate_pinning_logger.dart';
import 'certificate_pinning_mode.dart';
import 'mock_certificate_scenario.dart';
import 'mock_certificate_scenario_controller.dart';

/// Deterministic mock pin validator (no real TLS material required).
final class MockCertificatePinValidator implements CertificatePinValidator {
  MockCertificatePinValidator({
    required this._scenarioController,
    required this._validationTimeout,
    this._logger,
    this._mode = CertificatePinningMode.mockSuccess,
    final Future<void> Function(Duration delay)? delay,
  }) : _delay = delay ?? Future<void>.delayed;

  final MockCertificateScenarioController _scenarioController;
  final Duration _validationTimeout;
  final CertificatePinningLogger? _logger;
  final CertificatePinningMode _mode;
  final Future<void> Function(Duration delay) _delay;

  @override
  Future<CertificatePinResult> validate({
    required final String host,
    required final int port,
    required final Uint8List certificateBytes,
  }) async {
    final Stopwatch sw = Stopwatch()..start();
    final MockCertificateScenario scenario = _scenarioController.scenario;

    try {
      final CertificatePinResult result = await _resultForScenario(
        scenario: scenario,
        host: host,
        certificateBytes: certificateBytes,
      );
      sw.stop();
      _logger?.logValidation(
        host: host,
        mode: _mode,
        result: result,
        elapsed: sw.elapsed,
      );
      return result;
    } on CertificatePinningFailure catch (failure) {
      sw.stop();
      final CertificatePinResult result = CertificatePinFailureResult(failure);
      _logger?.logValidation(
        host: host,
        mode: _mode,
        result: result,
        elapsed: sw.elapsed,
      );
      return result;
    }
  }

  Future<CertificatePinResult> _resultForScenario({
    required final MockCertificateScenario scenario,
    required final String host,
    required final Uint8List certificateBytes,
  }) async {
    switch (scenario) {
      case MockCertificateScenario.validPrimaryPin:
        return const CertificatePinSuccess(
          matchKind: CertificatePinMatchKind.primary,
        );
      case MockCertificateScenario.validBackupPin:
        return const CertificatePinSuccess(
          matchKind: CertificatePinMatchKind.backup,
        );
      case MockCertificateScenario.invalidPin:
      case MockCertificateScenario.allPinsRejected:
        return const CertificatePinFailureResult(PinMismatchFailure());
      case MockCertificateScenario.missingPin:
        return const CertificatePinFailureResult(MissingPinFailure());
      case MockCertificateScenario.unsupportedHost:
        return const CertificatePinFailureResult(UnsupportedHostFailure());
      case MockCertificateScenario.expiredCertificate:
        return const CertificatePinFailureResult(CertificateExpiredFailure());
      case MockCertificateScenario.malformedCertificate:
        if (certificateBytes.isEmpty) {
          return const CertificatePinFailureResult(
            CertificateMalformedFailure(),
          );
        }
        return const CertificatePinFailureResult(CertificateMalformedFailure());
      case MockCertificateScenario.networkUnavailable:
        return const CertificatePinFailureResult(
          CertificateNetworkUnavailableFailure(),
        );
      case MockCertificateScenario.timeout:
        await _delay(_validationTimeout + const Duration(milliseconds: 50));
        return const CertificatePinFailureResult(
          CertificateValidationTimeoutFailure(),
        );
    }
  }
}
