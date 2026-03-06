import 'package:firebase_auth/firebase_auth.dart' show User;

/// Domain model for an authenticated user.
///
/// Flutter-agnostic; implementations map from platform-specific types
/// (e.g. Firebase [User]) to this type.
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
