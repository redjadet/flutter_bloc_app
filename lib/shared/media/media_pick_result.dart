import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_pick_result.freezed.dart';

/// Result of a camera, gallery, or video pick operation.
///
/// Shared across features so domain layers do not depend on feature barrels.
@freezed
sealed class MediaPickResult with _$MediaPickResult {
  const MediaPickResult._();

  /// User took or selected media; [imagePath] is the temporary file path.
  const factory MediaPickResult.success(final String imagePath) =
      _MediaPickResultSuccess;

  /// User cancelled the picker.
  const factory MediaPickResult.cancelled() = _MediaPickResultCancelled;

  /// Operation failed; [errorKey] is an l10n key for user-facing message.
  const factory MediaPickResult.failure({
    required final String errorKey,
    final String? message,
  }) = _MediaPickResultFailure;
}
