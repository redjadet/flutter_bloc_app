import 'dart:async';

import 'package:auth/auth.dart' hide AuthRepository;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/presentation/cubit/app_auth_state.dart';
import 'package:flutter_bloc_app/core/auth/session_lifecycle_coordinator.dart';
import 'package:flutter_bloc_app/features/auth/domain/auth_repository.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_subscription_mixin.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// App-scoped auth UX state. Router continues to use [AuthRepository] directly.
class AppAuthCubit extends Cubit<AppAuthState>
    with CubitSubscriptionMixin<AppAuthState> {
  AppAuthCubit({
    required this._authRepository,
    required this._sessionCoordinator,
  }) : super(const AppAuthState.initial());

  final AuthRepository _authRepository;
  final SessionLifecycleCoordinator _sessionCoordinator;
  StreamSubscription<AuthUser?>? _authSubscription;
  StreamSubscription<SessionInvalidationEvent>? _invalidationSubscription;
  SessionInvalidationReason? _stickyExpiredReason;

  Future<void> start() async {
    if (isClosed) return;
    emit(const AppAuthState.loading());
    _emitFromRepository();

    await _authSubscription?.cancel();
    _authSubscription = registerSubscription(
      _authRepository.authStateChanges.listen(
        _handleAuthUserChanged,
        onError: (final Object error, final StackTrace stackTrace) {
          AppLogger.error('AppAuthCubit.authStateChanges', error, stackTrace);
        },
        cancelOnError: false,
      ),
    );

    await _invalidationSubscription?.cancel();
    _invalidationSubscription = registerSubscription(
      _sessionCoordinator.invalidationEvents.listen(
        _handleInvalidation,
        onError: (final Object error, final StackTrace stackTrace) {
          AppLogger.error(
            'AppAuthCubit.invalidationEvents',
            error,
            stackTrace,
          );
        },
        cancelOnError: false,
      ),
    );
  }

  void acknowledgeSessionExpired() {
    if (isClosed) return;
    _stickyExpiredReason = null;
    emit(const AppAuthState.unauthenticated());
  }

  void _handleInvalidation(final SessionInvalidationEvent event) {
    if (isClosed) return;
    if (event.provider != AuthProviderKind.firebase) {
      return;
    }
    _stickyExpiredReason = event.reason;
    emit(AppAuthState.sessionExpired(event.reason));
  }

  void _handleAuthUserChanged(final AuthUser? user) {
    if (isClosed) return;
    if (user != null) {
      _stickyExpiredReason = null;
      emit(AppAuthState.authenticated(user));
      return;
    }
    if (_stickyExpiredReason case final SessionInvalidationReason reason) {
      emit(AppAuthState.sessionExpired(reason));
      return;
    }
    emit(const AppAuthState.unauthenticated());
  }

  void _emitFromRepository() {
    _handleAuthUserChanged(_authRepository.currentUser);
  }

  @override
  Future<void> close() {
    _authSubscription = null;
    _invalidationSubscription = null;
    return super.close();
  }
}
