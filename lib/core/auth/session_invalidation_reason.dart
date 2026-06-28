import 'package:flutter_bloc_app/core/auth/session_lifecycle_coordinator.dart'
    show SessionLifecycleCoordinator;

/// Why a session was invalidated (emitted on [SessionLifecycleCoordinator]).
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
