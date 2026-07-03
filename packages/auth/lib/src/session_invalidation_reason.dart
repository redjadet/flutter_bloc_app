/// Why a session was invalidated (emitted on the app session lifecycle coordinator).
enum SessionInvalidationReason {
  /// Firebase `getIdToken(true)` failed with an auth-classified error.
  accessTokenRefreshFailed,

  /// Backend returned 401 after one forced refresh and replay.
  remoteRejected,

  /// Reserved for future telemetry; not emitted on normal explicit sign-out.
  explicitSignOut,

  /// Supabase `refreshSession` failed with an auth-classified error.
  supabaseSessionInvalid,
}
