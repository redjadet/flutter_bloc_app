import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_app/shared/platform/biometric_authenticator.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';
import 'package:local_auth/local_auth.dart';

void main() {
  group('LocalBiometricAuthenticator', () {
    test('allows flow when device is unsupported', () async {
      final _StubLocalAuthentication localAuth = _StubLocalAuthentication(
        isDeviceSupportedResult: false,
      );
      final LocalBiometricAuthenticator authenticator =
          LocalBiometricAuthenticator(localAuth: localAuth);

      await AppLogger.silenceAsync(() async {
        final bool result = await authenticator.authenticate();

        expect(result, isTrue);
      });
    });

    test('allows flow when biometrics cannot be checked', () async {
      final _StubLocalAuthentication localAuth = _StubLocalAuthentication(
        canCheckBiometricsResult: false,
      );
      final LocalBiometricAuthenticator authenticator =
          LocalBiometricAuthenticator(localAuth: localAuth);

      await AppLogger.silenceAsync(() async {
        final bool result = await authenticator.authenticate();

        expect(result, isTrue);
      });
    });

    test('returns result from local_auth when available', () async {
      final _StubLocalAuthentication localAuth = _StubLocalAuthentication(
        authenticateResult: false,
      );
      final LocalBiometricAuthenticator authenticator =
          LocalBiometricAuthenticator(localAuth: localAuth);

      await AppLogger.silenceAsync(() async {
        final bool result = await authenticator.authenticate(
          localizedReason: 'required',
        );

        expect(result, isFalse);
        expect(localAuth.authenticateCalls.single, equals('required'));
      });
    });

    test('handles thrown errors by returning false', () async {
      final _StubLocalAuthentication localAuth = _StubLocalAuthentication(
        authenticateError: Exception('boom'),
      );
      final LocalBiometricAuthenticator authenticator =
          LocalBiometricAuthenticator(localAuth: localAuth);

      await AppLogger.silenceAsync(() async {
        final bool result = await authenticator.authenticate();

        expect(result, isFalse);
      });
    });
  });
}

class _StubLocalAuthentication extends LocalAuthentication {
  _StubLocalAuthentication({
    bool? isDeviceSupportedResult,
    bool? canCheckBiometricsResult,
    this.authenticateResult = true,
    this.authenticateError,
  }) : _isDeviceSupportedResult = isDeviceSupportedResult ?? true,
       _canCheckBiometricsResult = canCheckBiometricsResult ?? true;

  final bool _isDeviceSupportedResult;
  final bool _canCheckBiometricsResult;
  final bool authenticateResult;
  final Object? authenticateError;
  final List<String> authenticateCalls = <String>[];

  @override
  Future<bool> isDeviceSupported() async => _isDeviceSupportedResult;

  @override
  Future<bool> get canCheckBiometrics async => _canCheckBiometricsResult;

  @override
  Future<bool> authenticate({
    required String localizedReason,
    Iterable<Object?> authMessages = const <Object?>[],
    bool biometricOnly = false,
    bool sensitiveTransaction = true,
    bool persistAcrossBackgrounding = false,
  }) async {
    authenticateCalls.add(localizedReason);
    if (authenticateError != null) {
      throw authenticateError!;
    }
    return authenticateResult;
  }
}
