import 'mock_certificate_scenario.dart';

/// Holds the active mock pinning scenario for demos and tests.
final class MockCertificateScenarioController {
  MockCertificateScenarioController({
    final MockCertificateScenario initial =
        MockCertificateScenario.validPrimaryPin,
  }) : _scenario = initial;

  MockCertificateScenario _scenario;

  MockCertificateScenario get scenario => _scenario;

  void setScenario(final MockCertificateScenario scenario) {
    _scenario = scenario;
  }

  void reset() {
    _scenario = MockCertificateScenario.validPrimaryPin;
  }
}
