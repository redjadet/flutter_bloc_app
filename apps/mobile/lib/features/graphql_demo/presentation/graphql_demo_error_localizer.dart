import 'package:flutter_bloc_app/l10n/app_localizations.dart';
import 'package:utilities/utilities.dart';

/// Maps [AppError] from GraphQL demo state to existing graphqlSample* l10n keys.
String graphqlDemoErrorMessage(AppLocalizations l10n, AppError? error) {
  if (error is NetworkError) {
    return switch (error.kind) {
      NetworkErrorKind.offline ||
      NetworkErrorKind.timeout ||
      NetworkErrorKind.serviceUnavailable ||
      NetworkErrorKind.rateLimited => l10n.graphqlSampleNetworkError,
      NetworkErrorKind.server => l10n.graphqlSampleServerError,
      NetworkErrorKind.client => l10n.graphqlSampleInvalidRequestError,
      NetworkErrorKind.unknown => _messageOrGeneric(l10n, error.message),
    };
  }
  if (error is StorageError) {
    return l10n.graphqlSampleDataError;
  }
  return _messageOrGeneric(l10n, error?.message);
}

String _messageOrGeneric(AppLocalizations l10n, String? message) {
  final String trimmed = message?.trim() ?? '';
  if (trimmed.isNotEmpty) {
    return trimmed;
  }
  return l10n.graphqlSampleGenericError;
}
