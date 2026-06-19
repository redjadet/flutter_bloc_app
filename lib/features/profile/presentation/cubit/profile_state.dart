import 'package:flutter_bloc_app/features/profile/domain/profile_failure.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_state.freezed.dart';

@freezed
sealed class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = ProfileInitial;

  const factory ProfileState.loading() = ProfileLoading;

  const factory ProfileState.ready(final ProfileUser user) = ProfileReady;

  const factory ProfileState.error(final ProfileFailure failure) = ProfileError;

  const ProfileState._();

  bool get isLoading => maybeWhen(loading: () => true, orElse: () => false);

  bool get hasError => maybeWhen(error: (_) => true, orElse: () => false);

  bool get hasUser => maybeWhen(ready: (_) => true, orElse: () => false);

  ProfileUser? get user =>
      maybeWhen(ready: (final user) => user, orElse: () => null);

  String? get errorMessage => maybeWhen(
    error: (final failure) => failure.displayMessage,
    orElse: () => null,
  );
}
