import 'package:flutter_bloc_app/features/counter/domain/counter_error.dart';
import 'package:flutter_bloc_app/l10n/app_localizations.dart';

String counterErrorMessage(
  final AppLocalizations l10n,
  final CounterError error,
) => switch (error.type) {
  CounterErrorType.cannotGoBelowZero => l10n.cannotGoBelowZero,
  CounterErrorType.loadError => l10n.loadErrorMessage,
  CounterErrorType.saveError => l10n.saveErrorMessage,
  CounterErrorType.unknown => error.message ?? l10n.loadErrorMessage,
};
