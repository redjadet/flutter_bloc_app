// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get autoLabel => 'Auto';

  @override
  String get pausedLabel => 'Paused';

  @override
  String nextAutoDecrementIn(int s) {
    return 'Next auto-decrement in: ${s}s';
  }

  @override
  String get autoDecrementPaused => 'Auto-decrement paused !!!';

  @override
  String get lastChangedLabel => 'Last changed:';

  @override
  String get appTitle => 'Flutter Demo';

  @override
  String get homeTitle => 'Flutter Demo Home Page';

  @override
  String get pushCountLabel => 'You have pushed the button this many times:';

  @override
  String get incrementTooltip => 'Increment';

  @override
  String get decrementTooltip => 'Decrement';

  @override
  String get loadErrorMessage => 'Failed to load saved counter';

  @override
  String get startAutoHint => 'Tap + to start auto-decrement';

  @override
  String get cannotGoBelowZero => 'Count cannot go below 0';

  @override
  String get openExampleTooltip => 'Open example page';

  @override
  String get examplePageTitle => 'Example Page';

  @override
  String get examplePageDescription =>
      'This page demonstrates navigation with GoRouter.';

  @override
  String get exampleBackButtonLabel => 'Back to counter';

  @override
  String get openChartsTooltip => 'Open charts';

  @override
  String get openSettingsTooltip => 'Open settings';

  @override
  String get settingsPageTitle => 'Settings';

  @override
  String get themeSectionTitle => 'Appearance';

  @override
  String get themeModeSystem => 'System default';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get languageSectionTitle => 'Language';

  @override
  String get languageSystemDefault => 'Use device language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageSpanish => 'Español';

  @override
  String get chartPageTitle => 'Bitcoin Price (USD)';

  @override
  String get chartPageDescription =>
      'Closing price over the past 7 days (powered by CoinGecko)';

  @override
  String get chartPageError => 'Unable to load chart data.';

  @override
  String get chartPageEmpty => 'No chart data available yet.';

  @override
  String get chartZoomToggleLabel => 'Enable pinch zoom';
}
