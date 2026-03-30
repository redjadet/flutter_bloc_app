import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/auth/auth_user.dart';
import 'package:flutter_bloc_app/features/supabase_auth/domain/supabase_auth_repository.dart';
import 'package:flutter_bloc_app/features/supabase_auth/presentation/cubit/supabase_auth_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_subscription_mixin.dart';
import 'package:flutter_bloc_app/shared/utils/logger.dart';

/// Cubit managing Supabase authentication state and actions.
class SupabaseAuthCubit extends Cubit<SupabaseAuthState>
    with CubitSubscriptionMixin<SupabaseAuthState> {
  SupabaseAuthCubit({
    required final SupabaseAuthRepository repository,
    final AppLocalizations? l10n,
  }) : _repository = repository,
       _l10n = l10n,
       super(const SupabaseAuthState.initial());

  final SupabaseAuthRepository _repository;
  final AppLocalizations? _l10n;
  // ignore: cancel_subscriptions - Subscription is managed explicitly and by the mixin.
  StreamSubscription<Object?>? _authStateSubscription;

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
        cancelOnError: true,
      ),
    );
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
    return super.close();
  }

  Future<void> _runAuthAction({
    required final String logContext,
    required final Future<void> Function() operation,
    final void Function()? onSuccess,
  }) async {
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () async {
        if (isClosed) return;
        emit(const SupabaseAuthState.loading());

        await operation();
        if (isClosed) return;

        if (onSuccess case final runOnSuccess?) {
          runOnSuccess();
          return;
        }

        _emitCurrentAuthState();
      },
      logContext: logContext,
      isAlive: () => !isClosed,
      onError: (_) {},
      onErrorWithDetails: (final error, final stackTrace) {
        _emitActionError(
          context: logContext,
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  void _emitCurrentAuthState() {
    if (isClosed) return;

    final user = _repository.currentUser;
    if (user != null) {
      emit(SupabaseAuthState.authenticated(user));
      return;
    }

    emit(const SupabaseAuthState.unauthenticated());
  }

  void _handleAuthStateChanged(final AuthUser? user) {
    if (isClosed) return;

    if (user != null) {
      emit(SupabaseAuthState.authenticated(user));
      return;
    }

    emit(const SupabaseAuthState.unauthenticated());
  }

  void _handleAuthStateError(final Object error, final StackTrace stackTrace) {
    AppLogger.error('SupabaseAuthCubit.authStateChanges', error, stackTrace);
    if (isClosed) return;
    emit(SupabaseAuthState.error(_mapErrorMessage(error)));
  }

  void _emitActionError({
    required final String context,
    required final Object error,
    required final StackTrace? stackTrace,
  }) {
    // Expected user errors (wrong password, weak password) log at debug to avoid console noise.
    final bool isExpectedAuthFailure =
        error is SupabaseAuthException &&
        (error.code == SupabaseAuthErrorCode.invalidCredentials ||
            error.code == SupabaseAuthErrorCode.weakPassword ||
            error.code == SupabaseAuthErrorCode.invalidEmail ||
            error.code == SupabaseAuthErrorCode.userAlreadyExists);
    if (isExpectedAuthFailure) {
      AppLogger.debug('$context: $error');
    } else {
      AppLogger.error(context, error, stackTrace);
    }
    if (isClosed) return;
    emit(SupabaseAuthState.error(_mapErrorMessage(error)));
  }

  String _mapErrorMessage(final Object error) {
    if (error is SupabaseAuthException) {
      switch (error.code) {
        case SupabaseAuthErrorCode.invalidCredentials:
          return _l10n?.supabaseAuthErrorInvalidCredentials ?? error.message;
        case SupabaseAuthErrorCode.network:
          return _l10n?.supabaseAuthErrorNetwork ?? error.message;
        case SupabaseAuthErrorCode.weakPassword:
          return _l10n?.supabaseAuthErrorWeakPassword ?? error.message;
        case SupabaseAuthErrorCode.invalidEmail:
          return _l10n?.supabaseAuthErrorInvalidEmail ?? error.message;
        case SupabaseAuthErrorCode.userAlreadyExists:
          return _l10n?.supabaseAuthErrorUserAlreadyExists ?? error.message;
        case null:
          break;
      }

      final String trimmedMessage = error.message.trim();
      if (trimmedMessage.isNotEmpty) {
        return trimmedMessage;
      }
    }

    return error.toString();
  }

  Future<void> _disposeAuthStateSubscription() async {
    final StreamSubscription<Object?>? subscription = _authStateSubscription;
    _authStateSubscription = null;
    await cancelRegisteredSubscription(subscription);
  }
}
