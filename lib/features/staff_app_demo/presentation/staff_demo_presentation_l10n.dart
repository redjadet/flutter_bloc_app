import 'package:flutter_bloc_app/features/staff_app_demo/presentation/forms/staff_demo_forms_state.dart';
import 'package:flutter_bloc_app/features/staff_app_demo/presentation/messages/staff_demo_messages_state.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

String staffDemoMessagesResolvedError(
  final AppLocalizations l10n,
  final StaffDemoMessagesState state,
) {
  final known = state.knownError;
  if (known != null) {
    switch (known) {
      case StaffDemoMessagesKnownError.notSignedIn:
        return l10n.staffDemoNotSignedIn;
      case StaffDemoMessagesKnownError.inboxStreamFailed:
        return l10n.staffDemoMessagesErrorInboxLoadFailed;
    }
  }
  return state.errorMessage ?? l10n.errorUnknown;
}

/// Status banner copy for the staff demo forms page.
String? staffDemoFormsStatusBannerMessage(
  final AppLocalizations l10n,
  final StaffDemoFormsState state,
) {
  return switch (state.status) {
    StaffDemoFormsStatus.initial => null,
    StaffDemoFormsStatus.submitting => l10n.staffDemoSubmitting,
    StaffDemoFormsStatus.success => switch (state.lastSuccessKind) {
      StaffDemoFormsSuccessKind.availabilitySubmitted =>
        l10n.staffDemoFormsSuccessAvailability,
      StaffDemoFormsSuccessKind.managerReportSubmitted =>
        l10n.staffDemoFormsSuccessManagerReport,
      null => l10n.staffDemoFormsSubmitted,
    },
    StaffDemoFormsStatus.error => switch (state.knownError) {
      StaffDemoFormsKnownError.notSignedIn => l10n.staffDemoNotSignedIn,
      StaffDemoFormsKnownError.siteIdRequired =>
        l10n.staffDemoFormsErrorSiteRequired,
      null => state.errorMessage ?? l10n.errorUnknown,
    },
  };
}
