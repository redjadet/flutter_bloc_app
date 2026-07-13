import 'package:networking/networking.dart';

final class SelectMockScenario {
  const SelectMockScenario(this._controller);

  final MockCertificateScenarioController _controller;

  void call(final MockCertificateScenario scenario) {
    _controller.setScenario(scenario);
  }
}
