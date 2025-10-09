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
  String get exampleNativeInfoButton => 'Native Infos abrufen';

  @override
  String get exampleNativeInfoTitle => 'Plattforminformationen';

  @override
  String get exampleNativeInfoError =>
      'Native Plattforminformationen konnten nicht abgerufen werden.';

  @override
  String get exampleRunIsolatesButton => 'Isolat-Beispiele ausführen';

  @override
  String get exampleIsolateParallelPending =>
      'Parallele Aufgaben werden ausgeführt...';

  @override
  String exampleIsolateFibonacciLabel(int input, int value) {
    return 'Fibonacci($input) = $value';
  }

  @override
  String exampleIsolateParallelComplete(String values, int milliseconds) {
    return 'Parallel verdoppelte Werte: $values (abgeschlossen in $milliseconds ms)';
  }

  @override
  String get settingsBiometricPrompt =>
      'Authentifiziere dich, um die Einstellungen zu öffnen';

  @override
  String get settingsBiometricFailed =>
      'Identität konnte nicht bestätigt werden.';

  @override
  String get openChartsTooltip => 'Diagramme öffnen';

  @override
  String get openGraphqlTooltip => 'GraphQL-Demo anzeigen';

  @override
  String get openSettingsTooltip => 'Einstellungen öffnen';

  @override
  String get settingsPageTitle => 'Einstellungen';

  @override
  String get accountSectionTitle => 'Konto';

  @override
  String accountSignedInAs(String name) {
    return 'Angemeldet als $name';
  }

  @override
  String get accountSignedOutLabel => 'Nicht angemeldet.';

  @override
  String get accountSignInButton => 'Anmelden';

  @override
  String get accountManageButton => 'Konto verwalten';

  @override
  String get accountGuestLabel => 'Gastkonto wird verwendet';

  @override
  String get accountGuestDescription =>
      'Du bist anonym angemeldet. Erstelle ein Konto, um deine Daten zwischen Geräten zu synchronisieren.';

  @override
  String get accountUpgradeButton => 'Konto erstellen oder verknüpfen';

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
  String get appInfoSectionTitle => 'App-Informationen';

  @override
  String get appInfoVersionLabel => 'Version';

  @override
  String get appInfoBuildNumberLabel => 'Build-Nummer';

  @override
  String get appInfoLoadingLabel => 'App-Informationen werden geladen...';

  @override
  String get appInfoLoadErrorLabel =>
      'App-Informationen konnten nicht geladen werden.';

  @override
  String get appInfoRetryButtonLabel => 'Erneut versuchen';

  @override
  String get openChatTooltip => 'Mit KI chatten';

  @override
  String get chatPageTitle => 'KI-Chat';

  @override
  String get chatInputHint => 'Frag den Assistenten etwas...';

  @override
  String get chatSendButton => 'Nachricht senden';

  @override
  String get chatEmptyState => 'Beginne das Gespräch mit einer Nachricht.';

  @override
  String get chatModelLabel => 'Modell';

  @override
  String get chatModelGptOss20b => 'GPT-OSS-20B';

  @override
  String get chatModelGptOss120b => 'GPT-OSS-120B';

  @override
  String get chatHistoryShowTooltip => 'Verlauf anzeigen';

  @override
  String get chatHistoryHideTooltip => 'Verlauf ausblenden';

  @override
  String get chatHistoryPanelTitle => 'Konversationsverlauf';

  @override
  String get chatHistoryStartNew => 'Neue Unterhaltung starten';

  @override
  String get chatHistoryClearAll => 'Verlauf löschen';

  @override
  String get chatHistoryDeleteConversation => 'Unterhaltung löschen';

  @override
  String get chatHistoryClearAllWarning =>
      'Dadurch werden alle gespeicherten Unterhaltungen dauerhaft gelöscht.';

  @override
  String get profilePageTitle => 'Profil';

  @override
  String get anonymousSignInButton => 'Als Gast fortfahren';

  @override
  String get anonymousSignInDescription =>
      'Du kannst die App ohne Konto ausprobieren. Später kannst du in den Einstellungen upgraden.';

  @override
  String get anonymousSignInFailed =>
      'Gast-Sitzung konnte nicht gestartet werden. Bitte versuche es erneut.';

  @override
  String get anonymousUpgradeHint =>
      'Du nutzt derzeit eine Gast-Sitzung. Melde dich an, um deine Daten dauerhaft zu sichern.';

  @override
  String get authErrorInvalidEmail =>
      'Die E-Mail-Adresse scheint ungültig zu sein.';

  @override
  String get authErrorUserDisabled =>
      'Dieses Konto wurde deaktiviert. Bitte wende dich an den Support.';

  @override
  String get authErrorUserNotFound =>
      'Wir konnten kein Konto mit diesen Angaben finden.';

  @override
  String get authErrorWrongPassword =>
      'Das Passwort ist falsch. Bitte überprüfe es und versuche es erneut.';

  @override
  String get authErrorEmailInUse =>
      'Diese E-Mail ist bereits mit einem anderen Konto verknüpft.';

  @override
  String get authErrorOperationNotAllowed =>
      'Diese Anmeldemethode ist derzeit deaktiviert. Bitte wähle eine andere Option.';

  @override
  String get authErrorWeakPassword => 'Bitte wähle ein stärkeres Passwort.';

  @override
  String get authErrorRequiresRecentLogin =>
      'Bitte melde dich erneut an, um diesen Vorgang abzuschließen.';

  @override
  String get authErrorCredentialInUse =>
      'Diese Anmeldedaten sind bereits einem anderen Konto zugeordnet.';

  @override
  String get authErrorInvalidCredential =>
      'Die angegebenen Anmeldedaten sind ungültig oder abgelaufen.';

  @override
  String get authErrorGeneric =>
      'Die Anfrage konnte nicht abgeschlossen werden. Bitte versuche es erneut.';

  @override
  String chatHistoryDeleteConversationWarning(String title) {
    return '\"$title\" löschen?';
  }

  @override
  String get cancelButtonLabel => 'Abbrechen';

  @override
  String get deleteButtonLabel => 'Löschen';

  @override
  String get chatHistoryEmpty => 'Noch keine gespeicherten Unterhaltungen.';

  @override
  String chatHistoryConversationTitle(int index) {
    return 'Unterhaltung $index';
  }

  @override
  String chatHistoryUpdatedAt(String timestamp) {
    return 'Aktualisiert $timestamp';
  }

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

  @override
  String get graphqlSampleTitle => 'GraphQL-Länder';

  @override
  String get graphqlSampleFilterLabel => 'Nach Kontinent filtern';

  @override
  String get graphqlSampleAllContinents => 'Alle Kontinente';

  @override
  String get graphqlSampleErrorTitle => 'Etwas ist schiefgelaufen';

  @override
  String get graphqlSampleGenericError =>
      'Länder konnten derzeit nicht geladen werden.';

  @override
  String get graphqlSampleRetryButton => 'Erneut versuchen';

  @override
  String get graphqlSampleEmpty => 'Keine Länder entsprechen der Auswahl.';

  @override
  String get graphqlSampleCapitalLabel => 'Hauptstadt';

  @override
  String get graphqlSampleCurrencyLabel => 'Währung';

  @override
  String get graphqlSampleNetworkError =>
      'Netzwerkfehler. Bitte Verbindung prüfen und erneut versuchen.';

  @override
  String get graphqlSampleInvalidRequestError =>
      'Die Anfrage wurde abgelehnt. Bitte wähle einen anderen Filter.';

  @override
  String get graphqlSampleServerError =>
      'Der Dienst ist derzeit nicht verfügbar. Versuche es später erneut.';

  @override
  String get graphqlSampleDataError =>
      'Unerwartete Antwort empfangen. Bitte versuche es erneut.';

  @override
  String get exampleWebsocketButton => 'WebSocket-Demo öffnen';

  @override
  String exampleNativeBatteryLabel(int percent) {
    return 'Batteriestand: $percent%';
  }

  @override
  String get websocketDemoTitle => 'WebSocket-Demo';

  @override
  String get websocketDemoWebUnsupported =>
      'Die WebSocket-Demo ist in Web-Builds noch nicht verfügbar.';

  @override
  String get websocketReconnectTooltip => 'Neu verbinden';

  @override
  String get websocketEmptyState =>
      'Noch keine Nachrichten. Senden Sie eine Nachricht, um zu beginnen.';

  @override
  String get websocketMessageHint => 'Nachricht eingeben';

  @override
  String get websocketSendButton => 'Senden';

  @override
  String websocketStatusConnected(String endpoint) {
    return 'Verbunden mit $endpoint';
  }

  @override
  String websocketStatusConnecting(String endpoint) {
    return 'Verbinde mit $endpoint...';
  }

  @override
  String websocketErrorLabel(String error) {
    return 'WebSocket-Fehler: $error';
  }
}
