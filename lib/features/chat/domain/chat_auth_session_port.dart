import 'package:flutter_bloc_app/core/auth/auth_user.dart';

/// Auth session signals used by chat transport-hint refresh (Firebase + Supabase).
abstract interface class ChatAuthSessionPort {
  Stream<AuthUser?> get firebaseAuthStateChanges;

  Stream<AuthUser?> get supabaseAuthStateChanges;
}
