import 'dart:async';

import 'package:auth/auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/auth/session_lifecycle_coordinator.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_bloc_app/features/supabase_auth/presentation/cubit/supabase_auth_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_subscription_mixin.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

part 'supabase_auth_cubit_handlers.part.dart';

/// Cubit managing Supabase authentication state and actions.
class SupabaseAuthCubit extends Cubit<SupabaseAuthState>
    with CubitSubscriptionMixin<SupabaseAuthState>, _SupabaseAuthCubitHandlers {
  SupabaseAuthCubit({
    required this._repository,
    this._l10n,
    this._sessionCoordinator,
  }) : super(const SupabaseAuthState.initial());

  final SupabaseAuthRepository _repository;
  final AppLocalizations? _l10n;
  final SessionLifecycleCoordinator? _sessionCoordinator;
  StreamSubscription<Object?>? _authStateSubscription;
  StreamSubscription<SessionInvalidationEvent>? _invalidationSubscription;

  @override
  SupabaseAuthRepository get supabaseAuthRepository => _repository;

  @override
  AppLocalizations? get supabaseAuthL10n => _l10n;

  @override
  SessionLifecycleCoordinator? get supabaseSessionCoordinator =>
      _sessionCoordinator;

  @override
  StreamSubscription<Object?>? get supabaseAuthStateSubscription =>
      _authStateSubscription;

  @override
  set supabaseAuthStateSubscription(final StreamSubscription<Object?>? value) {
    _authStateSubscription = value;
  }

  @override
  StreamSubscription<SessionInvalidationEvent>?
  get supabaseInvalidationSubscription => _invalidationSubscription;

  @override
  set supabaseInvalidationSubscription(
    final StreamSubscription<SessionInvalidationEvent>? value,
  ) {
    _invalidationSubscription = value;
  }

  /// Loads current session and subscribes to auth state changes.
  Future<void> loadSession() async {
    if (isClosed) return;

    if (!_repository.isConfigured) {
      await _disposeAuthStateSubscription();
      if (isClosed) return;
      emit(const SupabaseAuthState.notConfigured());
      return;
    }

    if (isClosed) return;
    emit(const SupabaseAuthState.loading());
    _emitCurrentAuthState();

    await _disposeAuthStateSubscription();
    _authStateSubscription = registerSubscription(
      _repository.authStateChanges.listen(
        _handleAuthStateChanged,
        onError: _handleAuthStateError,
        cancelOnError: false,
      ),
    );

    await _disposeInvalidationSubscription();
    final SessionLifecycleCoordinator? coordinator = _sessionCoordinator;
    if (coordinator != null) {
      _invalidationSubscription = registerSubscription(
        coordinator.invalidationEvents.listen(
          _handleInvalidationEvent,
          onError: _handleAuthStateError,
          cancelOnError: false,
        ),
      );
    }
  }

  /// Signs in with email and password.
  Future<void> signIn({
    required final String email,
    required final String password,
  }) async {
    await _runAuthAction(
      logContext: 'SupabaseAuthCubit.signIn',
      operation: () => _repository.signInWithPassword(
        email: email,
        password: password,
      ),
    );
  }

  /// Signs up with email, password, and optional display name.
  Future<void> signUp({
    required final String email,
    required final String password,
    final String? displayName,
  }) async {
    await _runAuthAction(
      logContext: 'SupabaseAuthCubit.signUp',
      operation: () => _repository.signUp(
        email: email,
        password: password,
        displayName: displayName,
      ),
    );
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _runAuthAction(
      logContext: 'SupabaseAuthCubit.signOut',
      operation: _repository.signOut,
      onSuccess: () {
        if (isClosed) return;
        emit(const SupabaseAuthState.unauthenticated());
      },
    );
  }

  /// Clears the current error message and restores the current auth state.
  void clearError() {
    if (isClosed) return;

    if (!_repository.isConfigured) {
      emit(const SupabaseAuthState.notConfigured());
      return;
    }

    _emitCurrentAuthState();
  }

  @override
  Future<void> close() {
    _authStateSubscription = null;
    _invalidationSubscription = null;
    return super.close();
  }
}
