import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_repository.dart';
import 'package:flutter_bloc_app/features/profile/presentation/cubit/profile_state.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';

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

    try {
      final user = await _repository.getProfile();
      emit(
        state.copyWith(
          status: ViewStatus.success,
          user: user,
          clearError: true,
        ),
      );
    } on Exception catch (error) {
      emit(
        ProfileState(
          status: ViewStatus.error,
          error: error,
        ),
      );
    } on Object catch (error) {
      emit(
        ProfileState(
          status: ViewStatus.error,
          error: error,
        ),
      );
    }
  }
}
