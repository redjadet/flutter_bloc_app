import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_failure.freezed.dart';

@freezed
sealed class ProfileFailure with _$ProfileFailure implements Exception {
  const ProfileFailure._();

  const factory ProfileFailure.load({
    final String? message,
    final Object? cause,
  }) = ProfileLoadFailure;

  const factory ProfileFailure.unknown({
    final String? message,
    final Object? cause,
  }) = ProfileUnknownFailure;

  String get displayMessage => when(
    load: (final message, _) => message ?? 'Failed to load profile.',
    unknown: (final message, _) => message ?? 'Something went wrong.',
  );
}
