/// Canonical Remote Config parameter keys shared across domain, data, and core.
abstract final class RemoteConfigKeys {
  static const String awesomeFeatureEnabled = 'awesome_feature_enabled';
  static const String testValue1 = 'test_value_1';

  static const String supabaseUrl = 'SUPABASE_URL';
  static const String supabaseAnonKey = 'SUPABASE_ANON_KEY';
  static const String supabaseConfigVersion = 'SUPABASE_CONFIG_VERSION';
  static const String supabaseConfigEnabled = 'SUPABASE_CONFIG_ENABLED';

  /// Demo-scoped HF read token for Render `X-HF-Authorization`.
  static const String renderChatDemoHfReadToken =
      'RENDER_CHAT_DEMO_HF_READ_TOKEN';

  /// Offline-first cache metadata (Hive snapshot, not Firebase console keys).
  static const String lastSyncedAt = 'last_synced_at';
  static const String lastDataSource = 'last_data_source';
}
