import 'package:networking/networking.dart';

final class SelectMockScenario {
  const new(this._controller);

  final MockCertificateScenarioController _controller;

  void call(MockCertificateScenario scenario) {
    _controller.setScenario(scenario);
  }
}
