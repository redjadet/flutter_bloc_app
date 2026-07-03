part of 'supabase_auth_cubit.dart';

mixin _SupabaseAuthCubitHandlers
    on Cubit<SupabaseAuthState>, CubitSubscriptionMixin<SupabaseAuthState> {
  SupabaseAuthRepository get supabaseAuthRepository;
  AppLocalizations? get supabaseAuthL10n;
  SessionLifecycleCoordinator? get supabaseSessionCoordinator;
  StreamSubscription<Object?>? get supabaseAuthStateSubscription;
  set supabaseAuthStateSubscription(StreamSubscription<Object?>? value);
  StreamSubscription<SessionInvalidationEvent>?
  get supabaseInvalidationSubscription;
  set supabaseInvalidationSubscription(
    StreamSubscription<SessionInvalidationEvent>? value,
  );

  void _handleInvalidationEvent(final SessionInvalidationEvent event) {
    if (isClosed) return;
    if (event.provider != AuthProviderKind.supabase) {
      return;
    }
    emit(SupabaseAuthState.sessionExpired(event.reason));
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

    final user = supabaseAuthRepository.currentUser;
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

    final bool isSessionExpired = state.maybeMap(
      sessionExpired: (_) => true,
      orElse: () => false,
    );
    if (isSessionExpired) {
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
          return supabaseAuthL10n?.supabaseAuthErrorInvalidCredentials ??
              error.message;
        case SupabaseAuthErrorCode.network:
          return supabaseAuthL10n?.supabaseAuthErrorNetwork ?? error.message;
        case SupabaseAuthErrorCode.weakPassword:
          return supabaseAuthL10n?.supabaseAuthErrorWeakPassword ??
              error.message;
        case SupabaseAuthErrorCode.invalidEmail:
          return supabaseAuthL10n?.supabaseAuthErrorInvalidEmail ??
              error.message;
        case SupabaseAuthErrorCode.userAlreadyExists:
          return supabaseAuthL10n?.supabaseAuthErrorUserAlreadyExists ??
              error.message;
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
    final StreamSubscription<Object?>? subscription =
        supabaseAuthStateSubscription;
    supabaseAuthStateSubscription = null;
    await cancelRegisteredSubscription(subscription);
  }

  Future<void> _disposeInvalidationSubscription() async {
    final StreamSubscription<SessionInvalidationEvent>? subscription =
        supabaseInvalidationSubscription;
    supabaseInvalidationSubscription = null;
    await cancelRegisteredSubscription(subscription);
  }
}
