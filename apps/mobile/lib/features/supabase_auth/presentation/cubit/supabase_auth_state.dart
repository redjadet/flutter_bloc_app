import 'package:auth/auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'supabase_auth_state.freezed.dart';

@freezed
abstract class SupabaseAuthState with _$SupabaseAuthState {
  const factory SupabaseAuthState.initial() = _Initial;
  const factory SupabaseAuthState.loading() = _Loading;
  const factory SupabaseAuthState.authenticated(final AuthUser user) =
      _Authenticated;
  const factory SupabaseAuthState.unauthenticated() = _Unauthenticated;
  const factory SupabaseAuthState.sessionExpired(
    final SessionInvalidationReason reason,
  ) = _SessionExpired;
  const factory SupabaseAuthState.error(final String message) = _Error;
  const factory SupabaseAuthState.notConfigured() = _NotConfigured;
}
