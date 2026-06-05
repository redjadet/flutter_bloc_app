/// Stable log message tokens shared by app code and integration harness filters.
abstract final class IntegrationLogMessages {
  static String offlineFirstRemoteConfigFetchFailed(final String reason) =>
      'OfflineFirstRemoteConfigRepository.$reason failed';

  static const String offlineFirstTodoSaveSyncFailed =
      'OfflineFirstTodoRepository.save immediate sync failed, queuing for retry';

  static const String offlineFirstTodoDeleteSyncFailed =
      'OfflineFirstTodoRepository.delete immediate sync failed, queuing for retry';

  static const String realtimeDatabaseTodoWatchAllLogContext =
      'RealtimeDatabaseTodoRepository.watchAll';

  static const String realtimeDatabaseTodoWatchAllFailed =
      '$realtimeDatabaseTodoWatchAllLogContext failed';

  static const String realtimeDatabaseCounterWatchLogContext =
      'RealtimeDatabaseCounterRepository.watch';

  static const String realtimeDatabaseCounterWatchFailed =
      '$realtimeDatabaseCounterWatchLogContext failed';

  static const String staffDemoPushApnsNotAvailable =
      'FirestoreStaffDemoPushTokenRepository.registerTokens APNs token not available yet';

  static const String staffDemoPushRegisterFailed =
      'FirestoreStaffDemoPushTokenRepository.registerTokens failed';

  static const String appCheckDebugTokenPrefix =
      'Using default App Check debug token.';

  static const String staffDemoSendShiftAssignment =
      'StaffDemoMessagesCubit.sendShiftAssignment';

  static const String staffDemoProofSubmit = 'StaffDemoProofCubit.submit';

  static const String hiveKeyManagerGetEncryptionKey =
      'HiveKeyManager.getEncryptionKey';

  static const String hiveEncryptionKeyFallback =
      'Failed to retrieve encryption key from secure storage, using temporary key (data will not persist across restarts).';

  static const String secureStorageUnavailablePrefix =
      'Secure storage unavailable; using non-persisted Hive encryption key';

  static const String remoteConfigForceFetch = 'RemoteConfig.forceFetch';

  static const String remoteConfigRealtimeFetch = 'RemoteConfig realtime fetch';

  static const String remoteConfigForceFetchDisabledPrefix =
      'RemoteConfig.forceFetch disabled (Keychain unavailable)';

  static const String remoteConfigRealtimeFetchDisabledPrefix =
      'RemoteConfig realtime fetch disabled (Keychain unavailable)';
}
