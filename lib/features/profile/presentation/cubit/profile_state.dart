import 'package:flutter_bloc_app/features/profile/domain/profile_user.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_state.freezed.dart';

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(ViewStatus.initial) final ViewStatus status,
    final ProfileUser? user,
    final Object? error,
  }) = _ProfileState;

  const ProfileState._();

  bool get isLoading => status.isLoading;
  bool get hasError => status.isError;
  bool get hasUser => user != null;
}
