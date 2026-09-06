import 'package:networking/networking.dart';

final class ResetMockScenario {
  const new(this._controller);

  final MockCertificateScenarioController _controller;

  void call() => _controller.reset();
}
