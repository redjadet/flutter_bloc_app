import 'package:flutter_bloc_app/l10n/app_localizations.dart';

/// Maps persisted remote failure `code` strings (e.g. from dequeue) to plan ARB copy.
String terminalSyncFailureMessage(AppLocalizations l10n, String code) =>
    switch (code) {
      'auth_required' => l10n.chatAuthRefreshRequired,
      'token_missing' => l10n.chatTokenMissing,
      'forbidden' => l10n.chatSwitchAccount,
      'rate_limited' || 'invalid_request' => l10n.chatSessionEnded,
      _ => l10n.chatSessionEnded,
    };
