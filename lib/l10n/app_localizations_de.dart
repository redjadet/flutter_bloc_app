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

  @override
  String get startAutoHint =>
      'Bei Zähler 0: Tippen Sie auf + für Auto-Verringerung';

  @override
  String get cannotGoBelowZero => 'Der Zähler kann nicht unter 0 gehen';

  @override
  String get openExampleTooltip => 'Beispielseite öffnen';

  @override
  String get examplePageTitle => 'Beispielseite';

  @override
  String get examplePageDescription =>
      'Diese Seite demonstriert die Navigation mit GoRouter.';

  @override
  String get exampleBackButtonLabel => 'Zurück zum Zähler';

  @override
  String get openChartsTooltip => 'Diagramme öffnen';

  @override
  String get openSettingsTooltip => 'Einstellungen öffnen';

  @override
  String get settingsPageTitle => 'Einstellungen';

  @override
  String get themeSectionTitle => 'Erscheinungsbild';

  @override
  String get themeModeSystem => 'Systemstandard';

  @override
  String get themeModeLight => 'Hell';

  @override
  String get themeModeDark => 'Dunkel';

  @override
  String get languageSectionTitle => 'Sprache';

  @override
  String get languageSystemDefault => 'Gerätesprache verwenden';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get languageTurkish => 'Türkisch';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageFrench => 'Französisch';

  @override
  String get languageSpanish => 'Spanisch';

  @override
  String get chartPageTitle => 'Bitcoin-Preis (USD)';

  @override
  String get chartPageDescription =>
      'Schlusskurs der letzten 7 Tage (Quelle: CoinGecko)';

  @override
  String get chartPageError => 'Diagrammdaten konnten nicht geladen werden.';

  @override
  String get chartPageEmpty => 'Noch keine Diagrammdaten verfügbar.';

  @override
  String get chartZoomToggleLabel => 'Pinch-Zoom aktivieren';
}
