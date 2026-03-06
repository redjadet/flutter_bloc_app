import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_repository.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_user.dart';

/// Firebase Auth implementation of [AuthRepository].
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({required final FirebaseAuth firebaseAuth})
    : _firebaseAuth = firebaseAuth;

  final FirebaseAuth _firebaseAuth;

  @override
  AuthUser? get currentUser {
    final User? user = _firebaseAuth.currentUser;
    return user == null ? null : _toAuthUser(user);
  }

  @override
  Stream<AuthUser?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map((final user) {
        return user == null ? null : _toAuthUser(user);
      });

  @override
  Future<void> signInAnonymously() => _firebaseAuth.signInAnonymously();

  @override
  Future<void> signOut() => _firebaseAuth.signOut();

  static AuthUser _toAuthUser(final User user) => AuthUser(
    id: user.uid,
    email: user.email?.trim(),
    displayName: user.displayName?.trim(),
    isAnonymous: user.isAnonymous,
  );
}
