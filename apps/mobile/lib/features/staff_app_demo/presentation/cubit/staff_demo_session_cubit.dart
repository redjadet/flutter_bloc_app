import 'dart:async';

import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:auth/auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_profile_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_push_token_repository.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/domain/staff_demo_push_token_result.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/cubit/staff_demo_session_state.dart';

class StaffDemoSessionCubit extends Cubit<StaffDemoSessionState> {
  new({
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
      onSuccess: (profile) {
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
        unawaited(_registerPushTokens(userId: userId));
      },
      onFailure: (failure) {
        if (isClosed) return;
        if (_authRepository.currentUser?.id != userId) {
          unawaited(hydrate());
          return;
        }
        emit(
          state.copyWith(
            status: StaffDemoSessionStatus.error,
            errorMessage: failure.message,
          ),
        );
      },
      logContext: 'StaffDemoSessionCubit.hydrate',
    );
  }

  Future<void> _registerPushTokens({required String userId}) async {
    try {
      final StaffDemoPushTokenResult result = await _pushTokenRepository
          .registerTokens(userId: userId);
      switch (result) {
        case StaffDemoPushTokenRegistered():
          break;
        case StaffDemoPushTokenSkipped(:final reason):
          AppLogger.info(
            'StaffDemoSessionCubit push token registration skipped: $reason',
          );
        case StaffDemoPushTokenFailed(:final cause, :final stackTrace):
          // Boundary log: repository implementations may also log; do not assume.
          AppLogger.error(
            'StaffDemoSessionCubit push token registration failed',
            cause,
            stackTrace,
          );
      }
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'StaffDemoSessionCubit push token registration threw',
        error,
        stackTrace,
      );
    }
  }
}
