import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/therapy_auth_repository.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';

class OnlineTherapyDemoSessionState {
  const OnlineTherapyDemoSessionState({
    required this.role,
    required this.networkMode,
    required this.isBusy,
    this.user,
    this.errorMessage,
    this.emailDraft,
  });

  final TherapyRole role;
  final OnlineTherapyNetworkMode networkMode;
  final bool isBusy;
  final TherapyUser? user;
  final String? errorMessage;
  final String? emailDraft;

  bool get isLoggedIn => user != null;

  static const Object _noChange = Object();

  OnlineTherapyDemoSessionState copyWith({
    TherapyRole? role,
    OnlineTherapyNetworkMode? networkMode,
    bool? isBusy,
    Object? user = _noChange,
    String? errorMessage,
    String? emailDraft,
  }) => OnlineTherapyDemoSessionState(
    role: role ?? this.role,
    networkMode: networkMode ?? this.networkMode,
    isBusy: isBusy ?? this.isBusy,
    user: identical(user, _noChange) ? this.user : user as TherapyUser?,
    errorMessage: errorMessage,
    emailDraft: emailDraft ?? this.emailDraft,
  );
}

class OnlineTherapyDemoSessionCubit
    extends Cubit<OnlineTherapyDemoSessionState> {
  OnlineTherapyDemoSessionCubit({
    required final TherapyAuthRepository auth,
    required final OnlineTherapyNetworkModeController networkModeController,
  }) : _auth = auth,
       _networkModeController = networkModeController,
       super(
         OnlineTherapyDemoSessionState(
           role: TherapyRole.client,
           networkMode: networkModeController.mode,
           isBusy: false,
           user: auth.currentUser,
           emailDraft: 'demo@example.com',
         ),
       );

  final TherapyAuthRepository _auth;
  final OnlineTherapyNetworkModeController _networkModeController;

  Future<void> setRole(final TherapyRole role) async {
    if (state.role == role) return;
    if (!state.isLoggedIn) {
      emit(state.copyWith(role: role));
      return;
    }

    final TherapyUser? previousUser = state.user;
    final TherapyRole previousRole = state.role;
    final email = (state.emailDraft ?? '').trim();
    emit(state.copyWith(role: role, isBusy: true, user: null));
    await CubitExceptionHandler.executeAsync(
      operation: () => _auth.login(email: email, role: role),
      onSuccess: (user) {
        if (isClosed) return;
        emit(state.copyWith(isBusy: false, user: user));
      },
      onError: (message) {
        if (isClosed) return;
        emit(
          state.copyWith(
            role: previousRole,
            isBusy: false,
            user: previousUser,
            errorMessage: message,
          ),
        );
      },
      logContext: 'OnlineTherapyDemoSessionCubit.setRole',
      isAlive: () => !isClosed,
    );
  }

  void setNetworkMode(final OnlineTherapyNetworkMode mode) {
    if (state.networkMode == mode) return;
    _networkModeController.mode = mode;
    emit(state.copyWith(networkMode: mode));
  }

  void setEmailDraft(final String value) {
    emit(state.copyWith(emailDraft: value));
  }

  Future<void> login() async {
    if (state.isBusy) return;
    emit(state.copyWith(isBusy: true));
    await CubitExceptionHandler.executeAsync(
      operation: () {
        final email = (state.emailDraft ?? '').trim();
        return _auth.login(email: email, role: state.role);
      },
      onSuccess: (user) {
        if (isClosed) return;
        emit(state.copyWith(isBusy: false, user: user));
      },
      onError: (message) {
        if (isClosed) return;
        emit(state.copyWith(isBusy: false, errorMessage: message));
      },
      logContext: 'OnlineTherapyDemoSessionCubit.login',
      isAlive: () => !isClosed,
    );
  }

  Future<void> logout() async {
    if (state.isBusy) return;
    emit(state.copyWith(isBusy: true));
    await CubitExceptionHandler.executeAsyncVoid(
      operation: () => _auth.logout(),
      onSuccess: () {
        if (isClosed) return;
        emit(state.copyWith(isBusy: false, user: null));
      },
      onError: (message) {
        if (isClosed) return;
        emit(state.copyWith(isBusy: false, errorMessage: message));
      },
      logContext: 'OnlineTherapyDemoSessionCubit.logout',
      isAlive: () => !isClosed,
    );
  }
}
