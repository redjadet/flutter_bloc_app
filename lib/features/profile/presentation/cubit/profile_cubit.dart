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

  Future<void> loadProfile() async {
    emit(
      state.copyWith(
        status: ViewStatus.loading,
        clearError: true,
      ),
    );

    await CubitExceptionHandler.executeAsync(
      operation: _repository.getProfile,
      onSuccess: (final user) {
        emit(
          state.copyWith(
            status: ViewStatus.success,
            user: user,
            clearError: true,
          ),
        );
      },
      onError: (final String errorMessage) {
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
