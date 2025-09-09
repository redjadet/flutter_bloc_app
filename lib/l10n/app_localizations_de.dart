// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get autoLabel => 'Automatisch';

  @override
  String get pausedLabel => 'Pausiert';

  @override
  String nextAutoDecrementIn(int s) {
    return 'Nächste automatische Verringerung in: ${s}s';
  }

  @override
  String get autoDecrementPaused => 'Automatische Verringerung pausiert';

  @override
  String get lastChangedLabel => 'Zuletzt geändert:';

  @override
  String get appTitle => 'Flutter Demo';

  @override
  String get homeTitle => 'Flutter Demo Startseite';

  @override
  String get pushCountLabel => 'Sie haben so oft auf die Taste gedrückt:';

  @override
  String get incrementTooltip => 'Erhöhen';

  @override
  String get decrementTooltip => 'Verringern';

  @override
  String get loadErrorMessage =>
      'Gespeicherter Zähler konnte nicht geladen werden';
}
