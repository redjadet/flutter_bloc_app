import 'package:app_shared_flutter/app_shared_flutter.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

/// Localized user-facing message for a [MediaPickErrorKeys] value.
String cameraGalleryErrorMessage(
  final AppLocalizations l10n,
  final String key,
) {
  switch (key) {
    case MediaPickErrorKeys.permissionDenied:
      return l10n.cameraGalleryPermissionDenied;
    case MediaPickErrorKeys.cameraUnavailable:
      return l10n.cameraGalleryCameraUnavailable;
    case MediaPickErrorKeys.cancelled:
      return l10n.cameraGalleryCancelled;
    case MediaPickErrorKeys.fileTooLarge:
      return l10n.cameraGalleryFileTooLarge;
    case MediaPickErrorKeys.generic:
    default:
      return l10n.cameraGalleryGenericError;
  }
}
