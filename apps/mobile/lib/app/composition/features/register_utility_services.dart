import 'package:flutter_bloc_app/app/composition/injector_helpers.dart';
import 'package:flutter_bloc_app/app/platform/biometric_authenticator.dart';
import 'package:flutter_bloc_app/app/services/error_notification_service.dart';

/// Registers biometric authenticator and error notification service.
void registerUtilityServices() {
  registerLazySingletonIfAbsent<BiometricAuthenticator>(
    LocalBiometricAuthenticator.new,
  );
  registerLazySingletonIfAbsent<ErrorNotificationService>(
    SnackbarErrorNotificationService.new,
  );
}
