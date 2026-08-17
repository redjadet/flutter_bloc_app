import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_failure.freezed.dart';

@freezed
sealed class ProfileFailure with _$ProfileFailure implements Exception {
  const ProfileFailure._();

  const factory ProfileFailure.load({
    String? message,
    Object? cause,
  }) = ProfileLoadFailure;

  const factory ProfileFailure.unknown({
    String? message,
    Object? cause,
  }) = ProfileUnknownFailure;

  String get displayMessage => when(
    load: (message, _) => message ?? 'Failed to load profile.',
    unknown: (message, _) => message ?? 'Something went wrong.',
  );
}
