import 'package:flutter_bloc_app/features/certificate_pinning_demo/domain/secure_probe_repository.dart';

final class TriggerSecureProbe {
  const TriggerSecureProbe(this._repository);

  final SecureProbeRepository _repository;

  Future<SecureProbeOutcome> call() => _repository.probe();
}
