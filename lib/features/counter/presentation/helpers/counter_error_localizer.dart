import 'package:flutter_bloc_app/features/counter/domain/counter_error.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

String counterErrorMessage(AppLocalizations l10n, CounterError error) {
  switch (error.type) {
    case CounterErrorType.cannotGoBelowZero:
      return l10n.cannotGoBelowZero;
    case CounterErrorType.loadError || CounterErrorType.saveError:
      return l10n.loadErrorMessage;
    case CounterErrorType.unknown:
      return error.message ?? l10n.loadErrorMessage;
  }
}
