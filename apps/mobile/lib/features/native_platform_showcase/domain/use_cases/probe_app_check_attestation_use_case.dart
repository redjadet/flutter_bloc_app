import 'package:flutter_bloc_app/features/native_platform_showcase/domain/app_check_attestation_result.dart';
import 'package:flutter_bloc_app/features/native_platform_showcase/domain/firebase_app_check_attestation_service.dart';

class ProbeAppCheckAttestationUseCase {
  const ProbeAppCheckAttestationUseCase(this._service);

  final FirebaseAppCheckAttestationService _service;

  Future<AppCheckAttestationResult> call() => _service.probeCachedToken();
}
