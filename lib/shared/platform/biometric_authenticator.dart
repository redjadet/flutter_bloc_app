import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:local_auth/local_auth.dart';

/// Contract for triggering biometric authentication before sensitive actions.
abstract class BiometricAuthenticator {
  /// Prompts the user for biometric authentication and returns whether the
  /// user successfully authenticated. Implementations should handle cases where
  /// biometrics are unavailable and decide whether to allow or block access.
  Future<bool> authenticate({String? localizedReason});
}

/// Uses the `local_auth` package to request biometric authentication.
class LocalBiometricAuthenticator implements BiometricAuthenticator {
  LocalBiometricAuthenticator({LocalAuthentication? localAuth})
    : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;

  @override
  Future<bool> authenticate({String? localizedReason}) async {
    try {
      final bool isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) {
        AppLogger.info('Biometric auth unsupported on this device.');
        return true;
      }

      final bool canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) {
        AppLogger.info('Biometric sensors unavailable.');
        return true;
      }

      return await _localAuth.authenticate(
        localizedReason: localizedReason ?? 'Authenticate to continue',
        options: const AuthenticationOptions(biometricOnly: true),
      );
    } catch (error, stackTrace) {
      AppLogger.warning('Biometric authentication failed: $error');
      AppLogger.debug(stackTrace.toString());
      return false;
    }
  }
}
