import 'package:flutter/services.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:local_auth/local_auth.dart';

/// Contract for triggering biometric authentication before sensitive actions.
mixin BiometricAuthenticator {
  /// Prompts the user for biometric authentication and returns whether the
  /// user successfully authenticated. Implementations should handle cases where
  /// biometrics are unavailable and decide whether to allow or block access.
  Future<bool> authenticate({final String? localizedReason});
}

/// Uses the `local_auth` package to request biometric authentication.
class LocalBiometricAuthenticator implements BiometricAuthenticator {
  LocalBiometricAuthenticator({final LocalAuthentication? localAuth})
    : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;

  @override
  Future<bool> authenticate({final String? localizedReason}) async {
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
        biometricOnly: true,
      );
    } on PlatformException catch (error, stackTrace) {
      // Allow navigating to settings if biometrics are not enrolled on device.
      final String code = error.code;
      final bool notEnrolled =
          code.contains('noBiometricsEnrolled') ||
          code.contains('NotEnrolled') ||
          code.contains('notEnrolled');
      if (notEnrolled) {
        AppLogger.info('Biometry not enrolled; allowing access to settings.');
        return true;
      }
      AppLogger.warning('Biometric authentication failed');
      AppLogger.debug(stackTrace.toString());
      return false;
    } on Exception catch (error, stackTrace) {
      // Some platforms throw a non-PlatformException (e.g., LocalAuthException)
      // Parse the string form to detect enrollment-related failures.
      final String text = error.toString();
      final bool notEnrolled =
          text.contains('noBiometricsEnrolled') ||
          text.contains('NotEnrolled') ||
          text.contains('notEnrolled') ||
          text.contains('passcodeNotSet');
      if (notEnrolled) {
        AppLogger.info('Biometry not enrolled (Exception); allowing.');
        return true;
      }
      AppLogger.warning('Biometric authentication failed');
      AppLogger.debug(stackTrace.toString());
      return false;
    }
  }
}
