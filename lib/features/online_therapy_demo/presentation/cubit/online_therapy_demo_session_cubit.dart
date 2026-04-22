import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/online_therapy_fake_api.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/data/fake/online_therapy_network_mode.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/domain.dart';
import 'package:flutter_bloc_app/features/online_therapy_demo/domain/repositories/therapy_auth_repository.dart';

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
    required final OnlineTherapyFakeApi api,
  }) : _auth = auth,
       _api = api,
       super(
         OnlineTherapyDemoSessionState(
           role: TherapyRole.client,
           networkMode: api.mode,
           isBusy: false,
           user: auth.currentUser,
           emailDraft: 'demo@example.com',
         ),
       );

  final TherapyAuthRepository _auth;
  final OnlineTherapyFakeApi _api;

  Future<void> setRole(final TherapyRole role) async {
    if (state.role == role) return;
    if (!state.isLoggedIn) {
      emit(state.copyWith(role: role));
      return;
    }

    emit(state.copyWith(role: role, isBusy: true, user: null));
    try {
      final email = (state.emailDraft ?? '').trim();
      final user = await _auth.login(email: email, role: role);
      if (isClosed) return;
      emit(state.copyWith(isBusy: false, user: user));
    } on Object catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isBusy: false, errorMessage: e.toString()));
    }
  }

  void setNetworkMode(final OnlineTherapyNetworkMode mode) {
    if (state.networkMode == mode) return;
    _api.mode = mode;
    emit(state.copyWith(networkMode: mode));
  }

  void setEmailDraft(final String value) {
    emit(state.copyWith(emailDraft: value));
  }

  Future<void> login() async {
    if (state.isBusy) return;
    emit(state.copyWith(isBusy: true));
    try {
      final email = (state.emailDraft ?? '').trim();
      final user = await _auth.login(email: email, role: state.role);
      if (isClosed) return;
      emit(state.copyWith(isBusy: false, user: user));
    } on Object catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isBusy: false, errorMessage: e.toString()));
    }
  }

  Future<void> logout() async {
    if (state.isBusy) return;
    emit(state.copyWith(isBusy: true));
    try {
      await _auth.logout();
      if (isClosed) return;
      emit(state.copyWith(isBusy: false, user: null));
    } on Object catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isBusy: false, errorMessage: e.toString()));
    }
  }
}
