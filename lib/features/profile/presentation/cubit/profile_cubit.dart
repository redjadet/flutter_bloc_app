import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_repository.dart';
import 'package:flutter_bloc_app/features/profile/presentation/cubit/profile_state.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:flutter_bloc_app/shared/utils/cubit_async_operations.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required final ProfileRepository repository})
    : _repository = repository,
      super(const ProfileState());

  final ProfileRepository _repository;
  int _loadRequestId = 0;

  Future<void> loadProfile() async {
    if (isClosed) {
      return;
    }
    final int requestId = ++_loadRequestId;

    emit(
      state.copyWith(
        status: ViewStatus.loading,
        error: null,
      ),
    );

    await CubitExceptionHandler.executeAsync(
      operation: _repository.getProfile,
      isAlive: () => !isClosed,
      onSuccess: (final user) {
        if (isClosed || requestId != _loadRequestId) return;
        emit(
          state.copyWith(
            status: ViewStatus.success,
            user: user,
            error: null,
          ),
        );
      },
      onError: (final errorMessage) {
        if (isClosed || requestId != _loadRequestId) return;
        emit(
          ProfileState(
            status: ViewStatus.error,
            error: Exception(errorMessage),
          ),
        );
      },
      logContext: 'ProfileCubit.loadProfile',
    );
  }
}
