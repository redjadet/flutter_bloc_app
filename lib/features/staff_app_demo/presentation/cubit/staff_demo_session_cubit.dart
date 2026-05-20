import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/core/auth/auth_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_push_token_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_session_state.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';

class StaffDemoSessionCubit extends Cubit<StaffDemoSessionState> {
  StaffDemoSessionCubit({
    required this._authRepository,
    required this._profileRepository,
    required this._pushTokenRepository,
  }) : super(const StaffDemoSessionState());

  final AuthRepository _authRepository;
  final StaffDemoProfileRepository _profileRepository;
  final StaffDemoPushTokenRepository _pushTokenRepository;

  Future<void> hydrate() async {
    final user = _authRepository.currentUser;
    final String? userId = user?.id;
    if (userId == null || userId.isEmpty) {
      emit(
        state.copyWith(
          status: StaffDemoSessionStatus.error,
          errorMessage: 'Not signed in.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: StaffDemoSessionStatus.loading));
    await CubitExceptionHandler.executeAsync<StaffDemoProfile?>(
      operation: () => _profileRepository.loadProfile(userId: userId),
      isAlive: () => !isClosed,
      onSuccess: (final profile) {
        if (isClosed) return;
        if (_authRepository.currentUser?.id != userId) {
          unawaited(hydrate());
          return;
        }
        if (profile == null) {
          emit(state.copyWith(status: StaffDemoSessionStatus.missingProfile));
          return;
        }
        if (!profile.isActive) {
          emit(
            state.copyWith(
              status: StaffDemoSessionStatus.inactive,
              profile: profile,
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            status: StaffDemoSessionStatus.ready,
            profile: profile,
            errorMessage: null,
          ),
        );
        unawaited(_pushTokenRepository.registerTokens(userId: userId));
      },
      onError: (final message) {
        if (isClosed) return;
        if (_authRepository.currentUser?.id != userId) {
          unawaited(hydrate());
          return;
        }
        emit(
          state.copyWith(
            status: StaffDemoSessionStatus.error,
            errorMessage: message,
          ),
        );
      },
      logContext: 'StaffDemoSessionCubit.hydrate',
    );
  }
}
