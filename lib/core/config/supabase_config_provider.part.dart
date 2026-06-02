part of 'supabase_config_provider.dart';

const String kSupabaseConfigReasonFirebaseNotInitialized =
    'firebase_not_initialized';
const String kSupabaseConfigReasonFirebaseAuthUnavailable =
    'firebase_auth_unavailable';
const String kSupabaseConfigReasonFirebaseAuthNotReady =
    'firebase_auth_not_ready';
const String kSupabaseConfigReasonRemoteConfigUnavailable =
    'remote_config_unavailable';
const String kSupabaseConfigReasonRemoteConfigDisabled =
    'remote_config_disabled';
const String kSupabaseConfigReasonInvalidPayload = 'invalid_payload';
const String kSupabaseConfigReasonVersionUnchanged = 'version_unchanged';
const String kSupabaseConfigReasonRemoteConfigFetchFailed =
    'remote_config_fetch_failed';

@immutable
final class SupabaseConfigFetchResult {
  const SupabaseConfigFetchResult({
    required this.updated,
    required this.skipped,
    this.version,
    this.reason,
  });

  final bool updated;
  final bool skipped;
  final String? version;
  final String? reason;
}

extension _SupabaseConfigProviderInternals on SupabaseConfigProvider {
  FirebaseAuth? get _safeAuth {
    if (_auth != null) return _auth;
    try {
      return FirebaseAuth.instance;
    } on Object {
      return null;
    }
  }

  RemoteConfigService? get _safeRemoteConfig {
    if (_remoteConfig != null) return _remoteConfig;
    try {
      return getIt<RemoteConfigService>();
    } on Object {
      return null;
    }
  }

  SecretStorage get _safeStorage =>
      _storage ?? (SecretConfig.storage ?? createDefaultSecretStorage());

  String? _tryFirebaseProjectId() {
    try {
      final FirebaseApp app = Firebase.app();
      final String projectId = app.options.projectId;
      return projectId.trim().isEmpty ? null : projectId.trim();
    } on Object {
      return null;
    }
  }
}
