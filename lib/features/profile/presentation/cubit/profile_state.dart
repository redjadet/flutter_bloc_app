import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_app/features/profile/domain/profile_user.dart';
import 'package:flutter_bloc_app/shared/ui/view_status.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ViewStatus.initial,
    this.user,
    this.error,
  });

  final ViewStatus status;
  final ProfileUser? user;
  final Object? error;

  bool get isLoading => status.isLoading;
  bool get hasError => status.isError;
  bool get hasUser => user != null;

  ProfileState copyWith({
    final ViewStatus? status,
    final ProfileUser? user,
    final Object? error,
    final bool clearError = false,
    final bool resetUser = false,
  }) => ProfileState(
    status: status ?? this.status,
    user: resetUser ? null : user ?? this.user,
    error: clearError ? null : error ?? this.error,
  );

  @override
  List<Object?> get props => [status, user, error];

  @override
  String toString() =>
      'ProfileState(status: $status, hasUser: $hasUser, hasError: $hasError)';
}
