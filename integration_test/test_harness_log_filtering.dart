import 'package:flutter_bloc_app/shared/utils/logger.dart';

bool isUnexpectedIntegrationLog(
  final AppLogEntry entry, {
  required final bool isWeb,
}) {
  final bool isWarnOrError =
      entry.level == AppLogLevel.warning || entry.level == AppLogLevel.error;
  if (!isWarnOrError) {
    return false;
  }
  return !isIgnoredIntegrationLog(entry, isWeb: isWeb);
}

bool isIgnoredIntegrationLog(
  final AppLogEntry entry, {
  required final bool isWeb,
}) {
  // iOS integration runs occasionally surface transient Remote Config
  // cancellation from the plugin while the app is tearing down / relaunching
  // between flows. Treat this specific case as noise so it doesn't fail the
  // whole suite.
  if (entry.message == 'OfflineFirstRemoteConfigRepository.forceFetch failed') {
    final Object? error = entry.error;
    if (error != null &&
        error.toString().contains(
          '[firebase_remote_config/unknown] cancelled',
        )) {
      return true;
    }
  }

  // Some integration flows intentionally run without a Firebase user session.
  // When a feature tries to sync immediately, the repo logs an error and
  // queues the operation for retry. This is expected and shouldn't fail the
  // entire integration suite.
  if (entry.message ==
      'OfflineFirstTodoRepository.save immediate sync failed, queuing for retry') {
    final Object? error = entry.error;
    if (error != null &&
        error.toString().contains('[firebase_auth/no-current-user]') &&
        error.toString().contains('did not supply a user within')) {
      return true;
    }
  }

  if (entry.message ==
      'OfflineFirstTodoRepository.delete immediate sync failed, queuing for retry') {
    final Object? error = entry.error;
    if (error != null &&
        error.toString().contains('[firebase_auth/no-current-user]') &&
        error.toString().contains('did not supply a user within')) {
      return true;
    }
  }

  // Some flows may bootstrap realtime subscriptions before a Firebase user is
  // available (or when running intentionally unauthenticated). Treat this as
  // expected noise for integration runs.
  if (entry.message == 'RealtimeDatabaseTodoRepository.watchAll failed') {
    final Object? error = entry.error;
    if (error != null &&
        error.toString().contains('[firebase_auth/no-current-user]') &&
        error.toString().contains('did not supply a user within')) {
      return true;
    }
  }

  if (entry.message == 'RealtimeDatabaseCounterRepository.watch failed') {
    final Object? error = entry.error;
    if (error != null &&
        error.toString().contains('[firebase_auth/no-current-user]') &&
        error.toString().contains('did not supply a user within')) {
      return true;
    }
  }

  // Staff demo push token registration can log an APNs token warning on iOS
  // simulators (or before APNs registration completes). This should not fail
  // the integration suite.
  if (entry.message ==
      'FirestoreStaffDemoPushTokenRepository.registerTokens APNs token not available yet') {
    return true;
  }
  if (entry.message ==
      'FirestoreStaffDemoPushTokenRepository.registerTokens failed') {
    final Object? error = entry.error;
    if (error != null &&
        error.toString().contains('[firebase_messaging/apns-token-not-set]')) {
      return true;
    }
  }

  // App Check debug token guidance is expected on simulators during dev runs.
  if (entry.message.startsWith('Using default App Check debug token.')) {
    return true;
  }

  // Staff demo messaging can be denied in dev projects (tight rules / missing
  // seed state). The walkthrough still provides value without this write.
  if (entry.message == 'StaffDemoMessagesCubit.sendShiftAssignment') {
    final Object? error = entry.error;
    if (error != null &&
        error.toString().contains('[cloud_firestore/permission-denied]')) {
      return true;
    }
  }

  // Firebase Storage quota can be exceeded in shared dev projects. Some flows
  // degrade gracefully in that case; don't fail the entire suite on this
  // external quota constraint.
  if (entry.message == 'StaffDemoProofCubit.submit') {
    final Object? error = entry.error;
    if (error != null &&
        error.toString().contains('[firebase_storage/quota-exceeded]')) {
      return true;
    }
  }

  // Web tests cannot use the secure-storage-backed Hive key path. The app
  // falls back to an in-memory key for the session, which is expected for
  // browser integration runs and should not fail the suite.
  if (isWeb && entry.message == 'HiveKeyManager.getEncryptionKey') {
    final Object? error = entry.error;
    if (error != null && error.toString().contains('OperationError')) {
      return true;
    }
  }
  if (isWeb &&
      entry.message ==
          'Failed to retrieve encryption key from secure storage, using temporary key (data will not persist across restarts).') {
    return true;
  }

  // iOS simulators may not expose Keychain-backed secure storage for Hive keys.
  if (entry.message.startsWith(
    'Secure storage unavailable; using non-persisted Hive encryption key',
  )) {
    return true;
  }

  return false;
}

String formatIntegrationLogEntry(final AppLogEntry entry) {
  final StringBuffer buffer = StringBuffer()
    ..write(entry.level.name)
    ..write(': ')
    ..write(entry.message);
  if (entry.error != null) {
    buffer
      ..write(' | error=')
      ..write(entry.error);
  }
  return buffer.toString();
}
