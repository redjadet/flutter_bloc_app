import 'package:auth/auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_auth_state.freezed.dart';

@freezed
abstract class AppAuthState with _$AppAuthState {
  const factory initial() = _Initial;
  const factory loading() = _Loading;
  const factory authenticated(AuthUser user) = _Authenticated;
  const factory unauthenticated() = _Unauthenticated;
  const factory sessionExpired(SessionInvalidationReason reason) =
      _SessionExpired;
}
