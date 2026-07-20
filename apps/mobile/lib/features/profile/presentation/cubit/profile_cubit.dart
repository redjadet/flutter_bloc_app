import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/app/utils/cubit_async_operations.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_failure.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_repository.dart';
import 'package:flutter_bloc_app/features/profile/presentation/cubit/profile_state.dart';
import 'package:ilkersevim_async_utils/ilkersevim_async_utils.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required this._repository})
    : super(const ProfileState.initial());

  final ProfileRepository _repository;
  final RequestIdGuard _loadGuard = RequestIdGuard();

  Future<void> loadProfile() async {
    if (isClosed) return;
    final int requestId = _loadGuard.next();

    emit(const ProfileState.loading());

    await CubitExceptionHandler.executeAsync(
      operation: _repository.getProfile,
      isAlive: () => !isClosed,
      onSuccess: (final user) {
        if (isClosed || !_loadGuard.isCurrent(requestId)) return;
        emit(ProfileState.ready(user));
      },
      onError: (final errorMessage) {
        if (isClosed || !_loadGuard.isCurrent(requestId)) return;
        emit(
          ProfileState.error(
            ProfileFailure.load(message: errorMessage),
          ),
        );
      },
      logContext: 'ProfileCubit.loadProfile',
    );
  }
}
