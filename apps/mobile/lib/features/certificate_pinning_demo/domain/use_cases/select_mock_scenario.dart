import 'package:networking/networking.dart';

final class SelectMockScenario {
  const SelectMockScenario(this._controller);

  final MockCertificateScenarioController _controller;

  void call(MockCertificateScenario scenario) {
    _controller.setScenario(scenario);
  }
}
