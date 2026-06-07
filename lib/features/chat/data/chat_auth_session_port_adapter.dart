import 'package:flutter_bloc_app/core/auth/auth_repository.dart' as core_auth;
import 'package:flutter_bloc_app/core/auth/auth_user.dart';
import 'package:flutter_bloc_app/features/chat/domain/chat_auth_session_port.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';

class ChatAuthSessionPortAdapter implements ChatAuthSessionPort {
  ChatAuthSessionPortAdapter({
    required this._firebaseAuthRepository,
    required this._supabaseAuthRepository,
  });

  final core_auth.AuthRepository _firebaseAuthRepository;
  final SupabaseAuthRepository _supabaseAuthRepository;

  @override
  Stream<AuthUser?> get firebaseAuthStateChanges =>
      _firebaseAuthRepository.authStateChanges;

  @override
  Stream<AuthUser?> get supabaseAuthStateChanges =>
      _supabaseAuthRepository.authStateChanges;
}
