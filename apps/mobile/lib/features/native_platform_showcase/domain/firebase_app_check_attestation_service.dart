import 'package:flutter_bloc_app/features/native_platform_showcase/domain/app_check_attestation_result.dart';

/// Port for probing whether a cached Firebase App Check token is obtainable.
abstract class FirebaseAppCheckAttestationService {
  Future<AppCheckAttestationResult> probeCachedToken();
}
