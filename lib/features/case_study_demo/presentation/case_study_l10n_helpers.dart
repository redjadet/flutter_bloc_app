import 'package:flutter_bloc_app/features/camera_gallery/domain/camera_gallery_error_keys.dart';
import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

String caseStudyCaseTypeTitle(
  final AppLocalizations l10n,
  final CaseStudyCaseType type,
) {
  switch (type) {
    case CaseStudyCaseType.implant:
      return l10n.caseStudyCaseTypeImplant;
    case CaseStudyCaseType.ortho:
      return l10n.caseStudyCaseTypeOrtho;
    case CaseStudyCaseType.cosmetic:
      return l10n.caseStudyCaseTypeCosmetic;
    case CaseStudyCaseType.general:
      return l10n.caseStudyCaseTypeGeneral;
  }
}

String cameraGalleryErrorMessage(
  final AppLocalizations l10n,
  final String key,
) {
  switch (key) {
    case CameraGalleryErrorKeys.permissionDenied:
      return l10n.cameraGalleryPermissionDenied;
    case CameraGalleryErrorKeys.cameraUnavailable:
      return l10n.cameraGalleryCameraUnavailable;
    case CameraGalleryErrorKeys.cancelled:
      return l10n.cameraGalleryCancelled;
    case CameraGalleryErrorKeys.generic:
    default:
      return l10n.cameraGalleryGenericError;
  }
}
