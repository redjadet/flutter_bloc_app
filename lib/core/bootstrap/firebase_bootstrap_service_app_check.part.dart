part of 'firebase_bootstrap_service.dart';

Future<void> _activateAppCheck() async {
  if (kIsWeb) {
    return;
  }

  try {
    const String debugTokenEnv = String.fromEnvironment(
      'FIREBASE_APPCHECK_DEBUG_TOKEN',
    );
    final String debugToken = _resolveAppCheckDebugToken(debugTokenEnv);

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        await FirebaseAppCheck.instance.activate(
          providerAndroid: kDebugMode
              ? AndroidDebugProvider(debugToken: debugToken)
              : const AndroidPlayIntegrityProvider(),
        );
        break;
      case TargetPlatform.iOS:
        final bool activated = await _activateAppleAppCheck(
          debugToken: debugToken,
          logSimulatorInfo: true,
        );
        if (!activated) {
          return;
        }
        break;
      case TargetPlatform.macOS:
        final bool activated = await _activateAppleAppCheck(
          debugToken: debugToken,
          logSimulatorInfo: false,
        );
        if (!activated) {
          return;
        }
        break;
      default:
        return;
    }

    AppLogger.info(
      'Firebase App Check activated (${kDebugMode ? 'debug' : 'release'} mode)',
    );
    await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
    _logAppCheckDebugToken(debugToken, debugTokenEnv);
  } on Exception catch (error, stackTrace) {
    AppLogger.warning('Firebase App Check activation failed: $error');
    AppLogger.debug('App Check activation stack trace\n$stackTrace');
  }
}

/// Marks [FirebaseBootstrapService.isIosSimulatorInDebug] in debug iOS simulators.
/// Called from App Check activation and when reusing an existing Firebase app so
/// DI still skips RTDB remotes after hot restart or duplicate-app reuse.
Future<void> _markIosSimulatorInDebugIfNeeded() async {
  if (!kDebugMode || defaultTargetPlatform != TargetPlatform.iOS) {
    return;
  }
  try {
    final IosDeviceInfo info = await DeviceInfoPlugin().iosInfo;
    if (!info.isPhysicalDevice) {
      FirebaseBootstrapService.isIosSimulatorInDebug = true;
    }
  } on Exception catch (_) {
    // Best-effort; DI fallbacks remain disabled when detection fails.
  }
}

Future<bool> _activateAppleAppCheck({
  required final String debugToken,
  required final bool logSimulatorInfo,
}) async {
  if (kDebugMode && logSimulatorInfo) {
    await _markIosSimulatorInDebugIfNeeded();
    if (FirebaseBootstrapService.isIosSimulatorInDebug) {
      AppLogger.info(
        'iOS simulator detected; skipping Firebase App Check activation in debug.',
      );
      return false;
    }
  }

  await FirebaseAppCheck.instance.activate(
    providerApple: kDebugMode
        ? AppleDebugProvider(debugToken: debugToken)
        : const AppleAppAttestWithDeviceCheckFallbackProvider(),
  );
  return true;
}

String _resolveAppCheckDebugToken(final String debugTokenEnv) {
  return debugTokenEnv.isEmpty ? 'flutter_bloc_app_debug' : debugTokenEnv;
}

void _logAppCheckDebugToken(
  final String debugToken,
  final String debugTokenEnv,
) {
  if (!kDebugMode) {
    return;
  }

  AppLogger.info('Firebase App Check debug token: $debugToken');
  if (debugTokenEnv.isEmpty) {
    AppLogger.warning(
      '${IntegrationLogMessages.appCheckDebugTokenPrefix} For a unique token, run with '
      '--dart-define=FIREBASE_APPCHECK_DEBUG_TOKEN=<token> and add it in '
      'Firebase Console → App Check → Manage debug tokens.',
    );
  }
}
