import 'package:flutter_bloc_app/core/auth/auth_user.dart';
import 'package:flutter_bloc_app/core/auth/session_invalidation_reason.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_auth_state.freezed.dart';

@freezed
abstract class AppAuthState with _$AppAuthState {
  const factory AppAuthState.initial() = _Initial;
  const factory AppAuthState.loading() = _Loading;
  const factory AppAuthState.authenticated(final AuthUser user) =
      _Authenticated;
  const factory AppAuthState.unauthenticated() = _Unauthenticated;
  const factory AppAuthState.sessionExpired(
    final SessionInvalidationReason reason,
  ) = _SessionExpired;
}
