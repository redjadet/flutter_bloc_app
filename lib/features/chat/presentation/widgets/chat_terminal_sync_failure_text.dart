import 'package:flutter_bloc_app/l10n/app_localizations.dart';

/// Maps persisted remote failure `code` strings (e.g. from dequeue) to plan ARB copy.
String terminalSyncFailureMessage(
  final AppLocalizations l10n,
  final String code,
) {
  switch (code) {
    case 'auth_required':
      return l10n.chatAuthRefreshRequired;
    case 'token_missing':
      return l10n.chatTokenMissing;
    case 'forbidden':
      return l10n.chatSwitchAccount;
    case 'rate_limited':
      return l10n.chatSessionEnded;
    case 'invalid_request':
      return l10n.chatSessionEnded;
    default:
      return l10n.chatSessionEnded;
  }
}
