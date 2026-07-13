import 'package:networking/networking.dart';

final class ResetMockScenario {
  const ResetMockScenario(this._controller);

  final MockCertificateScenarioController _controller;

  void call() => _controller.reset();
}
