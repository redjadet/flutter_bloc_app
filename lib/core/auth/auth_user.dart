/// App-level contract for an authenticated user.
///
/// Implementations (e.g. auth feature, supabase_auth) map from
/// platform-specific types to this type. Used by router, auth gates, and
/// any code that needs "current user" without depending on a specific
/// auth feature.
class AuthUser {
  const AuthUser({
    required this.id,
    required this.isAnonymous,
    this.email,
    this.displayName,
  });

  final String id;
  final String? email;
  final String? displayName;
  final bool isAnonymous;
}
