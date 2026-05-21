import 'package:flutter_bloc_app/features/case_study_demo/domain/case_study_case_type.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:flutter_bloc_app/shared/media/media_pick_error_keys.dart';

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
    case MediaPickErrorKeys.permissionDenied:
      return l10n.cameraGalleryPermissionDenied;
    case MediaPickErrorKeys.cameraUnavailable:
      return l10n.cameraGalleryCameraUnavailable;
    case MediaPickErrorKeys.cancelled:
      return l10n.cameraGalleryCancelled;
    case MediaPickErrorKeys.generic:
    default:
      return l10n.cameraGalleryGenericError;
  }
}
